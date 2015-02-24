# Unit tests for interior path algorithm
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

import unittest
import intpm
from numpy.testing import assert_array_equal
from numpy import matrix

class TestIntPm(unittest.TestCase):
  def setUp(self):
    self.seq = range(10)
      
  def test_e(self):
    assert_array_equal([[1]], intpm.e(1))
    assert_array_equal([[1], [1]], intpm.e(2))

  def test_z(self):
    assert_array_equal([[0]], intpm.z(1))
    assert_array_equal([[0], [0]], intpm.z(2))
    
if __name__ == '__main__':
  unittest.main()
