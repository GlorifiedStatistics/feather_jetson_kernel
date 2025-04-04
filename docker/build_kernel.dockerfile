# docker build -t feather_kernel -f ./build_kernel.dockerfile .
FROM ubuntu:24.04

RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install git vim sudo make bc flex bison libssl-dev axel lbzip2

WORKDIR /opt/

# Clone our kernel-building git repo and build the kernel
RUN git clone https://github.com/GlorifiedStatistics/feather_jetson_kernel.git
WORKDIR /opt/feather_jetson_kernel
RUN ./build_kernel.sh
