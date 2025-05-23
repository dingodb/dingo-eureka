FROM rockylinux/rockylinux:8.9

ENV TZ=Asia/Shanghai

SHELL ["/bin/bash", "-c"]

COPY cmake-3.30.1-linux-x86_64.tar.gz musl-1.2.5.tar.gz protoc-25.1-linux-x86_64.zip go1.23.4.linux-amd64.tar.gz bazel-4.2.4-linux-x86_64 jemalloc-5.3.0.tar.bz2 /tmp/

# Step 2: Install necessary packages and set up the environment
RUN dnf update -y  \
    && dnf install -y epel-release  \
    && dnf install -y wget tar git gcc-toolset-13* perl flex bison patch fuse3-devel  libnl3-devel libunwind-devel python3-devel net-tools iproute bzip2 vim autoconf automake libtool \
    && dnf install -y systemd-devel libblkid libblkid-devel keyutils-libs-devel libcap-devel \
    && dnf clean all \
    && ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone

RUN pip3 install -U meson
RUN pip3 install cython PyYAML

RUN cd /tmp && tar -zxvf cmake-3.30.1-linux-x86_64.tar.gz \
    && cp -rf cmake-3.30.1-linux-x86_64/bin/* /usr/local/bin/  \
    && cp -rf cmake-3.30.1-linux-x86_64/share/* /usr/local/share \
    && rm -rf cmake-3.30.1-linux-x86_64

RUN cd /tmp && tar -C /usr/local -xzf go1.23.4.linux-amd64.tar.gz

RUN cd /tmp && unzip protoc-25.1-linux-x86_64.zip -d $HOME/.local

RUN cd /tmp && tar -zxvf musl-1.2.5.tar.gz && cd musl-1.2.5 && ./configure && make && make install

RUN cd /tmp && cp bazel-4.2.4-linux-x86_64 /usr/bin/bazel && chmod a+x /usr/bin/bazel

RUN cd /tmp && tar -xjvf jemalloc-5.3.0.tar.bz2 && chown -R root:root jemalloc-5.3.0 && cd jemalloc-5.3.0 && ./configure && make && make install

RUN cd /tmp && unzip ninja-linux.zip -d /usr/local/bin && chmod +x /usr/local/bin/ninja

# Install build dependencies
RUN dnf groupinstall -y "Development Tools"

ENV PATH=/opt/rh/gcc-toolset-13/root/usr/bin:/usr/local/go/bin:/root/go/bin:/root/.local/bin:/usr/local/musl/bin:$PATH
