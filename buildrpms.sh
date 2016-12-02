#!/bin/bash

# $1 INPUT_TEMPLATE_FILE
# $2 OUTPUT_DIR
# $3 ARTIFACT_DIR
# $4 GTEST_MAJOR_VERSION
# $5 GTEST_MINOR_VERSION
# $6 GTEST_PATCH_VERSION
# $7 GTEST_RELEASE_VERSION
function createSpecfile
{
  echo "INPUT_TEMPLATE_FILE   : $1"
  echo "OUTPUT_DIR            : $2"
  echo "ARTIFACT_DIR          : $3"
  echo "SRC_DIR               : $4"
  echo "GTEST_MAJOR_VERSION   : $5"
  echo "GTEST_MINOR_VERSION   : $6"
  echo "GTEST_PATCH_VERSION   : $7"
  echo "GTEST_RELEASE_VERSION : $8"
  if [ ! -e "$1" ] ; then
    echo "createSpecfile: INPUT_TEMPLATE_FILE $1 does not exist"
    exit 1
  fi
  if [ -z "$2" ]; then
    echo "createSpecfile: empty OUTPUT_DIR not allowed"
    exit 1
  fi
  if [ -z "$3" ]; then
    echo "createSpecfile: empty ARTIFACT_DIR not allowed"
    exit 1
  fi
  if [ ! -e "$3" ] ; then
    echo "createSpecfile: ARTIFACT_DIR $3 does not exist"
    exit 1
  fi
  if [ -z "$4" ]; then
    echo "createSpecfile: empty SRC_DIR not allowed"
    exit 1
  fi
  if [ ! -e "$4" ] ; then
    echo "createSpecfile: SRC_DIR $4 does not exist"
    exit 1
  fi
  if [ -z "$5" -o -z "$6" -o -z "$7" -o -z "$8" ]; then
    echo "createSpecfile: invalid argument"
    exit 1
  fi
  if [ ! -d "$2" ]; then mkdir -p $2; fi
  local SPECFILE=$2/$(basename $1 .template)
  echo "output spec file    : $SPECFILE"
  /bin/perl -pe "s|{ARTIFACT_DIR}|$3|;s|{SRC_DIR}|$4|;s|{GTEST_MAJOR_VERSION}|$5|;s|{GTEST_MINOR_VERSION}|$6|;s|{GTEST_PATCH_VERSION}|$7|;s|{GTEST_RELEASE_VERSION}|$8|;" $1 > ${SPECFILE}
}

SCRIPTDIR=$(dirname $(readlink -f $0))
pushd ${SCRIPTDIR}

# Cleanup
#rm -rf build

# Define dirs
SRC_DIR=${SCRIPTDIR}
ARTIFACT_DIR=${SCRIPTDIR}/build/artifacts
RPMBUILD_DIR=${ARTIFACT_DIR}/rpmbuild
RPMSPECS_DIR=${RPMBUILD_DIR}/SPECS
mkdir -p ${RPMSPECS_DIR}

# Build gtest and gmock
pushd build
cmake -Dgtest_build_tests=ON -DBUILD_SHARED_LIBS=ON -DCMAKE_PREFIX_PATH=./artifacts -DCMAKE_INSTALL_PREFIX=./artifacts -DCMAKE_CXX_FLAGS="-std=c++11" ..

# Test gtest 
make -j4 && make test

# Install artifacts to artifacts dir
make install

# Define version
GTEST_MAJOR_VERSION=1
GTEST_MINOR_VERSION=8
GTEST_PATCH_VERSION=0
GTEST_RELEASE_VERSION=1

# Copy gmock src dir
#  Previous packages assume that gmock-all.cc includes other .cc files from the same dir (i.e. #include "gmock-cardinalities.cc" instead of #include "src/gmock-cardinalities.cc")
# In order to preserve backward compatibility (and potentially forward compatibility), we mimic this approach
#  and replace #include "src/ with #include "./
mkdir -p ${ARTIFACT_DIR}/googlemock
cp -rf ${SRC_DIR}/googlemock/src ${ARTIFACT_DIR}/googlemock/
for GMOCKSRCFILE in ${ARTIFACT_DIR}/googlemock/src/*.cc; do
  sed -i 's|#include \"src/|#include \"./|' ${GMOCKSRCFILE}
done

echo "Generating spec files from templates"
createSpecfile "../rpm/gtest/gtest.spec.template" ${RPMSPECS_DIR} ${ARTIFACT_DIR} ${SRC_DIR} ${GTEST_MAJOR_VERSION} ${GTEST_MINOR_VERSION} ${GTEST_PATCH_VERSION} ${GTEST_RELEASE_VERSION}
createSpecfile "../rpm/gmock/gmock.spec.template" ${RPMSPECS_DIR} ${ARTIFACT_DIR} ${SRC_DIR} ${GTEST_MAJOR_VERSION} ${GTEST_MINOR_VERSION} ${GTEST_PATCH_VERSION} ${GTEST_RELEASE_VERSION}

echo "Building rpms from spec files"
pushd ${RPMSPECS_DIR}
rpmbuild -ba gtest.spec --define "_topdir ${RPMBUILD_DIR}"
rpmbuild -ba gmock.spec --define "_topdir ${RPMBUILD_DIR}"
