#!/bin/bash

# ./build_vendors.sh [-bcp]
#
# -b basic packages (with core compiler)
# -c additional compilers (with core compiler)
# -p python packages (with core compiler)

#------------------------------------------------------------------------------#
# Common setup
#------------------------------------------------------------------------------#

export rscriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $rscriptdir/build_vendors_common.sh

#------------------------------------------------------------------------------#
# Parse command line
#------------------------------------------------------------------------------#

build_core=false
build_python=false
build_compilers=false

while getopts ":bcp" opt; do
case $opt in
b) build_core=true      ;;
c) build_compilers=true ;;
p) build_python=true    ;;
\?) echo "" ;echo "invalid option: -$OPTARG"; print_use; exit 1 ;;
:)  echo "" ;echo "option -$OPTARG requires an argument."; print_use; exit 1 ;;
esac
done

#------------------------------------------------------------------------------#
# Core utilities (system compiler, no mpi)

if [[ ${build_core} == "true" ]] ; then

  echo -e "\nInstalling Core ($syscompiler) programs...\n"

  # do these first
  core_packages=(
    cmake
  )

  for package in ${core_packages[@]}; do
    echo -e "\n----------------------------------------"
    echo -e "$package % $syscompiler"
    echo -e "----------------------------------------\n"
    spack install $package % $syscompiler
  done

  run "module load cmake"

  # other packages
  core_packages=(
    ack
    ccache
    dia
    dos2unix
    doxygen
    eospac
    exuberant-ctags
    f90cache
    gdb
    ghostscript
    ghostscript-fonts
    git
    global
    gnuplot
    graphviz
    gsl
    htop
    intel-mkl
    kdiff3
    mscgen
    netlib-lapack
    ninja
    numdiff
    openblas
    qt
    random123
    ruby-svn2git
    screen
    scons
    subversion+perl
    uncrustify
  )

  for package in ${core_packages[@]}; do
    echo -e "\n----------------------------------------"
    echo -e "$package % $syscompiler"
    echo -e "----------------------------------------\n"
    spack install $package % $syscompiler
  done

fi


# should have cmake
run "module load cmake"
run "which cmake"


if [[ ${build_python} == "true" ]]; then

  python_packages=(
    py-flake8
    py-git-review
    py-gnuplot
    py-matplotlib
    py-sphinx
  )

  for package in ${python_packages[@]}; do
    echo -e "\n----------------------------------------"
    echo -e "$package % $syscompiler"
    echo -e "----------------------------------------\n"
    spack install  $package % $syscompiler
    spack activate $package % $syscompiler
  done

fi

#
# Fake packages:
#
# 1. Must be known by spack as a real package or listed in a repos.yaml ->
#    spack.lanl/packages.
# 2. Must be listed as an external-package in packages.yaml
# 3. Extra setup must be done in modules.yaml
# 4. Install with '% $syscompiler' to allow module to show up in 'Core'
#    section.

#spack install totalview % $syscompiler
#if [[ -d /scratch/vendors/bullseyecoverage-8.13.5 ]]; then
#  spack install bullseyecoverage % $syscompiler
#fi

#
# build compilers
#
# llvm@3.9.X won't compile with latest recipe.  I needed to comment out the
# commands that make install-LLVMDemangle

if [[ ${build_compilers} == "true" ]]; then

  echo -e "\nBuilding compilers...\n"

  # Add gcc@4.8.5 so that module is created for gcc/4.8.5.  This sytem compiler
  # must be registered as an external-package in linux/packages.yaml. Actually,
  # don't do this as it creats a recursive ref/link for Lmod.
  compilers=(
    gcc@7.3.0
    llvm@3.9.1
    llvm@6.0.0
  )

  for compiler in "${compilers[@]}"; do
    echo -e "\n----------------------------------------"
    echo -e "$compiler % $syscompiler"
    echo -e "----------------------------------------\n"
    spack install $compiler % $syscompiler
  done

fi

#------------------------------------------------------------------------------#
# Report
#------------------------------------------------------------------------------#

module avail

echo -e "\nDone with phase 1 (Core compiler)"
echo -e " - Consider rsync -vaum $SPACK_ROOT/var/spack/cache/ /home/kt/spack_mirror"
echo -e " - You must register new compilers with spack before continuing via.\n"
echo -e "     'module load gcc; spack compiler add'"

echo -e "\n - You must add a cmake line to packages.yaml."
echo -e "     cmake:"
echo -e "       buildable: False"
echo -e "       modules:"
echo -e "         cmake: cmake"

echo -e "\nNow, run build_vendors2.sh\n"

# # Are all compilers listed in compilers.yaml?
# echo -e "\nRegistering compilers with spack...\n"

# for compiler in "${compilers[@]}"; do
#   compmod=`echo $compiler | sed -e 's%@%/%'`
#   echo "Registering $compmod with compilers.yaml"
#   module load $compmod
#   spack compiler add
#   module unload $compmod
# done
# spack compiler list

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
