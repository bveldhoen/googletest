#.rst:
# FindGMock
# ---------
#
# Locate the Google C++ Mocking Framework.
#
# Defines the following variables:
#
# ::
#
#    GMOCK_FOUND - Found the Google Testing framework
#    GMOCK_INCLUDE_DIRS - Include directories
#
#
#
# Also defines the gmock source path
#
# ::
#
#    GMOCK_SOURCE_DIR - directory containing the gmock sources
#
#
#
# Accepts the following variables as input:
#
# ::
#
#    GMOCK_ROOT - (as a CMake or environment variable)
#                 The root directory of the gmock install prefix
#
#
#
#
# Example Usage:
#
# ::
#
#     enable_testing()
#     find_package(GMock REQUIRED)
#     include_directories(${GMOCK_INCLUDE_DIRS})
#
#
#
# ::
#
#     add_executable(foo ${GMOCK_SOURCE_DIR}/gmock-all.cc foo.cc)
#     target_link_libraries(foo)
#
#

find_path(GMOCK_INCLUDE_DIR gmock/gmock.h
    HINTS
        $ENV{GMOCK_ROOT}/include
        ${GMOCK_ROOT}/include
)
mark_as_advanced(GMOCK_INCLUDE_DIR)

find_path(GMOCK_SOURCE_DIR gmock-all.cc
    HINTS
        $ENV{GMOCK_ROOT}/src/gmock
        ${GMOCK_ROOT}/src/gmock
    PATHS
        ${GMOCK_INCLUDE_DIR}/../src/gmock
)
mark_as_advanced(GMOCK_SOURCE_DIR)

FIND_PACKAGE_HANDLE_STANDARD_ARGS(GMock DEFAULT_MSG GMOCK_INCLUDE_DIR GMOCK_SOURCE_DIR)

if(GMOCK_FOUND)
    set(GMOCK_INCLUDE_DIRS ${GMOCK_INCLUDE_DIR})
endif()

