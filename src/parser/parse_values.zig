const std = @import("std");
const Type = std.builtin.Type;

pub fn parseValues(
    comptime T: type,
    value: []const u8,
) !T {
    const ti = comptime @typeInfo(T);
    const return_value = switch (ti) {
        .bool => true,
        .int => |i| blk: {
            const num = if (i.signedness == .signed) try std.fmt.parseInt(T, value, 10) else try std.fmt.parseUnsigned(T, value, 10);
            break :blk num;
        },
        .float => blk: {
            const num = try std.fmt.parseFloat(T, value);
            break :blk num;
        },
        .pointer => |p| blk: {
            if (p.size != .slice) @compileError("Pointer is not a slice");
            const c = comptime @typeInfo(p.child);
            if (c != .int and c.int.signedness != .unsigned) @compileError("Not a unsigned integer");
            break :blk value;
        },
        else => {
            const err_msg = std.fmt.comptimePrint("Passed type is not currently handled: {any}", .{ti});
            @compileError(err_msg);
        },
    };
    return return_value;
}
