# Makefile for Hello World program

# Compiler
CXX = g++

# Compiler flags
CXXFLAGS = -Wall -g

# The target executable
TARGET = main

# The source files
SRCS = ../src/main.cpp

# Object files (generated from source files)
OBJS = $(SRCS:.cpp=.o)

# Default rule: build the target
all: $(TARGET)

# Rule to link the object files to create the executable
$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(OBJS)

# Rule to compile the source files into object files
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Clean up build artifacts
clean:
	rm -f $(TARGET) $(OBJS)

# Phony targets (not actual files)
.PHONY: all clean