const std = @import("std");
const evm = @import("evm");
const runner = @import("runner");
const test_utils = @import("test_utils");

const Hardfork = evm.Hardfork;

const fork_count = std.meta.fields(Hardfork).len;
const unknown_fork_idx = fork_count;
const bucket_count = fork_count + 1;

const ForkStats = struct {
    passed: usize = 0,
    failed: usize = 0,
    skipped: usize = 0,

    fn total(self: ForkStats) usize {
        return self.passed + self.failed + self.skipped;
    }

    fn merge(self: *ForkStats, other: ForkStats) void {
        self.passed += other.passed;
        self.failed += other.failed;
        self.skipped += other.skipped;
    }
};

const FailureRecord = struct {
    fork_idx: usize,
    file: []u8,
    name: []u8,
    err_name: []const u8,

    fn deinit(self: *FailureRecord, allocator: std.mem.Allocator) void {
        allocator.free(self.file);
        allocator.free(self.name);
    }
};

const DiscoveredFile = struct {
    full_path: []u8,
    rel_path: []u8,
    size: u64,
    dir_fork: ?Hardfork,

    fn deinit(self: *DiscoveredFile, allocator: std.mem.Allocator) void {
        allocator.free(self.full_path);
        allocator.free(self.rel_path);
    }
};

const ForkMask = std.StaticBitSet(fork_count);

const CliConfig = struct {
    dir: []const u8 = ".cache/eest-fixtures/current/fixtures/state_tests",
    jobs: usize = 0,
    include_forks: ForkMask = ForkMask.initEmpty(),
    has_include_forks: bool = false,
    exclude_forks: ForkMask = ForkMask.initEmpty(),
    filter: ?[]const u8 = null,
    json_output: bool = false,
    max_failures: usize = 0,
    show_failures: usize = 50,
    check_leaks: bool = false,

    fn allowsFork(self: CliConfig, hf: Hardfork) bool {
        const idx = @intFromEnum(hf);
        if (self.has_include_forks and !self.include_forks.isSet(idx)) return false;
        if (self.exclude_forks.isSet(idx)) return false;
        return true;
    }
};

const SharedState = struct {
    allocator: std.mem.Allocator,
    config: CliConfig,
    files: []const DiscoveredFile,
    next_file: std.atomic.Value(usize),
    failed_total: std.atomic.Value(usize),
    mutex: std.Thread.Mutex = .{},
    stats: [bucket_count]ForkStats = [_]ForkStats{.{}} ** bucket_count,
    failures: std.ArrayList(FailureRecord) = .{},
    parse_errors: usize = 0,

    fn shouldStop(self: *const SharedState) bool {
        return self.config.max_failures > 0 and self.failed_total.load(.monotonic) >= self.config.max_failures;
    }
};

pub fn main() !u8 {
    var gpa_impl = std.heap.GeneralPurposeAllocator(.{ .thread_safe = true }){};
    defer _ = gpa_impl.deinit();
    const allocator = gpa_impl.allocator();

    var config = CliConfig{};
    const parse_action = parseArgs(allocator, &config) catch |err| {
        std.debug.print("error: {s}\n", .{@errorName(err)});
        try printUsage(std.fs.File.stderr());
        return 2;
    };
    if (parse_action == .show_help) {
        try printUsage(std.fs.File.stdout());
        return 0;
    }
    defer if (config.filter) |f| allocator.free(f);
    defer if (!std.mem.eql(u8, config.dir, ".cache/eest-fixtures/current/fixtures/state_tests")) {
        allocator.free(config.dir);
    };

    const cpu_count = std.Thread.getCpuCount() catch 4;
    const jobs = if (config.jobs == 0) @max(cpu_count, 1) else config.jobs;

    // Pre-initialize Voltaire's embedded KZG trusted setup once on the main
    // thread before spawning workers (avoids first-call lock contention on 0x0a).
    try runner.initKzgTrustedSetup();

    const start_ns = std.time.nanoTimestamp();

    var files = std.ArrayList(DiscoveredFile){};
    defer {
        for (files.items) |*f| f.deinit(allocator);
        files.deinit(allocator);
    }

    try discoverJsonFiles(allocator, config, config.dir, "", null, &files);

    // Longest-processing-time-first scheduling reduces worker tail latency.
    std.mem.sort(DiscoveredFile, files.items, {}, struct {
        fn lessThan(_: void, a: DiscoveredFile, b: DiscoveredFile) bool {
            if (a.size != b.size) return a.size > b.size;
            return std.mem.order(u8, a.rel_path, b.rel_path) == .lt;
        }
    }.lessThan);

    var shared = SharedState{
        .allocator = allocator,
        .config = config,
        .files = files.items,
        .next_file = std.atomic.Value(usize).init(0),
        .failed_total = std.atomic.Value(usize).init(0),
    };
    defer {
        for (shared.failures.items) |*rec| rec.deinit(allocator);
        shared.failures.deinit(allocator);
    }

    const worker_count = @max(@min(jobs, @max(files.items.len, 1)), 1);
    if (worker_count == 1) {
        workerMain(&shared);
    } else {
        const threads = try allocator.alloc(std.Thread, worker_count);
        defer allocator.free(threads);

        var spawned: usize = 0;
        for (threads) |*t| {
            t.* = std.Thread.spawn(.{}, workerMain, .{&shared}) catch |err| {
                std.debug.print("warning: failed to spawn worker: {s}\n", .{@errorName(err)});
                break;
            };
            spawned += 1;
        }
        if (spawned == 0) {
            workerMain(&shared);
        } else {
            for (threads[0..spawned]) |t| t.join();
        }
    }

    const elapsed_ns: u64 = @intCast(@max(std.time.nanoTimestamp() - start_ns, 0));

    // Sort failures deterministically by fork, file, and test name.
    std.mem.sort(FailureRecord, shared.failures.items, {}, struct {
        fn lessThan(_: void, a: FailureRecord, b: FailureRecord) bool {
            if (a.fork_idx != b.fork_idx) return a.fork_idx < b.fork_idx;
            const file_ord = std.mem.order(u8, a.file, b.file);
            if (file_ord != .eq) return file_ord == .lt;
            return std.mem.order(u8, a.name, b.name) == .lt;
        }
    }.lessThan);

    var totals = ForkStats{};
    for (shared.stats) |s| totals.merge(s);

    var out = std.ArrayList(u8){};
    defer out.deinit(allocator);
    const writer = out.writer(allocator);

    if (config.json_output) {
        try writeJsonReport(writer, config, worker_count, files.items.len, elapsed_ns, &shared.stats, totals, shared.failures.items, shared.parse_errors);
    } else {
        try writeTableReport(writer, config, worker_count, files.items.len, elapsed_ns, &shared.stats, totals, shared.failures.items, shared.parse_errors);
    }
    try std.fs.File.stdout().writeAll(out.items);

    return if (totals.failed > 0 or shared.parse_errors > 0) 1 else 0;
}

const ParseAction = enum { run, show_help };

fn parseArgs(allocator: std.mem.Allocator, config: *CliConfig) !ParseAction {
    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();
    _ = args.skip();

    var dir_allocated = false;
    errdefer {
        if (dir_allocated) allocator.free(config.dir);
        if (config.filter) |f| allocator.free(f);
    }

    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "-h") or std.mem.eql(u8, arg, "--help")) {
            return .show_help;
        } else if (std.mem.eql(u8, arg, "--dir")) {
            const val = args.next() orelse return error.MissingDirArgument;
            if (dir_allocated) allocator.free(config.dir);
            config.dir = try allocator.dupe(u8, val);
            dir_allocated = true;
        } else if (std.mem.startsWith(u8, arg, "--dir=")) {
            if (dir_allocated) allocator.free(config.dir);
            config.dir = try allocator.dupe(u8, arg["--dir=".len..]);
            dir_allocated = true;
        } else if (std.mem.eql(u8, arg, "--jobs") or std.mem.eql(u8, arg, "-j")) {
            const val = args.next() orelse return error.MissingJobsArgument;
            config.jobs = @max(try std.fmt.parseInt(usize, val, 10), 1);
        } else if (std.mem.startsWith(u8, arg, "--jobs=")) {
            config.jobs = @max(try std.fmt.parseInt(usize, arg["--jobs=".len..], 10), 1);
        } else if (std.mem.eql(u8, arg, "--fork")) {
            const val = args.next() orelse return error.MissingForkArgument;
            try addForkList(val, &config.include_forks);
            config.has_include_forks = true;
        } else if (std.mem.startsWith(u8, arg, "--fork=")) {
            try addForkList(arg["--fork=".len..], &config.include_forks);
            config.has_include_forks = true;
        } else if (std.mem.eql(u8, arg, "--exclude-fork")) {
            const val = args.next() orelse return error.MissingExcludeForkArgument;
            try addForkList(val, &config.exclude_forks);
        } else if (std.mem.startsWith(u8, arg, "--exclude-fork=")) {
            try addForkList(arg["--exclude-fork=".len..], &config.exclude_forks);
        } else if (std.mem.eql(u8, arg, "--filter")) {
            const val = args.next() orelse return error.MissingFilterArgument;
            if (config.filter) |old| allocator.free(old);
            config.filter = try allocator.dupe(u8, val);
        } else if (std.mem.startsWith(u8, arg, "--filter=")) {
            if (config.filter) |old| allocator.free(old);
            config.filter = try allocator.dupe(u8, arg["--filter=".len..]);
        } else if (std.mem.eql(u8, arg, "--json")) {
            config.json_output = true;
        } else if (std.mem.eql(u8, arg, "--max-failures")) {
            const val = args.next() orelse return error.MissingMaxFailuresArgument;
            config.max_failures = try std.fmt.parseInt(usize, val, 10);
        } else if (std.mem.startsWith(u8, arg, "--max-failures=")) {
            config.max_failures = try std.fmt.parseInt(usize, arg["--max-failures=".len..], 10);
        } else if (std.mem.eql(u8, arg, "--show-failures")) {
            const val = args.next() orelse return error.MissingShowFailuresArgument;
            config.show_failures = try std.fmt.parseInt(usize, val, 10);
        } else if (std.mem.startsWith(u8, arg, "--show-failures=")) {
            config.show_failures = try std.fmt.parseInt(usize, arg["--show-failures=".len..], 10);
        } else if (std.mem.eql(u8, arg, "--check-leaks")) {
            config.check_leaks = true;
        } else {
            std.debug.print("unknown argument: {s}\n", .{arg});
            return error.UnknownArgument;
        }
    }
    return .run;
}

fn printUsage(file: std.fs.File) !void {
    try file.writeAll(
        \\Usage: eest-runner [OPTIONS]
        \\
        \\Parallel native runner for official Ethereum Execution Spec Tests (EEST) JSON fixtures.
        \\
        \\Options:
        \\  --dir <path>             Root directory containing *.json fixtures
        \\                           (default: .cache/eest-fixtures/current/fixtures/state_tests)
        \\  --jobs, -j <n>           Number of worker threads (default: CPU count)
        \\  --fork <name>            Run only this fork (repeatable or comma-separated)
        \\  --exclude-fork <name>    Skip this fork (repeatable or comma-separated, e.g. amsterdam)
        \\  --filter <pattern>       Pattern filter supporting .*, (a|b), [^...]
        \\  --json                   Output machine-readable JSON summary
        \\  --max-failures <n>       Stop scheduling after <n> failures (0 = unlimited)
        \\  --show-failures <n>      Max failure entries to print (default: 50, 0 = all)
        \\  --check-leaks            Use per-test GPA leak detection instead of arena reset
        \\  -h, --help               Show this help message
        \\
    );
}

fn addForkList(spec: []const u8, mask: *ForkMask) !void {
    var it = std.mem.splitScalar(u8, spec, ',');
    var count: usize = 0;
    while (it.next()) |raw| {
        const trimmed = std.mem.trim(u8, raw, " \t");
        if (trimmed.len == 0) continue;
        const hf = parseForkName(trimmed) orelse {
            std.debug.print("unknown fork name: '{s}'\n", .{trimmed});
            return error.UnknownFork;
        };
        mask.set(@intFromEnum(hf));
        count += 1;
    }
    if (count == 0) return error.UnknownFork;
}

fn parseForkName(raw: []const u8) ?Hardfork {
    if (Hardfork.fromString(raw)) |hf| return hf;

    var stripped = raw;
    if (std.ascii.startsWithIgnoreCase(stripped, "for_")) {
        stripped = stripped[4..];
    }

    var buf: [64]u8 = undefined;
    var n: usize = 0;
    for (stripped) |c| {
        if (c == '_' or c == '-' or c == ' ') continue;
        if (n >= buf.len) return null;
        buf[n] = std.ascii.toLower(c);
        n += 1;
    }
    const norm = buf[0..n];
    if (std.mem.eql(u8, norm, "frontier")) return .FRONTIER;
    if (std.mem.eql(u8, norm, "homestead")) return .HOMESTEAD;
    if (std.mem.eql(u8, norm, "dao")) return .DAO;
    if (std.mem.eql(u8, norm, "tangerinewhistle") or std.mem.eql(u8, norm, "eip150")) return .TANGERINE_WHISTLE;
    if (std.mem.eql(u8, norm, "spuriousdragon") or std.mem.eql(u8, norm, "eip158")) return .SPURIOUS_DRAGON;
    if (std.mem.eql(u8, norm, "byzantium")) return .BYZANTIUM;
    if (std.mem.eql(u8, norm, "constantinople")) return .CONSTANTINOPLE;
    if (std.mem.eql(u8, norm, "constantinoplefix") or std.mem.eql(u8, norm, "petersburg")) return .PETERSBURG;
    if (std.mem.eql(u8, norm, "istanbul")) return .ISTANBUL;
    if (std.mem.eql(u8, norm, "muirglacier")) return .MUIR_GLACIER;
    if (std.mem.eql(u8, norm, "berlin")) return .BERLIN;
    if (std.mem.eql(u8, norm, "london")) return .LONDON;
    if (std.mem.eql(u8, norm, "arrowglacier")) return .ARROW_GLACIER;
    if (std.mem.eql(u8, norm, "grayglacier")) return .GRAY_GLACIER;
    if (std.mem.eql(u8, norm, "paris") or std.mem.eql(u8, norm, "merge")) return .MERGE;
    if (std.mem.eql(u8, norm, "shanghai")) return .SHANGHAI;
    if (std.mem.eql(u8, norm, "cancun")) return .CANCUN;
    if (std.mem.eql(u8, norm, "prague")) return .PRAGUE;
    if (std.mem.eql(u8, norm, "osaka")) return .OSAKA;
    if (std.mem.eql(u8, norm, "amsterdam")) return .AMSTERDAM;
    return null;
}

fn forkDisplayName(idx: usize) []const u8 {
    if (idx == unknown_fork_idx) return "Unknown";
    const hf: Hardfork = @enumFromInt(idx);
    return switch (hf) {
        .FRONTIER => "Frontier",
        .HOMESTEAD => "Homestead",
        .DAO => "DAO",
        .TANGERINE_WHISTLE => "TangerineWhistle",
        .SPURIOUS_DRAGON => "SpuriousDragon",
        .BYZANTIUM => "Byzantium",
        .CONSTANTINOPLE => "Constantinople",
        .PETERSBURG => "ConstantinopleFix",
        .ISTANBUL => "Istanbul",
        .MUIR_GLACIER => "MuirGlacier",
        .BERLIN => "Berlin",
        .LONDON => "London",
        .ARROW_GLACIER => "ArrowGlacier",
        .GRAY_GLACIER => "GrayGlacier",
        .MERGE => "Paris",
        .SHANGHAI => "Shanghai",
        .CANCUN => "Cancun",
        .PRAGUE => "Prague",
        .OSAKA => "Osaka",
        .AMSTERDAM => "Amsterdam",
    };
}

fn discoverJsonFiles(
    allocator: std.mem.Allocator,
    config: CliConfig,
    full_dir: []const u8,
    rel_dir: []const u8,
    inherited_fork: ?Hardfork,
    out: *std.ArrayList(DiscoveredFile),
) !void {
    var dir = std.fs.cwd().openDir(full_dir, .{ .iterate = true }) catch |err| {
        std.debug.print("failed to open fixture directory '{s}': {s}\n", .{ full_dir, @errorName(err) });
        return err;
    };
    defer dir.close();

    var it = dir.iterate();
    while (try it.next()) |entry| {
        if (std.mem.eql(u8, entry.name, ".meta")) continue;

        const child_full = try std.fs.path.join(allocator, &.{ full_dir, entry.name });
        errdefer allocator.free(child_full);
        const child_rel = if (rel_dir.len == 0)
            try allocator.dupe(u8, entry.name)
        else
            try std.fs.path.join(allocator, &.{ rel_dir, entry.name });
        errdefer allocator.free(child_rel);

        switch (entry.kind) {
            .directory, .sym_link => {
                // Only prune top-level `for_<fork>` directories when `<fork>` resolves
                // directly to a known fork (transition dirs like for_cancuntopragueattime15k
                // return null and are inspected via their JSON post keys).
                var sub_fork = inherited_fork;
                if (sub_fork == null and std.ascii.startsWithIgnoreCase(entry.name, "for_")) {
                    if (parseForkName(entry.name)) |dir_hf| {
                        if (!config.allowsFork(dir_hf)) {
                            allocator.free(child_full);
                            allocator.free(child_rel);
                            continue;
                        }
                        sub_fork = dir_hf;
                    }
                }
                if (entry.kind == .sym_link) {
                    const st = dir.statFile(entry.name) catch {
                        allocator.free(child_full);
                        allocator.free(child_rel);
                        continue;
                    };
                    if (st.kind != .directory) {
                        if (st.kind == .file and std.mem.endsWith(u8, entry.name, ".json")) {
                            try out.append(allocator, .{
                                .full_path = child_full,
                                .rel_path = child_rel,
                                .size = st.size,
                                .dir_fork = sub_fork,
                            });
                            continue;
                        }
                        allocator.free(child_full);
                        allocator.free(child_rel);
                        continue;
                    }
                }
                try discoverJsonFiles(allocator, config, child_full, child_rel, sub_fork, out);
                allocator.free(child_full);
                allocator.free(child_rel);
            },
            .file => {
                if (!std.mem.endsWith(u8, entry.name, ".json")) {
                    allocator.free(child_full);
                    allocator.free(child_rel);
                    continue;
                }
                const st = dir.statFile(entry.name) catch null;
                try out.append(allocator, .{
                    .full_path = child_full,
                    .rel_path = child_rel,
                    .size = if (st) |s| s.size else 0,
                    .dir_fork = inherited_fork,
                });
            },
            else => {
                allocator.free(child_full);
                allocator.free(child_rel);
            },
        }
    }
}

fn detectCaseFork(test_case: std.json.Value, fallback: ?Hardfork) ?Hardfork {
    if (test_case != .object) return fallback;
    if (test_case.object.get("network")) |net| {
        if (net == .string) {
            if (parseForkName(net.string)) |hf| return hf;
        }
    }
    if (test_case.object.get("post")) |post| {
        if (post == .object) {
            var it = post.object.iterator();
            while (it.next()) |kv| {
                if (parseForkName(kv.key_ptr.*)) |hf| return hf;
            }
        }
    }
    return fallback;
}

fn workerMain(shared: *SharedState) void {
    var local_stats = [_]ForkStats{.{}} ** bucket_count;
    var local_parse_errors: usize = 0;

    var file_arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer file_arena.deinit();

    var case_arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer case_arena.deinit();

    while (!shared.shouldStop()) {
        const idx = shared.next_file.fetchAdd(1, .monotonic);
        if (idx >= shared.files.len) break;

        const file_info = shared.files[idx];
        _ = file_arena.reset(.{ .retain_with_limit = 16 * 1024 * 1024 });
        const file_alloc = file_arena.allocator();

        const content = std.fs.cwd().readFileAlloc(file_alloc, file_info.full_path, 256 * 1024 * 1024) catch |err| {
            local_parse_errors += 1;
            recordFailure(shared, forkIndex(file_info.dir_fork), file_info.rel_path, "<read>", @errorName(err));
            continue;
        };

        const parsed = std.json.parseFromSlice(std.json.Value, file_alloc, content, .{
            .duplicate_field_behavior = .use_last,
        }) catch |err| {
            local_parse_errors += 1;
            recordFailure(shared, forkIndex(file_info.dir_fork), file_info.rel_path, "<json>", @errorName(err));
            continue;
        };

        if (parsed.value != .object) continue;

        var case_it = parsed.value.object.iterator();
        while (case_it.next()) |kv| {
            if (shared.shouldStop()) break;

            const test_name = kv.key_ptr.*;
            const test_case = kv.value_ptr.*;

            const detected_fork = detectCaseFork(test_case, file_info.dir_fork);
            if (detected_fork) |hf| {
                if (!shared.config.allowsFork(hf)) continue;
            } else if (shared.config.has_include_forks) {
                continue;
            }

            if (shared.config.filter) |pattern| {
                const haystack = std.fmt.allocPrint(file_alloc, "{s}::{s}", .{ file_info.rel_path, test_name }) catch continue;
                if (!test_utils.matchesFilter(haystack, pattern)) continue;
            }

            const fidx = forkIndex(detected_fork);
            const run_result = runSingleCase(shared.config.check_leaks, &case_arena, test_case, file_info.full_path, test_name);
            if (run_result) |_| {
                local_stats[fidx].passed += 1;
            } else |err| {
                if (err == error.SkipZigTest) {
                    local_stats[fidx].skipped += 1;
                } else {
                    local_stats[fidx].failed += 1;
                    _ = shared.failed_total.fetchAdd(1, .monotonic);
                    recordFailure(shared, fidx, file_info.rel_path, test_name, @errorName(err));
                }
            }
        }
    }

    shared.mutex.lock();
    defer shared.mutex.unlock();
    for (&shared.stats, local_stats) |*dst, src| {
        dst.merge(src);
    }
    shared.parse_errors += local_parse_errors;
}

fn runSingleCase(
    check_leaks: bool,
    case_arena: *std.heap.ArenaAllocator,
    test_case: std.json.Value,
    full_path: []const u8,
    test_name: []const u8,
) anyerror!void {
    if (check_leaks) {
        var gpa = std.heap.GeneralPurposeAllocator(.{ .thread_safe = false }){};
        const res = runner.runJsonTestWithPathAndName(gpa.allocator(), test_case, full_path, test_name);
        const leak_status = gpa.deinit();
        try res;
        if (leak_status == .leak) return error.MemoryLeakDetected;
        return;
    }
    _ = case_arena.reset(.{ .retain_with_limit = 4 * 1024 * 1024 });
    return runner.runJsonTestWithPathAndName(case_arena.allocator(), test_case, full_path, test_name);
}

fn forkIndex(hf: ?Hardfork) usize {
    return if (hf) |f| @intFromEnum(f) else unknown_fork_idx;
}

fn recordFailure(
    shared: *SharedState,
    fidx: usize,
    rel_path: []const u8,
    test_name: []const u8,
    err_name: []const u8,
) void {
    shared.mutex.lock();
    defer shared.mutex.unlock();

    const cap = if (shared.config.max_failures > 0)
        shared.config.max_failures
    else if (shared.config.show_failures > 0)
        shared.config.show_failures
    else
        std.math.maxInt(usize);

    if (shared.failures.items.len >= cap) return;

    const file_copy = shared.allocator.dupe(u8, rel_path) catch return;
    const name_copy = shared.allocator.dupe(u8, test_name) catch {
        shared.allocator.free(file_copy);
        return;
    };
    shared.failures.append(shared.allocator, .{
        .fork_idx = fidx,
        .file = file_copy,
        .name = name_copy,
        .err_name = err_name,
    }) catch {
        shared.allocator.free(file_copy);
        shared.allocator.free(name_copy);
    };
}

fn writeTableReport(
    writer: anytype,
    config: CliConfig,
    worker_count: usize,
    file_count: usize,
    elapsed_ns: u64,
    stats: *const [bucket_count]ForkStats,
    totals: ForkStats,
    failures: []const FailureRecord,
    parse_errors: usize,
) !void {
    try writer.print("\n{s:<20} {s:>9} {s:>9} {s:>9} {s:>9} {s:>10}\n", .{
        "Fork",
        "Passed",
        "Failed",
        "Skipped",
        "Total",
        "Pass Rate",
    });
    try writer.print("{s}\n", .{"-" ** 71});

    for (stats, 0..) |s, idx| {
        if (s.total() == 0) continue;
        const executed = s.passed + s.failed;
        const pct: f64 = if (executed == 0) 100.0 else (@as(f64, @floatFromInt(s.passed)) * 100.0) / @as(f64, @floatFromInt(executed));
        try writer.print("{s:<20} {d:>9} {d:>9} {d:>9} {d:>9} {d:>9.2}%\n", .{
            forkDisplayName(idx),
            s.passed,
            s.failed,
            s.skipped,
            s.total(),
            pct,
        });
    }

    try writer.print("{s}\n", .{"-" ** 71});
    const total_executed = totals.passed + totals.failed;
    const total_pct: f64 = if (total_executed == 0) 100.0 else (@as(f64, @floatFromInt(totals.passed)) * 100.0) / @as(f64, @floatFromInt(total_executed));
    try writer.print("{s:<20} {d:>9} {d:>9} {d:>9} {d:>9} {d:>9.2}%\n", .{
        "TOTAL",
        totals.passed,
        totals.failed,
        totals.skipped,
        totals.total(),
        total_pct,
    });

    const elapsed_s = @as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0;
    try writer.print("\nElapsed: {d:.2}s ({d} threads, {d} files, dir={s})\n", .{
        elapsed_s,
        worker_count,
        file_count,
        config.dir,
    });
    if (parse_errors > 0) {
        try writer.print("Parse/IO errors: {d}\n", .{parse_errors});
    }

    if (failures.len > 0) {
        try writer.print("\nFailures (showing {d} of {d}):\n", .{ failures.len, totals.failed + parse_errors });
        for (failures, 0..) |f, i| {
            try writer.print("  {d}. [{s}] {s} :: {s} -> {s}\n", .{
                i + 1,
                forkDisplayName(f.fork_idx),
                f.file,
                f.name,
                f.err_name,
            });
        }
    }
}

fn writeJsonString(writer: anytype, s: []const u8) !void {
    try writer.writeByte('"');
    for (s) |c| {
        switch (c) {
            '"' => try writer.writeAll("\\\""),
            '\\' => try writer.writeAll("\\\\"),
            '\n' => try writer.writeAll("\\n"),
            '\r' => try writer.writeAll("\\r"),
            '\t' => try writer.writeAll("\\t"),
            else => {
                if (c < 0x20) {
                    try writer.print("\\u{x:0>4}", .{c});
                } else {
                    try writer.writeByte(c);
                }
            },
        }
    }
    try writer.writeByte('"');
}

fn writeJsonReport(
    writer: anytype,
    config: CliConfig,
    worker_count: usize,
    file_count: usize,
    elapsed_ns: u64,
    stats: *const [bucket_count]ForkStats,
    totals: ForkStats,
    failures: []const FailureRecord,
    parse_errors: usize,
) !void {
    const elapsed_ms = @as(f64, @floatFromInt(elapsed_ns)) / 1_000_000.0;
    try writer.writeAll("{\"success\":");
    try writer.writeAll(if (totals.failed == 0 and parse_errors == 0) "true" else "false");
    try writer.writeAll(",\"dir\":");
    try writeJsonString(writer, config.dir);
    try writer.print(",\"jobs\":{d},\"files\":{d},\"elapsed_ms\":{d:.2},\"parse_errors\":{d}", .{
        worker_count,
        file_count,
        elapsed_ms,
        parse_errors,
    });
    try writer.print(",\"totals\":{{\"passed\":{d},\"failed\":{d},\"skipped\":{d},\"total\":{d}}}", .{
        totals.passed,
        totals.failed,
        totals.skipped,
        totals.total(),
    });

    try writer.writeAll(",\"forks\":[");
    var first_fork = true;
    for (stats, 0..) |s, idx| {
        if (s.total() == 0) continue;
        if (!first_fork) try writer.writeByte(',');
        first_fork = false;
        try writer.writeAll("{\"fork\":");
        try writeJsonString(writer, forkDisplayName(idx));
        try writer.print(",\"passed\":{d},\"failed\":{d},\"skipped\":{d},\"total\":{d}}}", .{
            s.passed,
            s.failed,
            s.skipped,
            s.total(),
        });
    }

    try writer.writeAll("],\"failures\":[");
    for (failures, 0..) |f, i| {
        if (i > 0) try writer.writeByte(',');
        try writer.writeAll("{\"fork\":");
        try writeJsonString(writer, forkDisplayName(f.fork_idx));
        try writer.writeAll(",\"file\":");
        try writeJsonString(writer, f.file);
        try writer.writeAll(",\"name\":");
        try writeJsonString(writer, f.name);
        try writer.writeAll(",\"error\":");
        try writeJsonString(writer, f.err_name);
        try writer.writeByte('}');
    }
    try writer.writeAll("]}\n");
}
