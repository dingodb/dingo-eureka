FROM quay.io/pypa/manylinux_2_34_x86_64:latest

ENV TZ=Asia/Shanghai

SHELL ["/bin/bash", "-c"]

# wget -P /tmp/ https://github.com/protocolbuffers/protobuf/releases/download/v25.1/protoc-25.1-linux-x86_64.zip
# wget -P /tmp/ https://github.com/ninja-build/ninja/releases/download/v1.12.1/ninja-linux.zip
COPY protoc-25.1-linux-x86_64.zip  ninja-linux.zip /tmp/

# Install necessary packages and set up the environment
RUN dnf update -y  \
    && dnf install -y epel-release  \
    && dnf install -y wget tar git perl perl-lib perl-FindBin perl-IPC-Cmd flex bison patch fuse3-devel  libnl3-devel libunwind-devel python3-devel net-tools iproute bzip2 vim autoconf automake libtool \
    && dnf clean all \
    && ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone

RUN pip3 install -U meson

RUN cd /tmp && unzip protoc-25.1-linux-x86_64.zip -d $HOME/.local

RUN cd /tmp && unzip ninja-linux.zip -d /usr/local/bin && chmod +x /usr/local/bin/ninja

# Install build dependencies
RUN dnf groupinstall -y "Development Tools"

ENV PATH=/root/.local/bin:$PATH
