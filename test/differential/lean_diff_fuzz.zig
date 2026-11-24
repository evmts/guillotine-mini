//! Differential fuzz suite: guillotine-mini vs the Lean 4 reference spec executable.
//!
//! The Lean oracle (`spec/lean/.lake/build/bin/evm-lean-spec`) speaks the TSV protocol in
//! `LEAN_PROTOCOL.md`: one request line on stdin, one response line on stdout. This harness
//! computes the response guillotine-mini would give for every request by driving the real
//! `Evm`/`Frame` code paths, sends the same request to Lean, and compares the two lines byte
//! for byte. Any mismatch prints the vector and makes the process exit non-zero.
//!
//! Suites (default vector counts at scale 1, all deterministic for a given seed):
//!   word        WORD        >= 2,500  all 26 word opcodes incl. CLZ and EXP gas per fork
//!   memgas      MEMGAS      >= 1,500  memoryExpansionCost 0 .. 64 MiB .. u64 overflow
//!   sstore      SSTORE      >= 2,000  (original, current, new, cold, gas) x 7 forks
//!   jumpdest    JUMPDEST    >= 1,500  together with PUSH: 0x5b in immediates, truncated PUSHn
//!   precompile  PRECOMPILE  >=   500  precompile table + EIP-7825 tx gas cap per fork
//!   exec        EXEC        >= 2,500  random multi-opcode programs, Berlin..Osaka
//!
//! Configuration (environment variables override command-line flags):
//!   LEAN_SPEC_BIN      path to the Lean oracle (default: first positional arg, then
//!                      spec/lean/.lake/build/bin/evm-lean-spec)
//!   LEAN_DIFF_SEED     u64 PRNG seed (decimal or 0x-hex; default 0x6c65616e2d646966)
//!   LEAN_DIFF_SCALE    multiplier for the PRNG-driven vector counts (default 1)
//!   LEAN_DIFF_SUITES   comma list of suites to run (default: all)
//!   LEAN_DIFF_MAX_REPORT  mismatches printed in full before summarising (default 25)
//!   LEAN_DIFF_REQUIRE  1 = a missing oracle binary is a failure (default: skip, exit 0)
//!   LEAN_DIFF_ZIG_ONLY 1 = run only the Zig side (smoke test the harness without Lean)
//!   LEAN_DIFF_HALT_EQUIV 1 = EXEC exceptional halts of different reasons compare equal
//!                      (default strict; such mismatches are tagged "halt-reason only")
//!   LEAN_DIFF_REPLAY   file of protocol request lines to re-check instead of generating
//!                      (paste a printed `request :` line to reproduce one mismatch)
//! Flags: --seed=N --scale=N --suites=a,b --max-report=N --require --zig-only --halt-equiv
//!        --replay=FILE [ORACLE_PATH]
const std = @import("std");
const gm = @import("guillotine_mini");
const primitives = @import("voltaire");

const Allocator = std.mem.Allocator;
const Hardfork = gm.Hardfork;
const Address = primitives.Address;

/// Unlimited loop quota: every generated program is bounded by its gas instead, and
/// Debug-mode's default 1M-step quota would otherwise report ExecutionTimeout where
/// the spec reports OOG.
pub const evm_config: gm.EvmConfig = .{ .loop_quota = null };
const EvmT = gm.Evm(evm_config);
const FrameT = gm.Frame(evm_config);

/// Request currently being evaluated, so a guillotine-mini panic (e.g. a safety-checked
/// integer overflow) still reports the exact reproducing vector before aborting.
var current_request: ?*const Buf = null;

pub const panic = std.debug.FullPanic(panicWithVector);

fn panicWithVector(msg: []const u8, first_trace_addr: ?usize) noreturn {
    if (current_request) |req| {
        std.debug.print("\nlean-diff: PANIC inside guillotine-mini while evaluating vector:\n  request : {s}\n", .{req.items});
    }
    std.debug.defaultPanic(msg, first_trace_addr);
}

pub const DEFAULT_ORACLE_PATH = "spec/lean/.lake/build/bin/evm-lean-spec";
pub const DEFAULT_SEED: u64 = 0x6c65616e2d646966; // "lean-dif"

const SELF: Address = Address.fromU256(0xc0de_0000_0000_0000_0000_0000_0000_0000_0000_c0de);
const CALLER: Address = Address.fromU256(0xca11_0000_0000_0000_0000_0000_0000_0000_0000_ca11);

const U256_MAX: u256 = std.math.maxInt(u256);
const U64_MAX: u64 = std.math.maxInt(u64);

// ---------------------------------------------------------------------------
// Forks
// ---------------------------------------------------------------------------

/// Every fork name the Lean protocol accepts, in activation order.
pub const PROTOCOL_FORKS = [_]Hardfork{
    .FRONTIER,       .HOMESTEAD,  .TANGERINE_WHISTLE, .SPURIOUS_DRAGON, .BYZANTIUM,
    .CONSTANTINOPLE, .PETERSBURG, .ISTANBUL,          .BERLIN,          .LONDON,
    .MERGE,          .SHANGHAI,   .CANCUN,            .PRAGUE,          .OSAKA,
};
/// WORD grid forks: EXP byte cost flips at Spurious Dragon, shifts at Constantinople, CLZ at Osaka.
const WORD_FORKS = [_]Hardfork{ .FRONTIER, .TANGERINE_WHISTLE, .SPURIOUS_DRAGON, .BYZANTIUM, .CONSTANTINOPLE, .PRAGUE, .OSAKA };
const SSTORE_FORKS = [_]Hardfork{ .FRONTIER, .ISTANBUL, .BERLIN, .LONDON, .CANCUN, .PRAGUE, .OSAKA };
const EXEC_FORKS = [_]Hardfork{ .BERLIN, .LONDON, .SHANGHAI, .CANCUN, .PRAGUE, .OSAKA };

// ---------------------------------------------------------------------------
// Suites and options
// ---------------------------------------------------------------------------

pub const Suite = enum(u3) {
    word,
    memgas,
    sstore,
    jumpdest,
    precompile,
    exec,

    pub fn minVectors(s: Suite) u64 {
        return switch (s) {
            .word => 2500,
            .memgas => 1500,
            .sstore => 2000,
            .jumpdest => 1500,
            .precompile => 500,
            .exec => 2500,
        };
    }
};
const SUITE_COUNT = @typeInfo(Suite).@"enum".fields.len;
const ALL_SUITES: u8 = (1 << SUITE_COUNT) - 1;

pub const Options = struct {
    oracle_path: []const u8 = DEFAULT_ORACLE_PATH,
    seed: u64 = DEFAULT_SEED,
    scale: u32 = 1,
    suites: u8 = ALL_SUITES,
    max_report: u32 = 25,
    require_oracle: bool = false,
    zig_only: bool = false,
    /// Test-only cap on vectors per suite (0 = no cap).
    max_per_suite: u64 = 0,
    /// Treat EXEC mismatches where both sides halt exceptionally (OOG vs STACK_UNDERFLOW,
    /// ...) as equal. Both consume all gas, so they are consensus-equivalent.
    halt_equiv: bool = false,
    /// Replay request lines from this file instead of generating suites.
    replay_path: ?[]const u8 = null,
};

fn parseU64(text: []const u8) !u64 {
    const t = std.mem.trim(u8, text, " \t");
    if (std.mem.startsWith(u8, t, "0x") or std.mem.startsWith(u8, t, "0X")) return std.fmt.parseInt(u64, t[2..], 16);
    return std.fmt.parseInt(u64, t, 10);
}

fn parseSuites(text: []const u8) !u8 {
    var mask: u8 = 0;
    var it = std.mem.tokenizeAny(u8, text, ", ");
    while (it.next()) |name| {
        if (std.mem.eql(u8, name, "all")) return ALL_SUITES;
        if (std.mem.eql(u8, name, "push")) {
            mask |= 1 << @intFromEnum(Suite.jumpdest);
            continue;
        }
        const s = std.meta.stringToEnum(Suite, name) orelse {
            std.debug.print("lean-diff: unknown suite '{s}' (word,memgas,sstore,jumpdest,precompile,exec)\n", .{name});
            return error.InvalidSuite;
        };
        mask |= @as(u8, 1) << @intFromEnum(s);
    }
    return mask;
}

fn isTruthy(v: []const u8) bool {
    return v.len > 0 and !std.mem.eql(u8, v, "0") and !std.mem.eql(u8, v, "false");
}

/// Parse flags, then apply environment overrides. Returned strings live in `arena`.
pub fn loadOptions(arena: Allocator) !Options {
    var opts: Options = .{};
    const args = try std.process.argsAlloc(arena);
    for (args[1..]) |arg| {
        if (std.mem.startsWith(u8, arg, "--seed=")) {
            opts.seed = try parseU64(arg["--seed=".len..]);
        } else if (std.mem.startsWith(u8, arg, "--scale=")) {
            opts.scale = @intCast(try parseU64(arg["--scale=".len..]));
        } else if (std.mem.startsWith(u8, arg, "--suites=")) {
            opts.suites = try parseSuites(arg["--suites=".len..]);
        } else if (std.mem.startsWith(u8, arg, "--max-report=")) {
            opts.max_report = @intCast(try parseU64(arg["--max-report=".len..]));
        } else if (std.mem.startsWith(u8, arg, "--replay=")) {
            opts.replay_path = arg["--replay=".len..];
        } else if (std.mem.eql(u8, arg, "--halt-equiv")) {
            opts.halt_equiv = true;
        } else if (std.mem.eql(u8, arg, "--require")) {
            opts.require_oracle = true;
        } else if (std.mem.eql(u8, arg, "--zig-only")) {
            opts.zig_only = true;
        } else if (std.mem.startsWith(u8, arg, "--")) {
            std.debug.print("lean-diff: unknown flag {s}\n", .{arg});
            return error.InvalidArgument;
        } else {
            opts.oracle_path = arg;
        }
    }
    if (envOwned(arena, "LEAN_SPEC_BIN")) |v| opts.oracle_path = v;
    if (envOwned(arena, "LEAN_DIFF_SEED")) |v| opts.seed = try parseU64(v);
    if (envOwned(arena, "LEAN_DIFF_SCALE")) |v| opts.scale = @intCast(try parseU64(v));
    if (envOwned(arena, "LEAN_DIFF_SUITES")) |v| opts.suites = try parseSuites(v);
    if (envOwned(arena, "LEAN_DIFF_MAX_REPORT")) |v| opts.max_report = @intCast(try parseU64(v));
    if (envOwned(arena, "LEAN_DIFF_REQUIRE")) |v| opts.require_oracle = isTruthy(v);
    if (envOwned(arena, "LEAN_DIFF_ZIG_ONLY")) |v| opts.zig_only = isTruthy(v);
    if (envOwned(arena, "LEAN_DIFF_REPLAY")) |v| opts.replay_path = v;
    if (envOwned(arena, "LEAN_DIFF_HALT_EQUIV")) |v| opts.halt_equiv = isTruthy(v);
    if (opts.scale == 0) opts.scale = 1;
    return opts;
}

fn envOwned(arena: Allocator, key: []const u8) ?[]const u8 {
    const v = std.process.getEnvVarOwned(arena, key) catch return null;
    if (v.len == 0) return null;
    return v;
}

// ---------------------------------------------------------------------------
// Lean oracle process
// ---------------------------------------------------------------------------

pub const Oracle = struct {
    child: std.process.Child,
    argv: [1][]const u8,
    read_buf: []u8,
    reader: std.fs.File.Reader,
    gpa: Allocator,

    /// Spawn the oracle with piped stdin/stdout; stderr is inherited for diagnostics.
    pub fn start(gpa: Allocator, path: []const u8) !*Oracle {
        const self = try gpa.create(Oracle);
        errdefer gpa.destroy(self);
        self.gpa = gpa;
        self.read_buf = try gpa.alloc(u8, 8 << 20);
        errdefer gpa.free(self.read_buf);
        self.argv = .{path};
        self.child = std.process.Child.init(&self.argv, gpa);
        self.child.stdin_behavior = .Pipe;
        self.child.stdout_behavior = .Pipe;
        self.child.stderr_behavior = .Inherit;
        try self.child.spawn();
        self.reader = self.child.stdout.?.readerStreaming(self.read_buf);
        return self;
    }

    /// Send one request line (without trailing newline) and return the response line.
    /// The returned slice is valid until the next `query`.
    pub fn query(self: *Oracle, line: []const u8) ![]const u8 {
        const stdin = self.child.stdin orelse return error.OracleClosed;
        try stdin.writeAll(line);
        try stdin.writeAll("\n");
        const resp = (try self.reader.interface.takeDelimiter('\n')) orelse return error.OracleClosed;
        return std.mem.trimRight(u8, resp, "\r");
    }

    /// Send QUIT, close stdin, reap the child, and free everything.
    pub fn stop(self: *Oracle) !std.process.Child.Term {
        const gpa = self.gpa;
        defer {
            gpa.free(self.read_buf);
            gpa.destroy(self);
        }
        if (self.child.stdin) |stdin| {
            stdin.writeAll("QUIT\n") catch |err| {
                std.debug.print("lean-diff: QUIT write failed: {s}\n", .{@errorName(err)});
            };
            stdin.close();
            self.child.stdin = null;
        }
        return self.child.wait();
    }
};

// ---------------------------------------------------------------------------
// Encoding helpers (protocol: lowercase hex, no 0x, minimal digits, "-" for empty bytes)
// ---------------------------------------------------------------------------

const Buf = std.ArrayList(u8);

pub fn appendHexBytes(list: *Buf, gpa: Allocator, bytes: []const u8) !void {
    if (bytes.len == 0) return list.append(gpa, '-');
    const digits = "0123456789abcdef";
    try list.ensureUnusedCapacity(gpa, bytes.len * 2);
    for (bytes) |b| {
        list.appendAssumeCapacity(digits[b >> 4]);
        list.appendAssumeCapacity(digits[b & 0x0f]);
    }
}

/// Address as 40 lowercase hex digits (still a valid 1..64-digit protocol integer).
fn appendAddress(list: *Buf, gpa: Allocator, addr: Address) !void {
    try appendHexBytes(list, gpa, &addr.bytes);
}

fn forkName(fork: Hardfork) []const u8 {
    return @tagName(fork);
}

// ---------------------------------------------------------------------------
// Harness: compares Zig and Lean response lines, records statistics
// ---------------------------------------------------------------------------

const SuiteStats = struct {
    vectors: u64 = 0,
    mismatches: u64 = 0,
    /// EXEC mismatches where both sides halted exceptionally with different reasons.
    halt_reason_only: u64 = 0,
};

/// EXEC response status field, or null for other commands.
fn execStatus(resp: []const u8) ?[]const u8 {
    var it = std.mem.splitScalar(u8, resp, '\t');
    if (!std.mem.eql(u8, it.next() orelse return null, "OK")) return null;
    return it.next();
}

fn isExceptionalHalt(status: []const u8) bool {
    for ([_][]const u8{ "OOG", "STACK_UNDERFLOW", "STACK_OVERFLOW", "INVALID_JUMP", "INVALID_OPCODE" }) |s| {
        if (std.mem.eql(u8, status, s)) return true;
    }
    return false;
}

pub const Harness = struct {
    gpa: Allocator,
    opts: Options,
    oracle: ?*Oracle,
    req: Buf = .empty,
    zig: Buf = .empty,
    /// Zig-side diagnostics for the current vector (e.g. where an EXEC halted).
    note: Buf = .empty,
    stats: [SUITE_COUNT]SuiteStats = [_]SuiteStats{.{}} ** SUITE_COUNT,
    printed: u32 = 0,
    /// Voltaire 0x12..0x13 Prague+ compatibility observations: [zig says precompile, zig says not].
    bls_compat: [2]u64 = .{ 0, 0 },
    /// Zig-internal PUSH reader vs executed PUSHn cross-checks.
    push_exec_checks: u64 = 0,

    pub fn init(gpa: Allocator, opts: Options, oracle: ?*Oracle) Harness {
        return .{ .gpa = gpa, .opts = opts, .oracle = oracle };
    }

    pub fn deinit(self: *Harness) void {
        if (current_request == &self.req) current_request = null;
        self.req.deinit(self.gpa);
        self.zig.deinit(self.gpa);
        self.note.deinit(self.gpa);
    }

    fn begin(self: *Harness) void {
        current_request = &self.req;
        self.req.clearRetainingCapacity();
        self.zig.clearRetainingCapacity();
        self.note.clearRetainingCapacity();
    }

    fn atCap(self: *const Harness, suite: Suite) bool {
        return self.opts.max_per_suite != 0 and self.stats[@intFromEnum(suite)].vectors >= self.opts.max_per_suite;
    }

    /// Query Lean with `self.req` (or skip when running Zig-only).
    fn lean(self: *Harness) !?[]const u8 {
        const oracle = self.oracle orelse return null;
        return oracle.query(self.req.items) catch |err| {
            std.debug.print("lean-diff: oracle failed on request:\n  {s}\n  error: {s}\n", .{ self.req.items, @errorName(err) });
            return err;
        };
    }

    /// Strict comparison of `self.zig` against Lean's response to `self.req`.
    fn compare(self: *Harness, suite: Suite, fork: ?Hardfork, note: []const u8) !void {
        const st = &self.stats[@intFromEnum(suite)];
        st.vectors += 1;
        const lean_resp = (try self.lean()) orelse return;
        if (std.mem.eql(u8, lean_resp, self.zig.items)) return;
        if (suite == .exec) if (execStatus(lean_resp)) |ls| if (execStatus(self.zig.items)) |zs| {
            if (isExceptionalHalt(ls) and isExceptionalHalt(zs)) {
                st.halt_reason_only += 1;
                if (self.opts.halt_equiv) return;
                try self.note.appendSlice(self.gpa, "; halt-reason only: both sides halt exceptionally (all gas consumed); LEAN_DIFF_HALT_EQUIV=1 accepts this");
            }
        };
        self.mismatch(suite, fork, lean_resp, if (note.len > 0) note else self.note.items);
    }

    fn mismatch(self: *Harness, suite: Suite, fork: ?Hardfork, lean_resp: []const u8, note: []const u8) void {
        const st = &self.stats[@intFromEnum(suite)];
        st.mismatches += 1;
        if (self.printed >= self.opts.max_report) return;
        self.printed += 1;
        std.debug.print(
            \\
            \\MISMATCH suite={s} vector=#{d} fork={s}
            \\  request : {s}
            \\  zig     : {s}
            \\  lean    : {s}
            \\
        , .{ @tagName(suite), st.vectors - 1, if (fork) |f| forkName(f) else "-", self.req.items, self.zig.items, lean_resp });
        if (note.len > 0) std.debug.print("  note    : {s}\n", .{note});
    }

    pub fn totalVectors(self: *const Harness) u64 {
        var n: u64 = 0;
        for (self.stats) |s| n += s.vectors;
        return n;
    }

    pub fn totalMismatches(self: *const Harness) u64 {
        var n: u64 = 0;
        for (self.stats) |s| n += s.mismatches;
        return n;
    }
};

fn suitePrng(seed: u64, suite: Suite) std.Random.DefaultPrng {
    return std.Random.DefaultPrng.init(seed ^ (0x9E3779B97F4A7C15 *% (@as(u64, @intFromEnum(suite)) + 1)));
}

// ---------------------------------------------------------------------------
// Interesting values
// ---------------------------------------------------------------------------

const ONE: u256 = 1;
const EDGES = [_]u256{
    0,               1,                2,                     3,
    7,               8,                30,                    31,
    32,              33,               0x7f,                  0x80,
    0xff,            0x100,            256,                   257,
    0x7fff_ffff,     0xffff_ffff,      (ONE << 63) - 1,       ONE << 63,
    (ONE << 64) - 1, ONE << 64,        ONE << 127,            (ONE << 128) - 1,
    ONE << 128,      (ONE << 255) - 1, ONE << 255,            (ONE << 255) + 1,
    U256_MAX - 1,    U256_MAX,         0x8000_0000_0000_0080, 0xdead_beef_cafe_babe_0123_4567_89ab_cdef,
};

fn interesting(r: std.Random) u256 {
    return switch (r.uintLessThan(u8, 6)) {
        0, 1 => EDGES[r.uintLessThan(usize, EDGES.len)],
        2 => r.int(u256),
        3 => r.int(u256) >> r.int(u8),
        4 => r.uintLessThan(u64, 300),
        else => EDGES[r.uintLessThan(usize, EDGES.len)] +% (r.uintLessThan(u256, 5)) -% 2,
    };
}

// ---------------------------------------------------------------------------
// Suite 1: WORD
// ---------------------------------------------------------------------------

const WordOp = struct { op: u8, arity: u2 };
pub const WORD_OPS = [_]WordOp{
    .{ .op = 0x01, .arity = 2 }, .{ .op = 0x02, .arity = 2 }, .{ .op = 0x03, .arity = 2 },
    .{ .op = 0x04, .arity = 2 }, .{ .op = 0x05, .arity = 2 }, .{ .op = 0x06, .arity = 2 },
    .{ .op = 0x07, .arity = 2 }, .{ .op = 0x08, .arity = 3 }, .{ .op = 0x09, .arity = 3 },
    .{ .op = 0x0a, .arity = 2 }, .{ .op = 0x0b, .arity = 2 }, .{ .op = 0x10, .arity = 2 },
    .{ .op = 0x11, .arity = 2 }, .{ .op = 0x12, .arity = 2 }, .{ .op = 0x13, .arity = 2 },
    .{ .op = 0x14, .arity = 2 }, .{ .op = 0x15, .arity = 1 }, .{ .op = 0x16, .arity = 2 },
    .{ .op = 0x17, .arity = 2 }, .{ .op = 0x18, .arity = 2 }, .{ .op = 0x19, .arity = 1 },
    .{ .op = 0x1a, .arity = 2 }, .{ .op = 0x1b, .arity = 2 }, .{ .op = 0x1c, .arity = 2 },
    .{ .op = 0x1d, .arity = 2 }, .{ .op = 0x1e, .arity = 1 },
};

const WORD_GAS: i64 = 1_000_000;

/// Execute one word opcode through the real `Frame.executeOpcode` with args on the stack.
fn zigWord(h: *Harness, fork: Hardfork, op: u8, args: [3]u256) !void {
    var evm: EvmT = undefined;
    try evm.init(h.gpa, null, fork, null, CALLER, 0, null);
    defer evm.deinit();
    const code = [_]u8{op};
    var frame = try FrameT.init(h.gpa, &code, WORD_GAS, CALLER, SELF, 0, &.{}, @ptrCast(&evm), fork, false);
    defer frame.deinit();
    try frame.pushStack(args[2]);
    try frame.pushStack(args[1]);
    try frame.pushStack(args[0]);
    frame.executeOpcode(op) catch |err| {
        try h.zig.print(h.gpa, "ERR\t{s}", .{@errorName(err)});
        return;
    };
    const result = try frame.popStack();
    try h.zig.print(h.gpa, "OK\t{x}\t{d}", .{ result, WORD_GAS - frame.gas_remaining });
}

fn wordVector(h: *Harness, fork: Hardfork, w: WordOp, raw: [3]u256) !void {
    var args = raw;
    for (args[w.arity..]) |*a| a.* = 0; // protocol: unused args are 0
    h.begin();
    try h.req.print(h.gpa, "WORD\t{s}\t{x:0>2}\t{x}\t{x}\t{x}", .{ forkName(fork), w.op, args[0], args[1], args[2] });
    try zigWord(h, fork, w.op, args);
    try h.compare(.word, fork, "");
}

pub fn runWord(h: *Harness) !void {
    var prng = suitePrng(h.opts.seed, .word);
    const r = prng.random();
    // Deterministic edge grid: 7 forks x 26 ops x 16 combos = 2,912.
    for (WORD_FORKS, 0..) |fork, fi| {
        for (WORD_OPS) |w| {
            for (0..16) |j| {
                if (h.atCap(.word)) return;
                const idx = j + 16 * fi + w.op;
                try wordVector(h, fork, w, .{
                    EDGES[idx % EDGES.len],
                    EDGES[(idx * 7 + 3) % EDGES.len],
                    EDGES[(idx * 13 + 5) % EDGES.len],
                });
            }
        }
    }
    // PRNG fuzz across every protocol fork.
    for (0..@as(u64, 640) * h.opts.scale) |_| {
        if (h.atCap(.word)) return;
        const fork = PROTOCOL_FORKS[r.uintLessThan(usize, PROTOCOL_FORKS.len)];
        const w = WORD_OPS[r.uintLessThan(usize, WORD_OPS.len)];
        try wordVector(h, fork, w, .{ interesting(r), interesting(r), interesting(r) });
    }
}

// ---------------------------------------------------------------------------
// Suite 2: MEMGAS
// ---------------------------------------------------------------------------

const MIB: u64 = 1 << 20;
const MEM_CURRENTS = [_]u32{
    0,       1,               31,       32,              33,       64,       96,       1024,    4096,                      65536,
    1 << 20, (16 << 20) - 32, 16 << 20, (16 << 20) + 32, 17 << 20, 32 << 20, 64 << 20, 1 << 31, std.math.maxInt(u32) - 31, std.math.maxInt(u32),
};
const MEM_ENDS = [_]u64{
    0,        1,       31,            32,           33,             63,             64,           65,
    1024,     4096,    MIB,           16 * MIB - 1, 16 * MIB,       16 * MIB + 1,   17 * MIB,     32 * MIB,
    64 * MIB, 1 << 32, (1 << 32) + 1, 1 << 36,      (1 << 37) - 32, (1 << 37) - 31, 1 << 37,      (1 << 37) + 1,
    1 << 40,  1 << 48, 1 << 58,       1 << 63,      U64_MAX - 32,   U64_MAX - 31,   U64_MAX - 30, U64_MAX - 1,
    U64_MAX,
};

fn memVector(h: *Harness, frame: *FrameT, current: u32, end: u64) !void {
    h.begin();
    try h.req.print(h.gpa, "MEMGAS\t{d}\t{d}", .{ current, end });
    frame.memory_size = current;
    try h.zig.print(h.gpa, "OK\t{d}", .{frame.memoryExpansionCost(end)});
    try h.compare(.memgas, null, "");
}

fn randomEnd(r: std.Random, current: u32) u64 {
    return switch (r.uintLessThan(u8, 5)) {
        0 => @as(u64, current) + r.uintLessThan(u64, 4096),
        1 => @as(u64, current) +| (r.int(u64) >> r.int(u6)),
        2 => r.int(u64) >> r.int(u6),
        3 => (r.uintLessThan(u64, 1 << 33)) * 32 +% r.uintLessThan(u64, 32),
        else => MEM_ENDS[r.uintLessThan(usize, MEM_ENDS.len)] +% r.uintLessThan(u64, 65) -% 32,
    };
}

pub fn runMemGas(h: *Harness) !void {
    var prng = suitePrng(h.opts.seed, .memgas);
    const r = prng.random();
    var evm: EvmT = undefined;
    try evm.init(h.gpa, null, .OSAKA, null, CALLER, 0, null);
    defer evm.deinit();
    var frame = try FrameT.init(h.gpa, &.{}, 0, CALLER, SELF, 0, &.{}, @ptrCast(&evm), .OSAKA, false);
    defer frame.deinit();
    // Grid: 20 x 33 = 660 vectors.
    for (MEM_CURRENTS) |cur| for (MEM_ENDS) |end| {
        if (h.atCap(.memgas)) return;
        try memVector(h, &frame, cur, end);
    };
    for (0..@as(u64, 1000) * h.opts.scale) |_| {
        if (h.atCap(.memgas)) return;
        const cur: u32 = switch (r.uintLessThan(u8, 4)) {
            0 => MEM_CURRENTS[r.uintLessThan(usize, MEM_CURRENTS.len)],
            1 => r.uintLessThan(u32, 1 << 16) * 32,
            2 => r.int(u32) >> r.int(u5),
            else => r.int(u32),
        };
        try memVector(h, &frame, cur, randomEnd(r, cur));
    }
}

// ---------------------------------------------------------------------------
// Suite 3: SSTORE
// ---------------------------------------------------------------------------

const SSTORE_GAS = [_]u64{ 0, 2300, 2301, 2899, 2900, 4999, 5000, 19999, 20000, 22099, 22100, 1_000_000 };
const SSTORE_SLOT: u256 = 0x5107;
/// Refund counter seed so a negative refund delta is observable (the counter is u64).
const REFUND_SEED: u64 = 1 << 40;

fn zigSstore(h: *Harness, fork: Hardfork, original: u256, current: u256, new: u256, cold: bool, gas: u64) !void {
    var evm: EvmT = undefined;
    try evm.init(h.gpa, null, fork, null, CALLER, 0, null);
    defer evm.deinit();
    const key = gm.StorageKey{ .address = SELF.bytes, .slot = SSTORE_SLOT };
    try evm.storage.original_storage.put(key, original);
    if (current != 0) try evm.storage.storage.put(key, current);
    if (!cold and fork.isAtLeast(.BERLIN)) _ = try evm.accessStorageSlot(SELF, SSTORE_SLOT);
    evm.gas_refund = REFUND_SEED;
    const code = [_]u8{0x55};
    var frame = try FrameT.init(h.gpa, &code, @intCast(gas), CALLER, SELF, 0, &.{}, @ptrCast(&evm), fork, false);
    defer frame.deinit();
    try frame.pushStack(new);
    try frame.pushStack(SSTORE_SLOT);
    frame.executeOpcode(0x55) catch |err| {
        try h.zig.print(h.gpa, "ERR\t{s}", .{@errorName(err)});
        return;
    };
    const used: u64 = gas - @as(u64, @intCast(frame.gas_remaining));
    const delta: i128 = @as(i128, evm.gas_refund) - @as(i128, REFUND_SEED);
    try h.zig.print(h.gpa, "OK\t{d}\t{d}", .{ used, delta });
}

fn sstoreVector(h: *Harness, fork: Hardfork, o: u256, c: u256, n: u256, cold_in: bool, gas: u64) !void {
    const cold = cold_in and fork.isAtLeast(.BERLIN); // protocol: 0 pre-Berlin
    h.begin();
    try h.req.print(h.gpa, "SSTORE\t{s}\t{x}\t{x}\t{x}\t{d}\t{d}", .{ forkName(fork), o, c, n, @intFromBool(cold), gas });
    try zigSstore(h, fork, o, c, n, cold, gas);
    try h.compare(.sstore, fork, "");
}

pub fn runSstore(h: *Harness) !void {
    var prng = suitePrng(h.opts.seed, .sstore);
    const r = prng.random();
    // Exhaustive over value equality classes {0,1,2}^3 x 12 gas x (cold, warm) per fork.
    for (SSTORE_FORKS) |fork| {
        const colds: []const bool = if (fork.isAtLeast(.BERLIN)) &.{ true, false } else &.{false};
        for (colds) |cold| for (0..27) |v| for (SSTORE_GAS) |gas| {
            if (h.atCap(.sstore)) return;
            try sstoreVector(h, fork, v / 9, (v / 3) % 3, v % 3, cold, gas);
        };
    }
    for (0..@as(u64, 500) * h.opts.scale) |_| {
        if (h.atCap(.sstore)) return;
        const fork = SSTORE_FORKS[r.uintLessThan(usize, SSTORE_FORKS.len)];
        var vals: [3]u256 = undefined;
        const big = interesting(r) | 3;
        for (&vals) |*v| v.* = switch (r.uintLessThan(u8, 5)) {
            0 => 0,
            1 => 1,
            2 => big,
            3 => interesting(r),
            else => 2,
        };
        const gas: u64 = switch (r.uintLessThan(u8, 3)) {
            0 => SSTORE_GAS[r.uintLessThan(usize, SSTORE_GAS.len)] +% r.uintLessThan(u64, 5) -% 2,
            1 => r.uintLessThan(u64, 30_000),
            else => r.uintLessThan(u64, 1 << 40),
        };
        try sstoreVector(h, fork, vals[0], vals[1], vals[2], r.boolean(), @min(gas, 1 << 40));
    }
}

// ---------------------------------------------------------------------------
// Suite 4: JUMPDEST + PUSH
// ---------------------------------------------------------------------------

/// Random code with 0x5b hidden in PUSH immediates and (often) a truncated trailing PUSHn.
fn genJumpdestCode(r: std.Random, gpa: Allocator, code: *Buf) !void {
    code.clearRetainingCapacity();
    const target = r.uintLessThan(usize, 96);
    while (code.items.len < target) {
        switch (r.uintLessThan(u8, 10)) {
            0, 1, 2 => try code.append(gpa, 0x5b),
            3, 4, 5 => {
                const n = if (r.boolean()) r.intRangeAtMost(u8, 1, 4) else r.intRangeAtMost(u8, 1, 32);
                try code.append(gpa, 0x5f + n);
                for (0..n) |_| try code.append(gpa, if (r.boolean()) 0x5b else r.int(u8));
            },
            6 => try code.append(gpa, 0x5f),
            else => try code.append(gpa, r.int(u8)),
        }
    }
    if (r.uintLessThan(u8, 3) != 0) {
        const n = r.intRangeAtMost(u8, 1, 32);
        try code.append(gpa, 0x5f + n);
        const have = r.uintLessThan(u8, n); // strictly fewer than n bytes: truncated
        for (0..have) |_| try code.append(gpa, if (r.boolean()) 0x5b else r.int(u8));
    }
}

fn zigJumpdests(h: *Harness, code: []const u8) !void {
    var evm: EvmT = undefined;
    try evm.init(h.gpa, null, .OSAKA, null, CALLER, 0, null);
    defer evm.deinit();
    var frame = try FrameT.init(h.gpa, code, 0, CALLER, SELF, 0, &.{}, @ptrCast(&evm), .OSAKA, false);
    defer frame.deinit();
    const keys = try h.gpa.dupe(u32, frame.bytecode.valid_jumpdests.keys());
    defer h.gpa.free(keys);
    std.mem.sort(u32, keys, {}, std.sort.asc(u32));
    try h.zig.appendSlice(h.gpa, "OK\t");
    if (keys.len == 0) return h.zig.append(h.gpa, '-');
    for (keys, 0..) |k, i| {
        if (i != 0) try h.zig.append(h.gpa, ',');
        try h.zig.print(h.gpa, "{d}", .{k});
    }
}

/// Reads the PUSH immediate via `Bytecode.readImmediate`; when `code[pc]` really is PUSHsize,
/// also executes it through `Frame.executeOpcode` and requires the two Zig paths to agree.
fn zigPush(h: *Harness, code: []const u8, pc: u32, size: u8) !?[]const u8 {
    var evm: EvmT = undefined;
    try evm.init(h.gpa, null, .OSAKA, null, CALLER, 0, null);
    defer evm.deinit();
    var frame = try FrameT.init(h.gpa, code, 1_000, CALLER, SELF, 0, &.{}, @ptrCast(&evm), .OSAKA, false);
    defer frame.deinit();
    const value = frame.bytecode.readImmediate(pc, size) orelse return error.PcOutOfRange;
    try h.zig.print(h.gpa, "OK\t{x}", .{value});
    if (code[pc] != 0x5f + size) return null;
    h.push_exec_checks += 1;
    frame.pc = pc;
    frame.executeOpcode(code[pc]) catch |err| return @errorName(err);
    const pushed = try frame.popStack();
    if (pushed != value) return "executed PUSHn differs from Bytecode.readImmediate";
    if (frame.pc != pc + 1 + size) return "PUSHn did not advance pc by 1+n";
    return null;
}

pub fn runJumpdest(h: *Harness) !void {
    var prng = suitePrng(h.opts.seed, .jumpdest);
    const r = prng.random();
    var code: Buf = .empty;
    defer code.deinit(h.gpa);
    var pushes: std.ArrayList(u32) = .empty;
    defer pushes.deinit(h.gpa);

    // Fixed edge programs first.
    const fixed = [_][]const u8{
        &.{},             &.{0x5b},                           &.{ 0x60, 0x5b },       &.{ 0x60, 0x5b, 0x5b },
        &.{0x7f},         &.{ 0x7f, 0x5b },                   &.{ 0x61, 0x5b },       &.{ 0x5f, 0x5b },
        &.{ 0x5b, 0x60 }, &.{ 0x62, 0x5b, 0x5b, 0x5b, 0x5b }, &.{ 0x00, 0x5b, 0x7e },
    };
    for (fixed) |c| {
        h.begin();
        try h.req.appendSlice(h.gpa, "JUMPDEST\t");
        try appendHexBytes(&h.req, h.gpa, c);
        try zigJumpdests(h, c);
        try h.compare(.jumpdest, null, "");
    }
    for (0..@as(u64, 900) * h.opts.scale) |_| {
        if (h.atCap(.jumpdest)) return;
        try genJumpdestCode(r, h.gpa, &code);
        h.begin();
        try h.req.appendSlice(h.gpa, "JUMPDEST\t");
        try appendHexBytes(&h.req, h.gpa, code.items);
        try zigJumpdests(h, code.items);
        try h.compare(.jumpdest, null, "");
    }
    var made: u64 = 0;
    while (made < @as(u64, 700) * h.opts.scale) {
        if (h.atCap(.jumpdest)) return;
        try genJumpdestCode(r, h.gpa, &code);
        if (code.items.len == 0) continue;
        // Collect PUSH1..PUSH32 instruction boundaries.
        pushes.clearRetainingCapacity();
        var pc: usize = 0;
        while (pc < code.items.len) {
            const op = code.items[pc];
            if (op >= 0x60 and op <= 0x7f) {
                try pushes.append(h.gpa, @intCast(pc));
                pc += 1 + (op - 0x5f);
            } else pc += 1;
        }
        var at: u32 = undefined;
        var size: u8 = undefined;
        if (pushes.items.len > 0 and r.uintLessThan(u8, 4) != 0) {
            // Prefer the trailing (possibly truncated) PUSH.
            at = if (r.boolean()) pushes.items[pushes.items.len - 1] else pushes.items[r.uintLessThan(usize, pushes.items.len)];
            size = code.items[at] - 0x5f;
        } else {
            at = r.uintLessThan(u32, @intCast(code.items.len));
            size = r.intRangeAtMost(u8, 1, 32);
        }
        made += 1;
        h.begin();
        try h.req.appendSlice(h.gpa, "PUSH\t");
        try appendHexBytes(&h.req, h.gpa, code.items);
        try h.req.print(h.gpa, "\t{d}\t{d}", .{ at, size });
        if (try zigPush(h, code.items, at, size)) |internal| {
            const st = &h.stats[@intFromEnum(Suite.jumpdest)];
            st.vectors += 1;
            h.mismatch(.jumpdest, .OSAKA, "(zig-internal check)", internal);
            continue;
        }
        try h.compare(.jumpdest, null, "");
    }
}

// ---------------------------------------------------------------------------
// Suite 5: PRECOMPILE + EIP-7825
// ---------------------------------------------------------------------------

const TX_GAS_EDGES = [_]u64{ 0, 21_000, 16_777_215, 16_777_216, 16_777_217, 30_000_000, U64_MAX };

fn precompileAddrs() [36]u256 {
    var out: [36]u256 = undefined;
    var n: usize = 0;
    var i: u256 = 0;
    while (i <= 0x14) : (i += 1) {
        out[n] = i;
        n += 1;
    }
    for ([_]u256{
        0xff,                                              0x100,            0x101,                                               0x0fff,
        0x1000,                                            0xffff,           ONE << 152,                                          (ONE << 152) | 1,
        (ONE << 152) | 0x100,                              (ONE << 160) - 1, 0x0100_0000_0000_0000_0000_0000_0000_0000_0000_0001, 0xc0de,
        0x10_0000_0000_0000_0000_0000_0000_0000_0000_000b, 0x0a00,           0x0b00,
    }) |v| {
        out[n] = v;
        n += 1;
    }
    return out;
}

fn isBlsCompatBoundary(fork: Hardfork, addr: u256) bool {
    return fork.isAtLeast(.PRAGUE) and (addr == 0x12 or addr == 0x13);
}

fn precompileVector(h: *Harness, fork: Hardfork, addr_int: u256, gas: u64) !void {
    const addr = Address.fromU256(addr_int);
    h.begin();
    try h.req.print(h.gpa, "PRECOMPILE\t{s}\t", .{forkName(fork)});
    try appendAddress(&h.req, h.gpa, addr);
    try h.req.print(h.gpa, "\t{d}", .{gas});
    const is_pre = gm.evm.isPrecompileAddress(addr, fork);
    const allowed = gm.hardfork_hooks.isTxGasLimitAllowed(fork, gas);
    try h.zig.print(h.gpa, "OK\t{d}\t{d}", .{ @intFromBool(is_pre), @intFromBool(allowed) });

    if (!isBlsCompatBoundary(fork, addr_int)) return h.compare(.precompile, fork, "");

    // Voltaire may still list BLS12-381 at 0x12..0x13 (pre-ab9264bb 9-op table) while Lean
    // reports the canonical 7-op table 0x0b..0x11. Require Lean = canonical (0), require the
    // tx-cap bit to match, and record (not fail) Zig's table choice.
    const st = &h.stats[@intFromEnum(Suite.precompile)];
    st.vectors += 1;
    h.bls_compat[if (is_pre) 0 else 1] += 1;
    const lean_resp = (try h.lean()) orelse return;
    var expect: Buf = .empty;
    defer expect.deinit(h.gpa);
    try expect.print(h.gpa, "OK\t0\t{d}", .{@intFromBool(allowed)});
    if (!std.mem.eql(u8, lean_resp, expect.items)) {
        h.mismatch(.precompile, fork, lean_resp, "0x12..0x13 compat boundary: Lean must report the canonical 0x0b..0x11 table (is_precompile=0)");
    }
}

pub fn runPrecompile(h: *Harness) !void {
    var prng = suitePrng(h.opts.seed, .precompile);
    const r = prng.random();
    const addrs = precompileAddrs();
    // Grid: 15 forks x 36 addresses, rotating the tx gas edge (540) ...
    for (PROTOCOL_FORKS, 0..) |fork, fi| for (addrs, 0..) |a, ai| {
        if (h.atCap(.precompile)) return;
        try precompileVector(h, fork, a, TX_GAS_EDGES[(fi + ai) % TX_GAS_EDGES.len]);
    };
    // ... plus every tx gas edge on every fork (105) ...
    for (PROTOCOL_FORKS) |fork| for (TX_GAS_EDGES) |gas| {
        if (h.atCap(.precompile)) return;
        try precompileVector(h, fork, 0x01, gas);
    };
    // ... plus PRNG (240).
    for (0..@as(u64, 240) * h.opts.scale) |_| {
        if (h.atCap(.precompile)) return;
        const fork = PROTOCOL_FORKS[r.uintLessThan(usize, PROTOCOL_FORKS.len)];
        const a: u256 = switch (r.uintLessThan(u8, 3)) {
            0 => r.uintLessThan(u256, 0x120),
            1 => r.int(u160),
            else => addrs[r.uintLessThan(usize, addrs.len)],
        };
        const gas: u64 = switch (r.uintLessThan(u8, 3)) {
            0 => 16_777_216 +% r.uintLessThan(u64, 9) -% 4,
            1 => r.int(u64),
            else => r.uintLessThan(u64, 60_000_000),
        };
        try precompileVector(h, fork, a, gas);
    }
}

// ---------------------------------------------------------------------------
// Suite 6: EXEC
// ---------------------------------------------------------------------------

pub const ExecStatus = enum { STOP, RETURN, REVERT, OOG, STACK_UNDERFLOW, STACK_OVERFLOW, INVALID_JUMP, INVALID_OPCODE };

/// Map a Zig execution error to the protocol status. Zig reports `OutOfBounds` where an
/// operand does not fit u32: for JUMP/JUMPI that is an invalid destination, for memory
/// and copy operands the spec's expansion cost exceeds any u63 gas budget (OOG). Every
/// exceptional halt has gas 0, refund 0 and empty output, so only the class matters.
fn mapExecError(err: anyerror, faulting_op: ?u8) ?ExecStatus {
    return switch (err) {
        error.OutOfGas => .OOG,
        error.StackUnderflow => .STACK_UNDERFLOW,
        error.StackOverflow => .STACK_OVERFLOW,
        error.InvalidJump, error.InvalidJumpDestination => .INVALID_JUMP,
        error.InvalidOpcode => .INVALID_OPCODE,
        error.OutOfBounds => if (faulting_op != null and (faulting_op.? == 0x56 or faulting_op.? == 0x57)) .INVALID_JUMP else .OOG,
        else => null,
    };
}

/// Run `code` as one standalone top-level frame the way `Evm.call` does (fresh tx state,
/// Berlin+ pre-warming, frame pushed on `evm.frames`), writing the protocol response to
/// `h.zig`. Returns gas used on STOP/RETURN/REVERT.
fn zigExec(h: *Harness, fork: Hardfork, gas: u64, code: []const u8, calldata: []const u8) !?u64 {
    var evm: EvmT = undefined;
    try evm.init(h.gpa, null, fork, null, CALLER, 0, null);
    defer evm.deinit();
    try evm.initTransactionState(null);
    try evm.preWarmTransaction(SELF);
    const arena = evm.arena.allocator();
    try evm.frames.append(arena, try FrameT.init(arena, code, @intCast(gas), CALLER, SELF, 0, calldata, @ptrCast(&evm), fork, false));
    const idx = evm.frames.items.len - 1;
    const result = evm.frames.items[idx].execute();
    const frame = &evm.frames.items[idx];
    result catch |err| {
        const op: ?u8 = if (frame.pc < code.len) code[frame.pc] else null;
        try h.note.print(h.gpa, "zig halted at pc={d} op=0x{x:0>2} error={s} stack_depth={d}", .{ frame.pc, op orelse 0, @errorName(err), frame.stack.items.len });
        if (mapExecError(err, op)) |status| {
            try h.zig.print(h.gpa, "OK\t{s}\t0\t0\t-", .{@tagName(status)});
        } else {
            try h.zig.print(h.gpa, "OK\tZIG_ERROR_{s}\t0\t0\t-", .{@errorName(err)});
        }
        return null;
    };
    const gas_left: u64 = @intCast(@max(frame.gas_remaining, 0));
    const status: ExecStatus = if (frame.reverted)
        .REVERT
    else if (frame.pc < code.len and code[frame.pc] == 0xf3)
        .RETURN
    else
        .STOP;
    const refund: u64 = if (status == .REVERT) 0 else evm.gas_refund;
    try h.zig.print(h.gpa, "OK\t{s}\t{d}\t{d}\t", .{ @tagName(status), gas_left, refund });
    try appendHexBytes(&h.zig, h.gpa, if (status == .STOP) &.{} else frame.output);
    return gas - gas_left;
}

/// Tiny assembler with label fixups for JUMP/JUMPI targets.
pub const Asm = struct {
    gpa: Allocator,
    code: Buf = .empty,
    labels: std.ArrayList(u32) = .empty,
    fixups: std.ArrayList(u32) = .empty,

    pub fn deinit(self: *Asm) void {
        self.code.deinit(self.gpa);
        self.labels.deinit(self.gpa);
        self.fixups.deinit(self.gpa);
    }

    pub fn reset(self: *Asm) void {
        self.code.clearRetainingCapacity();
        self.labels.clearRetainingCapacity();
        self.fixups.clearRetainingCapacity();
    }

    fn op(self: *Asm, b: u8) !void {
        try self.code.append(self.gpa, b);
    }

    /// Minimal-width PUSHn (PUSH1 for zero so the program runs pre-Shanghai too).
    fn push(self: *Asm, v: u256) !void {
        const n: u8 = if (v == 0) 1 else @intCast((256 - @clz(v) + 7) / 8);
        try self.pushN(n, v);
    }

    fn pushN(self: *Asm, n: u8, v: u256) !void {
        try self.op(0x5f + n);
        var i: u8 = n;
        while (i > 0) {
            i -= 1;
            try self.op(@truncate(if (i >= 32) 0 else v >> (@as(u8, i) * 8)));
        }
    }

    fn label(self: *Asm) !u32 {
        const at: u32 = @intCast(self.code.items.len);
        try self.labels.append(self.gpa, at);
        try self.op(0x5b);
        return at;
    }

    fn jumpTarget(self: *Asm) !void {
        try self.op(0x61); // PUSH2, patched by finish()
        try self.fixups.append(self.gpa, @intCast(self.code.items.len));
        try self.op(0);
        try self.op(0);
    }

    /// Patch every jump target: usually a real JUMPDEST (preferring forward ones so most
    /// programs terminate), sometimes an arbitrary offset.
    fn finish(self: *Asm, r: std.Random) void {
        for (self.fixups.items) |at| {
            var target: u32 = r.uintLessThan(u32, @intCast(self.code.items.len + 4));
            if (self.labels.items.len > 0 and r.uintLessThan(u8, 10) < 9) {
                var forward: ?u32 = null;
                for (self.labels.items) |l| if (l > at) {
                    forward = l;
                    break;
                };
                target = if (forward != null and r.uintLessThan(u8, 10) < 8)
                    forward.?
                else
                    self.labels.items[r.uintLessThan(usize, self.labels.items.len)];
            }
            self.code.items[at] = @truncate(target >> 8);
            self.code.items[at + 1] = @truncate(target);
        }
    }
};

fn memOffset(r: std.Random) u256 {
    return switch (r.uintLessThan(u8, 20)) {
        0 => ONE << 24,
        1 => std.math.maxInt(u32),
        2 => ONE << 32,
        3 => ONE << 64,
        4 => U256_MAX,
        5, 6, 7 => r.uintLessThan(u64, 65_536),
        else => r.uintLessThan(u64, 512),
    };
}

fn smallLen(r: std.Random) u256 {
    return switch (r.uintLessThan(u8, 12)) {
        0 => 0,
        1 => memOffset(r),
        else => r.uintLessThan(u64, 97),
    };
}

fn storeValue(r: std.Random) u256 {
    return switch (r.uintLessThan(u8, 5)) {
        0, 1 => 0,
        2 => 1,
        3 => 2,
        else => interesting(r),
    };
}

/// True for opcodes that are defined on some fork but outside the Lean EXEC subset
/// (environment, logs, calls, creates, KECCAK256, SELFDESTRUCT). Emitting them would
/// compare guillotine-mini's full EVM against an oracle that does not model them.
pub fn outsideExecSubset(b: u8) bool {
    return switch (b) {
        0x20, 0x30...0x34, 0x3a...0x4a, 0xa0...0xa4, 0xf0...0xf2, 0xf4, 0xf5, 0xfa, 0xff => true,
        else => false,
    };
}

/// Random byte that is either in the EXEC subset or undefined on every fork. PUSH1..PUSH32
/// are excluded so a raw byte never swallows the next instruction and exposes one of its
/// immediates (which may be outside the subset) as an executed opcode.
fn execRawByte(r: std.Random) u8 {
    while (true) {
        const b = r.int(u8);
        if (!outsideExecSubset(b) and (b < 0x60 or b > 0x7f)) return b;
    }
}

/// Generate a valid-leaning but adversarial multi-opcode program.
pub fn genProgram(a: *Asm, r: std.Random) !void {
    a.reset();
    const segments = 1 + r.uintLessThan(u32, 28);
    for (0..segments) |_| {
        switch (r.uintLessThan(u8, 40)) {
            0...9 => { // word opcode with its operands pushed
                const w = WORD_OPS[r.uintLessThan(usize, WORD_OPS.len)];
                for (0..w.arity) |_| try a.push(interesting(r));
                try a.op(w.op);
            },
            10 => if (r.boolean()) try a.op(0x5f) else {
                const n = r.intRangeAtMost(u8, 1, 32);
                try a.pushN(n, r.int(u256));
            },
            11, 12 => try a.op(0x80 + (if (r.boolean()) r.uintLessThan(u8, 4) else r.uintLessThan(u8, 16))),
            13, 14 => try a.op(0x90 + (if (r.boolean()) r.uintLessThan(u8, 4) else r.uintLessThan(u8, 16))),
            15 => try a.op(0x50),
            16, 17 => { // MSTORE / MSTORE8
                try a.push(interesting(r));
                try a.push(memOffset(r));
                try a.op(if (r.boolean()) 0x52 else 0x53);
            },
            18 => {
                try a.push(memOffset(r));
                try a.op(0x51);
            },
            19 => { // MCOPY dest src len (dest on top)
                try a.push(smallLen(r));
                try a.push(memOffset(r));
                try a.push(memOffset(r));
                try a.op(0x5e);
            },
            20, 21 => { // TSTORE / TLOAD
                if (r.boolean()) {
                    try a.push(storeValue(r));
                    try a.push(r.uintLessThan(u8, 4));
                    try a.op(0x5d);
                } else {
                    try a.push(r.uintLessThan(u8, 4));
                    try a.op(0x5c);
                }
            },
            22, 23, 24 => { // SSTORE / SLOAD on a few hot keys to hit dirty-slot refunds
                if (r.uintLessThan(u8, 3) != 0) {
                    try a.push(storeValue(r));
                    try a.push(r.uintLessThan(u8, 4));
                    try a.op(0x55);
                } else {
                    try a.push(r.uintLessThan(u8, 4));
                    try a.op(0x54);
                }
            },
            25 => {
                try a.push(if (r.boolean()) r.uintLessThan(u8, 80) else memOffset(r));
                try a.op(0x35);
            },
            26 => try a.op(if (r.boolean()) 0x36 else 0x38),
            27 => { // CALLDATACOPY / CODECOPY dest off len
                try a.push(smallLen(r));
                try a.push(if (r.boolean()) r.uintLessThan(u8, 120) else memOffset(r));
                try a.push(memOffset(r));
                try a.op(if (r.boolean()) 0x37 else 0x39);
            },
            28 => try a.op(switch (r.uintLessThan(u8, 3)) {
                0 => 0x58,
                1 => 0x5a,
                else => 0x59,
            }),
            29, 30, 31 => _ = try a.label(),
            32, 33 => {
                try a.jumpTarget();
                try a.op(0x56);
            },
            34, 35 => {
                try a.push(if (r.boolean()) 0 else interesting(r));
                try a.jumpTarget();
                try a.op(0x57);
            },
            36 => for (0..r.intRangeAtMost(u8, 1, 4)) |_| try a.op(execRawByte(r)), // raw adversarial bytes
            37 => { // stack bomb: JUMPDEST PUSH1 1 PUSH2 self JUMP -> overflow or OOG
                if (r.uintLessThan(u8, 4) == 0) {
                    const l = try a.label();
                    try a.push(1);
                    try a.pushN(2, l);
                    try a.op(0x56);
                }
            },
            38 => { // early RETURN / REVERT
                try a.push(smallLen(r));
                try a.push(memOffset(r));
                try a.op(if (r.boolean()) 0xf3 else 0xfd);
            },
            else => try a.op(0x00),
        }
    }
    switch (r.uintLessThan(u8, 10)) {
        0, 1, 2 => { // RETURN small slice
            try a.push(r.uintLessThan(u8, 97));
            try a.push(r.uintLessThan(u8, 129));
            try a.op(0xf3);
        },
        3, 4 => {
            try a.push(r.uintLessThan(u8, 65));
            try a.push(r.uintLessThan(u8, 129));
            try a.op(0xfd);
        },
        5 => try a.op(0x00),
        6 => try a.op(0xfe),
        7 => { // truncated trailing PUSHn
            const n = r.intRangeAtMost(u8, 1, 32);
            try a.op(0x5f + n);
            for (0..r.uintLessThan(u8, n)) |_| try a.op(r.int(u8));
        },
        else => {},
    }
    a.finish(r);
}

fn execVector(h: *Harness, fork: Hardfork, gas: u64, code: []const u8, calldata: []const u8) !?u64 {
    h.begin();
    try h.req.print(h.gpa, "EXEC\t{s}\t{d}\t", .{ forkName(fork), gas });
    try appendHexBytes(&h.req, h.gpa, code);
    try h.req.append(h.gpa, '\t');
    try appendHexBytes(&h.req, h.gpa, calldata);
    const used = try zigExec(h, fork, gas, code, calldata);
    try h.compare(.exec, fork, "");
    return used;
}

fn execGas(r: std.Random) u64 {
    return switch (r.uintLessThan(u8, 10)) {
        0 => r.uintLessThan(u64, 120),
        1...5 => r.intRangeAtMost(u64, 1_000, 100_000),
        6...8 => r.intRangeAtMost(u64, 100_000, 1_000_000),
        else => r.intRangeAtMost(u64, 1_000_000, 3_000_000),
    };
}

pub fn runExec(h: *Harness) !void {
    var prng = suitePrng(h.opts.seed, .exec);
    const r = prng.random();
    var a: Asm = .{ .gpa = h.gpa };
    defer a.deinit();
    var calldata: [96]u8 = undefined;
    for (0..@as(u64, 2400) * h.opts.scale) |i| {
        if (h.atCap(.exec)) return;
        const fork = EXEC_FORKS[i % EXEC_FORKS.len];
        try genProgram(&a, r);
        const cd = calldata[0..r.uintLessThan(usize, calldata.len + 1)];
        r.bytes(cd);
        const gas = execGas(r);
        const used = try execVector(h, fork, gas, a.code.items, cd);
        // Every third program: re-run at the exact gas it used and one below.
        if (i % 3 == 0) if (used) |u| if (u > 0) {
            _ = try execVector(h, fork, u, a.code.items, cd);
            _ = try execVector(h, fork, u - 1, a.code.items, cd);
        };
    }
}

// ---------------------------------------------------------------------------
// Replay: re-check protocol request lines (e.g. pasted from a mismatch report)
// ---------------------------------------------------------------------------

fn parseFork(name: []const u8) !Hardfork {
    for (PROTOCOL_FORKS) |f| if (std.mem.eql(u8, name, @tagName(f))) return f;
    return error.UnknownFork;
}

fn parseHexU256(t: []const u8) !u256 {
    return std.fmt.parseInt(u256, t, 16);
}

fn parseHexBytes(gpa: Allocator, t: []const u8) ![]u8 {
    if (std.mem.eql(u8, t, "-")) return gpa.alloc(u8, 0);
    const out = try gpa.alloc(u8, t.len / 2);
    errdefer gpa.free(out);
    _ = try std.fmt.hexToBytes(out, t);
    return out;
}

/// Evaluate one request line on the Zig side and compare it with Lean.
pub fn replayLine(h: *Harness, line: []const u8) !void {
    var fields: [8][]const u8 = undefined;
    var n: usize = 0;
    var it = std.mem.splitScalar(u8, line, '\t');
    while (it.next()) |f| : (n += 1) {
        if (n == fields.len) return error.TooManyFields;
        fields[n] = f;
    }
    const cmd = fields[0];
    const want: usize = if (std.mem.eql(u8, cmd, "WORD")) 6 else if (std.mem.eql(u8, cmd, "MEMGAS")) 3 else if (std.mem.eql(u8, cmd, "SSTORE")) 7 else if (std.mem.eql(u8, cmd, "JUMPDEST")) 2 else if (std.mem.eql(u8, cmd, "PUSH")) 4 else if (std.mem.eql(u8, cmd, "PRECOMPILE")) 4 else if (std.mem.eql(u8, cmd, "EXEC")) 5 else return error.UnknownCommand;
    if (n != want) return error.WrongFieldCount;
    if (std.mem.eql(u8, cmd, "WORD")) {
        const op = try std.fmt.parseInt(u8, fields[2], 16);
        for (WORD_OPS) |w| if (w.op == op) {
            return wordVector(h, try parseFork(fields[1]), w, .{ try parseHexU256(fields[3]), try parseHexU256(fields[4]), try parseHexU256(fields[5]) });
        };
        return error.UnknownWordOpcode;
    }
    if (std.mem.eql(u8, cmd, "MEMGAS")) {
        var evm: EvmT = undefined;
        try evm.init(h.gpa, null, .OSAKA, null, CALLER, 0, null);
        defer evm.deinit();
        var frame = try FrameT.init(h.gpa, &.{}, 0, CALLER, SELF, 0, &.{}, @ptrCast(&evm), .OSAKA, false);
        defer frame.deinit();
        const cur = std.math.cast(u32, try std.fmt.parseInt(u64, fields[1], 10)) orelse return error.CurrentSizeExceedsFrameU32;
        return memVector(h, &frame, cur, try std.fmt.parseInt(u64, fields[2], 10));
    }
    if (std.mem.eql(u8, cmd, "SSTORE")) {
        return sstoreVector(h, try parseFork(fields[1]), try parseHexU256(fields[2]), try parseHexU256(fields[3]), try parseHexU256(fields[4]), std.mem.eql(u8, fields[5], "1"), try std.fmt.parseInt(u64, fields[6], 10));
    }
    if (std.mem.eql(u8, cmd, "PRECOMPILE")) {
        return precompileVector(h, try parseFork(fields[1]), try parseHexU256(fields[2]), try std.fmt.parseInt(u64, fields[3], 10));
    }
    const code = try parseHexBytes(h.gpa, fields[1 + @as(usize, if (std.mem.eql(u8, cmd, "EXEC")) 2 else 0)]);
    defer h.gpa.free(code);
    if (std.mem.eql(u8, cmd, "JUMPDEST")) {
        h.begin();
        try h.req.appendSlice(h.gpa, line);
        try zigJumpdests(h, code);
        return h.compare(.jumpdest, null, "");
    }
    if (std.mem.eql(u8, cmd, "PUSH")) {
        h.begin();
        try h.req.appendSlice(h.gpa, line);
        const pc = try std.fmt.parseInt(u32, fields[2], 10);
        if (pc >= code.len) return error.PcOutOfRange;
        if (try zigPush(h, code, pc, try std.fmt.parseInt(u8, fields[3], 10))) |internal| {
            h.stats[@intFromEnum(Suite.jumpdest)].vectors += 1;
            h.mismatch(.jumpdest, .OSAKA, "(zig-internal check)", internal);
            return;
        }
        return h.compare(.jumpdest, null, "");
    }
    const calldata = try parseHexBytes(h.gpa, fields[4]);
    defer h.gpa.free(calldata);
    _ = try execVector(h, try parseFork(fields[1]), try std.fmt.parseInt(u64, fields[2], 10), code, calldata);
}

pub fn runReplay(h: *Harness, path: []const u8) !void {
    const data = try std.fs.cwd().readFileAlloc(h.gpa, path, 1 << 30);
    defer h.gpa.free(data);
    var lines = std.mem.splitScalar(u8, data, '\n');
    while (lines.next()) |raw| {
        const line = std.mem.trim(u8, raw, " \r");
        if (line.len == 0 or line[0] == '#') continue;
        replayLine(h, line) catch |err| {
            std.debug.print("lean-diff: replay: cannot evaluate '{s}': {s}\n", .{ line, @errorName(err) });
            return err;
        };
    }
    std.debug.print("lean-diff: replayed {d} vectors, mismatches={d}\n", .{ h.totalVectors(), h.totalMismatches() });
}

// ---------------------------------------------------------------------------
// Driver
// ---------------------------------------------------------------------------

pub fn runSuites(h: *Harness) !void {
    const enabled = h.opts.suites;
    inline for (.{
        .{ Suite.word, runWord },
        .{ Suite.memgas, runMemGas },
        .{ Suite.sstore, runSstore },
        .{ Suite.jumpdest, runJumpdest },
        .{ Suite.precompile, runPrecompile },
        .{ Suite.exec, runExec },
    }) |entry| {
        if (enabled & (@as(u8, 1) << @intFromEnum(entry[0])) != 0) {
            var timer = try std.time.Timer.start();
            try entry[1](h);
            const st = h.stats[@intFromEnum(entry[0])];
            std.debug.print("lean-diff: suite {s:<10} vectors={d:>6} mismatches={d:>5} halt-reason-only={d:>4} ({d} ms)\n", .{
                @tagName(entry[0]), st.vectors, st.mismatches, st.halt_reason_only, timer.read() / std.time.ns_per_ms,
            });
        }
    }
}

pub fn main() !u8 {
    var dbg: std.heap.DebugAllocator(.{}) = .init;
    defer if (dbg.deinit() == .leak) {
        std.debug.print("lean-diff: memory leak detected\n", .{});
        std.process.exit(3);
    };
    const gpa = dbg.allocator();
    var arena_state = std.heap.ArenaAllocator.init(gpa);
    defer arena_state.deinit();
    const opts = try loadOptions(arena_state.allocator());

    var oracle: ?*Oracle = null;
    if (!opts.zig_only) {
        std.fs.cwd().access(opts.oracle_path, .{}) catch {
            if (opts.require_oracle) {
                std.debug.print("lean-diff: FAIL: Lean oracle not found at {s} (LEAN_DIFF_REQUIRE=1)\n", .{opts.oracle_path});
                return 2;
            }
            std.debug.print("lean-diff: SKIP: Lean oracle not found at {s}; build it with `lake build` in spec/lean or set LEAN_SPEC_BIN\n", .{opts.oracle_path});
            return 0;
        };
        oracle = try Oracle.start(gpa, opts.oracle_path);
    }

    std.debug.print("lean-diff: oracle={s} seed=0x{x} scale={d} suites=0x{x}\n", .{
        if (opts.zig_only) "(zig-only)" else opts.oracle_path, opts.seed, opts.scale, opts.suites,
    });
    var h = Harness.init(gpa, opts, oracle);
    defer h.deinit();
    const run_result = if (opts.replay_path) |path| runReplay(&h, path) else runSuites(&h);
    if (oracle) |o| {
        const term = try o.stop();
        switch (term) {
            .Exited => |code| if (code != 0) {
                std.debug.print("lean-diff: oracle exited with code {d}\n", .{code});
                return 1;
            },
            else => {
                std.debug.print("lean-diff: oracle terminated abnormally: {any}\n", .{term});
                return 1;
            },
        }
    }
    try run_result;

    const total = h.totalVectors();
    const bad = h.totalMismatches();
    std.debug.print("lean-diff: total vectors={d} mismatches={d} push-exec-crosschecks={d}\n", .{ total, bad, h.push_exec_checks });
    std.debug.print("lean-diff: Voltaire BLS 0x12..0x13 on Prague+: zig reports precompile={d}, not-precompile={d} (compat boundary, not asserted on the Zig side)\n", .{ h.bls_compat[0], h.bls_compat[1] });
    var short = false;
    if (opts.replay_path == null) for (h.stats, 0..) |st, i| {
        const s: Suite = @enumFromInt(i);
        if (opts.suites & (@as(u8, 1) << @intCast(i)) != 0 and st.vectors < s.minVectors()) {
            std.debug.print("lean-diff: FAIL: suite {s} ran {d} vectors, below the {d} minimum\n", .{ @tagName(s), st.vectors, s.minVectors() });
            short = true;
        }
    };
    if (bad > 0) {
        std.debug.print("lean-diff: FAIL: {d} differential mismatches (first {d} printed above)\n", .{ bad, @min(bad, opts.max_report) });
        return 1;
    }
    if (short) return 1;
    std.debug.print("lean-diff: PASS\n", .{});
    return 0;
}

// ---------------------------------------------------------------------------
// Unit tests (no oracle required)
// ---------------------------------------------------------------------------

const testing = std.testing;

test "hex encoding follows the protocol" {
    var b: Buf = .empty;
    defer b.deinit(testing.allocator);
    try appendHexBytes(&b, testing.allocator, &.{});
    try b.print(testing.allocator, "|", .{});
    try appendHexBytes(&b, testing.allocator, &.{ 0x00, 0x5b, 0xff });
    try b.print(testing.allocator, "|{x}|{x}|{x}", .{ @as(u256, 0), @as(u256, 0xABC), U256_MAX });
    try testing.expectEqualStrings("-|005bff|0|abc|" ++ "f" ** 64, b.items);
}

test "suite parsing and option defaults" {
    try testing.expectEqual(@as(u8, 0b100001), try parseSuites("word,exec"));
    try testing.expectEqual(@as(u8, 1 << 3), try parseSuites("push"));
    try testing.expectEqual(ALL_SUITES, try parseSuites("all"));
    try testing.expectError(error.InvalidSuite, parseSuites("nope"));
    try testing.expectEqual(@as(u64, 255), try parseU64("0xff"));
    try testing.expectEqual(@as(u64, 42), try parseU64("42"));
}

test "assembler pushes minimal big-endian immediates" {
    var a: Asm = .{ .gpa = testing.allocator };
    defer a.deinit();
    try a.push(0);
    try a.push(0x1234);
    try a.pushN(32, U256_MAX);
    try testing.expectEqualSlices(u8, &.{ 0x60, 0x00, 0x61, 0x12, 0x34, 0x7f }, a.code.items[0..6]);
    try testing.expectEqual(@as(usize, 6 + 32), a.code.items.len);
}

test "generated programs stay inside the Lean EXEC opcode subset" {
    var a: Asm = .{ .gpa = testing.allocator };
    defer a.deinit();
    var prng = std.Random.DefaultPrng.init(11);
    for (0..500) |_| {
        try genProgram(&a, prng.random());
        var pc: usize = 0;
        while (pc < a.code.items.len) {
            const op = a.code.items[pc];
            try testing.expect(!outsideExecSubset(op));
            pc += if (op >= 0x60 and op <= 0x7f) 1 + @as(usize, op - 0x5f) else 1;
        }
    }
}

test "program generation is deterministic per seed" {
    var a1: Asm = .{ .gpa = testing.allocator };
    defer a1.deinit();
    var a2: Asm = .{ .gpa = testing.allocator };
    defer a2.deinit();
    var p1 = std.Random.DefaultPrng.init(7);
    var p2 = std.Random.DefaultPrng.init(7);
    for (0..50) |_| {
        try genProgram(&a1, p1.random());
        try genProgram(&a2, p2.random());
        try testing.expectEqualSlices(u8, a1.code.items, a2.code.items);
    }
}

test "zig side: known answers on the real frame" {
    var h = Harness.init(testing.allocator, .{ .zig_only = true }, null);
    defer h.deinit();
    // EXP gas: 10 + 10/byte pre-Spurious, 10 + 50/byte after.
    try zigWord(&h, .FRONTIER, 0x0a, .{ 2, 0x100, 0 });
    try testing.expectEqualStrings("OK\t0\t30", h.zig.items);
    h.begin();
    try zigWord(&h, .SPURIOUS_DRAGON, 0x0a, .{ 2, 0x100, 0 });
    try testing.expectEqualStrings("OK\t0\t110", h.zig.items);
    h.begin();
    try zigWord(&h, .BYZANTIUM, 0x1b, .{ 1, 1, 0 });
    try testing.expectEqualStrings("ERR\tInvalidOpcode", h.zig.items);
    h.begin();
    try zigWord(&h, .PRAGUE, 0x1e, .{ 1, 0, 0 });
    try testing.expectEqualStrings("ERR\tInvalidOpcode", h.zig.items);
    // Exec: PUSH1 1 PUSH1 0 SSTORE STOP on Berlin: 3+3+22100 = 22106.
    h.begin();
    _ = try zigExec(&h, .BERLIN, 30_000, &.{ 0x60, 0x01, 0x60, 0x00, 0x55, 0x00 }, &.{});
    try testing.expectEqualStrings("OK\tSTOP\t7894\t0\t-", h.zig.items);
    h.begin();
    _ = try zigExec(&h, .CANCUN, 100, &.{ 0x60, 0x2a, 0x60, 0x00, 0x53, 0x60, 0x01, 0x60, 0x00, 0xf3 }, &.{});
    try testing.expectEqualStrings("OK\tRETURN\t82\t0\t2a", h.zig.items);
    h.begin();
    try zigJumpdests(&h, &.{ 0x60, 0x5b, 0x5b, 0x7f, 0x5b });
    try testing.expectEqualStrings("OK\t2", h.zig.items);
    h.begin();
    try testing.expectEqual(@as(?[]const u8, null), try zigPush(&h, &.{ 0x00, 0x62, 0xab }, 1, 3));
    try testing.expectEqualStrings("OK\tab0000", h.zig.items);
}

test "replay parses every protocol command" {
    var h = Harness.init(testing.allocator, .{ .zig_only = true }, null);
    defer h.deinit();
    const lines = [_][]const u8{
        "WORD\tOSAKA\t01\t1\t2\t0",
        "MEMGAS\t0\t32",
        "SSTORE\tLONDON\t1\t1\t0\t1\t30000",
        "JUMPDEST\t605b5b",
        "PUSH\t0062ab\t1\t3",
        "PRECOMPILE\tOSAKA\t0000000000000000000000000000000000000100\t16777217",
        "EXEC\tCANCUN\t100\t602a60005360016000f3\t-",
    };
    for (lines) |l| try replayLine(&h, l);
    try testing.expectEqual(@as(u64, lines.len), h.totalVectors());
    try testing.expectEqualStrings("OK\tRETURN\t82\t0\t2a", h.zig.items);
    try testing.expectError(error.WrongFieldCount, replayLine(&h, "WORD\tOSAKA"));
}

test "zig-only smoke over every suite is leak-free" {
    var h = Harness.init(testing.allocator, .{ .zig_only = true, .max_per_suite = 150 }, null);
    defer h.deinit();
    try runSuites(&h);
    for (h.stats) |st| try testing.expect(st.vectors >= 150);
    try testing.expectEqual(@as(u64, 0), h.totalMismatches());
}
