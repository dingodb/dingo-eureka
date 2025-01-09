FROM ubuntu:22.04

ENV TZ=Asia/Shanghai \
    LANG=C.UTF-8     \
    LC_ALL=C.UTF-8

SHELL ["/bin/bash", "-c"]

COPY cmake-3.30.1-linux-x86_64.tar.gz musl-1.2.5.tar.gz protoc-25.1-linux-x86_64.zip go1.23.4.linux-amd64.tar.gz jemalloc-5.3.0.tar.bz2 /tmp/

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get clean \
    && apt-get -y update \
    && apt install -y bzip2 unzip wget tar git make patch gcc g++ perl flex bison libnl-genl-3-dev libunwind-dev libfuse3-dev python3-dev software-properties-common \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone

RUN cd /tmp && tar -zxvf cmake-3.30.1-linux-x86_64.tar.gz \
    && cp -rf cmake-3.30.1-linux-x86_64/bin/* /usr/local/bin/  \
    && cp -rf cmake-3.30.1-linux-x86_64/share/* /usr/local/share \
    && rm -rf cmake-3.30.1-linux-x86_64

RUN cd /tmp && tar -C /usr/local -xzf go1.23.4.linux-amd64.tar.gz

RUN cd /tmp && unzip protoc-25.1-linux-x86_64.zip -d $HOME/.local

RUN cd /tmp && tar -zxvf musl-1.2.5.tar.gz && cd musl-1.2.5 && ./configure && make && make install

RUN cd /tmp && tar -xjvf jemalloc-5.3.0.tar.bz2 && cd jemalloc-5.3.0 && ./configure && make && make install

# Build and install libfiu
RUN mkdir -p /tmp/build && \
    cd /tmp/build && \
    wget https://github.com/albertito/libfiu/archive/refs/tags/1.1.tar.gz && \
    tar -xzf 1.1.tar.gz && \
    cd libfiu-1.1 && \ 
    make && \
    make install && \
    ldconfig

# Add Ubuntu toolchain PPA to get GCC 13
RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test

# Install GCC 13 and related tools
RUN apt-get update && apt-get install -y \
    gcc-13 \
    g++-13 \
    gfortran-13 \
    libomp-13-dev \
    && rm -rf /var/lib/apt/lists/*

# Set GCC 13 as the default compiler
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 100 \
    --slave /usr/bin/g++ g++ /usr/bin/g++-13 \
    --slave /usr/bin/gfortran gfortran /usr/bin/gfortran-13

# Set up additional development tools and libraries
RUN apt-get update && apt-get install -y \
    autoconf \
    automake \
    libtool \
    build-essential \
    gdb \
    valgrind \
    && rm -rf /var/lib/apt/lists/*

# Set up environment variables
ENV CC=/usr/bin/gcc-13
ENV CXX=/usr/bin/g++-13
ENV FC=/usr/bin/gfortran-13

ENV PATH=/opt/rh/gcc-toolset-13/root/usr/bin:/usr/local/go/bin:/root/go/bin:/root/.local/bin:/usr/local/musl/bin:$PATH