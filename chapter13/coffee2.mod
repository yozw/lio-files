param m;
param nperiods;

set I := {1 .. m};
set T := {1 .. nperiods};
param c;
param p;
param gamma1;
param gamma2;

param s0{I};
param d{I, T};

var x{i in I, t in T} >= 0;
var s{i in I, t in T};
var sp{i in I, t in T} >= 0;
var sm{i in I, t in T} >= 0;
var r{i in I, t in T};
var rp{i in I, t in T} >= 0;
var rm{i in I, t in T} >= 0;


minimize total_shortage: gamma1 * sum{i in I} sum{t in T} rm[i,t] + gamma2 * sum{i in I} sum{t in T} (sm[i,t] - rm[i,t]);

subject to beltcap {t in T}: 
     sum{i in I} x[i,t] <= c * p;

subject to splusmin {i in I, t in T}:
     s[i,t] = sp[i,t] - sm[i,t];

subject to inventory {i in I, t in T}:
     s[i,t] = (if t = 1 then s0[i] else sp[i,t-1]) + x[i,t] - d[i,t];

subject to rplusmin {i in I, t in T}:
     r[i,t] = rp[i,t] - rm[i,t];

subject to oldshortage {i in I, t in T}:
     r[i,t] = (if t = 1 then 0 else s[i,t-1]) + x[i,t];

data;

param m := 21;
param nperiods := 14;
param c := 2600;
param p := 5;

param gamma1 := 1;
param gamma2 := 1;

param s0 := 
     1   813    2  -272   3 -2500   4    0   5  220   6    0   7 -800   8 16
     9     0   10  1028  11  1333  12   68  13   97  14 1644  15    0  16  0 
    17 -2476   18     0  19    86  20 1640  21    0;            

param d : 1    2    3    4    5    6    7    8    9   10   11   12   13   14
 :=  1    0    0 1500 7400 1300 1200 1000 1000 1000 1000 1000 1300 1200 1300
     2 3400 3600    0 9700 1400  700  800  700  700  700  900 1000  900  900
     3 1500    0 5000    0    0    0    0    0    0    0    0    0    0    0
     4    0    0    0 2900    0 1000    0  400    0  400    0  400    0    0
     5  800 2600 2400 1200 1300 1200  700  700  700  700  700  400  400  500
     6    0    0    0    0    0    0    0    0 1600    0    0    0    0    0
     7  400  300  300  300  300  200  100  200  200  100  200  200  200  200
     8    0 1000 2500 3200  600  600  700  600  700  500  600  500  600  300
     9    0    0    0 2500    0    0    0 1500    0    0    0    0    0    0
    10    0    0    0  800  200  200  200  200  200  100  200  200  200  100
    11  600  600  900 1700 1000 1200  500 1000  500 1000  500 1200  600  500
    12  600    0    0    0    0    0    0    0    0    0    0    0    0    0
    13 1400    0    0  600  300  300  300  500  400  300  200  300  200  100
    14    0 1000    0    0    0  300  300  400  300  400  400  300  400  400
    15    0    0    0 1200  300  100  100  100  100  200    0  100  100  100
    16   80    0    0 1300  400  400  400  500  400  300  400  300  400  200
    17 4000    0    0    0    0    0    0    0    0    0    0    0    0    0
    18    0    0    0    0    0    0    0    0    0 2500    0 2500    0    0
    19  900    0    0 1000  500  200  300  200  200  300  300  300  300  200
    20    0    0    0    0    0 1500    0    0    0    0    0  200    0    0
    21    0    0    0 2250    0  750    0    0    0    0    0    0    0    0;  
end;

