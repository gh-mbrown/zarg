const std = @import("std");
const utils = @import("parse_utils.zig");
const values = @import("parse_values.zig");
const Allocator = std.mem.Allocator;
const Args = std.process.Args;

pub const ArgParseErrors = error{
    IncompleteArgs,
    NoFlagValue,
};

pub fn parseArgs(
    comptime T: type,
    allocator: Allocator,
    arguments: Args,
) !utils.genReturnType(T) {
    const flag_fields = comptime utils.returnField("flags", T);
    const arg_fields = comptime utils.returnField("arguments", T);

    const returnType = comptime utils.genReturnType(T);
    const null_fields = comptime utils.createNullStruct(flag_fields, arg_fields);

    var args = try arguments.toSlice(allocator);
    defer allocator.free(args);

    inline for (flag_fields) |ff| @"continue": {
        const index = utils.getIndex(ff.name, args) orelse break :@"continue";

        if (index + 1 >= args.len) return ArgParseErrors.IncompleteArgs;
        if (std.mem.startsWith(u8, args[index + 1], "-")) {
            if (@typeInfo(ff.type) == .optional) break :@"continue" else return ArgParseErrors.NoFlagValue;
        }

        const value = try values.parseValues(ff.type, args[index + 1]);

        args = utils.removeIndexFromArray([]u8, args, index + 1);
        args = utils.removeIndexFromArray([]u8, args, index);

        @field(null_fields, ff.name) = value;
    }

    const returnValue = utils.returnValue(returnType, null_fields);
}

test {}
