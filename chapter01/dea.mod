## # Data envelopment analysis
## See Section 1.6.4 of Sierksma and Zwols, *Linear and Integer Optimization: Theory and Practice*.

set INPUT;
set OUTPUT;

param N >= 1;
param u{1..N, INPUT};     # input values
param v{1..N, OUTPUT};    # output values

param K;                  # the DMU to assess
param eps > 0;

var x{i in INPUT} >= eps;
var y{j in OUTPUT} >= eps;

maximize objective: 
  sum {j in OUTPUT} y[j] * v[K, j];

subject to this_dmu: 
  sum {i in INPUT} x[i] * u[K, i] = 1;

subject to other_dmus{k in 1..N}: 
  sum {j in OUTPUT} y[j] * v[k, j] <= sum {i in INPUT} x[i] * u[k, i];

solve;

printf {i in INPUT} 'x(%s) = %f\n', i, x[i];
printf {j in OUTPUT} 'y(%s) = %f\n', j, y[j];
printf {k in 1..N} 'RE(%d;%d) = %f\n', k, K, (sum {j in OUTPUT} y[j] * v[k, j]) / (sum {i in INPUT} x[i] * u[k, i]);

data;

param eps := 0.00001;
param K := 1;
param N := 10;

set INPUT  := stock wages;
set OUTPUT := issues receipts reqs;

param u: stock wages :=
 1 51 38
 2 51 34
 3 56 46
 4 53 33
 5 50 36
 6 48 49
 7 59 39
 8 57 42
 9 47 35
10 53 39;

param v: issues receipts reqs :=
 1 63 46 22
 2 65 49 39
 3 62 40 20
 4 52 49 26
 5 57 48 26
 6 60 44 21
 7 61 48 19
 8 54 44 20
 9 59 48 33
10 60 48 22;

end;

