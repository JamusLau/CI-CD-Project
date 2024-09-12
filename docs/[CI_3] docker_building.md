# Docker
| Table of Content |
|-------|
| [Creating an Image](#creating-an-image) |
| [Running a Container using Image](#running-a-container-with-an-image) |
| [Updating an Image](#updating-an-image) |

## Install Docker Desktop
## Creating an Image

Using __Git Bash__,

While you are in the **root** directory, use `touch Dockerfile` to create an empty Dockerfile.

With the following makefile:
```makefile
# Makefile for Hello World program
# Compiler
CXX = g++

# Compiler flags
CXXFLAGS = -Wall -g

# The target executable
TARGET = main

# The source files
SRCS = ./src/main.cpp

# Object files (generated from source files)
OBJS = $(SRCS:.cpp=.o)

# Default rule: build the target
all: $(TARGET)

# Rule to link the object files to create the executable
$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(OBJS)

# Rule to compile the source files into object files
./src/%.o: ./src/%.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Clean up build artifacts
clean:
	rm -f $(TARGET) $(OBJS)

# Phony targets (not actual files)
.PHONY: all clean
```

You can use the following Dockerfile configuration:
```Dockerfile
# using an official gcc compiler image as the base image
FROM gcc:latest

# Set the working directory inside the container
WORKDIR /app

# Copying the makefile and source files to the woking dir
COPY ../src /app/src
COPY makefile /app/

# Install any necessary packages (if needed)
RUN apt-get update && apt-get install -y make

# Run make to build the application
RUN make

# Specify the command to run the application
CMD ["./main"]
```

To build the image, use `docker build -t <name>:<tag> .`,
- `docker build` command uses the Dockerfile to build a new image.
- `-t` tags the image with `<name>`.
- `<tag>` is optional but useful for tagging version onto Image.
- `.` at the end tells `docker build` to look for the Dockerfile in the current directory.

## Running a Container with an Image

To run the image in a container, use `docker run -dp HOST:CONTAINER <name>`,
- `-d (--detach)` runs the container in the background, where Docker will start your container and return you to the command prompt.
- `-p (--publish)` creates a port mapping between the host and container. Takes in a string value in format of `HOST:CONTAINER`, where `HOST` is the address on the host, and `CONTAINER` is the port on the container. e.g. `127.0.0.1:3000:3000` for `localhost:3000`.

Use Docker Desktop or `docker ps` to see all running containers.

Use `docker logs  -f <ContainerName>` to view the logs of a container in real time.

## Updating an Image
To update an image, use the same `docker build -t <name> .` command.
- `<name>` has to be the same as the one you are updating, use different name if you are planning to keep different versions of it.

Stop the old container running the image using `docker stop <container-id>`.

Remove the old container using `docker rm <container-id>`.

Run the container again using the same command: `docker run -dp 127.0.0.1:3000:3000 <name>`.
