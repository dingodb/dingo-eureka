# Use the specified base image
FROM dingodatabase/dingo-base:manylinux_2_34 AS builder

# Create a working directory
WORKDIR /dingo-eureka

# Copy the project files to the working directory
COPY ../../.. .

# Install cmake 3.30.1 to avoid cmake 4.x incompatibility with old cmake_minimum_required versions
RUN wget -q https://github.com/Kitware/CMake/releases/download/v3.30.1/cmake-3.30.1-linux-x86_64.tar.gz && \
    tar zxf cmake-3.30.1-linux-x86_64.tar.gz -C /opt/ && \
    rm cmake-3.30.1-linux-x86_64.tar.gz
ENV PATH="/opt/cmake-3.30.1-linux-x86_64/bin:$PATH"

# Build and install
RUN mkdir build && cd build && \
    cmake -DINSTALL_PATH=/root/.local/dingo-eureka -DWITH_LIBUSRBIO=OFF -DWITH_BOOST=OFF -DWITH_LIBRADOS=OFF -DWITH_TOML11=OFF -DWITH_LIBFUSE=OFF -DWITH_AWSSDKCPP=OFF -DWITH_TIKVCPP=OFF -DWITH_NANOBIND=ON .. && \
    ulimit -n 65535 && make -j2 -k

# Final stage
FROM dingodatabase/dingo-base:manylinux_2_34

ENV THIRD_PARTY_INSTALL_PATH=/root/.local/dingo-eureka
ENV DINGO_EUREKA_INSTALL_PATH=/root/.local/dingo-eureka

# Copy installed files from builder
COPY --from=builder /root/.local/dingo-eureka /root/.local/dingo-eureka

