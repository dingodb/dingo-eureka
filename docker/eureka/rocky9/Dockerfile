# Use the specified base image
# outer-base: dingodatabase/dingo-base:rocky9 inner-base: harbor.zetyun.cn/dingofs/dingo-base:rocky9
FROM dingodatabase/dingo-base:rocky9 AS builder
# FROM harbor.zetyun.cn/dingodb/dingo-base:rocky9-test AS builder

# Expose the gcc-toolset-13 sysroot so CMake finds its headers/libs
# (demangle.h, libiberty.a) instead of only the compiler seeing them.
ENV CMAKE_PREFIX_PATH=/opt/rh/gcc-toolset-13/root/usr

# Create a working directory
WORKDIR /dingo-eureka

# Copy the project files to the working directory
COPY ../../.. .

# Build and install
RUN mkdir build && cd build && \
    cmake -DINSTALL_PATH=/root/.local/dingo-eureka .. && \
    ulimit -n 65535 && make -j 32

# Final stage
FROM dingodatabase/dingo-base:rocky9
# FROM harbor.zetyun.cn/dingofs/dingo-base:rocky9

ENV THIRD_PARTY_INSTALL_PATH=/root/.local/dingo-eureka
ENV DINGO_EUREKA_INSTALL_PATH=/root/.local/dingo-eureka

# Copy installed files from builder
COPY --from=builder /root/.local/dingo-eureka /root/.local/dingo-eureka

