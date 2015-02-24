from numpy import matrix
from intpm import intpm_leq

A = matrix([[1, 1], [3, 1], [1, 0], [0, 1]])
b = matrix([9, 18, 7, 6]).T
c = matrix([-3, -2]).T

intpm_leq(A, b, c, 2.5)


