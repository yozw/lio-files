/**
# A portfolio selection problem
From: Section 1.6.5 of Sierksma and Zwols, *Linear and Integer Optimization: Theory and Practice*.

There are $n$ different stocks that can be bought. The investor wants to buy
a portfolio of stocks at the beginning of the month, and sell them at the end of the month, without making
any changes to the portfolio during that time. 
Let $i=1,\ldots, n$. Define $R_i$ to be the *rate of return* of stock $i$, i.e.:
\[
R_i = \frac{V_i^{1}}{V_i^{0}},
\]
where $V_i^{0}$ is the current value of stock $i$, and $V_i^{1}$ is the value of stock $i$ in 
one month. 
Let $S$ be the number of scenarios. We assume that all scenarios are equally likely to happen.
For each $i$, let $R_{i}^s$ be the rate of return of stock $i$ in scenario $s$.
The *expected rate of return* of stock $i$ is denoted and defined by:
\[
\mu_i = \frac{1}{S}\sum_{s=1}^S R_{i}^s.
\]
We measure risk by the *mean absolute deviation*:
\[
\rho_i = \frac{1}{S}\sum_{s=1}^S \left|R_{i}^s - \mu_i\right|.
\]
For each $i=1, \ldots, n$, define the following decision variable:
\[
x_i = \mbox{the fraction of the $\$10{,}000$ to be invested in stock $i$}.
\]
Since the investor wants to invest the full \$$10{,}000$, the $x_i$'s should satisfy the constraint:
\[
x_1 + \ldots + x_n = 1.
\]
If \$$x_i$ is invested in stock $i$, then it is straightforward to check that
the expected rate of return $\mu$ of the portfolio as a whole satisfies:
\[
\mu = \frac{1}{S}\sum_{s=1}^S \sum_{i=1}^n R_{i}^s x_i = \sum_{i=1}^n \mu_i x_i.
\]
The mean absolute deviation $\rho$ of a portfolio in which \$$x_i$ is invested in stock $i$ satisfies:
\[
\rho = \frac{1}{S}\sum_{s=1}^S \left|\sum_{i=1}^n R_{i}^s x_i - \mu \right| =
\frac{1}{S}\sum_{s=1}^S \left|\sum_{i=1}^n (R_{i}^s - \mu_i) x_i \right|.
\]
We introduce a positive weight parameter $\lambda$ which measures how much importance we attach to maximizing
the expected rate of return of the portfolio, relative to minimizing the risk of the portfolio. The portfolio
optimization problem is then:

<div class="display">
<table>
<table class="lo-model align-left">
<tr><td align=left>$\max$</td><td align=left>$\displaystyle\lambda\sum_{i=1}^n \mu_i x_i - \frac{1}{S}\sum_{s=1}^S \left|\sum_{i=1}^n (R_i^s - \mu_i) x_i\right|$</td></tr>
<tr><td align=left>$\mbox{subject to}$</td><td align=left>$\displaystyle\sum_{i=1}^n x_i = 1$</td></tr>
<tr><td></td><td align=left>$x_1, \ldots, x_n\geq 0$</td></tr>
</table>
</div>

Although this is not a linear optimization model (because of the absolute value operations), it can be turned into
one by introducing, for each $s=1,\ldots, S$, the decision variable $u_s$, and defining $u_s$ to be equal to the expression 
$\sum_{i=1}^n (R_i^s - \mu_i) x_i$ inside the absolute value bars. Next, we write $u_s = u_s^+ - u_s^-$ and 
$|u_s| = u_s^+ + u_s^-$. This results in the following linear optimization model:
<div class="display">
<table class="lo-model align-left">
<tr><td align=left>$\max$</td><td align=left>$\displaystyle\lambda\sum_{i=1}^n \mu_i x_i - \frac{1}{S}\sum_{s=1}^S \left(u_s^+ + u_s^-\right)$</td></tr>
<tr><td align=left>$\mbox{subject to}$</td><td align=left>$\displaystyle\sum_{i=1}^n x_i = 1$</td></tr>
<tr><td align=left></td><td align=left>$u_s^+ - u_s^- = \displaystyle \sum_{i=1}^n (R_i^s - \mu_i) x_i$ for $s=1, \ldots, S$</td></tr>
<tr><td></td><td align=left>$x_1, \ldots, x_n, u_s^+, u_s^-\geq 0$ for $s=1, \ldots, S$.</td></tr>
</table>
</div>
*/

param S;
param n;
param lambda >= 0;

param R{1..S, 1..n};

param mu{i in 1..n} := sum{s in 1..S} R[s,i] / S;

var return;
var risk;
var x{1..n} >= 0;
var uplus {1..S} >= 0;
var uminus{1..S} >= 0;

maximize z:
	lambda * (sum{s in 1..S, i in 1..n} R[s,i] * x[i]) / S
    - sum{s in 1..S} (uplus[s] + uminus[s]) / S;
    
subject to budget:
	sum {i in 1..n} x[i] = 1;
    
subject to usdef {s in 1..S}:
    uplus[s] - uminus[s] = sum{i in 1..n} (R[s,i] - mu[i]) * x[i];
    
subject to return_def:
    return = sum{s in 1..S, i in 1..n} R[s,i] * x[i] / S;

subject to risk_def:
    risk = sum{s in 1..S} (uplus[s] + uminus[s]) / S;

data;

param S := 6;
param n := 5;

param R : 1 2 3 4 5:=
  1  -0.0423  -0.0158   0.002    0.055    0.0214  
  2   0.083    0.0078  -0.0034   0.051    0.0248  
  3   0.0643   0.0162   0.0119  -0.029    0.0462  
  4   0.0035   0.0398   0.0214  -0.0019  -0.0272  
  5   0.0185   0.0061   0.016   -0.033   -0.0058  
  6  -0.061    0.0179   0.0061   0.0239  -0.0024 ;
    
param lambda := 4;
    
end;

