# Copyright (c) 2025 dingodb.com, Inc. All Rights Reserved
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

file(STRINGS "/etc/os-release" OS_RELEASE)

set(LINUX_DISTRO_NAME "")
set(LINUX_DISTRO_VERSION "")
set(OS_ARCH ${CMAKE_HOST_SYSTEM_PROCESSOR})
    
foreach(line IN LISTS OS_RELEASE)
    if(line MATCHES "^ID=(.*)")
        set(LINUX_DISTRO_NAME "${CMAKE_MATCH_1}")
        string(REGEX REPLACE "^\"|\"$" "" LINUX_DISTRO_NAME "${LINUX_DISTRO_NAME}")
    elseif(line MATCHES "^VERSION_ID=\"?([^\"]*)\"?")
        set(LINUX_DISTRO_VERSION "${CMAKE_MATCH_1}")
    elseif(line MATCHES "^PRETTY_NAME=\"?([^\"]*)\"?")
        set(LINUX_PRETTY_NAME "${CMAKE_MATCH_1}")
    endif()
endforeach()

message(STATUS "Linux Distribution: ${LINUX_PRETTY_NAME}")
message(STATUS "Distro ID: ${LINUX_DISTRO_NAME}")
message(STATUS "Distro Version: ${LINUX_DISTRO_VERSION}")

set(CPACK_PACKAGE_NAME ${PROJECT_NAME})
set(CPACK_PACKAGE_VERSION ${DINGOEUREKA_VERSION})

set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}${CPACK_PACKAGE_VERSION}.${LINUX_DISTRO_NAME}${LINUX_DISTRO_VERSION}-${OS_ARCH}")
set(CPACK_GENERATOR "TGZ")
set(CPACK_PACKAGE_VENDOR "zetyun")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Thrid-party library for dingofs and dingodb")

# package output path
if(NOT PACKAGE_OUTPUT_PATH)
    set(CPACK_OUTPUT_FILE_PREFIX "${CMAKE_BINARY_DIR}/packages")
else()
    set(CPACK_OUTPUT_FILE_PREFIX "${PACKAGE_OUTPUT_PATH}")
endif()
file(MAKE_DIRECTORY "${CPACK_OUTPUT_FILE_PREFIX}")

install(
  DIRECTORY "${INSTALL_PATH}/"
  DESTINATION "."
  USE_SOURCE_PERMISSIONS
)

include(CPack)