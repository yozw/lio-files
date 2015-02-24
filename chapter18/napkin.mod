## # The catering service problem
## See Chapter 18 of Sierksma and Zwols, *Linear and Integer Optimization: Theory and Practice*.

param T;
param M;
param p_napkin;
param p_fast;
param p_slow;
param d{t in 1..T} >= 0;

var p{t in 0..T}   >= 0;
var f{t in 1..T-2} >= 0;
var s{t in 1..T-4} >= 0;
var h{t in 1..T}   >= 0;

minimize costs:
  sum{t in 1..T} p_napkin * p[t] + sum{t in 1..T-2} p_fast * f[t] 
                                 + sum{t in 1..T-4} p_slow * s[t];

subject to P0:
  sum{t in 0..T} p[t] = M;

subject to P {t in 1..T}:
  (if t <= T-2 then f[t] else 0) + (if t <= T-4 then s[t] else 0) 
                                 - (if t >= 2 then h[t-1] else 0) + h[t] = d[t];

subject to Q0:
  - p[0] - h[7] = -M;

subject to Q {t in 1..T}:
  - p[t] - (if t >= 3 then f[t-2] else 0) - (if t >= 5 then s[t-4] else 0) = -d[t];
 
data;

param M := 125;
param T := 7;
param p_napkin := 3;
param p_fast := 0.75;
param p_slow := 0.5;
param d := 
  1 23 
  2 14 
  3 19 
  4 21 
  5 18 
  6 14 
  7 15;

end;
