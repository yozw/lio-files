# This is model 'Dovetail'

var x{1..8} >= 0;

param alpha := 3;
param MP := alpha * alpha;
param MD := alpha * alpha * 7 - alpha * (-5);

minimize z:    -3*x[1] - 2*x[2] + MP * x[7];

subject to c11:   x[1] +  x[2] + x[3] +  (9-3*alpha) * x[7] = 9;
subject to c12: 3*x[1] +  x[2] + x[4] + (18-5*alpha) * x[7] = 18;
subject to c13:   x[1]         + x[5] +  (7-2*alpha) * x[7] = 7;
subject to c14:           x[2] + x[6] +  (6-2*alpha) * x[7] = 6;
subject to c15: (alpha+3)*x[1] + (alpha+2)*x[2] + sum {i in 3..6} alpha*x[i] + alpha * x[8] = MD;

end;

