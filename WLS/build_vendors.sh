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

if ! [[ ~/.spack/linux/compilers.yaml ]]; then
  spack compilers
else
  spack compiler list
fi

#------------------------------------------------------------------------------#
# Core utilities (system compiler, no MPI)
#------------------------------------------------------------------------------#

echo -e "\nInstalling Core ($syscompiler) programs...\n"

# get modules working first
if [[ `type module | grep -c LMOD` == 0 ]]; then
  echo -e "\n----------------------------------------"
  echo -e "lmod % $syscompiler"
  echo -e "----------------------------------------\n"
  spack install lmod % $syscompiler
  MODULES_HOME=`spack location -i lmod`
  source $MODULES_HOME/lmod/lmod/init/bash
fi

# activate modules
module use $SPACK_ROOT/share/spack/lmod/`spack arch`/Core

# other packages
core_packages=(
  ack
  ccache
  cmake
  dia
  dos2unix
  doxygen
  exuberant-ctags
  f90cache
  gdb
  ghostscript
  ghostscript-fonts
  git
  global
  gnuplot
  graphviz
  htop
  kdiff3
  mscgen
  ninja
  numdiff
  qt
  random123
  screen
  scons
  subversion
  uncrustify
)

for package in ${core_packages[@]}; do
  echo -e "\n----------------------------------------"
  echo -e "$package % $syscompiler"
  echo -e "----------------------------------------\n"
  spack install $package % $syscompiler
done

python_packages=(
  py-flake8
  py-sphinx
)

for package in ${python_packages[@]}; do
  echo -e "\n----------------------------------------"
  echo -e "$package % $syscompiler"
  echo -e "----------------------------------------\n"
  spack install  $package % $syscompiler
  spack activate $package % $syscompiler
done

compiler_packages=(
#  gcc
  llvm
)

for package in ${compiler_packages[@]}; do
  echo -e "\n----------------------------------------"
  echo -e "$package % $syscompiler"
  echo -e "----------------------------------------\n"
  spack install  $package % $syscompiler
done

echo -e "\Done with phone 1 (Core compiler)"
echo -e " - Consider rsync -vaum $SPACK_ROOT/var/spack/cache/ /home/kt/spack_mirror"
echo -e " - You must register new compilers with spack before continuing via.\n"
echo -e "     'module load gcc; spack compiler add'"

echo -e "\n - You must add a cmake line to packages.yaml."
echo -e "     cmake:"
echo -e "       buildable: False"
echo -e "       modules:"
echo -e "         cmake: cmake"

echo -e "\nNow, run build_vendors2.sh\n"

#------------------------------------------------------------------------------#
# Done.
#------------------------------------------------------------------------------#
