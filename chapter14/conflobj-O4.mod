# (O4)

param K;				# number of tubes
param d{k in 1..K};			# demand
param p{k in 1..K};			# selling price
param cx{k in 1..K};		# production cost
param ct{t in 1..K};		# purchasing cost
param rm{t in 1..K};		# machine time
param rf{t in 1..K};		# finishing material
param RM;				# total available machine time
param RF;				# total available finishing material

var x{k in 1..K} >= 0;		# amount of production of tube T[k]
var t{k in 1..K} >= 0;		# amount of tube T[k] to be purchased
var z;
var w;

var zmin >= 0;
var zplus >= 0;
var wmin >= 0;
var wplus >= 0;
var mmin >= 0;
var mplus >= 0;

# objective 
minimize obj: 2 * zmin + wplus + 20 * mplus;

# demand constraints
subject to demand{k in 1..K}: x[k] + t[k] = d[k];

# resource constraints
subject to mtime: sum{k in 1..K} rm[k] * x[k] - mplus + mmin = RM;
subject to fmat:  sum{k in 1..K} rf[k] * x[k] <= RF;

# goal constraints for z and w
subject to zcons: sum{k in 1..K} ((p[k] - cx[k]) * x[k] + (p[k] - ct[k]) * t[k]) - zplus + zmin = 198500;
subject to wcons: sum{k in 1..K} ct[k] * t[k] - wplus + wmin = 78000;

# definitions of z and w
subject to zdef: z = sum{k in 1..K} ((p[k] - cx[k]) * x[k] + (p[k] - ct[k]) * t[k]);
subject to wdef: w = sum{k in 1..K} ct[k] * t[k];

data;

param  K  := 3;
param: d  := 1 3000  2 5000  3 7000;
param: p  := 1 20    2 24    3 18;
param: cx := 1 4     2 6     3 7;
param: ct := 1 7     2 7     3 9;
param: rm := 1 0.55  2 0.40  3 0.60;
param: rf := 1 1     2 1     3 1;
param  RM := 2400;
param  RF := 6000;

end;
