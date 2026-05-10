const std = @import("std");
const StructField = std.builtin.Type.StructField;
const Attributes = StructField.Attributes;

pub fn returnField(comptime field_name: []const u8, comptime T: type) []StructField {
    const ti = @typeInfo(T);
    if (ti != .@"struct") @compileError("Passed type " ++ @typeName(T) ++ " is not a struct");
    const field = comptime findField(field_name, ti.@"struct".fields);
    const f_ti = @typeInfo(field.type);
    if (f_ti != .@"struct") @compileError("Passed field " ++ field_name ++ "is not a struct");
    return ti.@"struct".fields;
}

fn findField(comptime field_name: []const u8, comptime fields: []const StructField) StructField {
    inline for (fields) |f| {
        if (std.mem.eql(u8, field_name, f.name)) return f;
    }
    @compileError("The passed fields do not contain one with the name " ++ field_name);
}

pub fn getIndex(comptime field_name: []const u8, args: [][]const u8) ?usize {
    for (args, 0..) |a, i| {
        if (!std.mem.startsWith(u8, a, "--")) continue;

        if (std.mem.eql(u8, field_name, a[2..])) return i;
    }

    return null;
}

pub fn removeIndexFromArray(
    comptime T: type,
    arr: []T,
    index: usize,
) []T {
    std.mem.copyForwards(T, arr[index..], arr[index + 1 ..]);
    return arr[0 .. arr.len - 1];
}

pub fn genReturnType(
    comptime T: type,
) type {
    comptime {
        const tot_fields: []StructField = returnField("flags", T) ++ returnField("arguments", T);
        var field_names: [tot_fields.len][]u8 = undefined;
        var field_types: [tot_fields.len]type = undefined;
        var field_attr: [tot_fields.len]Attributes = undefined;

        for (tot_fields, 0..) |t, i| {
            field_names[i] = t.name;
            field_types[i] = t.type;
            field_attr[i] = Attributes{
                .@"comptime" = false,
                .@"align" = @alignOf(t.type),
                .default_value_ptr = t.default_value_ptr,
            };
        }

        const ResultType = @Struct(.auto, null, &field_names, &field_types, &field_attr);
        return ResultType;
    }
}

fn genNullReturnType(
    comptime flag_fields: []StructField,
    comptime arg_fields: []StructField,
) type {
    comptime {
        const tot_arr: []StructField = flag_fields ++ arg_fields;

        var field_names: [tot_arr.len][]u8 = undefined;
        var field_types: [tot_arr.len]type = undefined;
        var field_attrs: [tot_arr.len]Attributes = undefined;

        for (tot_arr, 0..) |t, i| {
            field_names[i] = t.name;
            const ti = @typeInfo(t.type);
            field_types[i] = if (ti == .optional or ti == .bool) t.type else ?t.type;
            field_attrs = Attributes{
                .@"comptime" = false,
                .@"align" = @alignOf(field_types[i]),
                .default_value_ptr = t.default_value_ptr,
            };
        }

        const ResultType = @Struct(.auto, null, &field_names, &field_types, &field_attrs);
        return ResultType;
    }
}

pub fn createNullStruct(
    comptime flag_fields: []StructField,
    comptime arg_fields: []StructField,
) genNullReturnType(flag_fields, arg_fields) {
    const ResultType = comptime genNullReturnType(flag_fields, arg_fields);
    const result: ResultType = .{};

    return result;
}

pub fn returnValue(
    comptime T: type,
    null_result: anytype,
) T {
    const fields = comptime std.meta.fields(T);
}
