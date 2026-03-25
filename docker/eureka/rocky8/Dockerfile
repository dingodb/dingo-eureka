# Use the specified base image
FROM dingodatabase/dingo-base:rocky8 AS builder

# Create a working directory
WORKDIR /dingo-eureka

# Copy the project files to the working directory
COPY ../../.. .

# Build and install
RUN mkdir build && cd build && \
    cmake -DINSTALL_PATH=/root/.local/dingo-eureka .. && \
    ulimit -n 65535 && make -j 32

# Final stage
FROM dingodatabase/dingo-base:rocky8

ENV THIRD_PARTY_INSTALL_PATH=/root/.local/dingo-eureka
ENV DINGO_EUREKA_INSTALL_PATH=/root/.local/dingo-eureka

# Copy installed files from builder
COPY --from=builder /root/.local/dingo-eureka /root/.local/dingo-eureka

