The script buildrpm.sh builds the google test and google mock rpms from the sources contained in this repository.

The rpms are versioned as follows:
gtest - "gtest version"."gtest revision"."meynrelease"-"release"
gmock - "gmock version"."gmock revision"."meynrelease"-"release"

The version is extracted from the respective configure.ac files, the revision comes from the svn repository information
and the meynrelease is monotonically increasing number that increases everytime a new set of rpm's is made and installed.
When he version or the revision change the meynrelease number does *not* go back to 1.
The release behaves as the normal rpm release.

note: Part of the building process is the installation of the new gtest and gtest-devel rpm's. This is necessary to build
the gmock rpm.

Prerequisites (not exhaustive):
python-devel     - dependency of gtest
autoconf-archive - for the AX_CXX_COMPILE_STDCXX_11 macro

