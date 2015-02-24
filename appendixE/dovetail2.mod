/* Model parameters */
set P;                             # set of products
set I;                             # input products
param p{P};                        # profit per unit of product
param c{I};                        # availability of each input product
param a{I, P};                     # number of units of input required to produce
                                   # one unit of product

/* Decision variables */
var x{P} >= 0;                     # number of boxes (x 100,000) of each product

/* Objective function */
maximize z: 
    sum{j in P} p[j] * x[j];

/* Constraints */
subject to input {i in I}:         # one constraint for each input product
    sum{j in P} a[i, j] * x[j] <= c[i];

/* Model data */
data;

set P := long short;
set I := machine wood boxlong boxshort;

param p := 
  long   3
  short  2;
  
param c :=
  machine    9
  wood      18 
  boxlong    7
  boxshort   6;

param a : long short :=
machine   1    1
wood      3    1
boxlong   1    0
boxshort  0    1;

end;

