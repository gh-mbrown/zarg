const std = @import("std");
const Type = std.builtin.Type;

pub fn parseValues(
    comptime T: type,
    value: []const u8,
) !T {
    const ti = comptime @typeInfo(T);
    if (ti == .bool) return true;

    if (std.mem.startsWith(u8, value, "--") or std.mem.startsWith(u8, value, "-")) return error.NoValue;

    const return_value = switch (ti) {
        .optional => |o| try parseValues(o.child, value),
        .bool => true,
        .int => |i| if (i.signedness == .signed) try std.fmt.parseInt(T, value, 10) else try std.fmt.parseUnsigned(T, value, 10),
        .float => try std.fmt.parseFloat(T, value),
        .pointer => |p| blk: {
            if (p.size != .slice) @compileError("Pointer is not a slice");
            const c = comptime @typeInfo(p.child);
            if (c != .int and c.int.signedness != .unsigned) @compileError("Not a unsigned integer");
            break :blk value;
        },
        else => @compileError("Passed type is not currently handled: " ++ ti),
    };
    return return_value;
}
