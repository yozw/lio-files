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
