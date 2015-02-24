/* Hashable bit set
 * Copyright (C) 2013 Y. Zwols
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
 

/* This header file provides a fast hashable bitset implementation, which
   is used to cache TSP solutions. */ 

#ifndef HBITSET__
#define HBITSET__

#include <assert.h>
#include <inttypes.h>

#include <sstream>
#include <cstdlib>
#include <cstring>

typedef uint32_t _hbitset_word_t;

#define _HBITSET_WORDSIZE (8 * sizeof(_hbitset_word_t))
#define _HBITSET_NUM_WORDS(nbits) ((nbits + _HBITSET_WORDSIZE - 1) / _HBITSET_WORDSIZE)

template <unsigned int N>
class hbitset {
public:
  // default constructor initializes an empty bitset
  hbitset() { 
    memset(data, 0, array_size());
  }
  
  // copy constructor
  hbitset(const hbitset<N>& bs) { 
    memcpy(data, bs.data, array_size());
  }
  
  // assignment operator
  hbitset<N>& operator=(const hbitset<N> &rhs) {
    if (this == &rhs)      // Same object?
      return *this; 
    memcpy(data, rhs.data, array_size());
    return *this;
  }
  
  // equality operator
  bool operator ==(const hbitset<N>& bs) const {
    for (int i = 0; i < array_length(); i++)
      if (data[i] != bs.data[i])
        return false;
    return true;
  }
  
  // function to set a bit
  void set(const int i) {
    assert(i >= 0);
    assert(i < N);
    data[i / element_bits()] |= static_cast<_hbitset_word_t>(1) << (i & element_mask()); 
  }
  
  // function to reset a bit
  void reset(const int i) {
    assert(i >= 0);
    assert(i < N);
    data[i / element_bits()] &= ~(static_cast<_hbitset_word_t>(1) << (i & element_mask())); 
  }

  // function to set a bit
  bool get(const int i) const {
    assert(i >= 0);
    assert(i < N);
    _hbitset_word_t value = data[i / element_bits()] & (static_cast<_hbitset_word_t>(1) << (i & element_mask())); 
    return value != 0;
  }

  // maximum number of bits in the set
  size_t capacity() const {
    return N;
  }  
  
  // number of bits in the set (i.e. number of ones)
  size_t size() const {
    size_t count = 0;
    for (size_t i = 0; i < array_length(); i++) {
      _hbitset_word_t w = data[i];
      for (size_t b = 0; b < element_bits(); b++) {
        count += (w & 1);
        w >>= 1;
      }
    }
    return count;
  }

  // calculate a hash value 
  size_t hash() const {
    size_t value = 0;   
    for (int i = 0; i < array_length(); i++)
      value = _hash32(value + data[i]);
    return value;
  }
  
  // print out the contents of the set
  std::string str() const {
    std::stringstream ss;
    ss << "{";
    bool first = true;
    for (int i = 0; i < N; i++) {
      if (!get(i)) continue;
      if (!first)
        ss << ",";
      else
        first = false;
      ss << i;
    }
    ss << "}";
    return ss.str();
  }

private:  
  _hbitset_word_t data[_HBITSET_NUM_WORDS(N)];

  // size of array in bytes
  static inline size_t array_size() {
    return _HBITSET_NUM_WORDS(N) * sizeof(_hbitset_word_t);
  }

  // length of array in number of elements
  static inline size_t array_length() {
    return _HBITSET_NUM_WORDS(N);
  }

  // number of bits in one element of the data array
  static inline size_t element_bits() {
    return _HBITSET_WORDSIZE;
  }

  // this function return 2^(element_bits) - 1
  static inline size_t element_mask() {
    return (size_t) -1;
  }
  
  static inline uint32_t _hash32(uint32_t a) {
    a = (a ^ 61) ^ (a >> 16);
    a = a + (a << 3);
    a = a ^ (a >> 4);
    a = a * 0x27d4eb2d;
    a = a ^ (a >> 15);
    return a;
  }
};

namespace std {

template<unsigned int N>
struct hash<hbitset<N> > {
  std::size_t operator() (const hbitset<N> &bs) const {
    return bs.hash();
  }
};

}    
    

#endif
