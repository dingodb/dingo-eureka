# Use the specified base image
FROM dingodatabase/dingo-base:ubuntu2204 AS builder

# Create a working directory
WORKDIR /dingo-eureka

# Copy the project files to the working directory
COPY ../../.. .

# Build and install
RUN mkdir build && cd build && \
    cmake -DINSTALL_PATH=/root/.local/dingo-eureka -DCMAKE_BUILD_TYPE=Release .. && \
    make -j 32

# Final stage
FROM dingodatabase/dingo-base:ubuntu2204

ENV THIRD_PARTY_INSTALL_PATH=/root/.local/dingo-eureka
ENV DINGO_EUREKA_INSTALL_PATH=/root/.local/dingo-eureka

# Copy installed files from builder
COPY --from=builder /root/.local/dingo-eureka /root/.local/dingo-eureka

