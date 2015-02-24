var y1 >= 0;
var y2 >= 0;
var y3 >= 0;
var y4 >= 0;

minimize z: 9 * y1 + 18 * y2 + 7 * y3 + 6 * y4;

subject to c11: y1 + 3*y2 + y3 >= 3;
subject to c12: y1 + y2 + y4 >= 2;

end;
