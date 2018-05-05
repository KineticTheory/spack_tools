#!/bin/bash

#------------------------------------------------------------------------------#
# Variables that control the basic build.
#------------------------------------------------------------------------------#

SPACK_ROOT=~/spack
export PATH=$SPACK_ROOT/bin:$PATH
syscompiler="gcc@7.3.0"

#------------------------------------------------------------------------------#
# Setup and Report
#------------------------------------------------------------------------------#

echo -e "\nInitial tool rollout with spack.\n"
echo -e " - Using SPACK_ROOT = $SPACK_ROOT"
echo -e " - System compiler (Core) is $syscompiler"

echo -e "\nPurging modules"
module purge

# Install vendors using already intalled compilers.

compilers=(
  gcc@7.3.0
  clang@6.0.0
  )
mpis=(
  openmpi+thread_multiple~vt
#  openmpi@3.0.1+thread_multiple~vt
#  openmpi@2.1.3+thread_multiple~vt
#  openmpi@1.10.7+thread_multiple~vt
)

for compiler in "${compilers[@]}"; do

  # serial installs
  packages=(
    cppunit
    gsl
    metis
    netlib-lapack
    openblas
  )
  for package in ${packages[@]}; do
    echo -e "\n----------------------------------------"
    echo -e "$package % $compiler"
    echo -e "----------------------------------------\n"
    spack install $package % $compiler
  done

  # more serial installs (can we just use the core version?)
  # cmake, random123

  # gcc-serial
  gcc_packages=(
    googletest
    qt
    )
  case $compiler in
    gcc*)
      for package in ${gcc_packages[@]}; do
        echo -e "\n----------------------------------------"
        echo -e "$package % $compiler"
        echo -e "----------------------------------------\n"
        spack install $package % $compiler
      done
      ;;
  esac

  mpi_packages=(
    boost+mpi
    caliper
    hdf5+hl
    hypre~internal-superlu
    netlib-scalapack
    parmetis
    superlu-dist
    trilinos+nox
    )
  # mpis
  for mpi in "${mpis[@]}"; do
    spack install $mpi % $compiler
    for package in ${mpi_packages[@]}; do
      echo -e "\n----------------------------------------"
      echo -e "$package ^ $mpi % $compiler"
      echo -e "----------------------------------------\n"
      spack install $package ^ $mpi % $compiler
    done
  done

done

#------------------------------------------------------------------------------#
# Done.
#------------------------------------------------------------------------------#
