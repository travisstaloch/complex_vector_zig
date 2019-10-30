const std = @import("std");
const Complex = std.math.complex.Complex;
pub const Cx = Complex(f64);
pub const cx = Cx.new;
pub const cvec = CVec.new;
pub const cvecc = CVec.create;

pub const eps = 1.0e-12;

pub const CVec = struct {
    x: Cx,
    y: Cx,
    z: Cx,
    const Self = @This();
    pub fn new(x: Cx, y: Cx, z: Cx) Self {
       return Self {.x = x, .y = y, .z = z};
    }
    pub fn create(a: f64, b: f64, c: f64, d: f64, e: f64, f: f64) Self {
       return Self {.x = cx(a, b), .y = cx(c,d), .z = cx(e,f)};
    }
};

pub const Op = enum {
    add,
    sub,
    div,
    mul,
};

// pub fn cxs(args: ...) []Cx {
//         comptime var i = usize(0);
//         comptime var l = args.len / 2;
//         comptime var arr: [l]Cx = undefined;
//         comptime {
//             if (args.len % 2 != 0) @compileError("cxs expects even number of args, given {}" ++ args.len);
//         }
//         //comptime @compileLog("{}\n", arr.len);
//         inline while (i < l) : ( i+= 2) {
//             arr[i] = cx(args[i], args[i+1]);
//         }
//         return arr[0..];
// }