/**
# Data envelopment analysis
From: Section 1.6.4 of Sierksma and Zwols, *Linear and Integer Optimization: Theory and Practice*.

Let the decision making units (DMUs) be labeled $k = 1,\ldots,N$. For each $k=1,\ldots, N$, the *relative efficiency* $RE(k)$
of DMU $k$ is defined as:
\[
RE(k) = \frac{\mbox{weighted sum of output values of DMU $k$}}{\mbox{weighted sum of input values of DMU $k$}},
\]			
where $0 \leq RE(k) \leq 1$. 
Let $m \geq 1$ be the number of inputs, and $n \geq 1$ the number of outputs. For each $i = 1,\ldots,m$ and $j = 1,\ldots,n$, define:

* $x_i$ = the weight of input $i$;
* $y_j$ = the weight of output $j$;
* $u_{ik}$ = the (positive) amount of input $i$ to DMU $k$;
* $v_{jk}$ = the (positive) amount of output $j$ to DMU $k$.


The relative efficiency of DMU $k$ can then be formulated as follows:

<div class="display">
<table class="lo-model align-left">
<tr><td align=left>$RE^*(k) = $</td><td align=left>$\max$</td><td align=left>$v_{1k}y_1  + \ldots + v_{nk}y_n$</td></tr>
<tr><td></td><td align=left>$\mbox{subject to}$</td><td align=left>$u_{1k}x_1  + \ldots + u_{mk}x_m  = 1$</td></tr>
<tr><td></td><td></td><td align=left>$v_{1r}y_1  + \ldots + v_{nr}y_n  - u_{1r}x_1  - \ldots - u_{mr}x_m  \leq 0$ for $r = 1,\ldots,N$</td></tr>
<tr><td></td><td></td><td align=left>$x_1,\ldots, x_m, y_1, \ldots, y_n \geq \varepsilon$</td></tr>
</table>
</div>
*/

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

