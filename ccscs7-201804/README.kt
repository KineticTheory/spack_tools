# environment
git clone spack
export SPACK_ROOT=<path>
export PATH=$PATH:$SPACK_ROOT/bin
edit .spack/linux files
module purge
module unuse <all paths>
module use $SPACK_ROOT/share/spack/lmod/linux-rhel7-x86_64/Core

# compilers
spack install gcc llvm
module load gcc
spack compiler add
module swap gcc llvm
spack compiler add
# add fc and f77 for clang
spack compilers

module avail
# core compiler is gcc@4.8.5
# no hash
# many are suppressed (blacklist)
# extra variales set (LCOMPILER)

# openmpi
spack install openmpi%gcc@7.1.0
spack install openmpi%clang@4.0.0 # must use system m4 via packages.yaml

module load gcc openmpi
module list
module swap gcc llvm
module list

# libquo
spack install libquo%gcc@7.1.0 ^openmpi
spack install libquo%clang@4.0.0 ^openmpi

module load libquo
module swap llvm gcc
module list
