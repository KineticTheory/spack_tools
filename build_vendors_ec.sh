#!/bin/bash

#------------------------------------------------------------------------------#
# Notes
#------------------------------------------------------------------------------#

# 1. config.yaml's install_tree and moduel_roots must be the same as for normal
#    TPLs.
# 2. Be sure to move EC code away from $spack/opt/spack and replace with a
#    symlink.
# 3. Ensure that downloaded source code is not saved to a mirror where sources
#    are public.


# sg ccsrad
# umask 0007

#------------------------------------------------------------------------------#
# Common setup
#------------------------------------------------------------------------------#
export rscriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $rscriptdir/build_vendors_common.sh

#------------------------------------------------------------------------------#
# Setup and Report
#------------------------------------------------------------------------------#

EC_VENDOR_DIR=/scratch/vendors-ec

if ! [[ -f ~/.spack/config.yaml.ec ]] ;then
  echo -e "\nFATAL ERROR: did not find expected file ~/.spack/config.yaml.ec"
  echo -e "   This file should be a copy of ~/.spack/config.yaml, but the "
  echo -e "   these entries should point to unique directories where access is"
  echo -e "   controlled (e.g. /scratch/vendors-ec):"
  echo -e "   - build_state"
  echo -e "   - source_cache"
else
  run "mv ~/.spack/config.yaml ~/.spack/config.yaml.bak"
  run "mv ~/.spack/config.yaml.ec ~/.spack/config.yaml"
fi

#------------------------------------------------------------------------------#
# Build some stuff
#------------------------------------------------------------------------------#

# Install vendors using already intalled compilers (these should match those
# listed in build_vendors2.sh)

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

  # # serial installs
  # packages=(
  #   csk # actually csk -> boost -> mpi
  # )
  # for package in ${packages[@]}; do
  #   echo -e "\n----------------------------------------"
  #   echo -e "$package % $compiler"
  #   echo -e "----------------------------------------\n"
  #   spack install $package % $compiler
  # done

  # more serial installs (can we just use the core version?)
  # cmake, random123

  # # gcc-serial
  # gcc_packages=(
  #   googletest
  #   qt
  #   # vtk+qt+python # hangs?
  #   )
  # case $compiler in
  #   gcc*)
  #     for package in ${gcc_packages[@]}; do
  #       echo -e "\n----------------------------------------"
  #       echo -e "$package % $compiler"
  #       echo -e "----------------------------------------\n"
  #       spack install $package % $compiler
  #     done
  #     ;;
  # esac

  # McKay says we need hypre+int64, but I cannot build trilinos with this hypre.
  mpi_packages=(
    csk@0.3.2^boost+mpi
    )
#   mpi_gcc_packages=(
#     valgrind+boost+mpi
#     legion+mpi
# #    libquo # still broken.
#     cgns+mpi
#     moab+mpi^netlib-lapack
#     petsc+boost+hdf5+mpi
# #    silo+fortran # requires hdf5~mpi
#     )

  # mpis
  for mpi in "${mpis[@]}"; do
    echo -e "\n----------------------------------------"
    echo -e "$mpi % $compiler"
    echo -e "----------------------------------------\n"
    # spack install $mpi % $compiler
    for package in ${mpi_packages[@]}; do
      echo -e "\n----------------------------------------"
      echo -e "$package ^ $mpi % $compiler"
      echo -e "----------------------------------------\n"
      spack install $package ^ $mpi % $compiler
      # now relocate the install to another directory
      # e.g.: package_loc = /scratch/vendors/spack.20180425/opt/spack/linux-rhel7-x86_64/gcc-7.3.0/csk-0.3.0-l7qqkp3zbfyqm5oiu4uqryeztekrhgmw
      package_loc=`spack location -i $package ^ $mpi % $compiler`
      # e.g.: package_dirname = csk-0.3.0-l7qqkp3zbfyqm5oiu4uqryeztekrhgmw
      package_dirname=`echo $package_loc | sed -e "s%.*/%%"`
      # e.g.: package_rdir = opt/spack/linux-rhel7-x86_64/gcc-7.3.0
      package_rdir=`echo $package_loc | sed -e "s%${SPACK_ROOT}%%" | sed -e "s%/${package_dirname}%%"`
      if [[ -d $package_loc ]]; then
        run "mkdir -p ${EC_VENDOR_DIR}/spack/${package_rdir}"
        run "mv ${package_loc} ${EC_VENDOR_DIR}/spack/${package_rdir}/${package_dirname}"
        run "(cd ${SPACK_ROOT}/${package_rdir} && ln -s ${EC_VENDOR_DIR}/spack/${package_rdir}/${package_dirname})"
      else
        echo -e "\nProblems... Either the package didn't build or there are"
        echo -e "multiple matches. Please check install locations and PERMISSIONS!"
        exit 1
      fi
    done

  # case $compiler in
  #   gcc*)
  #   for package in ${mpi_gcc_packages[@]}; do
  #     echo -e "\n----------------------------------------"
  #     echo -e "$package ^ $mpi % $compiler"
  #     echo -e "----------------------------------------\n"
  #     spack install $package ^ $mpi % $compiler
  #   done
  #   ;;
  # esac

  done

done

#------------------------------------------------------------------------------#
# Check file permissions
#------------------------------------------------------------------------------#

run "chmod -R g+rX,o=g $SPACK_ROOT/share/spack/lmod"
run "chgrp -R ccsrad $EC_VENDOR_DIR"
run "chmod -R g+rX,o-rwX $EC_VENDOR_DIR"
run "find $EC_VENDOR_DIR -type d -exec chmod g+s {} \;"

#------------------------------------------------------------------------------#
# Restore config files
#------------------------------------------------------------------------------#

echo -e "\n Restore config files...\n"
run "spack clean -a"
run "mv ~/.spack/config.yaml ~/.spack/config.yaml.ec"
run "mv ~/.spack/config.yaml.bak ~/.spack/config.yaml"

#------------------------------------------------------------------------------#
# End
#------------------------------------------------------------------------------#
