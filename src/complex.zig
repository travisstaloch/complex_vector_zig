const std = @import("std");
const math = std.math;
const complex = math.complex;
const Complex = complex.Complex;

const common = @import("common.zig");
const Cx = common.Cx;
const cx = common.Cx.new;
const CVec = common.CVec;
const cvec = CVec.new;

const eps = common.eps;
const two_thirds_pi = 2.0 * math.pi / 3.0;
const four_thirds_pi = 4.0 * math.pi / 3.0;

pub fn cx_theta(z: Cx) f64 {
    return math.atan2(f64, z.im, z.re);
}

pub fn cx_sq(z: Cx) Cx {
    return z.mul(z);
}

pub fn cx_sqrt(z: Cx) [2]Cx {
    var theta = cx_theta(z);
    var sqrt_mag = math.sqrt(z.magnitude());

    // if (math.approxEq(f64, theta, 0.0, eps) or math.absFloat(math.absFloat(theta - math.pi)) < eps) {
    if (math.approxEq(f64, theta, 0.0, eps)) {
        return [_]Cx{ cx(sqrt_mag, 0), cx(sqrt_mag, 0) };
    } else {
        return [_]Cx{
            cx(sqrt_mag * math.cos(theta / 2), sqrt_mag * math.sin(theta / 2)),
            cx(sqrt_mag * math.cos(math.pi + theta / 2), sqrt_mag * math.sin(math.pi + theta / 2)),
        };
    }
}

pub fn cx_cbrt(z: Cx) [3]Cx {
    var theta = cx_theta(z);
    var cbrt_mag = math.cbrt(z.magnitude());

    return [_]Cx{
        cx(cbrt_mag * math.cos(theta / 3), cbrt_mag * math.sin(theta / 3)),
        cx(cbrt_mag * math.cos(two_thirds_pi + theta / 3), cbrt_mag * math.sin(two_thirds_pi + theta / 3)),
        cx(cbrt_mag * math.cos(four_thirds_pi + theta / 3), cbrt_mag * math.sin(four_thirds_pi + theta / 3)),
    };
}

pub fn cvec_mag(v: CVec) f64 {
    return math.sqrt(math.pow(f64, v.x.re, 2) + math.pow(f64, v.x.im, 2) +
        math.pow(f64, v.y.re, 2) + math.pow(f64, v.y.im, 2) +
        math.pow(f64, v.z.re, 2) + math.pow(f64, v.z.im, 2));
}

pub fn cvec_dot(v: CVec, w: CVec) Cx {
    var x = v.x.mul(w.x);
    var y = v.y.mul(w.y);
    var z = v.z.mul(w.z);
    return cx(x.re + y.re + z.re, x.im + y.im + z.im);
}

pub fn cvec_cross(v: CVec, w: CVec) CVec {
    return CVec{
        .x = v.y.mul(w.z).sub(v.z.mul(w.y)),
        .y = v.z.mul(w.x).sub(v.x.mul(w.z)),
        .z = v.x.mul(w.y).sub(v.y.mul(w.x)),
    };
}

pub fn cvec_normalize(v: CVec) CVec {
    var mag = cvec_mag(v);
    return CVec{
        .x = cx_scale_down(v.x, mag),
        .y = cx_scale_down(v.y, mag),
        .z = cx_scale_down(v.z, mag),
    };
}

pub fn cx_scale(a: Cx, factor: f64) Cx {
    return cx(a.re * factor, a.im * factor);
}

pub fn cx_scale_down(a: Cx, factor: f64) Cx {
    return cx(a.re / factor, a.im / factor);
}

pub fn cx_quadratic(a: Cx, b: Cx, c: Cx) [2]Cx {
    var t1 = cx(-1, 0).mul(b);
    var roots = cx_sqrt(cx_sq(b).sub(cx(4, 0).mul(a).mul(c)));
    var divisor = cx(2, 0).mul(a);
    return [_]Cx{
        t1.add(roots[0]).div(divisor),
        t1.sub(roots[0]).div(divisor),
    };
}

pub fn cvec_det(u: CVec, v: CVec, w: CVec) Cx {
    return u.x.mul(v.y).mul(w.z)
      .add(u.y.mul(v.z).mul(w.x))
      .add(u.z.mul(v.x).mul(w.y))
      .sub(w.x.mul(v.y).mul(u.z))
      .sub(w.y.mul(v.z).mul(u.x))
      .sub(w.z.mul(v.x).mul(u.y));
}

pub fn cvec_cramer(u: CVec, v: CVec, w: CVec, d: CVec) CVec {
    var det  = cvec_det(u, v, w);
    return cvec(
        cvec_det(
          cvec(d.x, u.y, u.z),
          cvec(d.y, v.y, v.z),
          cvec(d.z, w.y, w.z),
          ).div(det),
        cvec_det(
          cvec(u.x, d.x, u.z),
          cvec(v.x, d.y, v.z),
          cvec(w.x, d.z, w.z),
          ).div(det),
        cvec_det(
          cvec(u.x, u.y, d.x),
          cvec(v.x, v.y, d.y),
          cvec(w.x, w.y, d.z),
          ).div(det),
        );
}
