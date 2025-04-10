# dingo-eureka

## What's dingo-eureka

The [dingo-sdk](https://github.com/dingodb/dingo-sdk) and [dingofs](https://github.com/dingodb/dingofs) third party

## Dependencies

libfuse compilation requires Meson and Ninja:

### Rocky 8.9/9.4

```sh
sudo dnf install -y epel-release
sudo dnf install -y wget tar git gcc-toolset-13* perl flex bison patch autoconf automake libtool python3-pip
sudo dnf --enablerepo=crb install -y meson ninja-build

wget https://github.com/Kitware/CMake/releases/download/v3.30.1/cmake-3.30.1-linux-x86_64.tar.gz
tar zxvf cmake-3.30.1-linux-x86_64.tar.gz
sudo cp -rf cmake-3.30.1-linux-x86_64/bin/* /usr/local/bin/ &&   sudo cp -rf  cmake-3.30.1-linux-x86_64/share/* /usr/local/share && rm -rf cmake-3.30.1-linux-x86_64

source /opt/rh/gcc-toolset-13/enable
```

### Ubuntu 22.04/24.04

In Ubuntu, /bin/sh points to /bin/dash by default. We need to use /bin/bash as default shell. un `sudo dpkg-reconfigure dash` and select the option not to use /bin/dash as the default shell.

```sh
sudo apt update
sudo apt install -y wget tar git make patch gcc g++ perl flex bison autoconf automake libtool python3-pip
sudo apt install -y meson ninja-build

wget https://github.com/Kitware/CMake/releases/download/v3.30.1/cmake-3.30.1-linux-x86_64.tar.gz
tar zxvf cmake-3.30.1-linux-x86_64.tar.gz
sudo cp -rf cmake-3.30.1-linux-x86_64/bin/* /usr/local/bin/ && sudo cp -rf  cmake-3.30.1-linux-x86_64/share/* /usr/local/share && rm -rf cmake-3.30.1-linux-x86_64
```

## How to build 

### Download the Submodule

In the source dir

```shell
git submodule sync --recursive

git submodule update --init --recursive --progress
```

### Build and Install 
The default install path is ~/.local/dingo-eureka, if you want to use custome install path, pass `-DINSTALL_PATH=you-path` to cmake

In the source dir

```shell
mkdir build && cd build

cmake -DINSTALL_PATH=you-path ..

make -j 32
```

use default install path to build and install

```shell
mkdir build && cd build

cmake ..

make -j 32
```

## Submodule Version

| Name              | Version       |
| ----------------- | ------------- |
| gflags            | master        |
| glog              | v0.6.0        |
| googletest        | main          |
| fmt               | 11.1.3        |
| nlohmann-json     | develop       |
| rapidjson         | master        |
| jsoncpp           | master        |
| zlib              | v1.3.1        |
| protobuf          | v3.25.5       |
| grpc              | v1.62.2       |
| snappy            | main          |
| leveldb           | main          |
| brpc              | 1.12.1        |
| rocksdb           | v9.8.4        |
| incbin            | main          |
| libfiu            | master        |
| c4c32c            | main          |
| memcache          | v1.x          |
| openssl           | 3.4.0         |
| spdlog            | v1.15.1       |
| curl              | curl-8_12_1   |
| opentelemetry-cpp | main          |
| aws-sdk-cpp       | 1.11.400      |
| libuuid           | master        |
| hdf5              | hdf5_1.14.4.2 |
| libfuse           | master        |
