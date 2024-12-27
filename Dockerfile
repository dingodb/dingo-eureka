# Use the specified base image
# outer-base: dingodatabase/dingo-base:rocky9 inner-base: harbor.zetyun.cn/dingofs/dingo-base:rocky9
FROM dingodatabase/dingo-base:rocky9 AS builder

# Create a working directory
WORKDIR /dingo-eureka

# Copy the project files to the working directory
COPY . .

# Build and install
RUN mkdir build && cd build && \
    cmake -DINSTALL_PATH=/root/.local/dingo-eureka .. && \
    make -j ${nproc}

# Final stage
FROM dingodatabase/dingo-base:rocky9

ENV THIRD_PARTY_INSTALL_PATH=/root/.local/dingo-eureka

# Copy installed files from builder
COPY --from=builder /root/.local/dingo-eureka /root/.local/dingo-eureka

