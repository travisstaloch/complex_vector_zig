const std = @import("std");
const Complex = std.math.complex.Complex;
pub const Cx = Complex(f64);
pub const cx = Cx.new;
pub const cvec = CVec.new;

pub const eps = 1.0e-12;

pub const CVec = struct {
    x: Cx,
    y: Cx,
    z: Cx,
    const Self = @This();
    pub fn new(x: Cx, y: Cx, z: Cx) Self {
       return Self {.x = x, .y = y, .z = z};
    }
};

pub const Op = enum {
    add,
    sub,
    div,
    mul,
};
