# dingo-eureka

## What's dingo-eureka

The [dingo-sdk](https://github.com/dingodb/dingo-sdk) and [dingofs](https://github.com/dingodb/dingofs) third party

## Dependencies

libfuse compilation requires Meson and Ninja:

### Rocky 8.9/9.4

```sh
sudo dnf install -y epel-release && sudo crb enable
sudo dnf install -y wget tar git 'gcc-toolset-13*' perl flex bison patch autoconf automake libtool python3-pip pkgconfig libblkid-devel
sudo dnf install -y meson ninja-build
#for ceph librados
sudo dnf install -y systemd-devel libblkid keyutils-libs-devel libcap-devel python3-pyyaml
python3 -m pip install cython

wget https://github.com/Kitware/CMake/releases/download/v3.30.1/cmake-3.30.1-linux-x86_64.tar.gz
tar zxvf cmake-3.30.1-linux-x86_64.tar.gz
sudo cp -rf cmake-3.30.1-linux-x86_64/bin/* /usr/local/bin/ &&  sudo cp -rf  cmake-3.30.1-linux-x86_64/share/* /usr/local/share && rm -rf cmake-3.30.1-linux-x86_64
```

### Ubuntu 22.04/24.04

In Ubuntu, /bin/sh points to /bin/dash by default. We need to use /bin/bash as default shell. un `sudo dpkg-reconfigure dash` and select the option not to use /bin/dash as the default shell.

```sh
sudo apt update
sudo apt install -y wget tar git make patch gcc g++ perl flex bison autoconf automake libtool python3-pip pkg-config
sudo apt install -y meson ninja-build
#for usrbio
sudo apt install  gcc-12 g++-12 clang-14 libibverbs-dev
#for ceph librados
sudo apt install -y libudev-dev libblkid-dev libkeyutils-dev libcap-dev cython3 python3-yaml 

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
cmake -S . -B build -DINSTALL_PATH=you-path

cmake --build build -j 32 --verbose
```

There some lib build by ninja, and it's parrallel jobs not contorl by `cmake -j 32` or `make -j`
we can change it's s parrallel jobs in cmake configure phase, use `-DNINJA_JOBS=N`, the default is 8

for example

```shell
cmake -S . -B build -DNINJA_JOBS=16

cmake --build build -j 32 --verbose
```

use default install path to build and install

```shell
cmake -S . -B build

cmake --build build -j 32 --verbose
```

generate dingo-eureka package

```shell
cmake -S . -B build -DINSTALL_PATH=/opt/dingo-eureka -DENABLE_PACKAGE=ON -DPACKAGE_OUTPUT_PATH=/opt/packages

cmake --build build -j 32 --verbose

cd build && cpack
``` 
**Note:** The install path on the target server must also be /opt/dingo-eureka.

disable rados library build

```shell
cmake -DWITH_LIBRADOS=OFF ..
```

disable 3fs usrbio library build

```shell
cmake -DWITH_LIBUSRBIO=OFF ..
```

disable boost library build

note:you must also disable libusrbio and librados,because they depend on boost

```shell
cmake -DWITH_BOOST=OFF -DWITH_LIBRADOS=OFF -DWITH_LIBUSRBIO=OFF ..
```

## Submodule Version

| Name              | Version       |
| ----------------- | ------------- |
| gflags            | master        |
| glog              | v0.6.0        |
| googletest        | main          |
| toml11            | main          |
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
| double-conversion | master        |
| numactl           | master        |
| libevent          | master        |
| boost             | 1.82.0        |
| libusrbio         | main          |
| rdma-core         | v57.0         |
| librados          | v19.3.0       |
