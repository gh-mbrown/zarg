const std = @import("std");
const zarg = @import("parser/mod.zig");

test {
    std.testing.refAllDecls(@This());
}
