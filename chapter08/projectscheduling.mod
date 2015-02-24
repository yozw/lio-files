param n;
set GOALS := 1 .. n;
set ARCS within {GOALS, GOALS};

param c{ARCS} >= 0;

var t{GOALS} >= 0;

minimize completion_time: 
  t[n] - t[1];

subject to precedence_constraints {(i, j) in ARCS}:
  t[j] - t[i] >= c[i, j];

data;

param n := 6;
param : ARCS : c :=
  1 2 15
  1 3 10
  1 4 8
  2 3 3
  2 6 17
  3 5 7
  4 5 6
  4 6 3
  5 6 10;

end;

