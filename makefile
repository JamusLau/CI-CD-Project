CXX = g++;
CXXFLAGS = -Wall -std=c++17

all: main

main: main.o
	$(CXX) $(CXXFLAGS) -o main main.o

main.o: main.cpp
	$(CXX) $(CXXFLAGS) -c src/main.cpp

clean:
	rm -f main main.o