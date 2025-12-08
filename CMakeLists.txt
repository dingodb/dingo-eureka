# Copyright (c) 2024 dingodb.com, Inc. All Rights Reserved
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.

cmake_minimum_required(VERSION 3.23.1 FATAL_ERROR)
project(dingo-eureka C CXX)

# dingo-eureka version
set(DINGOEUREKA_VERSION 1.0)

# third-party install path
if(NOT INSTALL_PATH)
  set(INSTALL_PATH "$ENV{HOME}/.local/dingo-eureka")
endif()
message("INSTALL_PATH:${INSTALL_PATH}")

option(ENABLE_PACKAGE "Enable package generation" OFF)
if(ENABLE_PACKAGE)
  include(cmake/package.cmake)
endif()

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "RelWithDebInfo")
endif()
message("CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}")

if(CMAKE_BUILD_TYPE MATCHES "Debug")
  set(CMAKE_STATIC_LIBRARY_SUFFIX "d.a")
endif()

file(MAKE_DIRECTORY "${INSTALL_PATH}/lib")
file(MAKE_DIRECTORY "${INSTALL_PATH}/cmake")
file(MAKE_DIRECTORY "${INSTALL_PATH}/include")

set(NINJA_JOBS
    8
    CACHE STRING "Number of jobs to run in parallel when building with ninja")
message("Number of jobs to run in parallel when building with ninja: ${NINJA_JOBS}")

include(ExternalProject)

set(GFLAGS_INCLUDE_DIR
    "${INSTALL_PATH}/include"
    CACHE PATH "gflags include directory." FORCE)

if(WIN32)
  set(GFLAGS_LIBRARIES
      "${INSTALL_PATH}/lib/gflags_static.lib"
      CACHE FILEPATH "GFLAGS_LIBRARIES" FORCE)
else(WIN32)
  if(CMAKE_BUILD_TYPE MATCHES "Debug")
    set(GFLAGS_LIBRARIES
        "${INSTALL_PATH}/lib/libgflags_debug.a"
        CACHE FILEPATH "GFLAGS_LIBRARIES" FORCE)
  else()
    set(GFLAGS_LIBRARIES
        "${INSTALL_PATH}/lib/libgflags.a"
        CACHE FILEPATH "GFLAGS_LIBRARIES" FORCE)
  endif()
endif(WIN32)

# print GFLAGS_LIBRARIES
message("GFLAGS_LIBRARIES: ${GFLAGS_LIBRARIES}")

ExternalProject_Add(
  gflags
  PREFIX gflags
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/gflags
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DBUILD_STATIC_LIBS=ON -DBUILD_TESTING=OFF -DINSTALL_HEADERS=ON
  CMAKE_CACHE_ARGS -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_PATH}
                   -DCMAKE_INSTALL_LIBDIR:PATH=${INSTALL_PATH}/lib)

set(GLOG_INCLUDE_DIR
    "${INSTALL_PATH}/include"
    CACHE PATH "glog include directory." FORCE)

if(WIN32)
  set(GLOG_LIBRARIES
      "${INSTALL_PATH}/lib/glog.lib"
      CACHE FILEPATH "glog library." FORCE)
  set(GLOG_CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /wd4267 /wd4530")
else(WIN32)
  set(GLOG_LIBRARIES
      "${INSTALL_PATH}/lib/libglog${CMAKE_STATIC_LIBRARY_SUFFIX}"
      CACHE FILEPATH "glog library." FORCE)
  set(GLOG_CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS})
endif(WIN32)

# version must less than 0.7.0, because brpc depends
ExternalProject_Add(
  glog
  PREFIX glog
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/glog
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DBUILD_TESTING=OFF -DBUILD_SHARED_LIBS=OFF -DWITH_GFLAGS=ON
             -DWITH_UNWIND=OFF
  CMAKE_CACHE_ARGS -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON -Dgflags_DIR:STRING=${INSTALL_PATH}/lib/cmake/gflags
                   -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_PATH} -DCMAKE_INSTALL_LIBDIR:PATH=${INSTALL_PATH}/lib
  DEPENDS gflags)

ExternalProject_Add(
  gtest
  PREFIX gtest
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/googletest
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
  CMAKE_CACHE_ARGS -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_PATH}
                   -DCMAKE_INSTALL_LIBDIR:PATH=${INSTALL_PATH}/lib)

option(WITH_TOML11 "Build toml11 library" ON)

if(WITH_TOML11)
  ExternalProject_Add(
    toml11
    PREFIX toml11
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/toml11
    CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DTOML11_PRECOMPILE=ON
    CMAKE_CACHE_ARGS -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_PATH}
                     -DCMAKE_INSTALL_LIBDIR:PATH=${INSTALL_PATH}/lib)
endif()

ExternalProject_Add(
  fmt
  PREFIX fmt
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/fmt
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DFMT_TEST=OFF
  CMAKE_CACHE_ARGS -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_PATH}
                   -DCMAKE_INSTALL_LIBDIR:PATH=${INSTALL_PATH}/lib)

# used by sdk/fs
ExternalProject_Add(
  nlohmann-json
  PREFIX nlohmann-json
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/nlohmann-json
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_PREFIX_PATH=${INSTALL_PATH} -DJSON_BuildTests=OFF
             -DJSON_MultipleHeaders=ON -DJSON_Install=ON
  CMAKE_CACHE_ARGS -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_PATH}
                   -DCMAKE_INSTALL_LIBDIR:PATH=${INSTALL_PATH}/lib)

# used by sdk
ExternalProject_Add(
  rapidjson
  PREFIX rapidjson
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/rapidjson
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DBUILD_SHARED_LIBS=OFF -DRAPIDJSON_BUILD_DOC=OFF
             -DRAPIDJSON_BUILD_EXAMPLES=OFF -DRAPIDJSON_BUILD_TESTS=OFF
  CMAKE_CACHE_ARGS -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_PATH}
                   -DCMAKE_INSTALL_LIBDIR:PATH=${INSTALL_PATH}/lib)

# used by fs used by grpc protobuf
ExternalProject_Add(
  jsoncpp
  PREFIX jsoncpp
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/jsoncpp
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DJSONCPP_WITH_TESTS=OFF -DJSONCPP_WITH_POST_BUILD_UNITTEST=OFF
             -DBUILD_SHARED_LIBS=OFF -DBUILD_OBJECT_LIBS=OFF
  CMAKE_CACHE_ARGS -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_PATH}
                   -DCMAKE_INSTALL_LIBDIR:PATH=${INSTALL_PATH}/lib)

set(ZLIB_SOURCES_DIR ${CMAKE_CURRENT_SOURCE_DIR}/zlib)
set(ZLIB_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/zlib/build)

# print CMAKE_CURRENT_BINARY_DIR
message("CMAKE_CURRENT_BINARY_DIR: ${CMAKE_CURRENT_BINARY_DIR}")

file(WRITE ${ZLIB_BINARY_DIR}/copy_repo.sh
     "mkdir -p ${ZLIB_BINARY_DIR} && cp -rf ${ZLIB_SOURCES_DIR}/* ${ZLIB_BINARY_DIR}/")

execute_process(COMMAND sh ${ZLIB_BINARY_DIR}/copy_repo.sh)

# used by sdk/fs
ExternalProject_Add(
  zlib
  PREFIX zlib
  SOURCE_DIR ${ZLIB_BINARY_DIR}
  BINARY_DIR ${ZLIB_BINARY_DIR}
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DBUILD_SHARED_LIBS=OFF
  CMAKE_CACHE_ARGS -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=TRUE -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_PATH}
                   -DCMAKE_INSTALL_LIBDIR:PATH=${INSTALL_PATH}/lib)

# the openssl libdir must be relative path, this is bug: https://github.com/openssl/openssl/issues/26096
set(OPENSSL_SOURCES_DIR ${CMAKE_CURRENT_SOURCE_DIR}/openssl)
set(OPENSSL_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/openssl/build)
ExternalProject_Add(
  openssl
  PREFIX openssl
  SOURCE_DIR ${OPENSSL_SOURCES_DIR}
  BINARY_DIR ${OPENSSL_BINARY_DIR}
  CONFIGURE_COMMAND sh ${OPENSSL_SOURCES_DIR}/config -DOPENSSL_NO_SCTP -DOPENSSL_NO_KTLS -DOPENSSL_USE_NODELETE
                    -DOPENSSL_PIC -no-shared --prefix=${INSTALL_PATH} --libdir=lib
  BUILD_COMMAND $(MAKE)
  INSTALL_COMMAND ${CMAKE_COMMAND} -E chdir ${OPENSSL_BINARY_DIR} $(MAKE) install_sw)

set(PROTOBUF_SOURCES_DIR ${CMAKE_CURRENT_SOURCE_DIR}/protobuf)

ExternalProject_Add(
  absl
  PREFIX absl
  SOURCE_DIR "${PROTOBUF_SOURCES_DIR}/third_party/abseil-cpp"
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DABSL_BUILD_TESTING=OFF -DCMAKE_PREFIX_PATH=${INSTALL_PATH}
             -DABSL_USE_GOOGLETEST_HEAD=ON -DCMAKE_CXX_STANDARD=17
  CMAKE_CACHE_ARGS -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=TRUE -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_PATH}
                   -DCMAKE_INSTALL_LIBDIR:PATH=${INSTALL_PATH}/lib)

ExternalProject_Add(
  utf8_range
  PREFIX utf8_range
  SOURCE_DIR "${PROTOBUF_SOURCES_DIR}/third_party/utf8_range"
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_CXX_STANDARD=17
  CMAKE_CACHE_ARGS
    -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=TRUE -Dutf8_range_ENABLE_TESTS:BOOL=OFF
    -Dabsl_DIR:STRING=${INSTALL_PATH}/lib/cmake/absl -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_PATH}
    -DCMAKE_INSTALL_LIBDIR:PATH=${INSTALL_PATH}/lib
  DEPENDS absl)

# used by sdk/fs used by grpc
set(PROTOBUF_INSTALL_DIR ${INSTALL_PATH})
set(PROTOBUF_INCLUDE_DIR
    "${PROTOBUF_INSTALL_DIR}/include"
    CACHE PATH "protobuf include directory." FORCE)
set(PROTOBUF_LITE_LIBRARY
    "${PROTOBUF_INSTALL_DIR}/lib/libprotobuf-lite${CMAKE_STATIC_LIBRARY_SUFFIX}"
    CACHE FILEPATH "protobuf lite library." FORCE)
set(PROTOBUF_LIBRARY
    "${PROTOBUF_INSTALL_DIR}/lib/libprotobuf${CMAKE_STATIC_LIBRARY_SUFFIX}"
    CACHE FILEPATH "protobuf library." FORCE)
set(PROTOBUF_LIBRARIES
    ${PROTOBUF_LIBRARY}
    CACHE FILEPATH "protobuf library." FORCE)
set(PROTOBUF_PROTOC_LIBRARY
    "${PROTOBUF_INSTALL_DIR}/lib/libprotoc${CMAKE_STATIC_LIBRARY_SUFFIX}"
    CACHE FILEPATH "protoc library." FORCE)
set(PROTOBUF_PROTOC_EXECUTABLE
    "${PROTOBUF_INSTALL_DIR}/bin/protoc${CMAKE_EXECUTABLE_SUFFIX}"
    CACHE FILEPATH "protobuf executable." FORCE)

ExternalProject_Add(
  protobuf
  PREFIX protobuf
  SOURCE_DIR "${PROTOBUF_SOURCES_DIR}"
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_CXX_STANDARD=17
  CMAKE_CACHE_ARGS
    -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=TRUE
    -Dprotobuf_BUILD_TESTS:BOOL=OFF
    -Dprotobuf_WITH_ZLIB:BOOL=ON
    -DZLIB_ROOT:STRING=${INSTALL_PATH}
    -Dprotobuf_ABSL_PROVIDER:STRING=package
    -Dabsl_DIR:STRING=${INSTALL_PATH}/lib/cmake/absl
    -Dutf8_range_DIR:STRING=${INSTALL_PATH}/lib/cmake/utf8_range
    -Dprotobuf_JSONCPP_PROVIDER:STRING=package
    -Dprotobuf_MSVC_STATIC_RUNTIME:BOOL=OFF
    -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_PATH}
    # -DCMAKE_INSTALL_LIBDIR:PATH=lib # v21.12
    -DCMAKE_INSTALL_LIBDIR:PATH=${INSTALL_PATH}/lib # new version
  DEPENDS absl utf8_range zlib jsoncpp)

option(WITH_GRPC "Build grpc library" ON)

if(WITH_GRPC)
  set(GRPC_SOURCES_DIR ${CMAKE_CURRENT_SOURCE_DIR}/grpc)

  # Builds c-ares project from the git submodule.
  ExternalProject_Add(
    c-ares
    PREFIX c-ares
    SOURCE_DIR "${GRPC_SOURCES_DIR}/third_party/cares/cares"
    CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    CMAKE_CACHE_ARGS
      -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=TRUE -DCARES_SHARED:BOOL=OFF -DCARES_STATIC:BOOL=ON
      -DCARES_STATIC_PIC:BOOL=ON -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_PATH}
      -DCMAKE_INSTALL_LIBDIR:PATH=${INSTALL_PATH}/lib)

  # used by grpc Builds re2 project from the git submodule.
  ExternalProject_Add(
    re2
    PREFIX re2
    SOURCE_DIR "${GRPC_SOURCES_DIR}/third_party/re2"
    CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    CMAKE_CACHE_ARGS -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=TRUE -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_PATH}
                     -DCMAKE_INSTALL_LIBDIR:PATH=${INSTALL_PATH}/lib)

  # the location where protobuf-config.cmake will be installed varies by platform
  if(WIN32)
    set(_FINDPACKAGE_PROTOBUF_CONFIG_DIR "${INSTALL_PATH}/cmake")
  else()
    set(_FINDPACKAGE_PROTOBUF_CONFIG_DIR "${INSTALL_PATH}/lib/cmake/protobuf")
  endif()

  # if OPENSSL_ROOT_DIR is set, propagate that hint path to the external projects with OpenSSL dependency.
  # set(_CMAKE_ARGS_OPENSSL_ROOT_DIR "") if (OPENSSL_ROOT_DIR) set(_CMAKE_ARGS_OPENSSL_ROOT_DIR
  # "-DOPENSSL_ROOT_DIR:PATH=${OPENSSL_ROOT_DIR}") endif()

  # used by sdk Builds gRPC based on locally checked-out sources and set arguments so that all the dependencies are
  # correctly located.
  ExternalProject_Add(
    grpc
    PREFIX grpc
    SOURCE_DIR "${GRPC_SOURCES_DIR}"
    CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DOPENSSL_USE_STATIC_LIBS=TRUE
    CMAKE_CACHE_ARGS
      -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=TRUE
      -DgRPC_INSTALL:BOOL=ON
      -DgRPC_BUILD_TESTS:BOOL=OFF
      -DgRPC_BUILD_MSVC_MP_COUNT:STRING=-1
      -Dutf8_range_DIR:STRING=${INSTALL_PATH}/lib/cmake/utf8_range
      -DgRPC_PROTOBUF_PROVIDER:STRING=package
      -DProtobuf_DIR:PATH=${_FINDPACKAGE_PROTOBUF_CONFIG_DIR}
      -DgRPC_RE2_PROVIDER:STRING=package
      -Dre2_DIR:STRING=${INSTALL_PATH}/lib/cmake/re2
      -DgRPC_ZLIB_PROVIDER:STRING=package
      -DZLIB_ROOT:STRING=${INSTALL_PATH}
      -DgRPC_ABSL_PROVIDER:STRING=package
      -Dabsl_DIR:STRING=${INSTALL_PATH}/lib/cmake/absl
      -DgRPC_CARES_PROVIDER:STRING=package
      -Dc-ares_DIR:PATH=${INSTALL_PATH}/lib/cmake/c-ares
      -DgRPC_SSL_PROVIDER:STRING=package
      -DOPENSSL_ROOT_DIR:PATH=${INSTALL_PATH}
      -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_PATH}
      -DCMAKE_INSTALL_LIBDIR:PATH=${INSTALL_PATH}/lib
    DEPENDS c-ares protobuf re2 zlib absl openssl)
endif()

# use by brpc/rocksdb
ExternalProject_Add(
  snappy
  PREFIX snappy
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/snappy
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DSNAPPY_BUILD_TESTS=OFF -DSNAPPY_BUILD_BENCHMARKS=OFF
  CMAKE_CACHE_ARGS -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=TRUE -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_PATH}
                   -DCMAKE_INSTALL_LIBDIR:PATH=${INSTALL_PATH}/lib)

# use by brpc
ExternalProject_Add(
  leveldb
  PREFIX leveldb
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/leveldb
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DLEVELDB_BUILD_TESTS=OFF -DLEVELDB_BUILD_BENCHMARKS=OFF
  CMAKE_CACHE_ARGS -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=TRUE -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_PATH}
                   -DCMAKE_INSTALL_LIBDIR:PATH=${INSTALL_PATH}/lib)

# used by sdk/fs If minimal .a is need, you can set  WITH_DEBUG_SYMBOLS=OFF
set(BRPC_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/brpc/build)
set(DYNAMIC_ANNOTATIONS_HEADER_PATH ${INSTALL_PATH}/include/butil/third_party/dynamic_annotations/dynamic_annotations.h)
ExternalProject_Add(
  brpc
  PREFIX brpc
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/brpc
  BINARY_DIR ${BRPC_BINARY_DIR}
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
             -DCMAKE_PREFIX_PATH=${INSTALL_PATH}
             -DWITH_GLOG=ON
             -DWITH_SNAPPY=ON
             -DDOWNLOAD_GTEST=OFF
             -DBUILD_BRPC_TOOLS=OFF
             -DWITH_DEBUG_SYMBOLS=OFF
             -DOPENSSL_USE_STATIC_LIBS=TRUE
             -DGLOG_INCLUDE_PATH=${GLOG_INCLUDE_DIR}
             -DGLOG_LIB=${GLOG_LIBRARIES}
             -DGFLAGS_INCLUDE_PATH=${GFLAGS_INCLUDE_DIR}
             -DGFLAGS_LIBRARY=${GFLAGS_LIBRARIES}
             -DPROTOC_LIB=${PROTOBUF_LIBRARIES}
  CMAKE_CACHE_ARGS
    -DOPENSSL_ROOT_DIR:PATH=${INSTALL_PATH} -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON
    -Dgflags_DIR:STRING=${INSTALL_PATH}/lib/cmake/gflags -DProtobuf_DIR:PATH=${_FINDPACKAGE_PROTOBUF_CONFIG_DIR}
  BUILD_COMMAND $(MAKE) brpc-static
  INSTALL_COMMAND ""
  COMMAND cp ${BRPC_BINARY_DIR}/output/lib/libbrpc.a ${INSTALL_PATH}/lib
  COMMAND cp -r ${BRPC_BINARY_DIR}/output/include ${INSTALL_PATH}
  COMMAND sed -i "s|ANNOTATE_UNPROTECTED_READ|BUTIL_ANNOTATE_UNPROTECTED_READ|g" ${DYNAMIC_ANNOTATIONS_HEADER_PATH}
  COMMAND sed -i "s|ANNOTATE_IGNORE_READS_BEGIN|BUTIL_ANNOTATE_IGNORE_READS_BEGIN|g" ${DYNAMIC_ANNOTATIONS_HEADER_PATH}
  COMMAND sed -i "s|ANNOTATE_IGNORE_READS_END|BUTIL_ANNOTATE_IGNORE_READS_END|g" ${DYNAMIC_ANNOTATIONS_HEADER_PATH}
  COMMAND sed -i "s|ANNOTATE_IGNORE_READS_AND_WRITES_BEGIN|BUTIL_ANNOTATE_IGNORE_READS_AND_WRITES_BEGIN|g"
          ${DYNAMIC_ANNOTATIONS_HEADER_PATH}
  COMMAND sed -i "s|ANNOTATE_IGNORE_READS_AND_WRITES_END|BUTIL_ANNOTATE_IGNORE_READS_AND_WRITES_END|g"
          ${DYNAMIC_ANNOTATIONS_HEADER_PATH}
  DEPENDS zlib
          snappy
          protobuf
          leveldb
          gflags
          glog
          openssl)

# used by fs
set(BRAFT_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/braft/build)
set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} -DUSE_BTHREAD_MUTEX)
ExternalProject_Add(
  braft
  PREFIX braft
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/braft
  BINARY_DIR ${BRAFT_BINARY_DIR}
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
             -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
             -DCMAKE_CXX_STANDARD=17
             -DCMAKE_PREFIX_PATH=${INSTALL_PATH}
             -DBRPC_WITH_GLOG=ON
             -Dgflags_DIR:STRING=${INSTALL_PATH}/lib/cmake/gflags
             -DWITH_DEBUG_SYMBOLS=OFF
             -DGFLAGS_INCLUDE_PATH=${GFLAGS_INCLUDE_DIR}
             -DGFLAGS_LIB=${GFLAGS_LIBRARIES}
             -DGLOG_INCLUDE_PATH=${GLOG_INCLUDE_DIR}
             -DGLOG_LIB=${GLOG_LIBRARIES}
  CMAKE_CACHE_ARGS -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=TRUE -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_PATH}
                   -DCMAKE_INSTALL_LIBDIR:PATH=${INSTALL_PATH}/lib
  BUILD_COMMAND $(MAKE) braft-static
  INSTALL_COMMAND ""
  COMMAND cp ${BRAFT_BINARY_DIR}/output/lib/libbraft.a ${INSTALL_PATH}/lib
  COMMAND cp -r ${BRAFT_BINARY_DIR}/output/include ${INSTALL_PATH}
  DEPENDS brpc)

# use by rocksdb
ExternalProject_Add(
  lz4
  PREFIX lz4
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/lz4
  CONFIGURE_COMMAND ""
  BUILD_IN_SOURCE 1
  BUILD_COMMAND $(MAKE)
  INSTALL_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> $(MAKE) PREFIX=${INSTALL_PATH} install)

# use by rocksdb
ExternalProject_Add(
  zstd
  PREFIX zstd
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/zstd
  CONFIGURE_COMMAND ""
  BUILD_IN_SOURCE 1
  BUILD_COMMAND $(MAKE)
  INSTALL_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> $(MAKE) PREFIX=${INSTALL_PATH} install)

set(LIBURING_SOURCES_DIR ${CMAKE_CURRENT_SOURCE_DIR}/liburing)
ExternalProject_Add(
  liburing
  PREFIX liburing
  SOURCE_DIR ${LIBURING_SOURCES_DIR}
  BUILD_IN_SOURCE 1
  CONFIGURE_COMMAND sh ${LIBURING_SOURCES_DIR}/configure --prefix=${INSTALL_PATH}
  BUILD_COMMAND $(MAKE)
  INSTALL_COMMAND $(MAKE) install)

# used by fs and db
ExternalProject_Add(
  rocksdb
  PREFIX rocksdb
  SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/rocksdb"
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
             -DCMAKE_PREFIX_PATH=${INSTALL_PATH}
             -DCMAKE_CXX_STANDARD=17
             -DPORTABLE=ON
             -DWITH_SNAPPY=ON
             -DWITH_LZ4=ON
             -DWITH_ZSTD=ON
             -DWITH_ZLIB=ON
             -DWITH_RUNTIME_DEBUG=ON
             -DROCKSDB_BUILD_SHARED=OFF
             -DWITH_BENCHMARK_TOOLS=OFF
             -DWITH_TESTS=OFF
             -DWITH_CORE_TOOLS=OFF
             -DWITH_TOOLS=OFF
             -DWITH_TRACE_TOOLS=OFF
             -DPORTABLE=haswell
             -DUSE_RTTI=ON
  CMAKE_CACHE_ARGS -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=TRUE -DZLIB_ROOT:STRING=${INSTALL_PATH}
                   -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_PATH} -DCMAKE_INSTALL_LIBDIR:PATH=${INSTALL_PATH}/lib
  DEPENDS gflags zlib snappy lz4 zstd liburing)

set(LIBUNWIND_SOURCES_DIR ${CMAKE_CURRENT_SOURCE_DIR}/libunwind)
set(LIBUNWIND_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/libunwind/build)
ExternalProject_Add(
  libunwind
  PREFIX libunwind
  SOURCE_DIR ${LIBUNWIND_SOURCES_DIR}
  BINARY_DIR ${LIBUNWIND_BINARY_DIR}
  CONFIGURE_COMMAND autoreconf -i ${LIBUNWIND_SOURCES_DIR}
  COMMAND ${LIBUNWIND_SOURCES_DIR}/configure --prefix ${INSTALL_PATH} --disable-minidebuginfo --enable-static
          --enable-shared=no --with-pic --disable-msabi-support
  BUILD_COMMAND $(MAKE)
  INSTALL_COMMAND $(MAKE) install)

if(NOT DEFINED GPERFTOOLS_SETUP_DONE)
  set(GPERFTOOLS_SOURCES_DIR ${CMAKE_CURRENT_SOURCE_DIR}/gperftools)
  set(GPERFTOOLS_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/gperftools/build)
  file(WRITE ${GPERFTOOLS_BUILD_DIR}/copy_repo.sh
       "mkdir -p ${GPERFTOOLS_BUILD_DIR} && cp -rf ${GPERFTOOLS_SOURCES_DIR}/* ${GPERFTOOLS_BUILD_DIR}/")
  execute_process(COMMAND sh ${GPERFTOOLS_BUILD_DIR}/copy_repo.sh)

  # get libtoolize version to check if it is lower or higher than 2.5.0
  execute_process(
    COMMAND libtoolize --version
    OUTPUT_VARIABLE LIBTOOLIZE_VERSION_OUTPUT
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  string(REGEX MATCH "[0-9]+\\.[0-9]+\\.[0-9]+" LIBTOOLIZE_VERSION ${LIBTOOLIZE_VERSION_OUTPUT})
  message(STATUS "Detected libtoolize version: ${LIBTOOLIZE_VERSION}")
  if(LIBTOOLIZE_VERSION VERSION_LESS "2.5.0")
    set(LIBTOOL_PATCH_COMMAND COMMAND patch --forward -t --reject-file=- m4/libtool.m4 m4/libtool.patch)
  else()
    set(LIBTOOL_PATCH_COMMAND "")
  endif()

  ExternalProject_Add(
    gperftools
    PREFIX gperftools
    SOURCE_DIR ${GPERFTOOLS_BUILD_DIR}
    BUILD_IN_SOURCE 1
    CONFIGURE_COMMAND sh autoreconf -i -f ${LIBTOOL_PATCH_COMMAND}
    COMMAND sh autoreconf -i
    COMMAND sh configure --prefix=${INSTALL_PATH} --enable-shared=no --enable-static=yes --with-pic --enable-libunwind
            --enable-cpu-profiler --enable-heap-profiler --enable-heap-checker
    BUILD_COMMAND $(MAKE)
    INSTALL_COMMAND $(MAKE) install
    DEPENDS libunwind)

  set(GPERFTOOLS_SETUP_DONE TRUE)
endif()

set(LIBBACKTRACE_SOURCES_DIR ${CMAKE_CURRENT_SOURCE_DIR}/libbacktrace)
set(LIBBACKTRACE_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/libbacktrace/build)
file(WRITE ${LIBBACKTRACE_BINARY_DIR}/copy_repo.sh
     "mkdir -p ${LIBBACKTRACE_BINARY_DIR} && cp -rf ${LIBBACKTRACE_SOURCES_DIR}/* ${LIBBACKTRACE_BINARY_DIR}/")
execute_process(COMMAND sh ${LIBBACKTRACE_BINARY_DIR}/copy_repo.sh)
ExternalProject_Add(
  libbacktrace
  PREFIX libbacktrace
  SOURCE_DIR ${LIBBACKTRACE_BINARY_DIR}
  BUILD_IN_SOURCE 1
  CONFIGURE_COMMAND sh ${LIBBACKTRACE_BINARY_DIR}/configure --prefix=${INSTALL_PATH}
  BUILD_COMMAND $(MAKE) AM_CFLAGS=-fPIC
  INSTALL_COMMAND $(MAKE) install)

# used by fs
set(INCBIN_SOURCES_DIR ${CMAKE_CURRENT_SOURCE_DIR}/incbin)
ExternalProject_Add(
  incbin
  PREFIX incbin
  SOURCE_DIR "${INCBIN_SOURCES_DIR}"
  BINARY_DIR "${INCBIN_SOURCES_DIR}"
  CONFIGURE_COMMAND ""
  BUILD_COMMAND ""
  INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory ${INSTALL_PATH}/include
  COMMAND cp ${INCBIN_SOURCES_DIR}/incbin.h ${INSTALL_PATH}/include)

# used by fs
set(LIBFIU_SOURCES_DIR ${CMAKE_CURRENT_SOURCE_DIR}/libfiu)
ExternalProject_Add(
  libfiu
  PREFIX libfiu
  SOURCE_DIR ${LIBFIU_SOURCES_DIR}
  BUILD_IN_SOURCE ON
  CONFIGURE_COMMAND ""
  BUILD_COMMAND $(MAKE)
  INSTALL_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> $(MAKE) PREFIX=${INSTALL_PATH} install)

# used by fs
ExternalProject_Add(
  crc32c
  PREFIX crc32c
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/crc32c
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCRC32C_BUILD_TESTS=OFF -DCRC32C_BUILD_BENCHMARKS=OFF
             -DCRC32C_USE_GLOG=OFF
  CMAKE_CACHE_ARGS -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_PATH}
                   -DCMAKE_INSTALL_LIBDIR:PATH=${INSTALL_PATH}/lib)

# used by fs
ExternalProject_Add(
  libevent
  PREFIX libevent
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/libevent
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
             -DCMAKE_PREFIX_PATH=${INSTALL_PATH}
             -DEVENT__LIBRARY_TYPE=STATIC
             -DEVENT__DISABLE_BENCHMARK=ON
             -DEVENT__DISABLE_TESTS=ON
             -DEVENT__DISABLE_REGRESS=ON
             -DEVENT__DISABLE_SAMPLES=ON
             -DEVENT__HAVE_GETHOSTBYNAME_R=ON
             -DEVENT__HAVE_GETHOSTBYNAME_R_6_ARG=ON
             -DEVENT__HAVE_GETHOSTBYNAME_R_3_ARG=OFF
             -DEVENT__HAVE_GETHOSTBYNAME_R_5_ARG=OFF
  CMAKE_CACHE_ARGS -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_PATH}
                   -DCMAKE_INSTALL_LIBDIR:PATH=${INSTALL_PATH}/lib)

# used by fs
ExternalProject_Add(
  memcache
  PREFIX memcache
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/memcache
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_PREFIX_PATH=${INSTALL_PATH} -DBUILD_SHARED_LIBS=OFF
             -DBUILD_DOCS=OFF -DBUILD_DOCSONLY=OFF
  CMAKE_CACHE_ARGS -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_PATH}
                   -DCMAKE_INSTALL_LIBDIR:PATH=${INSTALL_PATH}/lib
  DEPENDS libevent)

# used by fs
ExternalProject_Add(
  spdlog
  PREFIX spdlog
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/spdlog
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_PREFIX_PATH=${INSTALL_PATH} -DSPDLOG_BUILD_SHARED=OFF
             -DSPDLOG_BUILD_EXAMPLE_HO=OFF -DSPDLOG_FMT_EXTERNAL=ON
  CMAKE_CACHE_ARGS -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_PATH}
                   -DCMAKE_INSTALL_LIBDIR:PATH=${INSTALL_PATH}/lib
  DEPENDS fmt)

# used by fs used by aws
ExternalProject_Add(
  curl
  PREFIX curl
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/curl
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
             -DCMAKE_PREFIX_PATH=${INSTALL_PATH}
             -DBUILD_STATIC_LIBS=ON
             -DBUILD_CURL_EXE=OFF
             -DBUILD_EXAMPLES=OFF
             -DBUILD_LIBCURL_DOCS=OFF
             -DBUILD_TESTING=OFF
             -DCURL_DISABLE_LDAP=ON
             -DBUILD_SHARED_LIBS=OFF
             -DCURL_USE_LIBPSL=OFF
             -DUSE_LIBIDN2=OFF
             -DCURL_ZLIB=ON
             -DCURL_ZSTD=ON
             -DCURL_BROTLI=OFF
             -DZSTD_INCLUDE_DIR=${INSTALL_PATH}/include
             -DZSTD_LIBRARY=${INSTALL_PATH}/lib/libzstd.a
             -DZLIB_INCLUDE_DIR=${INSTALL_PATH}/include
             -DZLIB_LIBRARY=${INSTALL_PATH}/lib/libz.a
             -DOPENSSL_ROOT_DIR=${INSTALL_PATH}
             -DOPENSSL_USE_STATIC_LIBS=ON
  CMAKE_CACHE_ARGS -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_PATH}
                   -DCMAKE_INSTALL_LIBDIR:PATH=${INSTALL_PATH}/lib
  DEPENDS zlib openssl zstd)

# used by fs used by aws
ExternalProject_Add(
  opentelemetry-cpp
  PREFIX opentelemetry-cpp
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/opentelemetry-cpp
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
             -DCMAKE_PREFIX_PATH=${INSTALL_PATH}
             -DBUILD_SHARED_LIBS=OFF
             -DWITH_OTLP_GRPC=OFF
             -DWITH_OTLP_HTTP=ON
             -DWITH_PROMETHEUS=OFF
             -DBUILD_TESTING=OFF
             -DWITH_EXAMPLES=OFF
             -DWITH_EXAMPLES_HTTP=OFF
  CMAKE_CACHE_ARGS
    -DOPENSSL_ROOT_DIR:PATH=${INSTALL_PATH} -DProtobuf_DIR:PATH=${_FINDPACKAGE_PROTOBUF_CONFIG_DIR}
    -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=TRUE -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_PATH}
    -DCMAKE_INSTALL_LIBDIR:PATH=${INSTALL_PATH}/lib
  DEPENDS curl protobuf openssl nlohmann-json)

option(WITH_AWSSDKCPP "Build aws-sdk-cpp library" ON)

if(WITH_AWSSDKCPP)
  # used by fs
  ExternalProject_Add(
    aws-sdk-cpp
    PREFIX aws-sdk-cpp
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/aws-sdk-cpp
    CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
               -DCMAKE_PREFIX_PATH=${INSTALL_PATH}
               -DBUILD_SHARED_LIBS=OFF
               -DENABLE_TESTING=OFF
               -DAUTORUN_UNIT_TESTS=OFF
               -DBUILD_ONLY=s3$<SEMICOLON>s3-crt
               -DBUILD_OPTEL=ON
               -DBUILD_OPTEL_OTLP_BENCHMARKS=ON # if not turn on the opentelemetry cmake find will fail
    CMAKE_CACHE_ARGS -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=TRUE -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_PATH}
                     -DCMAKE_INSTALL_LIBDIR:PATH=${INSTALL_PATH}/lib
    DEPENDS curl zlib openssl opentelemetry-cpp)
endif()

# used by fs
ExternalProject_Add(
  libuuid
  PREFIX libuuid
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/libuuid-cmake
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_PREFIX_PATH=${INSTALL_PATH} -DLIBUUID_STATIC=ON
             -DLIBUUID_SHARED=OFF
  CMAKE_CACHE_ARGS -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=TRUE -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_PATH}
                   -DCMAKE_INSTALL_LIBDIR:PATH=${INSTALL_PATH}/lib)

# used for sdk benchmark
ExternalProject_Add(
  hdf5
  PREFIX hdf5
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/hdf5
  CMAKE_ARGS -C
             ${CMAKE_CURRENT_SOURCE_DIR}/hdf5/config/cmake/cacheinit.cmake
             -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
             -DHDF5_ENABLE_SZIP_SUPPORT=OFF
             -DHDF5_ENABLE_Z_LIB_SUPPORT=ON
             -DHDF5_BUILD_CPP_LIB=ON
             -DHDF5_BUILD_EXAMPLES=OFF
             -DHDF5_BUILD_TOOLS=OFF
             -DBUILD_SHARED_LIBS=OFF
             -DBUILD_TESTING=OFF
             -DHDF5_BUILD_JAVA=OFF
             -DHDF5_BUILD_FORTRAN=OFF
             -DHDF5_BUILD_HL_GIF_TOOLS=OFF
  CMAKE_CACHE_ARGS -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=TRUE -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_PATH}
                   -DCMAKE_INSTALL_LIBDIR:PATH=${INSTALL_PATH}/lib
  DEPENDS zlib)

# libfuse
string(TOLOWER "${CMAKE_BUILD_TYPE}" TMP_BUILD_TYPE)
if(TMP_BUILD_TYPE STREQUAL "debug")
  set(MESON_BUILD_TYPE "debug")
elseif(TMP_BUILD_TYPE STREQUAL "release")
  set(MESON_BUILD_TYPE "release")
elseif(TMP_BUILD_TYPE STREQUAL "relwithdebinfo")
  set(MESON_BUILD_TYPE "debugoptimized")
elseif(TMP_BUILD_TYPE STREQUAL "minsizerel")
  set(MESON_BUILD_TYPE "minsize")
else()
  set(MESON_BUILD_TYPE "plain")
endif()
message("meson buildtype is ${MESON_BUILD_TYPE}")

set(LIBFUSE_SOURCES_DIR ${CMAKE_CURRENT_SOURCE_DIR}/libfuse)
set(LIBFUSE_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/libfuse/build)

option(WITH_LIBFUSE "Build fuse library" ON)

if(WITH_LIBFUSE)
  ExternalProject_Add(
    libfuse
    SOURCE_DIR ${LIBFUSE_SOURCES_DIR}
    BINARY_DIR ${LIBFUSE_BINARY_DIR}
    CONFIGURE_COMMAND
      meson setup ${LIBFUSE_SOURCES_DIR} ${LIBFUSE_BINARY_DIR} --prefix=${INSTALL_PATH} --buildtype=${MESON_BUILD_TYPE}
      --default-library=static --libdir=lib --includedir=include -Dexamples=false -Duseroot=false
      -Dudevrulesdir=${INSTALL_PATH}/include/fuse3/etc -Dinitscriptdir= -Dsysconfdir=${INSTALL_PATH}/include/fuse3/etc
    BUILD_COMMAND meson compile -C ${LIBFUSE_BINARY_DIR}
    INSTALL_COMMAND meson install -C ${LIBFUSE_BINARY_DIR}
    BUILD_ALWAYS FALSE)
endif()

# used by fs
ExternalProject_Add(
  double-conversion
  PREFIX double-conversion
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/double-conversion
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_PREFIX_PATH=${INSTALL_PATH} -DBUILD_SHARED_LIBS=OFF
             -DBUILD_TESTING=OFF
  CMAKE_CACHE_ARGS -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_PATH}
                   -DCMAKE_INSTALL_LIBDIR:PATH=${INSTALL_PATH}/lib)

# used by fs
set(NUMACTL_ORI_SOURCES_DIR ${CMAKE_CURRENT_SOURCE_DIR}/numactl)

set(NUMACTL_SOURCES_DIR ${CMAKE_CURRENT_BINARY_DIR}/numactl)
set(NUMACTL_BINARY_DIR ${NUMACTL_SOURCES_DIR}/build)

file(WRITE ${NUMACTL_SOURCES_DIR}/copy_repo.sh
     "mkdir -p ${NUMACTL_BINARY_DIR} && cp -rf ${NUMACTL_ORI_SOURCES_DIR}/* ${NUMACTL_SOURCES_DIR}/")

message(STATUS "copy numactl repo to build dir")
execute_process(COMMAND sh ${NUMACTL_SOURCES_DIR}/copy_repo.sh)

ExternalProject_Add(
  numactl
  PREFIX numactl
  SOURCE_DIR ${NUMACTL_SOURCES_DIR}
  BINARY_DIR ${NUMACTL_BINARY_DIR}
  BUILD_IN_SOURCE 0
  CONFIGURE_COMMAND cd <SOURCE_DIR> && sh autogen.sh
  COMMAND cd <BINARY_DIR> && sh <SOURCE_DIR>/configure --prefix=${INSTALL_PATH} --enable-shared=no --enable-static=yes
  BUILD_COMMAND $(MAKE)
  INSTALL_COMMAND $(MAKE) install)

# used by fs
option(WITH_BOOST "Build boost library" ON)

if(WITH_BOOST)
  set(BOOST_SOURCES_DIR ${CMAKE_CURRENT_SOURCE_DIR}/boost)
  set(BOOST_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/boost/build)

  ExternalProject_Add(
    boost
    SOURCE_DIR ${BOOST_SOURCES_DIR}
    BINARY_DIR ${BOOST_BINARY_DIR}
    CONFIGURE_COMMAND ""
    BUILD_COMMAND
      ${CMAKE_COMMAND} -B <BINARY_DIR> -S <SOURCE_DIR> -DCMAKE_PREFIX_PATH=${INSTALL_PATH}
      -DCMAKE_INSTALL_PREFIX=${INSTALL_PATH} -DCMAKE_INSTALL_LIBDIR=${INSTALL_PATH}/lib
      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DBUILD_SHARED_LIBS=OFF
      -DBUILD_TESTING=OFF -DBOOST_RUNTIME_LINK=STATIC -DBOOST_IOSTREAMS_ENABLE_ZLIB=ON -DBOOST_IOSTREAMS_ENABLE_ZSTD=OFF
      -DBOOST_IOSTREAMS_ENABLE_BZIP2=OFF -DBOOST_IOSTREAMS_ENABLE_LZMA=OFF
    INSTALL_COMMAND $(MAKE) install
    BUILD_ALWAYS FALSE
    DEPENDS zlib zstd)
endif()

# used by fs 3fs libusrbio
option(WITH_LIBUSRBIO "Build 3fs usrbio library" ON)

cmake_host_system_information(RESULT PRETTY_NAME QUERY DISTRIB_PRETTY_NAME)
if(WITH_LIBUSRBIO AND ${PRETTY_NAME} MATCHES "Ubuntu")
  if(NOT WITH_BOOST)
    message(FATAL_ERROR "LIBUSRBIO requires BOOST,please enable by WITH_BOOST")
  endif()

  set(LIBUSRBIO_ORI_SOURCES_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src/libusrbio)

  set(LIBUSRBIO_SOURCES_DIR ${CMAKE_CURRENT_BINARY_DIR}/libusrbio)
  set(LIBUSRBIO_BINARY_DIR ${LIBUSRBIO_SOURCES_DIR}/build)

  file(WRITE ${LIBUSRBIO_SOURCES_DIR}/copy_repo.sh "mkdir -p ${LIBUSRBIO_BINARY_DIR} && \
        rsync -a ${LIBUSRBIO_ORI_SOURCES_DIR}/. ${LIBUSRBIO_SOURCES_DIR}/")

  message(STATUS "copy libusrbio repo to build dir")
  execute_process(COMMAND sh ${LIBUSRBIO_SOURCES_DIR}/copy_repo.sh)

  message(STATUS "apply patch to 3fs usrbio")
  execute_process(COMMAND ./patches/apply.sh WORKING_DIRECTORY ${LIBUSRBIO_SOURCES_DIR})
  ExternalProject_Add(
    libusrbio
    SOURCE_DIR ${LIBUSRBIO_SOURCES_DIR}
    BINARY_DIR ${LIBUSRBIO_BINARY_DIR}
    CMAKE_ARGS -DCMAKE_PREFIX_PATH=${INSTALL_PATH}
               -DCMAKE_CXX_COMPILER=clang++-14
               -DCMAKE_C_COMPILER=clang-14
               -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
               -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY=${LIBUSRBIO_BINARY_DIR}/lib
               -DCMAKE_LIBRARY_OUTPUT_DIRECTORY=${LIBUSRBIO_BINARY_DIR}/lib
               -DBOOST_LINK_STATIC=ON
               -DBoost_USE_STATIC_RUNTIME=ON
               # Using 3fs built-in libfmt-v10 library
               -DCMAKE_CXX_FLAGS="-I${LIBUSRBIO_SOURCES_DIR}/third_party/fmt/include"
    CMAKE_CACHE_ARGS -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON
    BUILD_COMMAND ${CMAKE_COMMAND} --build ${LIBUSRBIO_BINARY_DIR} --target usrbio -j
    # copy library to install path
    COMMAND cp ${LIBUSRBIO_SOURCES_DIR}/src/lib/api/hf3fs_usrbio.h ${INSTALL_PATH}/include/
    COMMAND cp ${LIBUSRBIO_BINARY_DIR}/lib/libfolly.a ${INSTALL_PATH}/lib/
    COMMAND cp ${LIBUSRBIO_BINARY_DIR}/lib/libusrbio.a ${INSTALL_PATH}/lib/
    INSTALL_COMMAND ""
    BUILD_ALWAYS FALSE
    DEPENDS gflags
            glog
            double-conversion
            libevent
            numactl
            openssl
            boost)

endif()

# used by fs
option(WITH_RDMACORE "Build rdma-core library" ON)

set(RDMACORE_SOURCES_DIR ${CMAKE_CURRENT_SOURCE_DIR}/rdma-core)
set(RDMACORE_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/rdma-core/build)

if(WITH_RDMACORE)
  ExternalProject_Add(
    rdma-core
    PREFIX rdma-core
    SOURCE_DIR ${RDMACORE_SOURCES_DIR}
    BINARY_DIR ${RDMACORE_BINARY_DIR}
    CONFIGURE_COMMAND ${CMAKE_COMMAND} -GNinja -S <SOURCE_DIR> -B <BINARY_DIR> -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
                      -DENABLE_STATIC=ON -DENABLE_VALGRIND=OFF -DENABLE_RESOLVE_NEIGH=OFF -DNO_MAN_PAGES=ON -DNO_PYVERBS=1
    BUILD_COMMAND ninja -C <BINARY_DIR> -v -j ${NINJA_JOBS}
    # copy library to install path
    COMMAND cp -RL <BINARY_DIR>/include/infiniband ${INSTALL_PATH}/include/
    COMMAND cp -RL <BINARY_DIR>/include/rdma ${INSTALL_PATH}/include/
    COMMAND cp <BINARY_DIR>/lib/librdmacm.a ${INSTALL_PATH}/lib/
    COMMAND cp <BINARY_DIR>/lib/libibverbs.a ${INSTALL_PATH}/lib/
    COMMAND cp <BINARY_DIR>/lib/pkgconfig/libibverbs.pc ${INSTALL_PATH}/lib/pkgconfig
    COMMAND cp <BINARY_DIR>/lib/pkgconfig/librdmacm.pc ${INSTALL_PATH}/lib/pkgconfig
    INSTALL_COMMAND ""
    BUILD_ALWAYS FALSE)
endif()

# used by fs ceph librados
option(WITH_LIBRADOS "Build ceph rados library" ON)

if(WITH_LIBRADOS)
  if(NOT WITH_BOOST)
    message(FATAL_ERROR "LIBRADOS requires BOOST,please enable by WITH_BOOST")
  endif()

  set(LIBRADOS_SOURCES_DIR ${CMAKE_CURRENT_SOURCE_DIR}/librados)
  set(LIBRADOS_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/librados/build)

  ExternalProject_Add(
    librados
    SOURCE_DIR ${LIBRADOS_SOURCES_DIR}
    BINARY_DIR ${LIBRADOS_BINARY_DIR}
    CONFIGURE_COMMAND
      ${CMAKE_COMMAND} -GNinja -S <SOURCE_DIR> -B <BINARY_DIR> -DCMAKE_PREFIX_PATH=${INSTALL_PATH}
      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DENABLE_GIT_VERSION=OFF -DWITH_FUSE=OFF -DWITH_RADOSGW_AMQP_ENDPOINT=OFF
      -DWITH_RADOSGW_KAFKA_ENDPOINT=OFF -DWITH_BABELTRACE=OFF -DWITH_SEASTAR=OFF -DWITH_LIBCEPHFS=OFF -DWITH_CEPHFS=OFF
      -DWITH_MGR=OFF -DWITH_RADOSGW=OFF -DWITH_RBD=OFF -DWITH_KRBD=OFF -DWITH_TESTS=OFF -DWITH_MANPAGE=OFF
      -DENABLE_SHARED=OFF -DWITH_STATIC_LIBSTDCXX=ON -DWITH_LTTNG=OFF -DWITH_SYSTEMD=OFF -DWITH_JAEGER=OFF
      -DWITH_OPENLDAP=OFF -DWITH_BLKIN=OFF -DWITH_LIBCEPHSQLITE=OFF -DWITH_BLUESTORE=OFF -DWITH_QATZIP=OFF
      -DWITH_QATLIB=OFF -DWITH_FMT_HEADER_ONLY=ON -DWITH_SYSTEM_BOOST=ON -DBoost_USE_STATIC_LIBS=ON
      -DBoost_USE_STATIC_RUNTIME=ON
      # Using ceph built-in libfmt-v9 library
      -DCMAKE_CXX_FLAGS="-I<SOURCE_DIR>/src/fmt/include"
      # OpenSSL configurations
      -DOPENSSL_ROOT_DIR=${INSTALL_PATH} -DOPENSSL_INCLUDE_DIR=${INSTALL_PATH}/include
      -DOPENSSL_CRYPTO_LIBRARY=${INSTALL_PATH}/lib/libcrypto.a -DOPENSSL_SSL_LIBRARY=${INSTALL_PATH}/lib/libssl.a
      -DOPENSSL_LIBRARIES=${INSTALL_PATH}/lib/libcrypto.a;${INSTALL_PATH}/lib/libssl.a -DOPENSSL_USE_STATIC_LIBS=ON
    BUILD_COMMAND ninja -C <BINARY_DIR> rados-static -v -j ${NINJA_JOBS}
    # copy library to install path
    COMMAND cp -RL <SOURCE_DIR>/src/include/rados ${INSTALL_PATH}/include/
    COMMAND cp <BINARY_DIR>/lib/librados-static.a ${INSTALL_PATH}/lib/librados.a
    INSTALL_COMMAND ""
    BUILD_BYPRODUCTS ${INSTALL_PATH}/lib/librados.a ${INSTALL_PATH}/include/rados
    BUILD_ALWAYS FALSE
    DEPENDS openssl boost rdma-core curl)
endif()


# used for fs
option(WITH_TIKVCPP "Build tikv-cpp client library" ON)
if(WITH_TIKVCPP)
  ExternalProject_Add(
    tikvcpp
    PREFIX tikv-client-cpp
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/tikv-client-cpp
    CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
               -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_PATH}
               -DOPENSSL_ROOT_DIR:PATH=${INSTALL_PATH}
               -DOPENSSL_USE_STATIC_LIBS=ON
    CMAKE_CACHE_ARGS -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=TRUE 
                     -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_PATH}
                     -DCMAKE_INSTALL_LIBDIR:PATH=${INSTALL_PATH}/lib
                     -DOPENSSL_ROOT_DIR:PATH=${INSTALL_PATH}
    BUILD_COMMAND ${CMAKE_COMMAND} -E env OPENSSL_DIR=${INSTALL_PATH} 
                  OPENSSL_STATIC=1 
                  OPENSSL_LIB_DIR=${INSTALL_PATH}/lib 
                  OPENSSL_INCLUDE_DIR=${INSTALL_PATH}/include
                  $(MAKE)
    DEPENDS openssl
  )
endif()

# generated version file
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/dingoEurekaConfigVersion.cmake.in
               ${CMAKE_BINARY_DIR}/cmake/dingoEurekaConfigVersion.cmake @ONLY)
file(WRITE ${CMAKE_BINARY_DIR}/cmake/dingoEurekaConfig.cmake
     "#This file is mainly used to search dingo-eureka by find_package, do not delete it")
# copy dingo-eureka cmake version file
file(COPY ${CMAKE_BINARY_DIR}/cmake/dingoEurekaConfig.cmake ${CMAKE_BINARY_DIR}/cmake/dingoEurekaConfigVersion.cmake
     DESTINATION ${INSTALL_PATH}/cmake)

message(STATUS "dingo-eureka cmake version file: ${INSTALL_PATH}/cmake/dingoEurekaConfigVersion.cmake")

execute_process(
  COMMAND git describe --always --dirty
  OUTPUT_VARIABLE DINGO_EUREKA_GIT_VERSION
  OUTPUT_STRIP_TRAILING_WHITESPACE)

execute_process(
  COMMAND git describe --abbrev=0 --tags --always
  OUTPUT_VARIABLE DINGO_EUREKA_GIT_TAG_NAME
  OUTPUT_STRIP_TRAILING_WHITESPACE)

execute_process(
  COMMAND git log --pretty=format:%an -1
  OUTPUT_VARIABLE DINGO_EUREKA_GIT_COMMIT_USER
  OUTPUT_STRIP_TRAILING_WHITESPACE)

execute_process(
  COMMAND git log --pretty=format:%ae -1
  OUTPUT_VARIABLE DINGO_EUREKA_GIT_COMMIT_MAIL
  OUTPUT_STRIP_TRAILING_WHITESPACE)

execute_process(
  COMMAND git log --pretty=format:%ai -1
  OUTPUT_VARIABLE DINGO_EUREKA_GIT_COMMIT_TIME
  OUTPUT_STRIP_TRAILING_WHITESPACE)

execute_process(
  COMMAND git submodule
  WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
  OUTPUT_VARIABLE DINGO_EUREKA_GIT_SUBMODULE
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

if(NOT DINGO_EUREKA_GIT_VERSION)
  set(DINGO_EUREKA_GIT_VERSION "unknown")
  message(WARNING "dingo_eureka Git version is unknown")
endif()

if(NOT DINGO_EUREKA_GIT_TAG_NAME)
  set(DINGO_EUREKA_GIT_TAG_NAME "unknown")
  message(WARNING "dingo_eureka Git tag name is unknown")
endif()

message(STATUS "version: ${DINGOEUREKA_VERSION}")
message(STATUS "Git version: ${DINGO_EUREKA_GIT_VERSION}")
message(STATUS "Git tag name: ${DINGO_EUREKA_GIT_TAG_NAME}")
message(STATUS "Git commit user: ${DINGO_EUREKA_GIT_COMMIT_USER}")
message(STATUS "Git commit mail: ${DINGO_EUREKA_GIT_COMMIT_MAIL}")
message(STATUS "Git commit time: ${DINGO_EUREKA_GIT_COMMIT_TIME}")
message(STATUS "Git submodule: ${DINGO_EUREKA_GIT_SUBMODULE}")

function(set_feature_flag option_name flag_name)
    if(${option_name})
        set(${flag_name} 1 PARENT_SCOPE)
    else()
        set(${flag_name} 0 PARENT_SCOPE)
    endif()
endfunction()

set_feature_flag(ENABLE_PACKAGE DINGO_EUREKA_ENABLE_PACKAGE)
set_feature_flag(WITH_TOML11 DINGO_EUREKA_WITH_TOML11)
set_feature_flag(WITH_GRPC DINGO_EUREKA_WITH_GRPC)
set_feature_flag(WITH_AWSSDKCPP DINGO_EUREKA_WITH_AWSSDKCPP)
set_feature_flag(WITH_LIBFUSE DINGO_EUREKA_WITH_LIBFUSE)
set_feature_flag(WITH_BOOST DINGO_EUREKA_WITH_BOOST)
set_feature_flag(WITH_LIBUSRBIO DINGO_EUREKA_WITH_LIBUSRBIO)
set_feature_flag(WITH_RDMACORE DINGO_EUREKA_WITH_RDMACORE)
set_feature_flag(WITH_LIBRADOS DINGO_EUREKA_WITH_LIBRADOS)

configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/dingo_eureka_version.h.in
  ${INSTALL_PATH}/include/dingo_eureka_version.h
  @ONLY
)
