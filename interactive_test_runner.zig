const std = @import("std");
const builtin = @import("builtin");

// ANSI color codes and styles
const Color = struct {
    const reset = "\x1b[0m";
    const bold = "\x1b[1m";
    const dim = "\x1b[2m";
    const italic = "\x1b[3m";

    const black = "\x1b[30m";
    const red = "\x1b[31m";
    const green = "\x1b[32m";
    const yellow = "\x1b[33m";
    const blue = "\x1b[34m";
    const magenta = "\x1b[35m";
    const cyan = "\x1b[36m";
    const white = "\x1b[37m";
    const gray = "\x1b[90m";
    const bright_red = "\x1b[91m";
    const bright_green = "\x1b[92m";
    const bright_yellow = "\x1b[93m";
    const bright_blue = "\x1b[94m";
    const bright_cyan = "\x1b[96m";

    // Background colors
    const bg_red = "\x1b[41m";
    const bg_green = "\x1b[42m";
    const bg_blue = "\x1b[44m";
    const bg_yellow = "\x1b[43m";
    const bg_bright_red = "\x1b[101m";
};

const Icons = struct {
    const check = "✓";
    const cross = "✖";
    const dot = "·";
    const arrow = "›";
    const pointer = "❯";
    const info = "ℹ";
    const warning = "⚠";
    const error_icon = "⨯";
    const clock = "⏱";
    const filter_icon = "🔍";
};

const TestResult = struct {
    name: []const u8,
    suite: []const u8,
    test_name: []const u8,
    passed: bool,
    error_msg: ?[]const u8,
    duration_ns: u64,
};

const TestState = struct {
    index: usize,
    name: []const u8,
    suite: []const u8,
    test_name: []const u8,
    result: ?TestResult,
};

const Command = enum {
    run_all,
    run_filtered,
    run_failed,
    set_filter,
    clear_filter,
    quit,
    help,
    invalid,
};

fn extractSuiteName(full_name: []const u8) []const u8 {
    var last_test_pos: ?usize = null;
    var i: usize = 0;
    while (i < full_name.len - 5) : (i += 1) {
        if (std.mem.eql(u8, full_name[i..@min(i + 6, full_name.len)], ".test.")) {
            last_test_pos = i;
        }
    }

    if (last_test_pos) |pos| {
        return full_name[0..pos];
    }

    if (std.mem.lastIndexOf(u8, full_name, ".")) |pos| {
        return full_name[0..pos];
    }

    return full_name;
}

fn extractTestName(full_name: []const u8) []const u8 {
    var last_test_pos: ?usize = null;
    var i: usize = 0;
    while (i < full_name.len - 5) : (i += 1) {
        if (std.mem.eql(u8, full_name[i..@min(i + 6, full_name.len)], ".test.")) {
            last_test_pos = i + 6;
        }
    }

    if (last_test_pos) |pos| {
        return full_name[pos..];
    }

    if (std.mem.lastIndexOf(u8, full_name, ".")) |pos| {
        return full_name[pos + 1 ..];
    }

    return full_name;
}

fn formatDuration(writer: anytype, ns: u64) !void {
    if (ns < 1_000) {
        try writer.print("{s}{d} ns{s}", .{ Color.gray, ns, Color.reset });
    } else if (ns < 1_000_000) {
        try writer.print("{s}{d:.2} μs{s}", .{ Color.gray, @as(f64, @floatFromInt(ns)) / 1_000.0, Color.reset });
    } else if (ns < 1_000_000_000) {
        try writer.print("{s}{d:.2} ms{s}", .{ Color.gray, @as(f64, @floatFromInt(ns)) / 1_000_000.0, Color.reset });
    } else {
        try writer.print("{s}{d:.2} s{s}", .{ Color.yellow, @as(f64, @floatFromInt(ns)) / 1_000_000_000.0, Color.reset });
    }
}

fn clearScreen(writer: anytype) !void {
    try writer.print("\x1b[2J\x1b[H", .{});
}

fn clearLine(writer: anytype) !void {
    try writer.print("\r\x1b[K", .{});
}

fn matchesFilter(test_name: []const u8, filter: []const u8) bool {
    if (filter.len == 0) return true;
    return std.mem.indexOf(u8, test_name, filter) != null;
}

fn runTestInProcess(allocator: std.mem.Allocator, test_index: usize) !TestResult {
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

    const pid = try std.posix.fork();

    if (pid == 0) {
        // Child process
        std.testing.allocator_instance = .{};
        t.func() catch {
            std.posix.exit(1);
        };

        if (std.testing.allocator_instance.deinit() == .leak) {
            std.posix.exit(2);
        }

        std.posix.exit(0);
    } else {
        // Parent process
        const timeout_ns: i128 = 60 * std.time.ns_per_s;
        const deadline = std.time.nanoTimestamp() + timeout_ns;

        var timed_out = false;
        var wait_result: std.posix.WaitPidResult = undefined;

        while (true) {
            wait_result = std.posix.waitpid(pid, std.posix.W.NOHANG);

            if (wait_result.pid == pid) {
                break;
            }

            const now = std.time.nanoTimestamp();
            if (now >= deadline) {
                std.posix.kill(pid, std.posix.SIG.KILL) catch {};
                _ = std.posix.waitpid(pid, 0);
                timed_out = true;
                break;
            }

            std.Thread.sleep(10 * std.time.ns_per_ms);
        }

        const test_end = std.time.nanoTimestamp();
        test_result.duration_ns = @intCast(test_end - test_start);

        if (timed_out) {
            test_result.passed = false;
            test_result.error_msg = try allocator.dupe(u8, "test timeout (60s)");
        } else if (std.posix.W.IFEXITED(wait_result.status)) {
            const exit_code = std.posix.W.EXITSTATUS(wait_result.status);
            if (exit_code == 0) {
                test_result.passed = true;
            } else if (exit_code == 1) {
                test_result.passed = false;
                test_result.error_msg = try allocator.dupe(u8, "test failed");
            } else if (exit_code == 2) {
                test_result.passed = false;
                test_result.error_msg = try allocator.dupe(u8, "memory leak detected");
            } else {
                test_result.passed = false;
                test_result.error_msg = try std.fmt.allocPrint(allocator, "exited with code {d}", .{exit_code});
            }
        } else if (std.posix.W.IFSIGNALED(wait_result.status)) {
            const signal = std.posix.W.TERMSIG(wait_result.status);
            test_result.passed = false;
            test_result.error_msg = try std.fmt.allocPrint(allocator, "crashed with signal {d}", .{signal});
        } else {
            test_result.passed = false;
            test_result.error_msg = try allocator.dupe(u8, "abnormal termination");
        }
    }

    return test_result;
}

fn printProgress(writer: anytype, current: usize, total: usize, suite_name: []const u8) !void {
    try clearLine(writer);
    const percent = (current * 100) / total;

    const bar_width = 20;
    const filled = (current * bar_width) / total;

    try writer.print(" {s}⠙{s} ", .{ Color.cyan, Color.reset });

    try writer.print("{s}[{s}", .{ Color.dim, Color.reset });
    for (0..bar_width) |i| {
        if (i < filled) {
            try writer.print("{s}━{s}", .{ Color.bright_cyan, Color.reset });
        } else {
            try writer.print("{s}━{s}", .{ Color.gray, Color.reset });
        }
    }
    try writer.print("{s}]{s} ", .{ Color.dim, Color.reset });

    try writer.print("{s}{d}%{s} ", .{ Color.bright_cyan, percent, Color.reset });
    try writer.print("{s}|{s} ", .{ Color.dim, Color.reset });
    try writer.print("{s}{s}{s}", .{ Color.gray, suite_name, Color.reset });
    try writer.print(" {s}[{d}/{d}]{s}", .{ Color.dim, current, total, Color.reset });
}

fn displayMenu(writer: anytype, filter: ?[]const u8, total_tests: usize, matched_tests: usize, has_results: bool, failed_count: usize) !void {
    try writer.print("\n{s}┌─────────────────────────────────────────┐{s}\n", .{ Color.cyan, Color.reset });
    try writer.print("{s}│{s}  Interactive Test Runner {s}v0.15.1{s}  {s}│{s}\n", .{ Color.cyan, Color.reset, Color.gray, Color.reset, Color.cyan, Color.reset });
    try writer.print("{s}└─────────────────────────────────────────┘{s}\n\n", .{ Color.cyan, Color.reset });

    if (filter) |f| {
        if (f.len > 0) {
            try writer.print(" {s}Filter:{s} {s}\"{s}\"{s} {s}({d}/{d} tests){s}\n\n", .{
                Color.bold,
                Color.reset,
                Color.bright_yellow,
                f,
                Color.reset,
                Color.dim,
                matched_tests,
                total_tests,
                Color.reset,
            });
        } else {
            try writer.print(" {s}{d} tests total{s}\n\n", .{ Color.dim, total_tests, Color.reset });
        }
    } else {
        try writer.print(" {s}{d} tests total{s}\n\n", .{ Color.dim, total_tests, Color.reset });
    }

    try writer.print(" {s}Commands:{s}\n", .{ Color.bold, Color.reset });
    try writer.print("   {s}a{s}       - run all tests\n", .{ Color.bright_cyan, Color.reset });

    if (filter != null and filter.?.len > 0) {
        try writer.print("   {s}Enter{s}   - run filtered tests ({d})\n", .{ Color.bright_cyan, Color.reset, matched_tests });
        try writer.print("   {s}c{s}       - clear filter\n", .{ Color.bright_cyan, Color.reset });
    }

    if (has_results and failed_count > 0) {
        try writer.print("   {s}f{s}       - run failed tests ({d})\n", .{ Color.bright_cyan, Color.reset, failed_count });
    }

    try writer.print("   {s}/{s}       - filter by pattern\n", .{ Color.bright_cyan, Color.reset });
    try writer.print("   {s}h{s}       - show help\n", .{ Color.bright_cyan, Color.reset });
    try writer.print("   {s}q{s}       - quit\n\n", .{ Color.bright_cyan, Color.reset });

    try writer.print(" {s}{s}{s} ", .{ Color.bright_cyan, Icons.pointer, Color.reset });
}

fn displayResults(writer: anytype, allocator: std.mem.Allocator, results: []TestResult) !void {
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
            entry.value_ptr.* = std.ArrayList(TestResult){};
        }
        try entry.value_ptr.append(result);
    }

    // Sort suites
    var suites = std.ArrayList([]const u8){};
    defer suites.deinit(allocator);
    var suite_iter = suite_map.iterator();
    while (suite_iter.next()) |entry| {
        try suites.append(entry.key_ptr.*);
    }
    std.mem.sort([]const u8, suites.items, {}, struct {
        fn lessThan(_: void, a: []const u8, b: []const u8) bool {
            return std.mem.order(u8, a, b) == .lt;
        }
    }.lessThan);

    var passed_count: u32 = 0;
    var failed_count: u32 = 0;
    var failed_tests = std.ArrayList(TestResult){};
    defer failed_tests.deinit(allocator);

    try writer.print("\n{s}─────────────────────────────────────────{s}\n", .{ Color.dim, Color.reset });
    try writer.print(" {s}Test Results{s}\n", .{ Color.bold, Color.reset });
    try writer.print("{s}─────────────────────────────────────────{s}\n\n", .{ Color.dim, Color.reset });

    for (suites.items) |suite| {
        const tests = suite_map.get(suite).?;

        var suite_passed: u32 = 0;
        var suite_failed: u32 = 0;
        var suite_duration: u64 = 0;

        for (tests.items) |t| {
            suite_duration += t.duration_ns;
            if (t.passed) {
                suite_passed += 1;
                passed_count += 1;
            } else {
                suite_failed += 1;
                failed_count += 1;
                try failed_tests.append(t);
            }
        }

        // Print suite header
        if (suite_failed > 0) {
            try writer.print(" {s}{s} FAIL {s} {s}{s}{s} ", .{
                Color.bg_red,
                Color.white,
                Color.reset,
                Color.white,
                suite,
                Color.reset,
            });
        } else {
            try writer.print(" {s}{s}{s} {s}{s}{s} ", .{
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
            try writer.print("{s}{d} failed{s}", .{
                Color.red,
                suite_failed,
                Color.reset,
            });
            if (suite_passed > 0) {
                try writer.print(" {s}|{s} {s}{d} passed{s}", .{
                    Color.dim,
                    Color.reset,
                    Color.green,
                    suite_passed,
                    Color.reset,
                });
            }
        } else {
            try writer.print("{s}({d}){s}", .{
                Color.green,
                suite_passed,
                Color.reset,
            });
        }

        try writer.print(" ", .{});
        try formatDuration(writer, suite_duration);
        try writer.print("\n", .{});

        // Print failed test names
        for (tests.items) |t| {
            if (!t.passed) {
                try writer.print("   {s}{s}{s} {s}{s}{s}\n", .{
                    Color.red,
                    Icons.cross,
                    Color.reset,
                    Color.red,
                    t.test_name,
                    Color.reset,
                });
            }
        }
    }

    // Print detailed failure information
    if (failed_tests.items.len > 0) {
        try writer.print("\n{s}⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯{s}\n", .{
            Color.red,
            Color.reset,
        });
        try writer.print(" {s}Failed Tests {d}{s}\n", .{
            Color.red,
            failed_tests.items.len,
            Color.reset,
        });
        try writer.print("{s}⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯{s}\n\n", .{
            Color.red,
            Color.reset,
        });

        for (failed_tests.items, 0..) |fail, idx| {
            try writer.print(" {s}FAIL{s} {s}{s} {s}{s}{s}{s}\n", .{
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
                try writer.print("\n", .{});
                var lines = std.mem.tokenizeScalar(u8, msg, '\n');
                while (lines.next()) |line| {
                    try writer.print("      {s}{s} {s}{s}{s}\n", .{
                        Color.red,
                        Icons.cross,
                        Color.reset,
                        line,
                        Color.reset,
                    });
                }
            }

            if (idx < failed_tests.items.len - 1) {
                try writer.print("\n", .{});
            }
        }
    }

    // Print summary
    try writer.print("\n{s}─────────────────────────────────────────{s}\n", .{ Color.dim, Color.reset });
    try writer.print(" {s}Summary{s}\n", .{ Color.bold, Color.reset });

    if (failed_count > 0) {
        try writer.print("   {s}Tests:{s}  {s}{d} failed{s}", .{
            Color.bold,
            Color.reset,
            Color.red,
            failed_count,
            Color.reset,
        });
        if (passed_count > 0) {
            try writer.print(" {s}|{s} {s}{d} passed{s}", .{
                Color.dim,
                Color.reset,
                Color.green,
                passed_count,
                Color.reset,
            });
        }
    } else {
        try writer.print("   {s}Tests:{s}  {s}{d} passed{s}", .{
            Color.bold,
            Color.reset,
            Color.green,
            passed_count,
            Color.reset,
        });
    }
    try writer.print(" {s}({d}){s}\n", .{
        Color.dim,
        results.len,
        Color.reset,
    });
    try writer.print("{s}─────────────────────────────────────────{s}\n", .{ Color.dim, Color.reset });
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const stdout_file = std.fs.File.stdout();
    const stdin_file = std.fs.File.stdin();

    var stdout_buffer: [4096]u8 = undefined;
    var stdin_buffer: [4096]u8 = undefined;

    var stdout_writer = stdout_file.writer(&stdout_buffer);
    var stdin_reader = stdin_file.reader(&stdin_buffer);

    const stdout = &stdout_writer.interface;
    const stdin = &stdin_reader.interface;

    // Check if we have a TTY
    if (!stdout_file.isTty()) {
        try stdout.print("Error: Interactive test runner requires a TTY\n", .{});
        try stdout.flush();
        return error.NoTTY;
    }

    // Initialize test states
    var test_states = std.ArrayList(TestState){};
    defer test_states.deinit(allocator);

    for (builtin.test_functions, 0..) |t, i| {
        try test_states.append(.{
            .index = i,
            .name = t.name,
            .suite = extractSuiteName(t.name),
            .test_name = extractTestName(t.name),
            .result = null,
        });
    }

    var filter_buf: [256]u8 = undefined;
    var filter: ?[]const u8 = null;
    var last_results = std.ArrayList(TestResult){};
    defer {
        for (last_results.items) |*result| {
            if (result.error_msg) |msg| {
                allocator.free(msg);
            }
        }
        last_results.deinit(allocator);
    }

    // Main interactive loop
    while (true) {
        try clearScreen(stdout);

        // Count matched tests and failed tests
        var matched_count: usize = 0;
        var failed_count: usize = 0;

        for (test_states.items) |*state| {
            const matches = if (filter) |f| matchesFilter(state.name, f) else true;
            if (matches) matched_count += 1;

            if (state.result) |r| {
                if (!r.passed) failed_count += 1;
            }
        }

        const has_results = last_results.items.len > 0;

        try displayMenu(stdout, filter, test_states.items.len, matched_count, has_results, failed_count);
        try stdout.flush();

        // Read command
        const input_line = (stdin.takeDelimiterExclusive('\n') catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        }) orelse "";
        const input = std.mem.trim(u8, input_line, &std.ascii.whitespace);

        if (input.len == 0) {
            // Enter pressed - run filtered tests if we have a filter
            if (filter != null and filter.?.len > 0) {
                // Run filtered tests
                try runTests(allocator, stdout, stdin, &test_states, filter, &last_results);
            }
            continue;
        }

        if (std.mem.eql(u8, input, "q")) {
            break;
        } else if (std.mem.eql(u8, input, "a")) {
            // Run all tests
            filter = null;
            try runTests(allocator, stdout, stdin, &test_states, null, &last_results);
        } else if (std.mem.eql(u8, input, "f")) {
            // Run failed tests
            if (has_results and failed_count > 0) {
                try runFailedTests(allocator, stdout, stdin, &test_states, &last_results);
            }
        } else if (std.mem.eql(u8, input, "c")) {
            // Clear filter
            filter = null;
        } else if (input[0] == '/') {
            // Set filter
            const filter_text = std.mem.trim(u8, input[1..], &std.ascii.whitespace);
            if (filter_text.len > 0) {
                @memcpy(filter_buf[0..filter_text.len], filter_text);
                filter = filter_buf[0..filter_text.len];
            } else {
                filter = null;
            }
        } else if (std.mem.eql(u8, input, "h")) {
            try displayHelp(stdout, stdin);
        }
    }

    try stdout.print("\n{s}Goodbye!{s}\n\n", .{ Color.cyan, Color.reset });
    try stdout.flush();
}

fn runTests(allocator: std.mem.Allocator, writer: anytype, reader: anytype, test_states: *std.ArrayList(TestState), filter_pattern: ?[]const u8, last_results: *std.ArrayList(TestResult)) !void {
    // Clear previous results
    for (last_results.items) |*result| {
        if (result.error_msg) |msg| {
            allocator.free(msg);
        }
    }
    last_results.clearRetainingCapacity();

    // Count tests to run
    var tests_to_run = std.ArrayList(usize){};
    defer tests_to_run.deinit(allocator);

    for (test_states.items) |state| {
        const matches = if (filter_pattern) |f| matchesFilter(state.name, f) else true;
        if (matches) {
            try tests_to_run.append(state.index);
        }
    }

    if (tests_to_run.items.len == 0) {
        try writer.print("\n{s}No tests match the filter{s}\n", .{ Color.yellow, Color.reset });
        try writer.print("\nPress Enter to continue...", .{});
        try writer.flush();
        _ = try reader.readByte();
        return;
    }

    try clearScreen(writer);
    try writer.print("\n{s}Running {d} tests...{s}\n\n", .{ Color.cyan, tests_to_run.items.len, Color.reset });

    for (tests_to_run.items, 0..) |test_idx, i| {
        const state = &test_states.items[test_idx];

        try printProgress(writer, i + 1, tests_to_run.items.len, state.suite);

        const result = try runTestInProcess(allocator, test_idx);
        state.result = result;
        try last_results.append(result);
    }

    try clearLine(writer);
    try displayResults(writer, allocator, last_results.items);

    try writer.print("\nPress Enter to continue...", .{});
    try writer.flush();
    _ = try reader.readByte();
}

fn runFailedTests(allocator: std.mem.Allocator, writer: anytype, reader: anytype, test_states: *std.ArrayList(TestState), last_results: *std.ArrayList(TestResult)) !void {
    // Clear previous results
    for (last_results.items) |*result| {
        if (result.error_msg) |msg| {
            allocator.free(msg);
        }
    }
    last_results.clearRetainingCapacity();

    // Find failed tests
    var failed_indices = std.ArrayList(usize){};
    defer failed_indices.deinit(allocator);

    for (test_states.items) |state| {
        if (state.result) |r| {
            if (!r.passed) {
                try failed_indices.append(state.index);
            }
        }
    }

    if (failed_indices.items.len == 0) {
        try writer.print("\n{s}No failed tests to run{s}\n", .{ Color.green, Color.reset });
        try writer.print("\nPress Enter to continue...", .{});
        _ = try reader.readByte();
        return;
    }

    try clearScreen(writer);
    try writer.print("\n{s}Re-running {d} failed tests...{s}\n\n", .{ Color.yellow, failed_indices.items.len, Color.reset });

    for (failed_indices.items, 0..) |test_idx, i| {
        const state = &test_states.items[test_idx];

        try printProgress(writer, i + 1, failed_indices.items.len, state.suite);

        const result = try runTestInProcess(allocator, test_idx);
        state.result = result;
        try last_results.append(result);
    }

    try clearLine(writer);
    try displayResults(writer, allocator, last_results.items);

    try writer.print("\nPress Enter to continue...", .{});
    try writer.flush();
    _ = try reader.readByte();
}

fn displayHelp(writer: anytype, reader: anytype) !void {
    try clearScreen(writer);
    try writer.print("\n{s}┌─────────────────────────────────────────┐{s}\n", .{ Color.cyan, Color.reset });
    try writer.print("{s}│{s}          Help - Test Runner            {s}│{s}\n", .{ Color.cyan, Color.reset, Color.cyan, Color.reset });
    try writer.print("{s}└─────────────────────────────────────────┘{s}\n\n", .{ Color.cyan, Color.reset });

    try writer.print(" {s}Commands:{s}\n\n", .{ Color.bold, Color.reset });
    try writer.print("   {s}a{s}         Run all tests\n", .{ Color.bright_cyan, Color.reset });
    try writer.print("   {s}f{s}         Run only failed tests from last run\n", .{ Color.bright_cyan, Color.reset });
    try writer.print("   {s}/pattern{s}  Filter tests by pattern (substring match)\n", .{ Color.bright_cyan, Color.reset });
    try writer.print("   {s}c{s}         Clear current filter\n", .{ Color.bright_cyan, Color.reset });
    try writer.print("   {s}Enter{s}     Run filtered tests (when filter is active)\n", .{ Color.bright_cyan, Color.reset });
    try writer.print("   {s}h{s}         Show this help\n", .{ Color.bright_cyan, Color.reset });
    try writer.print("   {s}q{s}         Quit\n\n", .{ Color.bright_cyan, Color.reset });

    try writer.print(" {s}Examples:{s}\n\n", .{ Color.bold, Color.reset });
    try writer.print("   {s}/evm{s}      Filter for tests containing 'evm'\n", .{ Color.dim, Color.reset });
    try writer.print("   {s}/rlp{s}      Filter for tests containing 'rlp'\n", .{ Color.dim, Color.reset });
    try writer.print("   {s}c{s}         Clear filter and show all tests\n\n", .{ Color.dim, Color.reset });

    try writer.print("\nPress Enter to continue...", .{});
    try writer.flush();
    _ = try reader.readByte();
}
