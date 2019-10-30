### An educational port of https://github.com/blastwave/lastmiles complex_vector code from c to zig

### Similar Projects
 - https://github.com/jlcarr/ComplexLinearAlgebra/blob/master/clinalg.c

### TODO
- [ ] add license
- [ ] add some comments
- [ ] support arbitrary vector sizes
- [ ] consider using SIMD vectors
  - [ ] verify that math.Complex isn't already vectorized
  - [ ] research proper vectorization techniques
- [ ] error detection and handling
- [ ] create p (inplace) versions which accept result pointer
  - [x] added cvec cramerp and dotp versions
- [x] port rtrace/obs_point.c::intersect