############################### Using ubuntu ###############################################
# using an official gcc compiler image as the base image
FROM ubuntu:latest

# Set the working directory inside the container
WORKDIR /app

# Copying the makefile and source files to the woking dir
COPY ../src /app/src
# COPY makefile /app/

# Install any necessary packages (if needed)
# RUN apt-get update && apt-get install -y make
RUN apt-get update && apt-get install -y \
    g++ \
    libcpprest-dev \
    libboost-all-dev \
    libssl-dev \
    cmake

# Run make to build the application
# RUN make
RUN g++ -o ok_app src/main.cpp -lcpprest -lboost_system -lboost_thread -lboost_chrono -lboost_random -lssl -lcrypto

# Expose the port on which the API will listen
EXPOSE 8080

# Specify the command to run the application
CMD ["./main"]
#################################################################################
############################### Using Makefile #############################################
# # using an official gcc compiler image as the base image
# FROM gcc:latest

# # Set the working directory inside the container
# WORKDIR /app

# # Copying the makefile and source files to the woking dir
# COPY ../src /app/src
# COPY makefile /app/

# # Install any necessary packages (if needed)
# RUN apt-get update && apt-get install -y make

# # Run make to build the application
# RUN make

# # Specify the command to run the application
# CMD ["./main"]
#################################################################################