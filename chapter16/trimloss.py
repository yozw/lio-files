# Code for solving the trimloss problem
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

import glpk
import math

# INPUT DATA
W = 380                                        # width of the roll
b = [20, 9, 22, 19, 56, 23]                    # order demands
L = [128.5, 126, 100.5, 86.5, 82, 70.5]        # order widths
m = len(b)

# Initial patterns: patterns 7-13 from Table 13.2
A0 = [ [2, 0, 1, 0, 0, 0], 
       [2, 0, 0, 1, 0, 0], 
       [2, 0, 0, 0, 1, 0], 
       [2, 0, 0, 0, 0, 1], 
       [1, 1, 1, 0, 0, 0], 
       [1, 1, 0, 0, 0, 0],
       [0, 0, 0, 0, 0, 5] ]
       
# Add also single-order patterns
for c in range(m):
    pattern = [math.floor(W/L[c]) if k == c else 0.0 for k in range(m)]
    A0.append(pattern)

# Construct master Model
master = glpk.LPX()
master.obj.maximize = False

# Add rows to the master model
master.rows.add(m)
for ri in range(m):
    master.rows[ri].bounds = b[ri], b[ri] 

# Add columns to the master model
master.cols.add(m)
for pattern in A0:
    ci = master.cols.add(1)
    master.cols[ci].bounds = 0.0, None
    master.obj[ci] = 1.0
    master.cols[ci].matrix = pattern

# Construct knapsack model
knapsack = glpk.LPX()
knapsack.obj.maximize = True

# Add columns to the knapsack model
knapsack.cols.add(m)
for ci in range(m):
    knapsack.cols[ci].kind = int
    knapsack.cols[ci].bounds = 0.0, None

# Add one row to the knapsack model
knapsack.rows.add(1)
knapsack.rows[0].matrix = [L[i] for i in range(m)]
knapsack.rows[0].bounds = 0.0, W


# Initialization
optimal = False
glpk.env.term_on = False
iteration = 1

# Run the Gilmore-Gomory algorithm
while not optimal:    
    print "-" * 80
    print "ITERATION", iteration
    print "-" * 80
    print "Solving the master problem"
    
    # Solve master problem and extract dual solution
    master.simplex()
    y = [master.rows[r].dual for r in range(0, m)]

    # Print objective value and dual solution
    print "> Current objective value =", master.obj.value
    print "> Dual solution:", ", ".join([ "%0.4f" % value for value in y])
    
    # Solve knapsack model with the dual values of the master problem
    # as the objective coefficients
    knapsack.obj[:] = y
    knapsack.intopt()

    # Check if the optimal objective value <= 1
    print "> Optimal objective value of knapsack model =", knapsack.obj.value
    if knapsack.obj.value <= 1:
        optimal = True
    else:
        # Extract generated column and add it to the master problem        
        pattern = [int(knapsack.cols[c].primal) for c in range(m)]
        ci = master.cols.add(1)
        master.cols[ci].bounds = 0.0, None
        master.obj[ci] = 1.0
        master.cols[ci].matrix = pattern
        print "> Adding column:", pattern

    print 
    iteration += 1


# Print optimal solution
print "OPTIMAL SOLUTION:"
for c in master.cols:
    if c.primal != 0:
        pattern = [0 for i in range(m)]
        for (ri, value) in c.matrix:
            pattern[ri] = int(value)
        print "Pattern", pattern, "quantity:", c.primal
    
    
