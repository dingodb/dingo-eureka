FROM rockylinux/rockylinux:8.9

ENV TZ=Asia/Shanghai

SHELL ["/bin/bash", "-c"]

COPY cmake-3.30.1-linux-x86_64.tar.gz protoc-25.1-linux-x86_64.zip /tmp/

# Step 2: Install necessary packages and set up the environment
RUN dnf update -y  \
    && dnf install -y epel-release  \
    && dnf install -y wget tar git gcc-toolset-13* perl flex bison patch fuse3-devel  libnl3-devel libunwind-devel python3-devel net-tools iproute bzip2 vim autoconf automake libtool \
    && dnf install -y systemd-devel libblkid libblkid-devel keyutils-libs-devel libcap-devel \
    && dnf clean all \
    && ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone

RUN cd /tmp && tar -zxvf cmake-3.30.1-linux-x86_64.tar.gz \
    && cp -rf cmake-3.30.1-linux-x86_64/bin/* /usr/local/bin/  \
    && cp -rf cmake-3.30.1-linux-x86_64/share/* /usr/local/share \
    && rm -rf cmake-3.30.1-linux-x86_64 && rm -rf /tmp/cmake-3.30.1-linux-x86_64.tar.gz

RUN cd /tmp && unzip protoc-25.1-linux-x86_64.zip -d $HOME/.local && rm -rf /tmp/protoc-25.1-linux-x86_64.zip

# Install build dependencies
RUN dnf groupinstall -y "Development Tools"

ENV PATH=/opt/rh/gcc-toolset-13/root/usr/bin:/usr/local/go/bin:/root/go/bin:/root/.local/bin:/usr/local/musl/bin:$PATH
