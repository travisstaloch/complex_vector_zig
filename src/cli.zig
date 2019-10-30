const std = @import("std");
const ChildProcess = std.ChildProcess;
const Op = @import("common.zig").Op;
const warn = std.debug.warn;

fn printCmd(cwd: []const u8, argv: []const []const u8) void {
    std.debug.warn("cd {} && ", cwd);
    for (argv) |arg| {
        std.debug.warn("{} ", arg);
    }
    std.debug.warn("\n");
}

fn exec(cwd: []const u8, argv: []const []const u8, a: *std.mem.Allocator) !ChildProcess.ExecResult {
    const max_output_size = 100 * 1024;

    const result = ChildProcess.exec(a, argv, null, null, max_output_size) catch |err| {
        std.debug.warn("The following command failed:\n");
        printCmd(cwd, argv);
        return err;
    };
    switch (result.term) {
        .Exited => |code| {
            if (code != 0) {
                std.debug.warn("The following command exited with error code {}:\n", code);
                printCmd(cwd, argv);
                std.debug.warn("stderr:\n{}\n", result.stderr);
                return error.CommandFailed;
            }
        },
        else => {
            std.debug.warn("The following command terminated unexpectedly:\n");
            printCmd(cwd, argv);
            std.debug.warn("stderr:\n{}\n", result.stderr);
            return error.CommandFailed;
        },
    }
    return result;
}

test "call julia in shell" {
    const DefaultPrng = std.rand.Xoroshiro128;
    var prng = DefaultPrng.init(0);
    prng.seed(std.time.timestamp());
    var a = &std.heap.ArenaAllocator.init(std.heap.direct_allocator).allocator;

    var i = isize(0);
    while (i < 20) : (i += 1) {
        var f1 = prng.random.float(f64) * 100.0 - 50.0;
        var f2 = prng.random.float(f64) * 100.0 - 50.0;
        var f3 = prng.random.float(f64) * 100.0 - 50.0;
        var f4 = prng.random.float(f64) * 100.0 - 50.0;
        var op_code = prng.random.int(u2);
        var op = @intToEnum(Op, op_code);
        const opstr = switch (op) {
            Op.add => "+",
            Op.sub => "-",
            Op.mul => "*",
            Op.div => "/",
        };
        var buf1: [500]u8 = undefined;
        // var buf2: [400]u8 = undefined;
        var s = try std.fmt.bufPrint(buf1[0..], "\"println(({d:.4} + {d:.4}im) {} ({d:.4} + {d:.4}im))\"", f1, f2, opstr, f3, f4);
        // var s2 = try std.fmt.bufPrint(buf2[0..], "{}", s);
        // warn("julia -e {}\n", s);

        const exec_result = try exec(".", [_][]const u8{ "julia", "-e", s }, a);
        std.time.sleep(100000000);
        warn("exec_result: {} {}\n", exec_result.stdout, exec_result.stderr);
        // if (exec_result.stdout.len > 0) {
        //   warn("stdout: {}\n", exec_result.stdout);
        // } else if (exec_result.stderr.len > 0) {
        //   warn("stderr: {}\n", exec_result.stderr);
        // } else {
        //     warn("error: {}", exec_result);
        // }
        warn("stderr: {}\n", exec_result);
    }
}
