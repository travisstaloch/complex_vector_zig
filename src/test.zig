const std = @import("std");
const warn = std.debug.warn;
const assert = std.debug.assert;
const math = std.math;

const common = @import("common.zig");
const Cx = common.Cx;
const CVec = common.CVec;
const cx = common.Cx.new;
const cvec = common.CVec.new;
const Op = common.Op;
const eps = common.eps;
const cplx = @import("complex.zig");

const VERBOSE = false;

fn cx_cmp(a: Cx, b: Cx) bool {
    return math.approxEq(f64, a.re, b.re, eps) and math.approxEq(f64, a.im, b.im, eps);
}

fn cvec_cmp(v: CVec, w: CVec) bool {
    return cx_cmp(v.x, w.x) and cx_cmp(v.y, w.y) and cx_cmp(v.z, w.z);
}

const cx_fmt = "{d:.4} + {d:.4}im ";

fn cx_print(a: Cx) void {
    warn(cx_fmt ++ "\n", a.re, a.im);
}

fn cx_str(a: Cx, buf: []u8) ![]u8 {
    return try std.fmt.bufPrint(buf, cx_fmt, a.re, a.im);
}

// check if op(a, b) == r
fn cx_check(a: Cx, b: Cx, r: Cx, op: Op) bool {
    var f = switch (op) {
        Op.add => Cx.add,
        Op.sub => Cx.sub,
        Op.mul => Cx.mul,
        Op.div => Cx.div,
    };
    if (VERBOSE) {
        var buf1: [100]u8 = undefined;
        var buf2: [100]u8 = undefined;
        var buf3: [100]u8 = undefined;
        var sa = cx_str(a, buf1[0..]) catch @panic("cx_str(a) failed");
        var sb = cx_str(b, buf2[0..]) catch @panic("cx_str(b) failed");
        var sr = cx_str(f(a, b), buf3[0..]) catch @panic("cx_str(f(a, b)) failed");
        warn("{} {} {} = {}\n", sa, @tagName(op), sb, sr);
    }
    return cx_cmp(f(a, b), r);
}

test "mul / div" {
    assert(cx_check(cx(0, 1), cx(0, 1), cx(-1, 0), Op.mul));
    assert(cx_check(cx(1, 0), cx(0, 1), cx(0, 1), Op.mul));
    assert(cx_check(cx(-1, 0), cx(0, 0), cx(0, 0), Op.mul));
    assert(cx_check(cx(4, 3), cx(2, -1), cx(11, 2), Op.mul));
    assert(cx_check(cx(4, 3), cx(2, -1), cx(1, 2), Op.div));
    assert(cx_check(cx(4, 3), cx(-4, -12), cx(-0.325, 0.225), Op.div));
}

test "theta / magnitude" {
    assert(math.approxEq(f64, cplx.cx_theta(cx(2, 1)), 4.636476090008061e-01, eps));
    assert(math.approxEq(f64, cplx.cx_theta(cx(4, 3)), 6.435011087933e-01, eps));
    // warn("{}\n", cx(4, 3).magnitude());
    assert(math.approxEq(f64, cx(4, 3).magnitude(), 5, eps));
}

var roots: [2]Cx = undefined;
test "sq / sqrt / cbrt" {
    assert(cx_cmp(cplx.cx_sq(cx(4, 3)), cx(7, 24)));
    // warn("{}\n", cx_theta(cx_sq(cx(4, 3))));
    assert(math.approxEq(f64, cplx.cx_theta(cplx.cx_sq(cx(4, 3))), 1.287002217587e+00, eps));

    roots = cplx.cx_sqrt(cx(7, 24));
    assert(cx_cmp(roots[0], cx(4, 3)));
    assert(cx_cmp(roots[1], cx(-4, -3)));

    roots = cplx.cx_sqrt(cx(0, 1));
    const root2div2 = 0.7071067811865476;
    assert(cx_cmp(roots[0], cx(root2div2, root2div2)));
    assert(cx_cmp(roots[1], cx(-root2div2, -root2div2)));

    var roots3 = cplx.cx_cbrt(cx(-11, 2));
    assert(cx_cmp(roots3[0], cx(1.232050807569e+00, 1.866025403784e+00)));
    assert(cx_cmp(roots3[1], cx(-2.232050807569e+00, 1.339745962156e-01)));
    assert(cx_cmp(roots3[2], cx(1, -2)));
}

var v1: CVec = undefined;
test "vec mag / dot / cross / normalize" {
    v1 = CVec{ .x = cx(1, 1), .y = cx(2, 2), .z = cx(3, 3) };
    assert(math.approxEq(f64, cplx.cvec_mag(v1), 5.2915026221291, eps));
    // warn("mag {}\n", cvec_mag(v1));
    var v2 = CVec{ .x = cx(-1, -1), .y = cx(-2, -2), .z = cx(3, -3) };
    assert(cx_cmp(cplx.cvec_dot(v1, v2), cx(18, -10)));
    assert(cvec_cmp(cplx.cvec_cross(v1, v2), CVec{ .x = cx(12, 12), .y = cx(-6, -6), .z = cx(0, 0) }));
    assert(cvec_cmp(cplx.cvec_normalize(v1), CVec{
        .x = cx(0.1889822365046, 0.18898223650462),
        .y = cx(0.3779644730092, 0.3779644730092),
        .z = cx(0.5669467095138, 0.5669467095138),
    }));
}

test "quadratic" {
    roots = cplx.cx_quadratic(cx(1, 0), cx(-9, 0), cx(14, 0));
    assert(cx_cmp(roots[0], cx(7, 0)));
    assert(cx_cmp(roots[1], cx(2, 0)));

    roots = cplx.cx_quadratic(cx(1, 0), cx(5, 0), cx(-14, 0));
    assert(cx_cmp(roots[0], cx(2, 0)));
    assert(cx_cmp(roots[1], cx(-7, 0)));

    roots = cplx.cx_quadratic(cx(1, 0), cx(-5, 0), cx(14, 0));
    // cx_print(roots[0]);
    // cx_print(roots[1]);
    assert(cx_cmp(roots[0], cx(2.5, -2.7838821814150108)));
    assert(cx_cmp(roots[1], cx(2.5, 2.7838821814150108)));

    roots = cplx.cx_quadratic(cx(2, 3), cx(-5, 2), cx(-1, -7));
    // cx_print(roots[0]);
    // cx_print(roots[1]);
    assert(cx_cmp(roots[0], cx(1.3076923076923077, -0.46153846153846156)));
    assert(cx_cmp(roots[1], cx(-1, -1)));
}

test "det / cramer" {
    assert(cx_cmp(cplx.cvec_det(
      cvec(cx(1,0), cx(2,0), cx(3,0)),
      cvec(cx(4,0), cx(5,0), cx(6,0)),
      cvec(cx(7,0), cx(8,0), cx(9,0))), cx(0, 0)));

    assert(cx_cmp(cplx.cvec_det(
      cvec(cx(10,0), cx(-2,0), cx(-3,0)),
      cvec(cx(4,0), cx(5,0), cx(6,0)),
      cvec(cx(7,0), cx(8,0), cx(9,0))), cx(-33, 0)));

    assert(cx_cmp(cplx.cvec_det(
      cvec(cx(0.5,-1), cx(-2,0), cx(-3,0)),
      cvec(cx(4,0), cx(5,0), cx(6,0)),
      cvec(cx(7,0), cx(-2,4), cx(9,0))), cx(121.5, -117)));

    v1 = cplx.cvec_cramer(
      cvec(cx(0.5,-1), cx(-2,0), cx(-3,0)),
      cvec(cx(4,0), cx(5,0), cx(6,0)),
      cvec(cx(7,0), cx(-2,4), cx(9,0)),
      cvec(cx(1,0.5), cx(2,0.75), cx(3,-0.25)));
    // cx_print(v1.x);
    // cx_print(v1.y);
    // cx_print(v1.z);
    assert(cvec_cmp(v1,
      cvec(cx( 5.857651245552e-01, 5.455516014235e-01),
           cx(-1.992882562278e-02, 1.937722419929e-01),
           cx(-4.056939501779e-02,-4.001779359431e-01)),
    ));
}
