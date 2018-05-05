#!/bin/bash

#------------------------------------------------------------------------------#
# Common setup
#------------------------------------------------------------------------------#

export rscriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $rscriptdir/build_vendors_common.sh

#------------------------------------------------------------------------------#
# Setup and Report
#------------------------------------------------------------------------------#

# Install vendors using already intalled compilers.

compilers=(
  gcc@7.3.0
  clang@6.0.0
  )

mpis=(
  openmpi
)

for compiler in "${compilers[@]}"; do

  # ensure compiler is available.
  if [[ `spack compiler list | grep -c $compiler` == 0 ]]; then
    # clang requires user-setup to mix and match clang, clang++ and gfortran.
    if ! [[ $compiler =~ clang ]]; then
      compiler_module=`echo $compiler | sed -e 's%@%/%'`
      run "module load $compiler_module"
      run "spack compiler add"
      run "module unload $compiler_module"
    fi

    if [[ `spack compiler list | grep -c $compiler` == 0 ]]; then
      echo "Error: $compiler is not available or not registered with spack."
      echo "       Try 'module load $compiler_module; spack compielr add'"
      echo "       and then examine ~/.spack/linux/compilers.yaml."
      continue
    fi
  fi

  # serial installs
  packages=(
    cppunit
    eospac
    gsl
    libunwind
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
    # vtk+qt+python # hangs?
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

  # McKay says we need hypre+int64, but I cannot build trilinos with this hypre.
  mpi_packages=(
    boost+mpi
    caliper+mpi
    hdf5+hl+mpi
    hypre~internal-superlu+mpi
    netlib-scalapack
    parmetis
    superlu-dist
    trilinos+nox
    )
  mpi_gcc_packages=(
    valgrind+boost+mpi
    legion+mpi
#    libquo # still broken.
    cgns+mpi
    moab+mpi^netlib-lapack
    petsc+boost+hdf5+mpi
#    silo+fortran # requires hdf5~mpi
    )

  # mpis
  for mpi in "${mpis[@]}"; do
    echo -e "\n----------------------------------------"
    echo -e "$mpi % $compiler"
    echo -e "----------------------------------------\n"
    spack install $mpi % $compiler
    for package in ${mpi_packages[@]}; do
      echo -e "\n----------------------------------------"
      echo -e "$package ^ $mpi % $compiler"
      echo -e "----------------------------------------\n"
      spack install $package ^ $mpi % $compiler
    done

  case $compiler in
    gcc*)
    for package in ${mpi_gcc_packages[@]}; do
      echo -e "\n----------------------------------------"
      echo -e "$package ^ $mpi % $compiler"
      echo -e "----------------------------------------\n"
      spack install $package ^ $mpi % $compiler
    done
    ;;
  esac

  done

done


#------------------------------------------------------------------------------#
# EC code
#------------------------------------------------------------------------------#





# Synchronize the source cache with our mirror.
rsync -vaum $SPACK_ROOT/var/spack/cache/ /scratch/vendors/spack.mirror
if ! [[ `uname -n` =~ ccscs7 ]]; then
  rsync -vaum $SPACK_ROOT/var/spack/cache/ ccscs7:/scratch/vendors/spack.mirror
fi

#----------------------------------------#
# Regenerate modulefiles

# spack module refresh
# spack module rm -y -m lmod ncurses%gcc

#----------------------------------------#
# Generate load script

# https://spack.readthedocs.io/en/latest/workflows.html

#----------------------------------------#
# Spack views
