const std = @import("std");
const builtin = @import("builtin");
const utils = @import("test/utils.zig");
const watcher = @import("test/watcher.zig");

const Color = utils.Color;
const Icons = utils.Icons;
const TestResult = utils.TestResult;

const TestState = struct {
    index: usize,
    name: []const u8,
    suite: []const u8,
    test_name: []const u8,
    result: ?TestResult,
    log_output: ?[]const u8 = null,
};

const LogBuffer = struct {
    lines: std.ArrayList([]const u8),
    allocator: std.mem.Allocator,
    max_lines: usize,

    fn init(allocator: std.mem.Allocator, max_lines: usize) LogBuffer {
        return .{
            .lines = std.ArrayList([]const u8){},
            .allocator = allocator,
            .max_lines = max_lines,
        };
    }

    fn deinit(self: *LogBuffer) void {
        for (self.lines.items) |line| {
            self.allocator.free(line);
        }
        self.lines.deinit(self.allocator);
    }

    fn addLine(self: *LogBuffer, line: []const u8) !void {
        const owned_line = try self.allocator.dupe(u8, line);

        if (self.lines.items.len >= self.max_lines) {
            // Remove oldest line
            const old_line = self.lines.orderedRemove(0);
            self.allocator.free(old_line);
        }

        try self.lines.append(self.allocator, owned_line);
    }

    fn clear(self: *LogBuffer) void {
        for (self.lines.items) |line| {
            self.allocator.free(line);
        }
        self.lines.clearRetainingCapacity();
    }

    fn getTail(self: *LogBuffer, n: usize) [][]const u8 {
        const start = if (self.lines.items.len > n) self.lines.items.len - n else 0;
        return self.lines.items[start..];
    }
};

fn runTestsParallelWithProgress(allocator: std.mem.Allocator, writer: anytype, test_indices: []const usize, max_workers: usize, show_logs: bool) ![]TestResult {
    _ = show_logs;
    if (test_indices.len == 0) return &[_]TestResult{};

    // Create task list
    const tasks = try allocator.alloc(utils.TestTask, test_indices.len);
    defer allocator.free(tasks);

    for (tasks, 0..) |*task, i| {
        task.* = .{ .index = test_indices[i] };
    }

    // Create worker threads
    const worker_count = @min(max_workers, test_indices.len);
    const threads = try allocator.alloc(std.Thread, worker_count);
    defer allocator.free(threads);

    var next_task_idx: usize = 0;
    var completed_count: usize = 0;
    var task_mutex = std.Thread.Mutex{};

    const WorkerContext = struct {
        tasks_ptr: [*]utils.TestTask,
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

                // Run the test
                const task = &ctx.tasks_ptr[task_idx];
                const result = utils.runTestInProcess(ctx.allocator, task.index) catch |err| {
                    std.debug.print("Error running test {d}: {}\n", .{ task.index, err });
                    continue;
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

    // Launch workers
    for (threads, 0..) |*thread, i| {
        thread.* = try std.Thread.spawn(.{}, workerFn, .{WorkerContext{
            .tasks_ptr = tasks.ptr,
            .tasks_len = tasks.len,
            .next_idx = &next_task_idx,
            .completed = &completed_count,
            .mutex = &task_mutex,
            .allocator = allocator,
        }});
        _ = i;
    }

    // Show progress while tests run
    const start_time = std.time.milliTimestamp();
    while (true) {
        task_mutex.lock();
        const current = completed_count;
        task_mutex.unlock();

        if (current >= test_indices.len) break;

        // Update progress display
        const elapsed_ms = std.time.milliTimestamp() - start_time;
        const elapsed_sec = @as(f64, @floatFromInt(elapsed_ms)) / 1000.0;
        const rate = if (elapsed_sec > 0) @as(f64, @floatFromInt(current)) / elapsed_sec else 0;

        try writer.print("\r{s}Progress:{s} {d}/{d} tests ({d:.1} tests/sec) ", .{
            Color.cyan,
            Color.reset,
            current,
            test_indices.len,
            rate,
        });

        std.time.sleep(100 * std.time.ns_per_ms); // Update every 100ms
    }

    try writer.print("\n", .{});

    // Wait for all workers
    for (threads) |thread| {
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

fn printProgressWithLogs(writer: anytype, current: usize, total: usize, suite_name: []const u8, test_name: []const u8, log_buffer: *LogBuffer, show_logs: bool) !void {
    const percent = (current * 100) / total;
    const bar_width = 40;
    const filled = (current * bar_width) / total;

    // Clear previous output
    try writer.print("\x1b[2J\x1b[H", .{}); // Clear screen and move to home

    // Header
    try writer.print("\n {s}Running Tests{s}\n", .{ Color.bold, Color.reset });
    try writer.print(" {s}─────────────────────────────────────────{s}\n\n", .{ Color.dim, Color.reset });

    // Progress bar
    try writer.print(" {s}[{s}", .{ Color.dim, Color.reset });
    for (0..bar_width) |i| {
        if (i < filled) {
            try writer.print("{s}━{s}", .{ Color.bright_cyan, Color.reset });
        } else {
            try writer.print("{s}━{s}", .{ Color.gray, Color.reset });
        }
    }
    try writer.print("{s}]{s} {s}{d}%{s}\n\n", .{ Color.dim, Color.reset, Color.bright_cyan, percent, Color.reset });

    // Current test info
    try writer.print(" {s}Suite:{s} {s}{s}{s}\n", .{ Color.bold, Color.reset, Color.cyan, suite_name, Color.reset });
    try writer.print(" {s}Test:{s}  {s}{s}{s}\n", .{ Color.bold, Color.reset, Color.dim, test_name, Color.reset });
    try writer.print(" {s}Progress:{s} {s}{d}/{d}{s}\n\n", .{ Color.bold, Color.reset, Color.gray, current, total, Color.reset });

    if (show_logs) {
        try writer.print(" {s}Recent Output:{s}\n", .{ Color.bold, Color.reset });
        try writer.print(" {s}─────────────────────────────────────────{s}\n", .{ Color.dim, Color.reset });

        const tail_lines = log_buffer.getTail(30);
        if (tail_lines.len == 0) {
            try writer.print(" {s}(no output){s}\n", .{ Color.dim, Color.reset });
        } else {
            for (tail_lines) |line| {
                // Truncate long lines
                const max_len = 80;
                const display_line = if (line.len > max_len) line[0..max_len] else line;
                try writer.print(" {s}{s}{s}\n", .{ Color.gray, display_line, Color.reset });
            }
        }
        try writer.print(" {s}─────────────────────────────────────────{s}\n", .{ Color.dim, Color.reset });
    }
}

fn displayMenu(writer: anytype, filter: ?[]const u8, total_tests: usize, matched_tests: usize, has_results: bool, failed_count: usize, parallel_enabled: bool) !void {
    try writer.print("\n{s}┌─────────────────────────────────────────┐{s}\n", .{ Color.cyan, Color.reset });
    try writer.print("{s}│{s}  Interactive Test Runner {s}v0.15.1{s}  {s}│{s}\n", .{ Color.cyan, Color.reset, Color.gray, Color.reset, Color.cyan, Color.reset });
    try writer.print("{s}└─────────────────────────────────────────┘{s}\n\n", .{ Color.cyan, Color.reset });

    if (filter) |f| {
        if (f.len > 0) {
            try writer.print(" {s}Filter:{s} {s}\"{s}\"{s} {s}({d}/{d} tests){s}\n", .{
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
            try writer.print(" {s}{d} tests total{s}\n", .{ Color.dim, total_tests, Color.reset });
        }
    } else {
        try writer.print(" {s}{d} tests total{s}\n", .{ Color.dim, total_tests, Color.reset });
    }

    // Show parallel execution status
    try writer.print(" {s}Parallel:{s} {s}{s}{s}\n\n", .{
        Color.bold,
        Color.reset,
        if (parallel_enabled) Color.green else Color.red,
        if (parallel_enabled) "enabled" else "disabled",
        Color.reset,
    });

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
    try writer.print("   {s}p{s}       - toggle parallel execution\n", .{ Color.bright_cyan, Color.reset });
    try writer.print("   {s}w{s}       - toggle watch mode (auto-rerun on file changes)\n", .{ Color.bright_cyan, Color.reset });
    try writer.print("   {s}l{s}       - toggle log display (during test runs)\n", .{ Color.bright_cyan, Color.reset });
    try writer.print("   {s}h{s}       - show help\n", .{ Color.bright_cyan, Color.reset });
    try writer.print("   {s}q{s}       - quit\n\n", .{ Color.bright_cyan, Color.reset });

    try writer.print(" {s}{s}{s} ", .{ Color.bright_cyan, Icons.pointer, Color.reset });
}

fn displayHelp(writer: anytype, reader: anytype) !void {
    try utils.clearScreen(writer);
    try writer.print("\n{s}┌─────────────────────────────────────────┐{s}\n", .{ Color.cyan, Color.reset });
    try writer.print("{s}│{s}          Help - Test Runner            {s}│{s}\n", .{ Color.cyan, Color.reset, Color.cyan, Color.reset });
    try writer.print("{s}└─────────────────────────────────────────┘{s}\n\n", .{ Color.cyan, Color.reset });

    try writer.print(" {s}Commands:{s}\n\n", .{ Color.bold, Color.reset });
    try writer.print("   {s}a{s}         Run all tests\n", .{ Color.bright_cyan, Color.reset });
    try writer.print("   {s}f{s}         Run only failed tests from last run\n", .{ Color.bright_cyan, Color.reset });
    try writer.print("   {s}/pattern{s}  Filter tests by pattern (substring match)\n", .{ Color.bright_cyan, Color.reset });
    try writer.print("   {s}c{s}         Clear current filter\n", .{ Color.bright_cyan, Color.reset });
    try writer.print("   {s}p{s}         Toggle parallel execution\n", .{ Color.bright_cyan, Color.reset });
    try writer.print("   {s}l{s}         Toggle log display during test execution\n", .{ Color.bright_cyan, Color.reset });
    try writer.print("   {s}Enter{s}     Run filtered tests (when filter is active)\n", .{ Color.bright_cyan, Color.reset });
    try writer.print("   {s}h{s}         Show this help\n", .{ Color.bright_cyan, Color.reset });
    try writer.print("   {s}q{s}         Quit\n\n", .{ Color.bright_cyan, Color.reset });

    try writer.print(" {s}Examples:{s}\n\n", .{ Color.bold, Color.reset });
    try writer.print("   {s}/evm{s}      Filter for tests containing 'evm'\n", .{ Color.dim, Color.reset });
    try writer.print("   {s}/rlp{s}      Filter for tests containing 'rlp'\n", .{ Color.dim, Color.reset });
    try writer.print("   {s}c{s}         Clear filter and show all tests\n\n", .{ Color.dim, Color.reset });

    try writer.print("\nPress Enter to continue...", .{});
    _ = try reader.readByte();
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const stdout_file = std.fs.File.stdout();
    const stdin_file = std.fs.File.stdin();

    var stdout = stdout_file.deprecatedWriter();
    var stdin = stdin_file.deprecatedReader();

    // Check if we have a TTY
    if (!stdout_file.isTty()) {
        try stdout.print("Error: Interactive test runner requires a TTY\n", .{});
        return error.NoTTY;
    }

    // Check for initial filter from environment
    const env_filter = std.posix.getenv("TEST_FILTER");

    // Initialize test states
    var test_states = std.ArrayList(TestState){};
    defer test_states.deinit(allocator);

    for (builtin.test_functions, 0..) |t, i| {
        try test_states.append(allocator, .{
            .index = i,
            .name = t.name,
            .suite = utils.extractSuiteName(t.name),
            .test_name = utils.extractTestName(t.name),
            .result = null,
        });
    }

    var filter_buf: [256]u8 = undefined;
    var filter: ?[]const u8 = null;

    // Apply environment filter if present
    if (env_filter) |f| {
        const len = @min(f.len, filter_buf.len);
        @memcpy(filter_buf[0..len], f[0..len]);
        filter = filter_buf[0..len];
    }

    var last_results = std.ArrayList(TestResult){};
    defer {
        for (last_results.items) |*result| {
            if (result.error_msg) |msg| {
                allocator.free(msg);
            }
        }
        last_results.deinit(allocator);
    }

    var show_logs_during_run = true;
    var parallel_enabled = true;
    const max_workers = blk: {
        if (std.posix.getenv("TEST_WORKERS")) |workers_str| {
            const workers = std.fmt.parseInt(usize, workers_str, 10) catch 4;
            break :blk workers;
        }
        // Default to CPU count - each test runs an isolated EVM instance
        const cpu_count = std.Thread.getCpuCount() catch 4;
        break :blk cpu_count;
    };

    // Main interactive loop
    while (true) {
        try utils.clearScreen(stdout);

        // Count matched tests and failed tests
        var matched_count: usize = 0;
        var failed_count: usize = 0;

        for (test_states.items) |*state| {
            const matches = if (filter) |f| utils.matchesFilter(state.name, f) else true;
            if (matches) matched_count += 1;

            if (state.result) |r| {
                if (!r.passed) failed_count += 1;
            }
        }

        const has_results = last_results.items.len > 0;

        try displayMenu(stdout, filter, test_states.items.len, matched_count, has_results, failed_count, parallel_enabled);

        // Read command
        const input_line = (try stdin.readUntilDelimiterOrEof(&filter_buf, '\n')) orelse break;

        const input = std.mem.trim(u8, input_line, &std.ascii.whitespace);

        if (input.len == 0) {
            // Enter pressed - run filtered tests if we have a filter
            if (filter != null and filter.?.len > 0) {
                // Run filtered tests
                try runTests(allocator, stdout, stdin, stdout, &test_states, filter, &last_results, show_logs_during_run, parallel_enabled, max_workers);
            }
            continue;
        }

        if (std.mem.eql(u8, input, "q")) {
            break;
        } else if (std.mem.eql(u8, input, "a")) {
            // Run all tests
            filter = null;
            try runTests(allocator, stdout, stdin, stdout, &test_states, null, &last_results, show_logs_during_run, parallel_enabled, max_workers);
        } else if (std.mem.eql(u8, input, "f")) {
            // Run failed tests
            if (has_results and failed_count > 0) {
                try runFailedTests(allocator, stdout, stdin, stdout, &test_states, &last_results, show_logs_during_run, parallel_enabled, max_workers);
            }
        } else if (std.mem.eql(u8, input, "c")) {
            // Clear filter
            filter = null;
        } else if (std.mem.eql(u8, input, "p")) {
            // Toggle parallel execution
            parallel_enabled = !parallel_enabled;
            try utils.clearScreen(stdout);
            try stdout.print("\n{s}Parallel execution {s}{s}{s}\n", .{
                Color.cyan,
                if (parallel_enabled) Color.green else Color.red,
                if (parallel_enabled) "enabled" else "disabled",
                Color.reset,
            });
            try stdout.print("\nPress Enter to continue...", .{});
            _ = try stdin.readByte();
        } else if (std.mem.eql(u8, input, "l")) {
            // Toggle log display
            show_logs_during_run = !show_logs_during_run;
            try utils.clearScreen(stdout);
            try stdout.print("\n{s}Log display {s}{s}{s}\n", .{
                Color.cyan,
                if (show_logs_during_run) Color.green else Color.red,
                if (show_logs_during_run) "enabled" else "disabled",
                Color.reset,
            });
            try stdout.print("\nPress Enter to continue...", .{});
            _ = try stdin.readByte();
        } else if (input.len > 0 and input[0] == '/') {
            // Set filter
            const filter_text = std.mem.trim(u8, input[1..], &std.ascii.whitespace);
            if (filter_text.len > 0) {
                const len = @min(filter_text.len, filter_buf.len);
                @memcpy(filter_buf[0..len], filter_text[0..len]);
                filter = filter_buf[0..len];
            } else {
                filter = null;
            }
        } else if (std.mem.eql(u8, input, "h")) {
            try displayHelp(stdout, stdin);
        }
    }

    try stdout.print("\n{s}Goodbye!{s}\n\n", .{ Color.cyan, Color.reset });
}

fn runTests(allocator: std.mem.Allocator, writer: anytype, reader: anytype, _: anytype, test_states: *std.ArrayList(TestState), filter_pattern: ?[]const u8, last_results: *std.ArrayList(TestResult), show_logs: bool, parallel: bool, max_workers: usize) !void {
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
        const matches = if (filter_pattern) |f| utils.matchesFilter(state.name, f) else true;
        if (matches) {
            try tests_to_run.append(allocator, state.index);
        }
    }

    if (tests_to_run.items.len == 0) {
        try writer.print("\n{s}No tests match the filter{s}\n", .{ Color.yellow, Color.reset });
        try writer.print("\nPress Enter to continue...", .{});
        _ = try reader.readByte();
        return;
    }

    if (parallel and tests_to_run.items.len > 1) {
        // Run tests in parallel with live progress
        try writer.print("\n{s}Running {d} tests in parallel with {d} workers...{s}\n\n", .{
            Color.cyan,
            tests_to_run.items.len,
            max_workers,
            Color.reset,
        });

        const parallel_results = try runTestsParallelWithProgress(
            allocator,
            writer,
            tests_to_run.items,
            max_workers,
            show_logs,
        );
        defer allocator.free(parallel_results);

        for (parallel_results) |result| {
            try last_results.append(allocator, result);
            // Update test state
            for (test_states.items) |*state| {
                if (std.mem.eql(u8, state.name, result.name)) {
                    state.result = result;
                    break;
                }
            }
        }
    } else {
        // Initialize log buffer
        var log_buffer = LogBuffer.init(allocator, 100);
        defer log_buffer.deinit();

        for (tests_to_run.items, 0..) |test_idx, i| {
            const state = &test_states.items[test_idx];

            try printProgressWithLogs(writer, i + 1, tests_to_run.items.len, state.suite, state.test_name, &log_buffer, show_logs);

            const result = try utils.runTestInProcess(allocator, test_idx);
            state.result = result;
            try last_results.append(allocator, result);

            // Show result immediately after test completes
            if (show_logs) {
                const icon = if (result.passed) Icons.check else Icons.cross;
                const color = if (result.passed) Color.green else Color.red;
                const status = if (result.passed) "PASS" else "FAIL";

                const log_msg = try std.fmt.allocPrint(allocator, "{s}{s}{s} {s} {s}.{s}", .{
                    color,
                    icon,
                    Color.reset,
                    status,
                    state.suite,
                    state.test_name,
                });
                defer allocator.free(log_msg);
                try log_buffer.addLine(log_msg);

                // Add error message to log buffer
                if (!result.passed and result.error_msg != null) {
                    const err_msg = try std.fmt.allocPrint(allocator, "  Error: {s}", .{result.error_msg.?});
                    defer allocator.free(err_msg);
                    try log_buffer.addLine(err_msg);
                }
            }
        }
    }

    try utils.displayResults(writer, allocator, last_results.items);

    try writer.print("\nPress Enter to continue...", .{});
    _ = try reader.readByte();
}

fn runFailedTests(allocator: std.mem.Allocator, writer: anytype, reader: anytype, _: anytype, test_states: *std.ArrayList(TestState), last_results: *std.ArrayList(TestResult), show_logs: bool, parallel: bool, max_workers: usize) !void {
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
                try failed_indices.append(allocator, state.index);
            }
        }
    }

    if (failed_indices.items.len == 0) {
        try writer.print("\n{s}No failed tests to run{s}\n", .{ Color.green, Color.reset });
        try writer.print("\nPress Enter to continue...", .{});
        _ = try reader.readByte();
        return;
    }

    if (parallel and failed_indices.items.len > 1) {
        // Run tests in parallel with live progress
        try writer.print("\n{s}Running {d} failed tests in parallel with {d} workers...{s}\n\n", .{
            Color.cyan,
            failed_indices.items.len,
            max_workers,
            Color.reset,
        });

        const parallel_results = try runTestsParallelWithProgress(
            allocator,
            writer,
            failed_indices.items,
            max_workers,
            show_logs,
        );
        defer allocator.free(parallel_results);

        for (parallel_results) |result| {
            try last_results.append(allocator, result);
            // Update test state
            for (test_states.items) |*state| {
                if (std.mem.eql(u8, state.name, result.name)) {
                    state.result = result;
                    break;
                }
            }
        }
    } else {
        // Initialize log buffer
        var log_buffer = LogBuffer.init(allocator, 100);
        defer log_buffer.deinit();

        for (failed_indices.items, 0..) |test_idx, i| {
            const state = &test_states.items[test_idx];

            try printProgressWithLogs(writer, i + 1, failed_indices.items.len, state.suite, state.test_name, &log_buffer, show_logs);

            const result = try utils.runTestInProcess(allocator, test_idx);
            state.result = result;
            try last_results.append(allocator, result);

            // Show result immediately after test completes
            if (show_logs) {
                const icon = if (result.passed) Icons.check else Icons.cross;
                const color = if (result.passed) Color.green else Color.red;
                const status = if (result.passed) "PASS" else "FAIL";

                const log_msg = try std.fmt.allocPrint(allocator, "{s}{s}{s} {s} {s}.{s}", .{
                    color,
                    icon,
                    Color.reset,
                    status,
                    state.suite,
                    state.test_name,
                });
                defer allocator.free(log_msg);
                try log_buffer.addLine(log_msg);

                // Add error message to log buffer
                if (!result.passed and result.error_msg != null) {
                    const err_msg = try std.fmt.allocPrint(allocator, "  Error: {s}", .{result.error_msg.?});
                    defer allocator.free(err_msg);
                    try log_buffer.addLine(err_msg);
                }
            }
        }
    }

    try utils.displayResults(writer, allocator, last_results.items);

    try writer.print("\nPress Enter to continue...", .{});
    _ = try reader.readByte();
}
