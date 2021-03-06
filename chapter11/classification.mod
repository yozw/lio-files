/**
# Classifying documents by language
See Chapter 11 of Sierksma and Zwols, *Linear and Integer Optimization: Theory and Practice*.
*/

param N1;                     # number of English documents in learning set
param N2;                     # number of Dutch documents in learning set

set DOCUMENTS := 1..(N1+N2);  # set of all documents
set L1 := 1..N1;              # set of English documents
set L2 := (N1+1)..(N1+N2);    # set of Dutch documents
set FEATURES;                 # set of features

param f{FEATURES, DOCUMENTS}; # values of the feature vectors

var wp{FEATURES} >= 0;        # positive part of weights
var wm{FEATURES} >= 0;        # negative part of weights
var b;                        # intercept

minimize obj:                 # objective
  sum {j in FEATURES} (wp[j] + wm[j]);
  
subject to cons_L1{i in L1}:  # constraints for English documents
  sum {j in FEATURES} (wp[j] - wm[j]) * f[j, i] + b >= 1;
  
subject to cons_L2{i in L2}:  # constraints for Dutch documents
  sum {j in FEATURES} (wp[j] - wm[j]) * f[j, i] + b <= -1;

data;

param N1 := 6;
param N2 := 6;

set FEATURES := A B C D E F G H I J K L M N O P Q R S T U V W X Y Z;

param f : 
      1     2     3     4     5     6     7     8     9    10    11    12 :=
A 10.40  9.02  9.48  7.89  8.44  8.49  8.68  9.78 12.27  7.42  8.60 10.22 
B  1.61  1.87  1.84  1.58  1.41  1.55  2.03  1.08  0.99  1.82  1.79  2.62 
C  2.87  2.95  4.86  2.78  3.85  3.13  0.80  1.37  1.10  1.03  2.15  1.83 
D  4.29  3.52  3.16  4.18  3.91  5.04  5.50  6.05  6.13  7.11  5.97  6.46 
E 12.20 11.75 12.69 11.24 11.88 11.82 18.59 17.83 17.74 17.85 15.29 18.25 
F  2.12  2.31  2.97  2.00  2.55  1.90  0.76  0.89  0.77  1.26  1.19  1.48 
G  2.23  1.67  2.17  2.16  1.79  2.58  2.75  2.99  2.96  2.21  2.39  4.10 
H  4.45  4.36  4.25  5.56  4.45  5.43  1.69  3.29  2.96  1.66  2.27  2.62 
I  9.20  7.61  7.59  7.62  8.33  8.25  5.25  6.89  6.24  8.14  7.29  5.68 
J  0.13  0.22  0.14  0.25  0.22  0.40  1.35  1.30  0.88  2.05  1.55  1.57 
K  0.75  0.64  0.57  0.91  0.33  0.91  3.90  1.90  1.86  2.13  1.91  2.10 
L  4.05  3.28  4.81  4.74  4.31  3.77  4.11  4.44  3.50  3.40  3.82  3.76 
M  2.41  3.46  2.55  3.10  2.74  2.58  2.50  2.21  3.40  3.00  1.67  1.75 
N  7.03  7.70  6.60  7.02  7.16  7.34 10.63  8.80 10.30 11.45  9.32 11.53 
O  5.85  6.82  8.11  6.74  6.76  6.54  6.48  5.51  4.27  4.82  4.78  4.28 
P  1.53  2.51  1.79  1.93  2.41  1.43  1.31  1.23  1.42  1.11  2.51  0.52 
Q  0.11  0.02  0.14  0.12  0.19  0.08  0.00  0.05  0.00  0.00  0.00  0.09 
R  6.44  7.00  6.04  5.82  6.35  6.07  7.75  6.24  5.04  6.24  6.69  6.20 
S  7.35  7.68  5.28  7.22  6.35  6.66  3.43  4.66  3.18  5.13  6.57  3.14 
T  8.50  8.10  8.92  9.03  8.98  7.61  5.42  6.77  7.12  4.82  6.33  5.94 
U  2.25  3.17  2.12  2.87  2.88  3.09  1.74  1.32  1.20  1.58  2.75  1.40 
V  0.80  1.01  1.08  0.89  1.22  0.95  3.30  2.56  3.61  4.19  2.75  2.45 
W  1.26  1.21  1.51  1.61  1.47  2.62  0.97  1.51  1.53  0.55  1.31  0.87 
X  0.05  0.22  0.09  0.05  0.19  0.28  0.04  0.00  0.00  0.00  0.00  0.00 
Y  1.72  1.87  1.04  2.56  1.71  1.43  0.08  0.14  0.11  0.00  0.24  0.09 
Z  0.40  0.02  0.19  0.14  0.14  0.08  0.93  1.18  1.42  1.03  0.84  1.05;

end;
