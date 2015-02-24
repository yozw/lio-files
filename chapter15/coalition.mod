param n;	                # number of players
param m;	                # number of inputs
param r;                    # number of outputs

set PLAYERS := {1 .. n};    # set of players
set INPUTS  := {1 .. m};    # set of inputs
set OUTPUTS := {1 .. r};    # set of outputs

param a{PLAYERS};           # coalition vector
param c{OUTPUTS};           # profit per output unit
param A{INPUTS, OUTPUTS};   # production matrix
param B{INPUTS, PLAYERS};   # capacity matrix

var x{OUTPUTS} >= 0;        # output level 

# maximize total profit
maximize z:                 
    sum {j in OUTPUTS} c[j] * x[j];
 
# capacity constraint for each input
subject to capacity {i in INPUTS}:
	sum{j in OUTPUTS} A[i,j] * x[j] <= sum{k in PLAYERS} B[i, k] * a[k];

data;

param r := 3;
param m := 3;
param n := 3;

param A : 1 2 3 :=
1 2 0 1
2 2 4 3
3 1 0 1;

param c :=
1 5
2 2
3 7;

param B : 1 2 3 :=
1 2 2 2
2 8 2 4
3 2 1 3;

param a :=
1 1
2 1
3 1;

end;

