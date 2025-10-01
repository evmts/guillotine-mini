#!/usr/bin/env python3
"""
Generate Zig test files from execution-specs JSON test files.
This script scans the execution-specs directory and creates a Zig test file
for each JSON test file.
"""

import os
import json
import sys
from pathlib import Path


def sanitize_test_name(name: str) -> str:
    """Convert test name to valid Zig identifier."""
    # Replace invalid characters with underscores
    sanitized = name.replace("-", "_").replace(".", "_").replace(" ", "_")
    # Remove any other special characters
    sanitized = "".join(c if c.isalnum() or c == "_" else "_" for c in sanitized)
    # Ensure it doesn't start with a number
    if sanitized and sanitized[0].isdigit():
        sanitized = "test_" + sanitized
    return sanitized


def generate_test_file(json_path: Path, output_dir: Path, specs_root: Path) -> None:
    """Generate a Zig test file for a JSON test file."""
    # Read and parse JSON to get test names
    try:
        with open(json_path, "r") as f:
            data = json.load(f)
    except (json.JSONDecodeError, IOError) as e:
        print(f"Warning: Could not parse {json_path}: {e}", file=sys.stderr)
        return

    if not isinstance(data, dict):
        print(f"Warning: {json_path} does not contain a test object", file=sys.stderr)
        return

    # Get relative path from specs root for the JSON file
    rel_path = json_path.relative_to(specs_root)

    # Create output file path
    output_file = output_dir / rel_path.with_suffix(".zig")
    output_file.parent.mkdir(parents=True, exist_ok=True)

    # Generate Zig test code
    zig_code = ['const std = @import("std");']
    zig_code.append('const testing = std.testing;')
    zig_code.append('const runner = @import("../../runner.zig");')
    zig_code.append("")

    # Generate a test for each test case in the JSON file
    for test_name in data.keys():
        safe_test_name = sanitize_test_name(test_name)

        # Absolute path to JSON file from repository root
        # When tests run, cwd is the repository root
        json_abs_path = f"execution-specs/tests/eest/static/state_tests/{rel_path}"

        zig_code.append(f'test "{safe_test_name}" {{')
        zig_code.append("    const allocator = testing.allocator;")
        zig_code.append("")
        zig_code.append("    // Read and parse the JSON test file")
        zig_code.append(f'    const json_path = "{json_abs_path}";')
        zig_code.append("    const json_content = try std.fs.cwd().readFileAlloc(allocator, json_path, 100 * 1024 * 1024);")
        zig_code.append("    defer allocator.free(json_content);")
        zig_code.append("")
        zig_code.append("    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_content, .{});")
        zig_code.append("    defer parsed.deinit();")
        zig_code.append("")
        zig_code.append("    // Get the specific test case")
        zig_code.append(f'    const test_case = parsed.value.object.get("{test_name}") orelse return error.TestNotFound;')
        zig_code.append("")
        zig_code.append("    // Run the test")
        zig_code.append("    try runner.runJsonTest(allocator, test_case);")
        zig_code.append("}")
        zig_code.append("")

    # Write the Zig file
    with open(output_file, "w") as f:
        f.write("\n".join(zig_code))

    print(f"Generated: {output_file}")


def main():
    # Get the repository root
    script_dir = Path(__file__).parent
    repo_root = script_dir.parent
    specs_root = repo_root / "execution-specs" / "tests" / "eest" / "static" / "state_tests"
    output_root = repo_root / "test" / "specs" / "generated"

    # Clean output directory
    if output_root.exists():
        import shutil
        shutil.rmtree(output_root)
    output_root.mkdir(parents=True, exist_ok=True)

    # Find all JSON test files
    json_files = list(specs_root.rglob("*.json"))
    print(f"Found {len(json_files)} JSON test files")
    print(f"Generating all test files...")

    # Generate test files
    for i, json_file in enumerate(json_files, 1):
        if i % 100 == 0:
            print(f"Progress: {i}/{len(json_files)} files...")
        generate_test_file(json_file, output_root, specs_root)

    print(f"\nGenerated {len(json_files)} test files in {output_root}")


if __name__ == "__main__":
    main()
