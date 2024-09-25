############################### Using ubuntu ###############################################
# # using an official gcc compiler image as the base image
# FROM ubuntu:latest

# # Set the working directory inside the container
# WORKDIR /app

# # Copying the makefile and source files to the woking dir
# COPY ./src /app/src

# # Install any necessary packages (if needed)
# RUN apt-get update && apt-get install -y \
#     g++ \
#     libcpprest-dev \
#     libboost-all-dev \
#     libssl-dev \
#     cmake

# # Run make to build the application
# RUN g++ -o ok_app src/ok-app.cpp -lcpprest -lboost_system -lboost_thread -lboost_chrono -lboost_random -lssl -lcrypto

# # Expose the port on which the API will listen
# EXPOSE 8080

# # Specify the command to run the application
# CMD ["./ok_app"]
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
############################### Using Makefile #############################################
# Use the official Microsoft Visual Studio Build Tools image
FROM mcr.microsoft.com/dotnet/framework/runtime:4.8-windowsservercore-ltsc2019

# See. https://stackoverflow.com/questions/76470752/chocolatey-installation-in-docker-started-to-fail-restart-due-to-net-framework
ENV chocolateyVersion=1.4.0

# Set the working directory inside the container
WORKDIR /app

# Copy the source file to the working directory
COPY ./src /app/src

# Set the shell to PowerShell
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Install Chocolatey
RUN Set-ExecutionPolicy Bypass -Scope Process -Force; \
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; \
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'));

# Verify Chocolatey Installation
RUN choco --version;

# Install build dependencies
RUN choco install visualstudio2019buildtools --allWorkloads --includeRecommended --includeOptional --passive -y; \
    choco install powershell-core -y

# Set the shell to PowerShell
SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Compile the C++ program
RUN cd "C:\BuildTools\Common7\Tools\"; \
    & .\VsDevCmd.bat -arch=amd64 && \
    cl /EHsc src/main.cpp /Fe:main.exe

#################################################################################