# Model (11.12)

param T;
param s0;
param c;
param alpha;
param gamma;
param d{1..T};
param sigma{t in 1..T} := gamma * d[1 + t mod T];
param a{t in 1..T}     := sum {k in 1..t} d[k] + sigma[t] - s0;

var xstar   >= 0;
var x{1..T} >= 0;

minimize z: c*alpha*T*xstar + 2*c*alpha*sum {t in 1..T} (x[t]-xstar);

subject to acons{t in 1..T-1}: sum {k in 1..t} x[k] >= a[t]; 
subject to aconsT:             sum {k in 1..T} x[k] = a[T]; 
subject to xcons{t in 1..T}:   xstar <= x[t];

data;

param T     := 12;
param s0    := 140;
param alpha := 8;
param c     := 10;
param gamma := 0.2;
param:  d   :=
    1  30     2  40     3  70     4  60     5  70     6  40 
    7  20     8  20     9  10    10  10    11  20    12  20 ;
end;
