## # Designing a reservoir for irrigation
## See Chapter 10 of Sierksma and Zwols, *Linear and Integer Optimization: Theory and Practice*.

param T;
param Qin   {t in 1..T} >= 0;
param alpha {t in 1..T} >= 0;
param M;

var Qout {t in 1..T} >= 0;
var Qirr {t in 1..T} >= 0;
var Q    {t in 1..T} >= 0;
var V    {t in 0..T} >= 0;
var W >= 0;
var x >= 0;

minimize objective:
  sum {t in 1..T} Qout[t];
subject to defQt {t in 1..T}:                                        # (10.1)
  Q[t] = Qirr[t] + Qout[t];
subject to defVt {t in 1..T}:                                        # (10.3)
   V[t] = V[0] + sum{k in 1..t} (Qin[k] - Q[k]);
subject to defQirr {t in 1..T}:                                      # (10.4)
  Qirr[t] = alpha[t] * x;
subject to Qout_lb {t in 1..T}:                                      # (10.5)
  Qout[t] >= M;
subject to Vt_ub {t in 1..T}:                                        # (10.6)
  V[t] <= W; 
subject to defV0:                                                    # (10.7)
  V[0] = V[T];

data;

param T := 12;
param M := 2.3;
param alpha := 
  1 0.134   2 0.146   3 0.079   4 0.122   5 0.274   6 0.323 
  7 0.366   8 0.427   9 0.421  10 0.354  11 0.140  12 0.085;
param Qin := 
  1 41      2 51      3 63     4 99       5 51      6 20
  7 14      8 12      9  2    10 14      11 34     12 46;
end;
