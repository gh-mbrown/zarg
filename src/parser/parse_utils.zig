const std = @import("std");
const StructField = std.builtin.Type.StructField;

pub fn returnFields(comptime field_name: []const u8, comptime T: type) []StructField {
    const ti = @typeInfo(T);
    if (ti != .@"struct") @compileError("Passed type is not a struct");
    const field = comptime findField(field_name, ti.@"struct".fields);
    const f_ti = @typeInfo(field.type);
    if (f_ti != .@"struct") @compileError("Passed field is not a struct");
    return ti.@"struct".fields;
}

fn findField(comptime field_name: []const u8, comptime fields: []const StructField) StructField {
    inline for (fields) |f| if (std.mem.eql(u8, field_name, f.name)) return f;
    const err_msg = std.fmt.comptimePrint("The passed fields do not contain one with the name {s}", .{field_name});
    @compileError(err_msg);
}

pub fn getIndex(comptime field_name: []const u8, args: [][]const u8) ?usize {
    for (args, 0..) |a, i| {
        if (!std.mem.startsWith(u8, a, "--")) continue;

        if (std.mem.eql(u8, field_name, a[2..])) return i;
    }

    return null;
}
