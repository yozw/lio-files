/* Decision variables */
var x1 >= 0;                        # number of boxes (x 100,000) of long matches
var x2 >= 0;                        # number of boxes (x 100,000) of short matches
 
/* Objective function */
maximize z:     3*x1 + 2*x2;

/* Constraints */
subject to c11:   x1 +   x2 <=  9;  # machine capacity (1.1)
subject to c12: 3*x1 +   x2 <= 18;  # wood (1.2)
subject to c13:   x1        <=  7;  # boxes for long matches (1.3)
subject to c14:          x2 <=  6;  # boxes for short matches (1.4)

end;

