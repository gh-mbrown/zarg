const std = @import("std");
const utils = @import("parse_utils.zig");
const values = @import("parse_values.zig");
const Allocator = std.mem.Allocator;

pub const ArgParseErrors = error{
    IncompleteArgs,
    NoFlagValue,
};

pub fn parseArgs(
    comptime T: type,
    allocator: Allocator,
) !T {
    const flag_fields = comptime utils.returnFields("flags", T);
    _ = comptime utils.returnFields("arguments", T);

    const args = try std.process.argsAlloc(allocator);
    defer allocator.free(args);

    inline for (flag_fields) |ff| @"continue": {
        const index = utils.getIndex(ff.name, args) orelse break :@"continue";

        if (index + 1 >= args.len) return ArgParseErrors.IncompleteArgs;
        if (std.mem.startsWith(u8, args[index + 1], "-")) {
            if (@typeInfo(ff.type) == .optional) break :@"continue" else return ArgParseErrors.NoFlagValue;
        }

        const value = try values.parseValues(ff.type, args[index + 1]);
    }
}
