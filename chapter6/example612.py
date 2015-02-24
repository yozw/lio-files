from math import sqrt
from numpy import matrix
from intpm import intpm

A = matrix([[1, 0, 1, 0], [0, 1, 0, 1]])
b = matrix([1, 1]).T
c = matrix([-1, -2, 0, 0]).T

mu = 100
x1 = 0.5 * (-2 * mu + 1 + sqrt(1 + 4*mu*mu))
x2 = 0.5 * (-mu + 1 + sqrt(1 + mu * mu))

x0 = matrix([x1, x2, 1 - x1, 1 - x2]).T

intpm(A, b, c, x0, mu)


