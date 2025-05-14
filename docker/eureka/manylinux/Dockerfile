# Use the specified base image
FROM dingodatabase/dingo-base:manylinux_2_34 AS builder

# Create a working directory
WORKDIR /dingo-eureka

# Copy the project files to the working directory
COPY ../../.. .

# Build and install
RUN mkdir build && cd build && \
    cmake -DINSTALL_PATH=/root/.local/dingo-eureka -DWITH_LIBUSRBIO=OFF -DWITH_BOOST=OFF -DWITH_LIBRADOS=OFF -DWITH_TOML11=OFF -DWITH_LIBFUSE=OFF -DWITH_AWSSDKCPP=OFF .. && \
    ulimit -n 65535 && make -j2 -k

# Final stage
FROM dingodatabase/dingo-base:manylinux_2_34

ENV THIRD_PARTY_INSTALL_PATH=/root/.local/dingo-eureka
ENV DINGO_EUREKA_INSTALL_PATH=/root/.local/dingo-eureka

# Copy installed files from builder
COPY --from=builder /root/.local/dingo-eureka /root/.local/dingo-eureka

