const std = @import("std");
const math = std.math;

const common = @import("common.zig");
const Cx = common.Cx;
const cx = common.Cx.new;
const CVec = common.CVec;
const cvec = CVec.new;
const cvecc = common.cvecc;

const eps = common.eps;
const two_thirds_pi = 2.0 * math.pi / 3.0;
const four_thirds_pi = 4.0 * math.pi / 3.0;

// zig fmt: off
// ****************************************
// Complex functions, prefixed with cx_
// ****************************************
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
            cx( sqrt_mag * math.cos(theta / 2), 
                sqrt_mag * math.sin(theta / 2)),
            cx( sqrt_mag * math.cos(math.pi + theta / 2), 
                sqrt_mag * math.sin(math.pi + theta / 2)),
        };
    }
}

pub fn cx_cbrt(z: Cx) [3]Cx {
    var theta = cx_theta(z);
    var cbrt_mag = math.cbrt(z.magnitude());

    return [_]Cx{
        cx( cbrt_mag * math.cos(theta / 3), 
            cbrt_mag * math.sin(theta / 3)),
        cx( cbrt_mag * math.cos(two_thirds_pi + theta / 3), 
            cbrt_mag * math.sin(two_thirds_pi + theta / 3)),
        cx( cbrt_mag * math.cos(four_thirds_pi + theta / 3), 
            cbrt_mag * math.sin(four_thirds_pi + theta / 3)),
    };
}

pub fn cx_scale(z: Cx, factor: f64) Cx {
    return cx(z.re * factor, z.im * factor);
}

pub fn cx_scale_down(z: Cx, factor: f64) Cx {
    return cx(z.re / factor, z.im / factor);
}

pub fn cx_quadraticp(r: *[2]Cx, a: *const Cx, b: *const Cx, c: *const Cx) void {
    var t1 = cx(-1, 0).mul(b.*);
    var roots = cx_sqrt(cx_sq(b.*).sub(cx(4, 0).mul(a.*).mul(c.*)));
    var divisor = cx(2, 0).mul(a.*);
    r.*[0] = t1.add(roots[0]).div(divisor);
    r.*[1] = t1.sub(roots[0]).div(divisor);
}

pub fn cx_quadratic(a: Cx, b: Cx, c: Cx) [2]Cx {
    var t1 = cx(-1, 0).mul(b);
    var roots = cx_sqrt(cx_sq(b).sub(cx(4, 0).mul(a).mul(c)));
    var divisor = cx(2, 0).mul(a);
    return [_]Cx{
        t1.add(roots[0]).div(divisor),
        t1.sub(roots[0]).div(divisor),
    };
    // var r: [2]Cx = undefined;
    // cx_quadraticp(&r, &a, &b, &c);
    // return r;
}


// ****************************************
// Complex Vector functions, prefixed with cvec_
// ****************************************
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

pub fn cvec_apply(a: CVec, b: CVec, f: fn(Cx, Cx) Cx) CVec {
    return cvec(f(a.x, b.x), f(a.y, b.y), f(a.z, b.z));
}

pub fn cvec_add(a: CVec, b: CVec) CVec {
    // return cvec(a.x.add(b.x), a.y.add(b.y), a.z.add(b.z));
    return cvec_apply(a, b, Cx.add);
}

pub fn cvec_sub(a: CVec, b: CVec) CVec {
    // return cvec(a.x.sub(b.x), a.y.sub(b.y), a.z.sub(b.z));
    return cvec_apply(a, b, Cx.sub);
}

pub fn cvec_mul(a: CVec, b: CVec) CVec {
    return cvec_apply(a, b, Cx.mul);
}

pub fn cvec_div(a: CVec, b: CVec) CVec {
    return cvec_apply(a, b, Cx.div);
}

pub fn cvec_sq(a: CVec) CVec {
    return cvec_mul(a, a);
}

pub fn cvec_normalize(v: CVec) CVec {
    var mag = cvec_mag(v);
    return CVec{
        .x = cx_scale_down(v.x, mag),
        .y = cx_scale_down(v.y, mag),
        .z = cx_scale_down(v.z, mag),
    };
}

pub fn cvec_scale(v: CVec, factor: f64) CVec {
    return cvec(cx_scale(v.x, factor), cx_scale(v.y, factor), cx_scale(v.z, factor));
}

pub fn cvec_detp(r: *Cx, u: *const CVec, v: *const CVec, w: *const CVec) void {
    r.* = u.*.x.mul(v.*.y).mul(w.*.z)
        .add(u.*.y.mul(v.*.z).mul(w.*.x))
        .add(u.*.z.mul(v.*.x).mul(w.*.y))
        .sub(w.*.x.mul(v.*.y).mul(u.*.z))
        .sub(w.*.y.mul(v.*.z).mul(u.*.x))
        .sub(w.*.z.mul(v.*.x).mul(u.*.y));
}

pub fn cvec_det(u: CVec, v: CVec, w: CVec) Cx {
    return u.x.mul(v.y).mul(w.z)
      .add(u.y.mul(v.z).mul(w.x))
      .add(u.z.mul(v.x).mul(w.y))
      .sub(w.x.mul(v.y).mul(u.z))
      .sub(w.y.mul(v.z).mul(u.x))
      .sub(w.z.mul(v.x).mul(u.y));
    // var r: Cx = undefined;
    // cvec_detp(&r, &u, &v, &w);
    // return r;
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

pub fn cvec_cramerp(r: *CVec, u: *const CVec, v: *const CVec, 
    w: *const CVec, d: *const CVec) void {

    var det: Cx = undefined;
    cvec_detp(&det, u, v, w);
    
    cvec_detp(&r.*.x, 
        &cvec(d.*.x, u.*.y, u.*.z),
        &cvec(d.*.y, v.*.y, v.*.z),
        &cvec(d.*.z, w.*.y, w.*.z),
        );
    r.*.x = r.*.x.div(det);
    
    cvec_detp(&r.*.y, 
        &cvec(u.*.x, d.*.x, u.*.z),
        &cvec(v.*.x, d.*.y, v.*.z),
        &cvec(w.*.x, d.*.z, w.*.z),
        );
    r.*.y = r.*.y.div(det);
    
    cvec_detp(&r.*.z, 
        &cvec(u.*.x, u.*.y, d.*.x),
        &cvec(v.*.x, v.*.y, d.*.y),
        &cvec(w.*.x, w.*.y, d.*.z),
        );
    r.*.z = r.*.z.div(det);        
}

pub fn intersect( sign: CVec, loc: CVec, axi: CVec, obs_p: CVec, obs_v: CVec ) [2]Cx {
    var asq = cx_sq(axi.x);
    var bsq = cx_sq(axi.y);
    var csq = cx_sq(axi.z);
    var axii = cvec(bsq.mul(csq), asq.mul(csq), asq.mul(bsq));
    // var signXaxii = cvecc(
    //     sign.x.mul(axii.x).re, 0, 
    //     sign.y.mul(axii.y).re, 0, 
    //     sign.z.mul(axii.z).re, 0, 
    //     );
    var Rsq = cvec(cx_sq(obs_v.x), cx_sq(obs_v.y), cx_sq(obs_v.z));
    var A = cvec_dot(axii, Rsq);
    var LsubP = cvec_sub(obs_p, loc);
    var RmulLsubP = cvec_mul(obs_v, LsubP);
    var B = cx_scale(cvec_dot(axii, RmulLsubP), 2);
    var LsubPsq = cvec_sq(LsubP);
    var signDotLsubP = cvec_dot(axii, LsubPsq);
    var asbscs = cx_sq(axi.x).mul(cx_sq(axi.y)).mul(cx_sq(axi.z));
    var C = signDotLsubP.sub(asbscs);
    var res = cx_quadratic(A, B, C);

    if (false) {
        const warn = std.debug.warn;
        var buf: [1024]u8 = undefined;
        warn("\n\nINFO : intermediate axi vector = {}\n", cvec_str(axii, buf[0..]));
        warn("\nINFO: R^2 = {}\n", cvec_str(Rsq, buf[0..]));
        warn("\n\nINFO : A = {}\n", cx_str(A, buf[0..]));
        warn("dbug : LsubP = {}\n", cvec_str(LsubP, buf[0..]));
        warn("INFO : R * ( L - P ) = {}\n", cvec_str(RmulLsubP, buf[0..]));
        warn("INFO : B = {}\n", cx_str(B, buf[0..]));
        warn("INFO : ( L - P )^2 = {}\n", cvec_str(LsubPsq, buf[0..]));
        warn("INFO : <sign bits> dot < L-P bits > = {}\n", cx_str(signDotLsubP, buf[0..]));
        warn("INFO : a^2 * b^2 * c^2 = {}\n", cx_str(asbscs, buf[0..]));
        warn("INFO : C = {}\n", cx_str(C, buf[0..]));
        warn("Quadratic result 1 = {}\n", cx_str(res[0], buf[0..]));
        warn("          result 2 = {}\n", cx_str(res[1], buf[0..]));
    }
    return res;
}



// ****************************************
// Print utility functions
// ****************************************
const cx_fmt = "{d:.4} + {d:.4}im ";
const cvec_fmt = "<" ++ cx_fmt ++ ", " ++ cx_fmt ++ ", " ++ cx_fmt ++ ">";

fn cx_print(a: Cx) void {
    warn(cx_fmt ++ "\n", a.re, a.im);
}

fn cx_str(a: Cx, buf: []u8) ![]u8 {
    return try std.fmt.bufPrint(buf, cx_fmt, a.re, a.im);
}

pub fn cvec_print(a: CVec, buf: []u8) void {
    warn(cvec_fmt ++ "\n", a.x.re, a.x.im, a.y.re, a.y.im, a.z.re, a.z.im);
}

pub fn cvec_str(a: CVec, buf: []u8) ![]u8 {
    return try std.fmt.bufPrint(buf, cvec_fmt, a.x.re, a.x.im, a.y.re, a.y.im, a.z.re, a.z.im);
}
