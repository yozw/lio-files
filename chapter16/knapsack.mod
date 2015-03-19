/**
# Minimizing trimloss when cutting cardboard; knapsack problem
See Chapter 16 of Sierksma and Zwols, *Linear and Integer Optimization: Theory and Practice*.
*/

var x1 >= 0, <= 2, integer;
var x2 >= 0, <= 4, integer;
var x3 >= 0, <= 7, integer;

maximize z: 11*x1 + 15*x2 + 10*x3;

subject to knapsack:
	5*x1 + 3*x2 + x3 <= 11;
    
end;

