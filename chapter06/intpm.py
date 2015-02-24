# Interior path method implementation
# Copyright (C) 2013-2015 Y. Zwols and G. Sierksma
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

from math import sqrt, exp
from numpy import matrix, bmat, ones, zeros, identity, diagflat, asscalar
from numpy.linalg import solve, inv, det

""" Returns an n-dimension column vector of zeros """
def z(n):
  return zeros([n,1])

""" Returns an n-dimension column vector of ones """
def e(n):
  return ones([n,1])

""" Checks that A, b, c have consistent dimensions, and prints a message."""  
def check_input(A, b, c, function_name):
  (m, n) = A.shape
  assert b.shape == (m, 1)
  assert c.shape == (n, 1)
  print ">", function_name, "called for model with", n, "variables and", m, "constraints"
  return (m, n)

""" Solves the model min c'x subject to Ax <= b, x >= 0.
    This function returns a tuple (obj, x, y), where obj is the optimal 
    objective value, x is the optimal primal solution, and y is the 
    optimal dual solution."""
def intpm_leq(A, b, c, alpha):
  (m, n) = check_input(A, b, c, "intpm_leq")

  # Introduce slack variables
  A = bmat([[A, identity(m)]])
  c = bmat([[c], [z(m)]])
  
  # Run the interior path algorithm for models with equality constraints
  return intpm_eq(A, b, c, alpha)


""" Solves the model min c'x subject to Ax = b, x >= 0. 
    This function returns a tuple (obj, x, y), where obj is the optimal 
    objective value, x is the optimal primal solution, and y is the 
    optimal dual solution."""
def intpm_eq(A, b, c, alpha):
  (m, n) = check_input(A, b, c, "intpm_eq")
  
  # Construct an auxiliary problem for which it is easy to find an intiial 
  # solution. See Section 6.4.2.
  MP = alpha * alpha
  MD = alpha * alpha * (n+1) - alpha * sum(c)

  A = bmat([
    [A, b-alpha*A*e(n), z(m)], 
    [(alpha*e(n)-c).T, z(1), alpha*e(1)]
  ])
  b = bmat([[b], [MD*e(1)]])
  c = bmat([[c], [MP*e(1)], [z(1)]])
  x0 = bmat([[alpha*e(n)], [e(1)], [alpha*e(1)]])
  mu = alpha * alpha
  
  # Run the interior path algorithm
  return intpm(A, b, c, x0, mu)

""" Solves the model min c'x subject to Ax = b, x >= 0, by using the given
    initial strictly feasible point x0, interior path parameter mu, and 
    precision t.     
    This function returns a tuple (obj, x, y), where obj is the optimal 
    objective value, x is the optimal primal solution, and y is the 
    optimal dual solution."""
def intpm(A, b, c, x0, mu0, t = 10):
  (m, n) = check_input(A, b, c, "intpm")
  
  # Calculate theta and the target value of mu
  theta = 1. / (6. * sqrt(n))
  mu_final = exp(-t)/n
  x = x0
  mu = mu0
  iterations = 0

  # Perform interior path iterations
  print "Starting interior path algorithm"
  while mu > mu_final:
    iterations += 1
    
    # Update mu
    mu = (1 - theta) * mu
    
    # Calculate next point
    # NOTE: solve(AX * AX.T, AX) calculates inv(AX * AX.T) * AX in a more 
    # efficient and numerically stable manner.
    X = diagflat(x) 
    AX = A * X
    PAX = identity(n) - AX.T * solve(AX * AX.T, AX)
    x = x + X * PAX * (e(n) - X * c / mu)

  # Calculate the corresponding dual solution and the optimal objective value
  w = mu * solve(X, e(n))
  y = solve(A * A.T, A * (c - w))
  obj = asscalar(c.T * x)
  
  # Print out some information
  print "Interior path algorithm terminated after", iterations, "iterations"
  print "Objective value =", obj
  print "Duality gap =", asscalar(b.T * y - c.T * x)
  print "Primal solution:"
  for (i, value) in enumerate(x):
    print "x%-2d = %16.8f" % (i, value)
  print "Dual solution:"
  for (i, value) in enumerate(y):
    print "y%-2d = %16.8f" % (i, value)
  return (obj, x, w)

