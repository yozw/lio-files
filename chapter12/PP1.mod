# Model (PP1)

param T;
param s0;
param gamma;
param d{1..T};
param sigma{t in 1..T} := gamma * d[1 + t mod T];
param a{t in 1..T}     := sum {k in 1..t} d[k] + sigma[t] - s0;

var xstar   >= 0;
var x{1..T} >= 0;

minimize z: xstar;

subject to acons{t in 1..T}:   t * xstar >= a[t]; 

data;

param T     := 12;
param s0    := 140;
param gamma := 0.2;
param:  d   :=
    1  30     2  40     3  70     4  60     5  70     6  40 
    7  20     8  20     9  10    10  10    11  20    12  20 ;
end;

