CXX=g++

all: helicopter 

helicopter: src/helicopter.cc src/hbitset.h
	$(CXX) -DNDEBUG -march=native -O3 -o helicopter src/helicopter.cc -lglpk -lrt -std=gnu++0x



