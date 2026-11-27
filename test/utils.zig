const std = @import("std");
const builtin = @import("builtin");

// ANSI color codes and styles
pub const Color = struct {
    pub const reset = "\x1b[0m";
    pub const bold = "\x1b[1m";
    pub const dim = "\x1b[2m";
    pub const italic = "\x1b[3m";
    pub const underline = "\x1b[4m";

    pub const black = "\x1b[30m";
    pub const red = "\x1b[31m";
    pub const green = "\x1b[32m";
    pub const yellow = "\x1b[33m";
    pub const blue = "\x1b[34m";
    pub const magenta = "\x1b[35m";
    pub const cyan = "\x1b[36m";
    pub const white = "\x1b[37m";
    pub const gray = "\x1b[90m";
    pub const bright_red = "\x1b[91m";
    pub const bright_green = "\x1b[92m";
    pub const bright_yellow = "\x1b[93m";
    pub const bright_blue = "\x1b[94m";
    pub const bright_magenta = "\x1b[95m";
    pub const bright_cyan = "\x1b[96m";

    // Background colors
    pub const bg_red = "\x1b[41m";
    pub const bg_green = "\x1b[42m";
    pub const bg_yellow = "\x1b[43m";
    pub const bg_blue = "\x1b[44m";
    pub const bg_magenta = "\x1b[45m";
    pub const bg_cyan = "\x1b[46m";
    pub const bg_white = "\x1b[47m";
    pub const bg_gray = "\x1b[100m";
    pub const bg_bright_red = "\x1b[101m";
    pub const bg_bright_green = "\x1b[102m";
};

pub const Icons = struct {
    pub const check = "✓";
    pub const cross = "✖";
    pub const dot = "·";
    pub const arrow = "›";
    pub const pointer = "❯";
    pub const info = "ℹ";
    pub const warning = "⚠";
    pub const error_icon = "⨯";
    pub const clock = "⏱";
    pub const filter_icon = "🔍";
};

pub const TestResult = struct {
    name: []const u8,
    suite: []const u8,
    test_name: []const u8,
    passed: bool,
    todo: bool = false,
    /// The test returned error.SkipZigTest. Skipped tests also set `passed`.
    skipped: bool = false,
    error_msg: ?[]const u8,
    duration_ns: u64,
    file_path: ?[]const u8 = null,
    line_number: ?u32 = null,
};

pub fn extractSuiteName(full_name: []const u8) []const u8 {
    // Find the last occurrence of ".test."
    var last_test_pos: ?usize = null;
    var i: usize = 0;
    while (i + 6 <= full_name.len) : (i += 1) {
        if (std.mem.eql(u8, full_name[i .. i + 6], ".test.")) {
            last_test_pos = i;
        }
    }

    if (last_test_pos) |pos| {
        return full_name[0..pos];
    }

    // Fallback: find last dot
    if (std.mem.lastIndexOf(u8, full_name, ".")) |pos| {
        return full_name[0..pos];
    }

    return full_name;
}

pub fn extractTestName(full_name: []const u8) []const u8 {
    // Find the last occurrence of ".test."
    var last_test_pos: ?usize = null;
    var i: usize = 0;
    while (i + 6 <= full_name.len) : (i += 1) {
        if (std.mem.eql(u8, full_name[i .. i + 6], ".test.")) {
            last_test_pos = i + 6;
        }
    }

    if (last_test_pos) |pos| {
        return full_name[pos..];
    }

    // Fallback: find last dot
    if (std.mem.lastIndexOf(u8, full_name, ".")) |pos| {
        return full_name[pos + 1 ..];
    }

    return full_name;
}

pub fn formatDuration(writer: anytype, ns: u64) !void {
    if (ns < 1_000) {
        try std.fmt.format(writer, "{s}{d} ns{s}", .{ Color.gray, ns, Color.reset });
    } else if (ns < 1_000_000) {
        try std.fmt.format(writer, "{s}{d:.2} μs{s}", .{ Color.gray, @as(f64, @floatFromInt(ns)) / 1_000.0, Color.reset });
    } else if (ns < 1_000_000_000) {
        try std.fmt.format(writer, "{s}{d:.2} ms{s}", .{ Color.gray, @as(f64, @floatFromInt(ns)) / 1_000_000.0, Color.reset });
    } else {
        try std.fmt.format(writer, "{s}{d:.2} s{s}", .{ Color.yellow, @as(f64, @floatFromInt(ns)) / 1_000_000_000.0, Color.reset });
    }
}

pub fn clearLine(writer: anytype) !void {
    try std.fmt.format(writer, "\r\x1b[K", .{});
}

pub fn clearScreen(writer: anytype) !void {
    try std.fmt.format(writer, "\x1b[2J\x1b[H", .{});
}

pub fn moveCursorUp(writer: anytype, lines: usize) !void {
    try std.fmt.format(writer, "\x1b[{d}A", .{lines});
}

pub fn printProgress(writer: anytype, current: usize, total: usize, suite_name: []const u8) !void {
    try clearLine(writer);
    const percent = (current * 100) / total;

    // Progress bar
    const bar_width = 20;
    const filled = (current * bar_width) / total;

    try std.fmt.format(writer, " {s}⠙{s} ", .{ Color.cyan, Color.reset });

    // Progress bar
    try std.fmt.format(writer, "{s}[{s}", .{ Color.dim, Color.reset });
    for (0..bar_width) |i| {
        if (i < filled) {
            try std.fmt.format(writer, "{s}━{s}", .{ Color.bright_cyan, Color.reset });
        } else {
            try std.fmt.format(writer, "{s}━{s}", .{ Color.gray, Color.reset });
        }
    }
    try std.fmt.format(writer, "{s}]{s} ", .{ Color.dim, Color.reset });

    try std.fmt.format(writer, "{s}{d}%{s} ", .{ Color.bright_cyan, percent, Color.reset });
    try std.fmt.format(writer, "{s}|{s} ", .{ Color.dim, Color.reset });
    try std.fmt.format(writer, "{s}{s}{s}", .{ Color.gray, suite_name, Color.reset });
    try std.fmt.format(writer, " {s}[{d}/{d}]{s}", .{ Color.dim, current, total, Color.reset });
}

/// Exit codes a forked test child reports to the parent.
pub const ChildExit = struct {
    pub const pass: u8 = 0;
    pub const fail: u8 = 1;
    pub const leak: u8 = 2;
    pub const skip: u8 = 3;
};

/// Maps a test function's error to a child exit code.
/// error.SkipZigTest is a skip, not a failure.
pub fn errorExitCode(err: anyerror) u8 {
    return if (err == error.SkipZigTest) ChildExit.skip else ChildExit.fail;
}

/// Records the outcome for `exit_code` in `result`.
pub fn applyExitCode(allocator: std.mem.Allocator, result: *TestResult, exit_code: u8) !void {
    switch (exit_code) {
        ChildExit.pass => result.passed = true,
        ChildExit.skip => {
            result.passed = true;
            result.skipped = true;
        },
        ChildExit.fail => {
            result.passed = false;
            result.error_msg = try allocator.dupe(u8, "test failed");
        },
        ChildExit.leak => {
            result.passed = false;
            result.error_msg = try allocator.dupe(u8, "memory leak detected");
        },
        else => {
            result.passed = false;
            result.error_msg = try std.fmt.allocPrint(allocator, "exited with code {d}", .{exit_code});
        },
    }
}

/// Runs `func` with a fresh testing allocator and returns its exit code.
fn runTestFunction(name: []const u8, func: *const fn () anyerror!void) u8 {
    std.testing.allocator_instance = .{};
    const exit_code: u8 = if (func()) |_| ChildExit.pass else |err| blk: {
        if (err != error.SkipZigTest) std.debug.print("{s}: {s}\n", .{ name, @errorName(err) });
        break :blk errorExitCode(err);
    };
    const leaked = std.testing.allocator_instance.deinit() == .leak;
    if (exit_code == ChildExit.pass and leaked) return ChildExit.leak;
    return exit_code;
}

/// A worker count of 0 would schedule tests on no thread, so clamp to >= 1.
/// Unparseable values fall back to `default_count`.
pub fn parseWorkerCount(env_value: ?[]const u8, default_count: usize) usize {
    const requested = if (env_value) |value|
        std.fmt.parseInt(usize, value, 10) catch default_count
    else
        default_count;
    return @max(requested, 1);
}

pub fn runTestInProcess(allocator: std.mem.Allocator, test_index: usize) !TestResult {
    const t = builtin.test_functions[test_index];
    const suite_name = extractSuiteName(t.name);
    const test_name = extractTestName(t.name);

    var test_result = TestResult{
        .name = t.name,
        .suite = suite_name,
        .test_name = test_name,
        .passed = true,
        .error_msg = null,
        .duration_ns = 0,
    };

    const test_start = std.time.nanoTimestamp();

    // TEST_NOFORK=1 runs the test in this process so panics print full
    // traces. The runner then continues with the next test.
    if (std.posix.getenv("TEST_NOFORK") != null) {
        const exit_code = runTestFunction(t.name, t.func);
        test_result.duration_ns = @intCast(std.time.nanoTimestamp() - test_start);
        try applyExitCode(allocator, &test_result, exit_code);
        return test_result;
    }

    // Fork to isolate test execution. A failed fork is a failed test, not a
    // runner error, so the parallel scheduler always records an outcome.
    const pid = std.posix.fork() catch |err| {
        test_result.passed = false;
        test_result.error_msg = try std.fmt.allocPrint(allocator, "fork failed: {s}", .{@errorName(err)});
        return test_result;
    };

    if (pid == 0) {
        std.posix.exit(runTestFunction(t.name, t.func));
    }

    // Parent process - wait for child with 60 second timeout
    const timeout_ns: i128 = 60 * std.time.ns_per_s;
    const deadline = std.time.nanoTimestamp() + timeout_ns;

    var timed_out = false;
    var wait_result: std.posix.WaitPidResult = undefined;

    while (true) {
        // Try non-blocking wait
        wait_result = std.posix.waitpid(pid, std.posix.W.NOHANG);

        // Check if child has exited
        if (wait_result.pid == pid) {
            break;
        }

        // Check timeout
        const now = std.time.nanoTimestamp();
        if (now >= deadline) {
            // Timeout - kill the child process
            std.posix.kill(pid, std.posix.SIG.KILL) catch |err| {
                // If we can't kill the process, report it but continue cleanup
                std.debug.print("Warning: Failed to kill timed-out test process {d}: {}\n", .{ pid, err });
            };
            _ = std.posix.waitpid(pid, 0); // Clean up zombie
            timed_out = true;
            break;
        }

        // Sleep a bit before checking again
        std.Thread.sleep(3 * std.time.ns_per_ms);
    }

    const test_end = std.time.nanoTimestamp();
    test_result.duration_ns = @intCast(test_end - test_start);

    if (timed_out) {
        test_result.passed = false;
        test_result.error_msg = try allocator.dupe(u8, "test timeout (60s)");
    } else if (std.posix.W.IFEXITED(wait_result.status)) {
        try applyExitCode(allocator, &test_result, std.posix.W.EXITSTATUS(wait_result.status));
    } else if (std.posix.W.IFSIGNALED(wait_result.status)) {
        const signal = std.posix.W.TERMSIG(wait_result.status);
        test_result.passed = false;
        test_result.error_msg = try std.fmt.allocPrint(allocator, "crashed with signal {d}", .{signal});
    } else {
        test_result.passed = false;
        test_result.error_msg = try allocator.dupe(u8, "abnormal termination");
    }

    return test_result;
}

pub fn displayResults(writer: anytype, allocator: std.mem.Allocator, results: []TestResult) !void {
    // Group results by suite
    var suite_map = std.StringHashMap(std.ArrayList(TestResult)).init(allocator);
    defer {
        var it = suite_map.iterator();
        while (it.next()) |entry| {
            entry.value_ptr.deinit(allocator);
        }
        suite_map.deinit();
    }

    for (results) |result| {
        const entry = try suite_map.getOrPut(result.suite);
        if (!entry.found_existing) {
            entry.value_ptr.* = .{};
        }
        try entry.value_ptr.append(allocator, result);
    }

    // Sort suites
    var suites: std.ArrayList([]const u8) = .{};
    defer suites.deinit(allocator);
    var suite_iter = suite_map.iterator();
    while (suite_iter.next()) |entry| {
        try suites.append(allocator, entry.key_ptr.*);
    }
    std.mem.sort([]const u8, suites.items, {}, struct {
        fn lessThan(_: void, a: []const u8, b: []const u8) bool {
            return std.mem.order(u8, a, b) == .lt;
        }
    }.lessThan);

    var passed_count: u32 = 0;
    var failed_count: u32 = 0;
    var todo_count: u32 = 0;
    var skipped_count: u32 = 0;
    var failed_tests = std.ArrayListUnmanaged(TestResult){};
    defer failed_tests.deinit(allocator);

    try std.fmt.format(writer, "\n{s}─────────────────────────────────────────{s}\n", .{ Color.dim, Color.reset });
    try std.fmt.format(writer, " {s}Test Results{s}\n", .{ Color.bold, Color.reset });
    try std.fmt.format(writer, "{s}─────────────────────────────────────────{s}\n\n", .{ Color.dim, Color.reset });

    for (suites.items) |suite| {
        const tests = suite_map.get(suite).?;

        var suite_passed: u32 = 0;
        var suite_failed: u32 = 0;
        var suite_todo: u32 = 0;
        var suite_duration: u64 = 0;

        for (tests.items) |t| {
            suite_duration += t.duration_ns;
            if (t.todo) {
                suite_todo += 1;
                todo_count += 1;
            } else if (t.skipped) {
                skipped_count += 1;
            } else if (t.passed) {
                suite_passed += 1;
                passed_count += 1;
            } else {
                suite_failed += 1;
                failed_count += 1;
                try failed_tests.append(allocator, t);
            }
        }

        // Print suite header
        if (suite_failed > 0) {
            try std.fmt.format(writer, " {s}{s} FAIL {s} {s}{s}{s} ", .{
                Color.bg_red,
                Color.white,
                Color.reset,
                Color.white,
                suite,
                Color.reset,
            });
        } else if (suite_todo > 0 and suite_passed == 0) {
            try std.fmt.format(writer, " {s}{s} TODO {s} {s}{s}{s} ", .{
                Color.bg_yellow,
                Color.black,
                Color.reset,
                Color.yellow,
                suite,
                Color.reset,
            });
        } else {
            try std.fmt.format(writer, " {s}{s}{s} {s}{s}{s} ", .{
                Color.green,
                Icons.check,
                Color.reset,
                Color.dim,
                suite,
                Color.reset,
            });
        }

        // Print test counts
        if (suite_failed > 0) {
            try std.fmt.format(writer, "{s}{d} failed{s}", .{
                Color.red,
                suite_failed,
                Color.reset,
            });
            if (suite_passed > 0) {
                try std.fmt.format(writer, " {s}|{s} {s}{d} passed{s}", .{
                    Color.dim,
                    Color.reset,
                    Color.green,
                    suite_passed,
                    Color.reset,
                });
            }
            if (suite_todo > 0) {
                try std.fmt.format(writer, " {s}|{s} {s}{d} todo{s}", .{
                    Color.dim,
                    Color.reset,
                    Color.yellow,
                    suite_todo,
                    Color.reset,
                });
            }
        } else if (suite_todo > 0) {
            try std.fmt.format(writer, "{s}{d} todo{s}", .{
                Color.yellow,
                suite_todo,
                Color.reset,
            });
            if (suite_passed > 0) {
                try std.fmt.format(writer, " {s}|{s} {s}{d} passed{s}", .{
                    Color.dim,
                    Color.reset,
                    Color.green,
                    suite_passed,
                    Color.reset,
                });
            }
        } else {
            try std.fmt.format(writer, "{s}({d}){s}", .{
                Color.green,
                suite_passed,
                Color.reset,
            });
        }

        try std.fmt.format(writer, " ", .{});
        try formatDuration(writer, suite_duration);
        try std.fmt.format(writer, "\n", .{});

        // Print all test names with pass/fail status on same line
        for (tests.items) |t| {
            if (t.todo) {
                try std.fmt.format(writer, "   {s}{s} {s}(TODO){s}\n", .{
                    Color.yellow,
                    t.test_name,
                    Color.yellow,
                    Color.reset,
                });
            } else if (t.skipped) {
                try std.fmt.format(writer, "   {s}{s} {s}(SKIP){s}\n", .{
                    Color.gray,
                    t.test_name,
                    Color.dim,
                    Color.reset,
                });
            } else if (t.passed) {
                try std.fmt.format(writer, "   {s}{s}{s} {s}\n", .{
                    Color.green,
                    Icons.check,
                    Color.reset,
                    t.test_name,
                });
            } else {
                try std.fmt.format(writer, "   {s}{s}{s} {s}\n", .{
                    Color.red,
                    Icons.cross,
                    Color.reset,
                    t.test_name,
                });
            }
        }
    }

    // Print detailed failure information
    if (failed_tests.items.len > 0) {
        try std.fmt.format(writer, "\n{s}⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯{s}\n", .{
            Color.red,
            Color.reset,
        });
        try std.fmt.format(writer, " {s}Failed Tests {d}{s}\n", .{
            Color.red,
            failed_tests.items.len,
            Color.reset,
        });
        try std.fmt.format(writer, "{s}⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯{s}\n\n", .{
            Color.red,
            Color.reset,
        });

        for (failed_tests.items, 0..) |fail, idx| {
            try std.fmt.format(writer, " {s}FAIL{s} {s}{s} {s}{s}{s}{s}\n", .{
                Color.bg_bright_red,
                Color.reset,
                Color.white,
                Icons.arrow,
                Color.reset,
                Color.bright_yellow,
                fail.name,
                Color.reset,
            });

            if (fail.error_msg) |msg| {
                try std.fmt.format(writer, "\n", .{});
                var lines = std.mem.tokenizeScalar(u8, msg, '\n');
                while (lines.next()) |line| {
                    try std.fmt.format(writer, "      {s}{s} {s}{s}{s}\n", .{
                        Color.red,
                        Icons.cross,
                        Color.reset,
                        line,
                        Color.reset,
                    });
                }
            }

            if (idx < failed_tests.items.len - 1) {
                try std.fmt.format(writer, "\n", .{});
            }
        }
    }

    // Print summary
    try std.fmt.format(writer, "\n{s}─────────────────────────────────────────{s}\n", .{ Color.dim, Color.reset });
    try std.fmt.format(writer, " {s}Summary{s}\n", .{ Color.bold, Color.reset });

    if (failed_count > 0) {
        try std.fmt.format(writer, "   {s}Tests:{s}  {s}{d} failed{s}", .{
            Color.bold,
            Color.reset,
            Color.red,
            failed_count,
            Color.reset,
        });
        if (passed_count > 0) {
            try std.fmt.format(writer, " {s}|{s} {s}{d} passed{s}", .{
                Color.dim,
                Color.reset,
                Color.green,
                passed_count,
                Color.reset,
            });
        }
        if (todo_count > 0) {
            try std.fmt.format(writer, " {s}|{s} {s}{d} todo{s}", .{
                Color.dim,
                Color.reset,
                Color.yellow,
                todo_count,
                Color.reset,
            });
        }
    } else {
        try std.fmt.format(writer, "   {s}Tests:{s}  {s}{d} passed{s}", .{
            Color.bold,
            Color.reset,
            Color.green,
            passed_count,
            Color.reset,
        });
        if (todo_count > 0) {
            try std.fmt.format(writer, " {s}|{s} {s}{d} todo{s}", .{
                Color.dim,
                Color.reset,
                Color.yellow,
                todo_count,
                Color.reset,
            });
        }
    }
    if (skipped_count > 0) {
        try std.fmt.format(writer, " {s}|{s} {s}{d} skipped{s}", .{
            Color.dim,
            Color.reset,
            Color.gray,
            skipped_count,
            Color.reset,
        });
    }
    try std.fmt.format(writer, " {s}({d}){s}\n", .{
        Color.dim,
        results.len,
        Color.reset,
    });
    try std.fmt.format(writer, "{s}─────────────────────────────────────────{s}\n", .{ Color.dim, Color.reset });
}

const FilterNfa = struct {
    const max_states: usize = 512;
    const max_depth: usize = 16;

    const State = union(enum) {
        literal: struct { byte: u8, next: u16 },
        any: struct { next: u16 },
        neg_class: struct { start: u16, end: u16, next: u16 },
        jump: u16,
        split: struct { a: u16, b: u16 },
        accept,
    };

    const Fragment = struct {
        start: u16,
        end: u16,
    };

    const StateSet = std.StaticBitSet(max_states);

    pattern: []const u8,
    states: [max_states]State = undefined,
    len: u16 = 0,

    fn addState(self: *FilterNfa, state: State) error{PatternTooComplex}!u16 {
        if (self.len >= max_states) return error.PatternTooComplex;
        const idx = self.len;
        self.states[idx] = state;
        self.len += 1;
        return idx;
    }

    fn compile(pattern: []const u8) error{PatternTooComplex}!struct { nfa: FilterNfa, start: u16 } {
        var nfa = FilterNfa{ .pattern = pattern };
        var pos: usize = 0;
        const frag = try nfa.parseAlternation(&pos, 0, false);
        return .{ .nfa = nfa, .start = frag.start };
    }

    fn parseAlternation(self: *FilterNfa, pos: *usize, depth: usize, in_group: bool) error{PatternTooComplex}!Fragment {
        var branch = try self.parseConcat(pos, depth, in_group);
        while (pos.* < self.pattern.len and self.pattern[pos.*] == '|') {
            pos.* += 1;
            const rhs = try self.parseConcat(pos, depth, in_group);
            const end = try self.addState(.accept);
            self.states[branch.end] = .{ .jump = end };
            self.states[rhs.end] = .{ .jump = end };
            const start = try self.addState(.{ .split = .{ .a = branch.start, .b = rhs.start } });
            branch = .{ .start = start, .end = end };
        }
        return branch;
    }

    fn parseConcat(self: *FilterNfa, pos: *usize, depth: usize, in_group: bool) error{PatternTooComplex}!Fragment {
        var current: ?Fragment = null;
        while (pos.* < self.pattern.len) {
            const c = self.pattern[pos.*];
            if (c == '|') break;
            if (in_group and c == ')') break;

            const frag = try self.parseAtom(pos, depth);
            if (current) |prev| {
                self.states[prev.end] = .{ .jump = frag.start };
                current = .{ .start = prev.start, .end = frag.end };
            } else {
                current = frag;
            }
        }
        if (current) |frag| return frag;
        const empty = try self.addState(.accept);
        return .{ .start = empty, .end = empty };
    }

    fn parseAtom(self: *FilterNfa, pos: *usize, depth: usize) error{PatternTooComplex}!Fragment {
        const c = self.pattern[pos.*];
        if (c == '.' and pos.* + 1 < self.pattern.len and self.pattern[pos.* + 1] == '*') {
            pos.* += 2;
            const end = try self.addState(.accept);
            const split = try self.addState(.{ .split = .{ .a = 0, .b = end } });
            const any = try self.addState(.{ .any = .{ .next = split } });
            self.states[split].split.a = any;
            return .{ .start = split, .end = end };
        }
        if (c == '(' and hasMatchingCloseParen(self.pattern, pos.*)) {
            if (depth >= max_depth) return error.PatternTooComplex;
            pos.* += 1;
            const inner = try self.parseAlternation(pos, depth + 1, true);
            if (pos.* < self.pattern.len and self.pattern[pos.*] == ')') pos.* += 1;
            return inner;
        }
        if (c == '[' and pos.* + 2 < self.pattern.len and self.pattern[pos.* + 1] == '^') {
            if (std.mem.indexOfScalarPos(u8, self.pattern, pos.* + 2, ']')) |close| {
                if (close > pos.* + 2) {
                    if (close > std.math.maxInt(u16)) return error.PatternTooComplex;
                    const class_start: u16 = @intCast(pos.* + 2);
                    const class_end: u16 = @intCast(close);
                    pos.* = close + 1;
                    const end = try self.addState(.accept);
                    const start = try self.addState(.{ .neg_class = .{
                        .start = class_start,
                        .end = class_end,
                        .next = end,
                    } });
                    return .{ .start = start, .end = end };
                }
            }
        }
        if (c == '\\' and pos.* + 1 < self.pattern.len) {
            const escaped = self.pattern[pos.* + 1];
            pos.* += 2;
            const end = try self.addState(.accept);
            const start = try self.addState(.{ .literal = .{ .byte = escaped, .next = end } });
            return .{ .start = start, .end = end };
        }
        pos.* += 1;
        const end = try self.addState(.accept);
        const start = try self.addState(.{ .literal = .{ .byte = c, .next = end } });
        return .{ .start = start, .end = end };
    }

    fn addEpsilonClosure(self: *const FilterNfa, set: *StateSet, start_state: u16) bool {
        var stack: [max_states]u16 = undefined;
        var top: usize = 0;
        if (!set.isSet(start_state)) {
            set.set(start_state);
            stack[top] = start_state;
            top += 1;
        }
        var accepted = false;
        while (top > 0) {
            top -= 1;
            const s = stack[top];
            switch (self.states[s]) {
                .accept => accepted = true,
                .jump => |next| {
                    if (!set.isSet(next)) {
                        set.set(next);
                        stack[top] = next;
                        top += 1;
                    }
                },
                .split => |sp| {
                    if (!set.isSet(sp.a)) {
                        set.set(sp.a);
                        stack[top] = sp.a;
                        top += 1;
                    }
                    if (!set.isSet(sp.b)) {
                        set.set(sp.b);
                        stack[top] = sp.b;
                        top += 1;
                    }
                },
                .literal, .any, .neg_class => {},
            }
        }
        return accepted;
    }

    fn matches(self: *const FilterNfa, start: u16, text: []const u8) bool {
        var current = StateSet.initEmpty();
        if (self.addEpsilonClosure(&current, start)) return true;

        for (text) |byte| {
            var next = StateSet.initEmpty();
            var it = current.iterator(.{});
            while (it.next()) |idx| {
                switch (self.states[idx]) {
                    .literal => |lit| {
                        if (byte == lit.byte and self.addEpsilonClosure(&next, lit.next)) return true;
                    },
                    .any => |a| {
                        if (self.addEpsilonClosure(&next, a.next)) return true;
                    },
                    .neg_class => |nc| {
                        if (negClassMatches(self.pattern[nc.start..nc.end], byte) and self.addEpsilonClosure(&next, nc.next)) {
                            return true;
                        }
                    },
                    .jump, .split, .accept => {},
                }
            }
            if (self.addEpsilonClosure(&next, start)) return true;
            current = next;
        }
        return false;
    }
};

fn hasMatchingCloseParen(pattern: []const u8, open_pos: usize) bool {
    var depth: usize = 0;
    var i: usize = open_pos;
    while (i < pattern.len) {
        if (pattern[i] == '\\' and i + 1 < pattern.len) {
            i += 2;
            continue;
        }
        if (pattern[i] == '[' and i + 2 < pattern.len and pattern[i + 1] == '^') {
            if (std.mem.indexOfScalarPos(u8, pattern, i + 2, ']')) |close| {
                if (close > i + 2) {
                    i = close + 1;
                    continue;
                }
            }
        }
        if (pattern[i] == '(') {
            depth += 1;
        } else if (pattern[i] == ')') {
            depth -= 1;
            if (depth == 0) return true;
        }
        i += 1;
    }
    return false;
}

fn negClassMatches(spec: []const u8, byte: u8) bool {
    var i: usize = 0;
    while (i < spec.len) {
        if (i + 2 < spec.len and spec[i + 1] == '-' and spec[i] <= spec[i + 2]) {
            if (byte >= spec[i] and byte <= spec[i + 2]) return false;
            i += 3;
        } else {
            if (byte == spec[i]) return false;
            i += 1;
        }
    }
    return true;
}

fn hasPatternSyntax(filter: []const u8) bool {
    for (filter, 0..) |c, i| {
        switch (c) {
            '(', '|', '\\' => return true,
            '.' => if (i + 1 < filter.len and filter[i + 1] == '*') return true,
            '[' => if (i + 1 < filter.len and filter[i + 1] == '^') return true,
            else => {},
        }
    }
    return false;
}

/// Unanchored bounded pattern match supporting literal substrings, `.*` wildcards,
/// `(a|b|c)` / `a|b` alternation, `[^...]` negated character classes, and `\` escapes.
/// Positive `[...]` brackets are treated literally so pytest IDs like `[fork_Osaka-state_test]`
/// match without escaping.
pub fn matchesFilter(test_name: []const u8, filter: []const u8) bool {
    if (filter.len == 0) return true;
    if (!hasPatternSyntax(filter)) {
        return std.mem.indexOf(u8, test_name, filter) != null;
    }
    const compiled = FilterNfa.compile(filter) catch {
        return std.mem.indexOf(u8, test_name, filter) != null;
    };
    return compiled.nfa.matches(compiled.start, test_name);
}

pub const OutputFormat = enum {
    pretty,
    json,
    junit,
};

pub fn outputJSON(writer: anytype, results: []TestResult, duration_ns: u64) !void {
    var passed: usize = 0;
    var failed: usize = 0;
    var todo: usize = 0;
    var skipped: usize = 0;

    for (results) |r| {
        if (r.todo) {
            todo += 1;
        } else if (r.skipped) {
            skipped += 1;
        } else if (r.passed) {
            passed += 1;
        } else {
            failed += 1;
        }
    }

    try std.fmt.format(writer, "{{", .{});
    try std.fmt.format(writer, "\"success\":{s},", .{if (failed == 0) "true" else "false"});
    try std.fmt.format(writer, "\"total\":{d},", .{results.len});
    try std.fmt.format(writer, "\"passed\":{d},", .{passed});
    try std.fmt.format(writer, "\"failed\":{d},", .{failed});
    try std.fmt.format(writer, "\"todo\":{d},", .{todo});
    try std.fmt.format(writer, "\"skipped\":{d},", .{skipped});
    try std.fmt.format(writer, "\"duration_ms\":{d:.2},", .{@as(f64, @floatFromInt(duration_ns)) / 1_000_000.0});
    try std.fmt.format(writer, "\"tests\":[", .{});

    for (results, 0..) |r, i| {
        try std.fmt.format(writer, "{{", .{});
        try std.fmt.format(writer, "\"name\":\"{s}\",", .{escapeJSON(r.name)});
        try std.fmt.format(writer, "\"suite\":\"{s}\",", .{escapeJSON(r.suite)});
        try std.fmt.format(writer, "\"test_name\":\"{s}\",", .{escapeJSON(r.test_name)});
        try std.fmt.format(writer, "\"status\":\"{s}\",", .{if (r.todo) "todo" else if (r.skipped) "skipped" else if (r.passed) "passed" else "failed"});
        try std.fmt.format(writer, "\"duration_ms\":{d:.2}", .{@as(f64, @floatFromInt(r.duration_ns)) / 1_000_000.0});

        if (r.error_msg) |msg| {
            try std.fmt.format(writer, ",\"error\":\"{s}\"", .{escapeJSON(msg)});
        }

        try std.fmt.format(writer, "}}", .{});
        if (i < results.len - 1) {
            try std.fmt.format(writer, ",", .{});
        }
    }

    try std.fmt.format(writer, "]}}\n", .{});
}

pub fn outputJUnit(writer: anytype, allocator: std.mem.Allocator, results: []TestResult, duration_ns: u64) !void {
    var passed: usize = 0;
    var failed: usize = 0;
    var skipped: usize = 0;

    for (results) |r| {
        if (r.todo or r.skipped) {
            skipped += 1;
        } else if (r.passed) {
            passed += 1;
        } else {
            failed += 1;
        }
    }

    const duration_s = @as(f64, @floatFromInt(duration_ns)) / 1_000_000_000.0;

    try std.fmt.format(writer, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n", .{});
    try std.fmt.format(writer, "<testsuites tests=\"{d}\" failures=\"{d}\" skipped=\"{d}\" time=\"{d:.3}\">\n", .{
        results.len,
        failed,
        skipped,
        duration_s,
    });

    // Group by suite
    var suite_map = std.StringHashMap(std.ArrayList(TestResult)).init(allocator);
    defer {
        var it = suite_map.iterator();
        while (it.next()) |entry| {
            entry.value_ptr.deinit(allocator);
        }
        suite_map.deinit();
    }

    for (results) |result| {
        const entry = try suite_map.getOrPut(result.suite);
        if (!entry.found_existing) {
            entry.value_ptr.* = .{};
        }
        try entry.value_ptr.append(allocator, result);
    }

    var suite_iter = suite_map.iterator();
    while (suite_iter.next()) |entry| {
        const suite_name = entry.key_ptr.*;
        const tests = entry.value_ptr.*;

        var suite_duration: u64 = 0;
        var suite_failed: usize = 0;
        var suite_skipped: usize = 0;

        for (tests.items) |t| {
            suite_duration += t.duration_ns;
            if (t.todo or t.skipped) {
                suite_skipped += 1;
            } else if (!t.passed) {
                suite_failed += 1;
            }
        }

        const suite_duration_s = @as(f64, @floatFromInt(suite_duration)) / 1_000_000_000.0;

        try std.fmt.format(writer, "  <testsuite name=\"{s}\" tests=\"{d}\" failures=\"{d}\" skipped=\"{d}\" time=\"{d:.3}\">\n", .{
            escapeXML(suite_name),
            tests.items.len,
            suite_failed,
            suite_skipped,
            suite_duration_s,
        });

        for (tests.items) |t| {
            const test_duration_s = @as(f64, @floatFromInt(t.duration_ns)) / 1_000_000_000.0;
            try std.fmt.format(writer, "    <testcase name=\"{s}\" classname=\"{s}\" time=\"{d:.3}\"", .{
                escapeXML(t.test_name),
                escapeXML(t.suite),
                test_duration_s,
            });

            if (t.todo or t.skipped) {
                try std.fmt.format(writer, ">\n      <skipped message=\"{s}\"/>\n    </testcase>\n", .{if (t.todo) "TODO" else "SkipZigTest"});
            } else if (!t.passed) {
                try std.fmt.format(writer, ">\n      <failure message=\"{s}\"/>\n    </testcase>\n", .{
                    if (t.error_msg) |msg| escapeXML(msg) else "Test failed",
                });
            } else {
                try std.fmt.format(writer, "/>\n", .{});
            }
        }

        try std.fmt.format(writer, "  </testsuite>\n", .{});
    }

    try std.fmt.format(writer, "</testsuites>\n", .{});
}

fn escapeJSON(s: []const u8) []const u8 {
    // Check if string needs escaping
    var needs_escape = false;
    for (s) |c| {
        if (c == '"' or c == '\\' or c == '\n' or c == '\r' or c == '\t' or c < 0x20) {
            needs_escape = true;
            break;
        }
    }

    if (!needs_escape) return s;

    // Allocate and escape
    // Note: This uses page_allocator for JSON output lifetime
    // The escaped strings need to live for the duration of the output
    const allocator = std.heap.page_allocator;
    var result: std.ArrayList(u8) = .{};
    result.ensureTotalCapacity(allocator, s.len) catch return s;
    for (s) |c| {
        switch (c) {
            '"' => result.appendSlice(allocator, "\\\"") catch return s,
            '\\' => result.appendSlice(allocator, "\\\\") catch return s,
            '\n' => result.appendSlice(allocator, "\\n") catch return s,
            '\r' => result.appendSlice(allocator, "\\r") catch return s,
            '\t' => result.appendSlice(allocator, "\\t") catch return s,
            else => {
                if (c < 0x20) {
                    // Control characters: use \uXXXX format
                    std.fmt.format(result.writer(allocator), "\\u{x:0>4}", .{c}) catch return s;
                } else {
                    result.append(allocator, c) catch return s;
                }
            },
        }
    }
    return result.toOwnedSlice(allocator) catch return s;
}

fn escapeXML(s: []const u8) []const u8 {
    // Check if string needs escaping
    var needs_escape = false;
    for (s) |c| {
        if (c == '<' or c == '>' or c == '&' or c == '"' or c == '\'') {
            needs_escape = true;
            break;
        }
    }

    if (!needs_escape) return s;

    // Allocate and escape
    // Note: This uses page_allocator for XML output lifetime
    // The escaped strings need to live for the duration of the output
    const allocator = std.heap.page_allocator;
    var result: std.ArrayList(u8) = .{};
    result.ensureTotalCapacity(allocator, s.len) catch return s;
    for (s) |c| {
        switch (c) {
            '<' => result.appendSlice(allocator, "&lt;") catch return s,
            '>' => result.appendSlice(allocator, "&gt;") catch return s,
            '&' => result.appendSlice(allocator, "&amp;") catch return s,
            '"' => result.appendSlice(allocator, "&quot;") catch return s,
            '\'' => result.appendSlice(allocator, "&apos;") catch return s,
            else => result.append(allocator, c) catch return s,
        }
    }
    return result.toOwnedSlice(allocator) catch return s;
}

pub const TestTask = struct {
    index: usize,
    result: ?TestResult = null,
    mutex: std.Thread.Mutex = .{},
};

pub fn runTestsParallel(allocator: std.mem.Allocator, test_indices: []const usize, max_workers: usize) ![]TestResult {
    if (test_indices.len == 0) return &[_]TestResult{};

    // Create task list
    const tasks = try allocator.alloc(TestTask, test_indices.len);
    defer allocator.free(tasks);

    for (tasks, 0..) |*task, i| {
        task.* = .{ .index = test_indices[i] };
    }

    // Create worker threads (at least one, so a nonempty selection always runs)
    const worker_count = @max(@min(max_workers, test_indices.len), 1);
    const threads = try allocator.alloc(std.Thread, worker_count);
    defer allocator.free(threads);

    var next_task_idx: usize = 0;
    var completed_count: usize = 0;
    var task_mutex = std.Thread.Mutex{};

    const WorkerContext = struct {
        tasks_ptr: [*]TestTask,
        tasks_len: usize,
        next_idx: *usize,
        completed: *usize,
        mutex: *std.Thread.Mutex,
        allocator: std.mem.Allocator,
    };

    const workerFn = struct {
        fn run(ctx: WorkerContext) void {
            while (true) {
                // Get next task
                ctx.mutex.lock();
                const task_idx = ctx.next_idx.*;
                if (task_idx >= ctx.tasks_len) {
                    ctx.mutex.unlock();
                    break;
                }
                ctx.next_idx.* += 1;
                ctx.mutex.unlock();

                // Run the test. Every scheduled test records exactly one
                // outcome, so the progress loop below always terminates.
                const task = &ctx.tasks_ptr[task_idx];
                const result = runTestInProcess(ctx.allocator, task.index) catch |err| blk: {
                    const t = builtin.test_functions[task.index];
                    break :blk TestResult{
                        .name = t.name,
                        .suite = extractSuiteName(t.name),
                        .test_name = extractTestName(t.name),
                        .passed = false,
                        .error_msg = std.fmt.allocPrint(ctx.allocator, "runner error: {s}", .{@errorName(err)}) catch null,
                        .duration_ns = 0,
                    };
                };

                task.mutex.lock();
                task.result = result;
                task.mutex.unlock();

                // Update completed count
                ctx.mutex.lock();
                ctx.completed.* += 1;
                ctx.mutex.unlock();
            }
        }
    }.run;

    const worker_ctx = WorkerContext{
        .tasks_ptr = tasks.ptr,
        .tasks_len = tasks.len,
        .next_idx = &next_task_idx,
        .completed = &completed_count,
        .mutex = &task_mutex,
        .allocator = allocator,
    };

    // Launch workers. If a spawn fails, the workers already running drain the
    // queue; if none started, run every test on this thread.
    var spawned: usize = 0;
    for (threads) |*thread| {
        thread.* = std.Thread.spawn(.{}, workerFn, .{worker_ctx}) catch |err| {
            std.debug.print("Warning: failed to spawn test worker: {s}\n", .{@errorName(err)});
            break;
        };
        spawned += 1;
    }
    if (spawned == 0) workerFn(worker_ctx);

    // Show progress while tests run
    const stdout = std.fs.File.stdout();
    const writer = stdout.deprecatedWriter();
    const start_time = std.time.milliTimestamp();
    var check_count: usize = 0;
    var last_check_count: usize = 0;

    // Print initial newline for test result markers
    try writer.print("\n", .{});

    while (true) {
        task_mutex.lock();
        const current = completed_count;
        task_mutex.unlock();

        if (current >= test_indices.len) break;

        // Count passed/failed for displaying markers
        var passed: usize = 0;
        var failed: usize = 0;
        for (0..tasks.len) |i| {
            tasks[i].mutex.lock();
            if (tasks[i].result) |r| {
                if (r.passed) {
                    passed += 1;
                } else {
                    failed += 1;
                }
            }
            tasks[i].mutex.unlock();
        }

        // Print new check/cross marks
        const total_checks = passed + failed;
        while (check_count < total_checks) {
            // Determine if this check is pass or fail
            const is_pass = check_count < passed;
            if (is_pass) {
                try writer.print("{s}{s}{s}", .{ Color.green, Icons.check, Color.reset });
            } else {
                try writer.print("{s}{s}{s}", .{ Color.red, Icons.cross, Color.reset });
            }
            check_count += 1;

            // Add newline every 100 marks to keep output manageable
            if (check_count % 100 == 0) {
                try writer.print("\n", .{});
            }
        }

        // Only update progress line if we printed new marks
        if (check_count != last_check_count) {
            const elapsed_ms = std.time.milliTimestamp() - start_time;
            const elapsed_sec = @as(f64, @floatFromInt(elapsed_ms)) / 1000.0;
            const rate = if (elapsed_sec > 0) @as(f64, @floatFromInt(current)) / elapsed_sec else 0;

            try writer.print("  {s}[{d}/{d} - {d:.0} tests/sec]{s}", .{
                Color.dim,
                current,
                test_indices.len,
                rate,
                Color.reset,
            });
            last_check_count = check_count;
        }

        std.Thread.sleep(50 * std.time.ns_per_ms); // Update every 50ms for smoother output
    }

    try writer.print("\n", .{});

    // Wait for all workers
    for (threads[0..spawned]) |thread| {
        thread.join();
    }

    // Collect results
    var results: std.ArrayList(TestResult) = .{};
    for (tasks) |task| {
        if (task.result) |result| {
            try results.append(allocator, result);
        }
    }

    return try results.toOwnedSlice(allocator);
}

pub fn printSlowestTests(writer: anytype, allocator: std.mem.Allocator, results: []TestResult, count: usize) !void {
    if (results.len == 0) return;

    // Create a copy for sorting
    var sorted: std.ArrayList(TestResult) = .{};
    defer sorted.deinit(allocator);

    for (results) |r| {
        try sorted.append(allocator, r);
    }

    // Sort by duration (descending)
    std.mem.sort(TestResult, sorted.items, {}, struct {
        fn lessThan(_: void, a: TestResult, b: TestResult) bool {
            return a.duration_ns > b.duration_ns;
        }
    }.lessThan);

    const display_count = @min(count, sorted.items.len);
    if (display_count == 0) return;

    try std.fmt.format(writer, "\n{s}─────────────────────────────────────────{s}\n", .{ Color.dim, Color.reset });
    try std.fmt.format(writer, " {s}Slowest Tests ({d}){s}\n", .{ Color.bold, display_count, Color.reset });
    try std.fmt.format(writer, "{s}─────────────────────────────────────────{s}\n\n", .{ Color.dim, Color.reset });

    for (sorted.items[0..display_count]) |t| {
        const icon = if (t.skipped) Icons.dot else if (t.passed) Icons.check else Icons.cross;
        const color = if (t.skipped) Color.gray else if (t.passed) Color.green else Color.red;

        try std.fmt.format(writer, " {s}{s}{s} {s}{s}.{s}{s} ", .{
            color,
            icon,
            Color.reset,
            Color.dim,
            t.suite,
            t.test_name,
            Color.reset,
        });
        try formatDuration(writer, t.duration_ns);
        try std.fmt.format(writer, "\n", .{});
    }
}

test "parseWorkerCount clamps zero and falls back on garbage" {
    try std.testing.expectEqual(@as(usize, 1), parseWorkerCount("0", 8));
    try std.testing.expectEqual(@as(usize, 3), parseWorkerCount("3", 8));
    try std.testing.expectEqual(@as(usize, 8), parseWorkerCount("lots", 8));
    try std.testing.expectEqual(@as(usize, 8), parseWorkerCount(null, 8));
    try std.testing.expectEqual(@as(usize, 1), parseWorkerCount(null, 0));
}

test "SkipZigTest maps to a skip, other errors to a failure" {
    try std.testing.expectEqual(ChildExit.skip, errorExitCode(error.SkipZigTest));
    try std.testing.expectEqual(ChildExit.fail, errorExitCode(error.TestUnexpectedResult));
}

test "applyExitCode records skipped tests as non-failures" {
    const allocator = std.testing.allocator;
    var r = TestResult{ .name = "a.test.b", .suite = "a", .test_name = "b", .passed = false, .error_msg = null, .duration_ns = 0 };
    try applyExitCode(allocator, &r, ChildExit.skip);
    try std.testing.expect(r.passed and r.skipped);
    try std.testing.expect(r.error_msg == null);

    var f = TestResult{ .name = "a.test.b", .suite = "a", .test_name = "b", .passed = true, .error_msg = null, .duration_ns = 0 };
    try applyExitCode(allocator, &f, 42);
    defer allocator.free(f.error_msg.?);
    try std.testing.expect(!f.passed and !f.skipped);
    try std.testing.expectEqualStrings("exited with code 42", f.error_msg.?);
}

test "extractSuiteName and extractTestName handle short names" {
    try std.testing.expectEqualStrings("abc", extractSuiteName("abc"));
    try std.testing.expectEqualStrings("", extractTestName(""));
    try std.testing.expectEqualStrings("mod", extractSuiteName("mod.test.name"));
    try std.testing.expectEqualStrings("name", extractTestName("mod.test.name"));
}

test "matchesFilter handles literals, wildcards, alternation, negated classes, and edge cases" {
    // Empty & literals
    try std.testing.expect(matchesFilter("anything", ""));
    try std.testing.expect(matchesFilter("abc_def_ghi", "def"));
    try std.testing.expect(!matchesFilter("abc_def_ghi", "xyz"));
    // Bare dot is literal; pytest bracket IDs stay literal.
    try std.testing.expect(matchesFilter("test_push.py::test_x[fork_Osaka-state_test]", "test_push.py"));
    try std.testing.expect(!matchesFilter("test_push_py::test_x", "test_push.py"));
    try std.testing.expect(matchesFilter(
        "tests/osaka/test_clz.py::test_clz[fork_Osaka-state_test-zero]",
        "test_clz[fork_Osaka-state_test-zero]",
    ));

    // .* wildcards
    try std.testing.expect(matchesFilter("frontier_call", "frontier.*call"));
    try std.testing.expect(matchesFilter("frontiercall", "frontier.*call"));
    try std.testing.expect(!matchesFilter("call_frontier", "frontier.*call"));

    // Alternation (grouped, nested, top-level, empty)
    try std.testing.expect(matchesFilter("foo_g1add_bar", "(g1add|g1mul|g1msm)"));
    try std.testing.expect(matchesFilter("foo_g1mul_bar", "(g1add|g1mul|g1msm)"));
    try std.testing.expect(matchesFilter("foo_g1msm_bar", "(g1add|g1mul|g1msm)"));
    try std.testing.expect(!matchesFilter("foo_g2add_bar", "(g1add|g1mul|g1msm)"));
    try std.testing.expect(matchesFilter("alpha_two", "alpha_(one|(two|three))"));
    try std.testing.expect(matchesFilter("beta", "alpha|beta"));
    try std.testing.expect(matchesFilter("ac", "a(|b)c"));
    try std.testing.expect(matchesFilter("abc", "a(|b)c"));

    // Negated character classes
    try std.testing.expect(matchesFilter("set_code_txs.test", "set_code_txs[^_2]"));
    try std.testing.expect(!matchesFilter("set_code_txs_2.test", "set_code_txs[^_2]"));
    try std.testing.expect(!matchesFilter("set_code_txs2.test", "set_code_txs[^_2]"));
    try std.testing.expect(!matchesFilter("set_code_txs", "set_code_txs[^_2]"));
    try std.testing.expect(matchesFilter("val_a", "val_[^0-9]"));
    try std.testing.expect(!matchesFilter("val_5", "val_[^0-9]"));
    try std.testing.expect(matchesFilter("x_b", "x_[^-a]"));
    try std.testing.expect(!matchesFilter("x_-", "x_[^-a]"));
    try std.testing.expect(matchesFilter("x_b", "x_[^a-]"));
    try std.testing.expect(!matchesFilter("x_-", "x_[^a-]"));

    // Escapes
    try std.testing.expect(matchesFilter("a(b|c)", "a\\(b\\|c\\)"));
    try std.testing.expect(!matchesFilter("ab", "a\\(b\\|c\\)"));

    // Malformed patterns do not crash or hang
    try std.testing.expect(matchesFilter("foo(bar", "foo(bar"));
    try std.testing.expect(matchesFilter("foo[^bar", "foo[^bar"));
    try std.testing.expect(matchesFilter("foo[^]bar", "foo[^]bar"));
    try std.testing.expect(matchesFilter("foo)bar", "foo)bar"));

    // Bounded execution against catastrophic-backtracking patterns
    const long_b = "b" ** 4096;
    try std.testing.expect(!matchesFilter(long_b, ".*.*.*.*.*.*.*.*(a|aa|aaa)"));
}

test "matchesFilter covers every build.zig spec sub-target filter" {
    const Case = struct {
        filter: []const u8,
        positive: []const u8,
        negative: []const u8,
    };

    const cases = [_]Case{
        // Berlin
        .{
            .filter = "berlin.*acl.*account_storage_warm_cold_state",
            .positive = "generated.berlin.eip2930_access_list.acl.test.account_storage_warm_cold_state",
            .negative = "generated.berlin.eip2930_access_list.acl.test.transaction_intrinsic_gas_cost",
        },
        .{
            .filter = "berlin.*acl.*transaction_intrinsic_gas_cost",
            .positive = "generated.berlin.eip2930_access_list.acl.test.transaction_intrinsic_gas_cost",
            .negative = "generated.cancun.acl.test.transaction_intrinsic_gas_cost",
        },
        .{
            .filter = "berlin.*tx_intrinsic_gas.*tx_type_0",
            .positive = "generated.berlin.eip2930.tx_intrinsic_gas.test.tx_type_0_access_list",
            .negative = "generated.berlin.eip2930.tx_intrinsic_gas.test.tx_type_1_access_list",
        },
        .{
            .filter = "berlin.*tx_intrinsic_gas.*tx_type_1",
            .positive = "generated.berlin.eip2930.tx_intrinsic_gas.test.tx_type_1_access_list",
            .negative = "generated.berlin.eip2930.tx_intrinsic_gas.test.tx_type_0_access_list",
        },
        // Frontier
        .{
            .filter = "frontier.*precompile",
            .positive = "generated.frontier.precompiles.test.ecrecover",
            .negative = "generated.byzantium.precompiles.test.modexp",
        },
        .{
            .filter = "frontier.*identity",
            .positive = "generated.frontier.identity_precompile.test.identity",
            .negative = "generated.frontier.create.test.create",
        },
        .{
            .filter = "frontier.*create",
            .positive = "generated.frontier.create.test.create_contract",
            .negative = "generated.frontier.opcodes.test.dup",
        },
        .{
            .filter = "frontier.*call",
            .positive = "generated.frontier.opcodes.call.test.call_value",
            .negative = "generated.frontier.opcodes.dup.test.dup1",
        },
        .{
            .filter = "frontier.*calldata",
            .positive = "generated.frontier.opcodes.calldata.test.calldataload",
            .negative = "generated.frontier.opcodes.call.test.call_value",
        },
        .{
            .filter = "frontier.*dup",
            .positive = "generated.frontier.opcodes.dup.test.dup16",
            .negative = "generated.frontier.opcodes.push.test.push1",
        },
        .{
            .filter = "frontier.*push",
            .positive = "generated.frontier.opcodes.push.test.push32",
            .negative = "generated.frontier.opcodes.dup.test.dup1",
        },
        .{
            .filter = "frontier.*stack_overflow",
            .positive = "generated.frontier.opcodes.push.stack_overflow.test.push10",
            .negative = "generated.frontier.opcodes.push.push.test.push10",
        },
        .{
            .filter = "frontier.*opcodes.*all_opcodes",
            .positive = "generated.frontier.opcodes.all_opcodes.test.all_opcodes",
            .negative = "generated.frontier.opcodes.push.test.push1",
        },
        // Cancun
        .{
            .filter = "eip1153_tstore_test_tstorage_py",
            .positive = "generated.cancun.eip1153_tstore.test.eip1153_tstore_test_tstorage_py__basic",
            .negative = "generated.cancun.eip1153_tstore.test.eip1153_tstore_test_tstore_reentrancy",
        },
        .{
            .filter = "eip1153_tstore_test_tstore_reentrancy",
            .positive = "generated.cancun.eip1153_tstore.test.eip1153_tstore_test_tstore_reentrancy",
            .negative = "generated.cancun.eip1153_tstore.test.eip1153_tstore_test_tstorage_py",
        },
        .{
            .filter = "tstorage_execution_contexts",
            .positive = "generated.cancun.eip1153.test.tstorage_execution_contexts_call",
            .negative = "generated.cancun.eip1153.test.tstorage_create_contexts",
        },
        .{
            .filter = "tload_reentrancy",
            .positive = "generated.cancun.eip1153.test.tload_reentrancy_static",
            .negative = "generated.cancun.eip1153.test.tstorage_clear_after_tx",
        },
        .{
            .filter = "tstorage_reentrancy_contexts",
            .positive = "generated.cancun.eip1153.test.tstorage_reentrancy_contexts_0",
            .negative = "generated.cancun.eip1153.test.tstorage_selfdestruct",
        },
        .{
            .filter = "tstorage_create_contexts",
            .positive = "generated.cancun.eip1153.test.tstorage_create_contexts_0",
            .negative = "generated.cancun.eip1153.test.tstorage_selfdestruct",
        },
        .{
            .filter = "tstorage_selfdestruct",
            .positive = "generated.cancun.eip1153.test.tstorage_selfdestruct_0",
            .negative = "generated.cancun.eip1153.test.tstorage_clear_after_tx",
        },
        .{
            .filter = "tstorage_clear_after_tx",
            .positive = "generated.cancun.eip1153.test.tstorage_clear_after_tx_0",
            .negative = "generated.cancun.eip1153.test.tstorage_selfdestruct",
        },
        .{
            .filter = "eip5656_mcopy",
            .positive = "generated.cancun.eip5656_mcopy.test.mcopy_overlap",
            .negative = "generated.cancun.eip7516_blobgasfee.test.blobbasefee",
        },
        .{
            .filter = "test_selfdestruct_py",
            .positive = "generated.cancun.eip6780.test.test_selfdestruct_py__basic",
            .negative = "generated.cancun.eip6780.test.test_selfdestruct_revert_py__basic",
        },
        .{
            .filter = "dynamic_create2_selfdestruct_collision",
            .positive = "generated.cancun.eip6780.test.dynamic_create2_selfdestruct_collision",
            .negative = "generated.cancun.eip6780.test.reentrancy_selfdestruct_revert",
        },
        .{
            .filter = "reentrancy_selfdestruct_revert",
            .positive = "generated.cancun.eip6780.test.reentrancy_selfdestruct_revert",
            .negative = "generated.cancun.eip6780.test.test_selfdestruct_py",
        },
        .{
            .filter = "test_selfdestruct_revert_py",
            .positive = "generated.cancun.eip6780.test.test_selfdestruct_revert_py__case",
            .negative = "generated.cancun.eip6780.test.test_selfdestruct_py__case",
        },
        .{
            .filter = "eip7516_blobgasfee",
            .positive = "generated.cancun.eip7516_blobgasfee.test.blobbasefee",
            .negative = "generated.cancun.eip5656_mcopy.test.mcopy",
        },
        .{
            .filter = "test_point_evaluation_precompile_py",
            .positive = "generated.cancun.eip4844.test.test_point_evaluation_precompile_py__ok",
            .negative = "generated.cancun.eip4844.test.test_point_evaluation_precompile_gas_py__ok",
        },
        .{
            .filter = "test_point_evaluation_precompile_gas_py",
            .positive = "generated.cancun.eip4844.test.test_point_evaluation_precompile_gas_py__ok",
            .negative = "generated.cancun.eip4844.test.test_point_evaluation_precompile_py__ok",
        },
        .{
            .filter = "test_blobhash_opcode_py__test_blobhash_",
            .positive = "generated.cancun.eip4844.test.test_blobhash_opcode_py__test_blobhash_index",
            .negative = "generated.cancun.eip4844.test.blobhash_opcode_contexts",
        },
        .{
            .filter = "blobhash_opcode_contexts",
            .positive = "generated.cancun.eip4844.test.blobhash_opcode_contexts_call",
            .negative = "generated.cancun.eip4844.test.blob_tx_attribute",
        },
        .{
            .filter = "blob_tx_attribute",
            .positive = "generated.cancun.eip4844.test.blob_tx_attribute_value",
            .negative = "generated.cancun.eip4844.test.blob_gas_subtraction_tx",
        },
        .{
            .filter = "blob_gas_subtraction_tx",
            .positive = "generated.cancun.eip4844.test.blob_gas_subtraction_tx",
            .negative = "generated.cancun.eip4844.test.insufficient_balance_blob_tx",
        },
        .{
            .filter = "insufficient_balance_blob_tx",
            .positive = "generated.cancun.eip4844.test.insufficient_balance_blob_tx",
            .negative = "generated.cancun.eip4844.test.sufficient_balance_blob_tx",
        },
        .{
            .filter = "sufficient_balance_blob_tx",
            .positive = "generated.cancun.eip4844.test.sufficient_balance_blob_tx",
            .negative = "generated.cancun.eip4844.test.valid_blob_tx_combinations",
        },
        .{
            .filter = "valid_blob_tx_combinations",
            .positive = "generated.cancun.eip4844.test.valid_blob_tx_combinations",
            .negative = "generated.cancun.eip4844.test.blob_tx_attribute",
        },
        // Prague
        .{
            .filter = "prague.*eip7623.*type_0",
            .positive = "generated.prague.eip7623_increase_calldata_cost.test.transaction_validity_type_0",
            .negative = "generated.prague.eip7623_increase_calldata_cost.test.transaction_validity_type_3",
        },
        .{
            .filter = "prague.*eip7623.*type_1_type_2",
            .positive = "generated.prague.eip7623_increase_calldata_cost.test.transaction_validity_type_1_type_2",
            .negative = "generated.prague.eip7623_increase_calldata_cost.test.transaction_validity_type_4",
        },
        .{
            .filter = "prague.*eip7623.*type_3",
            .positive = "generated.prague.eip7623_increase_calldata_cost.test.transaction_validity_type_3",
            .negative = "generated.prague.eip7623_increase_calldata_cost.test.transaction_validity_type_0",
        },
        .{
            .filter = "prague.*eip7623.*type_4",
            .positive = "generated.prague.eip7623_increase_calldata_cost.test.transaction_validity_type_4",
            .negative = "generated.prague.eip7623_increase_calldata_cost.test.transaction_validity_type_3",
        },
        .{
            .filter = "prague.*eip7623.*(refunds|execution_gas)",
            .positive = "generated.prague.eip7623_increase_calldata_cost.test.test_refunds",
            .negative = "generated.prague.eip7623_increase_calldata_cost.test.transaction_validity_type_0",
        },
        .{
            .filter = "prague.*eip7623.*(refunds|execution_gas)",
            .positive = "generated.prague.eip7623_increase_calldata_cost.test.test_execution_gas",
            .negative = "generated.cancun.eip7623.test.test_execution_gas",
        },
        .{
            .filter = "prague.*bls12.*(g1add|g1mul|g1msm)",
            .positive = "generated.prague.eip2537_bls_12_381_precompiles.bls12_g1msm.test.g1msm",
            .negative = "generated.prague.eip2537_bls_12_381_precompiles.bls12_g2add.test.g2add",
        },
        .{
            .filter = "prague.*bls12.*(g2add|g2mul|g2msm)",
            .positive = "generated.prague.eip2537_bls_12_381_precompiles.bls12_g2mul.test.g2mul",
            .negative = "generated.prague.eip2537_bls_12_381_precompiles.bls12_g1add.test.g1add",
        },
        .{
            .filter = "prague.*bls12.*pairing",
            .positive = "generated.prague.eip2537_bls_12_381_precompiles.bls12_pairing.test.valid",
            .negative = "generated.prague.eip2537_bls_12_381_precompiles.bls12_map_fp_to_g1.test.valid",
        },
        .{
            .filter = "prague.*bls12.*map",
            .positive = "generated.prague.eip2537_bls_12_381_precompiles.bls12_map_fp2_to_g2.test.valid",
            .negative = "generated.prague.eip2537_bls_12_381_precompiles.bls12_pairing.test.valid",
        },
        .{
            .filter = "prague.*bls12.*(variable_length|before_fork)",
            .positive = "generated.prague.eip2537_bls_12_381_precompiles.bls12_precompiles_before_fork.test.g1add",
            .negative = "generated.prague.eip2537_bls_12_381_precompiles.bls12_g1add.test.valid",
        },
        .{
            .filter = "prague.*eip7702.*calls",
            .positive = "generated.prague.eip7702_set_code_tx.calls.test.delegate_call",
            .negative = "generated.prague.eip7702_set_code_tx.gas.test.gas_cost",
        },
        .{
            .filter = "prague.*eip7702.*gas",
            .positive = "generated.prague.eip7702_set_code_tx.gas.test.gas_cost",
            .negative = "generated.prague.eip7702_set_code_tx.calls.test.delegate_call",
        },
        .{
            .filter = "prague.*eip7702.*set_code_txs[^_2]",
            .positive = "generated.prague.eip7702_set_code_tx.set_code_txs.test.test_set_code_txs_py__ok",
            .negative = "generated.prague.eip7702_set_code_tx.set_code_txs_2.test.test_set_code_txs_2_py__ok",
        },
        .{
            .filter = "prague.*eip7702.*set_code_txs_2",
            .positive = "generated.prague.eip7702_set_code_tx.set_code_txs_2.test.test_set_code_txs_2_py__ok",
            .negative = "generated.prague.eip7702_set_code_tx.set_code_txs.test.test_set_code_txs_py__ok",
        },
        // Osaka
        .{
            .filter = "osaka.*modexp_variable_gas_cost",
            .positive = "generated.osaka.eip7883_modexp_gas_increase.modexp_variable_gas_cost.test.case_0",
            .negative = "generated.osaka.eip7883_modexp_gas_increase.vectors_from_eip.test.case_0",
        },
        .{
            .filter = "osaka.*vectors_from_eip",
            .positive = "generated.osaka.eip7883_modexp_gas_increase.vectors_from_eip.test.case_0",
            .negative = "generated.osaka.eip7883_modexp_gas_increase.vectors_from_legacy.test.case_0",
        },
        .{
            .filter = "osaka.*vectors_from_legacy",
            .positive = "generated.osaka.eip7883_modexp_gas_increase.vectors_from_legacy.test.case_0",
            .negative = "generated.osaka.eip7883_modexp_gas_increase.vectors_from_eip.test.case_0",
        },
        .{
            .filter = "osaka.*modexp.*(call_operations|gas_usage|invalid|entry_points|exceed)",
            .positive = "generated.osaka.eip7883_modexp_gas_increase.test.entry_points_check",
            .negative = "generated.osaka.eip7883_modexp_gas_increase.test.vectors_from_eip",
        },
        .{
            .filter = "osaka.*(eip7823|eip7825)",
            .positive = "generated.osaka.eip7825_transaction_gas_limit_cap.test.tx_gas_cap",
            .negative = "generated.osaka.eip7939_count_leading_zeros.test.clz",
        },
        .{
            .filter = "osaka.*(eip7823|eip7825)",
            .positive = "generated.osaka.eip7823_modexp_upper_bounds.test.bound_1024",
            .negative = "generated.prague.eip7825.test.tx_gas_cap",
        },
        // Shanghai, Byzantium, Constantinople, Istanbul
        .{
            .filter = "eip3855_push0",
            .positive = "generated.shanghai.eip3855_push0.test.push0_key_sstore",
            .negative = "generated.shanghai.eip3651_warm_coinbase.test.warm",
        },
        .{
            .filter = "eip3651_warm_coinbase",
            .positive = "generated.shanghai.eip3651_warm_coinbase.test.warm",
            .negative = "generated.shanghai.eip3855_push0.test.push0",
        },
        .{
            .filter = "test_initcode_py",
            .positive = "generated.shanghai.eip3860.test.test_initcode_py__max",
            .negative = "generated.shanghai.eip3860.test.with_eof",
        },
        .{
            .filter = "with_eof",
            .positive = "generated.shanghai.eip3860.test.test_initcode_with_eof",
            .negative = "generated.shanghai.eip3860.test.test_initcode_py",
        },
        .{
            .filter = "eip4895_withdrawals",
            .positive = "generated.shanghai.eip4895_withdrawals.test.withdrawals",
            .negative = "generated.shanghai.eip3855_push0.test.push0",
        },
        .{
            .filter = "eip198_modexp",
            .positive = "generated.byzantium.eip198_modexp.test.modexp",
            .negative = "generated.istanbul.eip152_blake2.test.blake2",
        },
        .{
            .filter = "eip145_bitwise_shift",
            .positive = "generated.constantinople.eip145_bitwise_shift.test.shl",
            .negative = "generated.constantinople.eip1014_create2.test.create2",
        },
        .{
            .filter = "eip1014_create2",
            .positive = "generated.constantinople.eip1014_create2.test.create2",
            .negative = "generated.constantinople.eip145_bitwise_shift.test.shr",
        },
        .{
            .filter = "eip152_blake2",
            .positive = "generated.istanbul.eip152_blake2.test.blake2f",
            .negative = "generated.istanbul.eip1344_chainid.test.chainid",
        },
        .{
            .filter = "eip1344_chainid",
            .positive = "generated.istanbul.eip1344_chainid.test.chainid",
            .negative = "generated.istanbul.eip152_blake2.test.blake2f",
        },
    };

    for (cases) |c| {
        try std.testing.expect(matchesFilter(c.positive, c.filter));
        try std.testing.expect(!matchesFilter(c.negative, c.filter));
    }
}

// Exercised by `zig test test/utils.zig --test-runner test_runner.zig`:
// a skip must not fail the run.
test "SkipZigTest is reported as skipped" {
    return error.SkipZigTest;
}
