#!/bin/bash

#------------------------------------------------------------------------------#
# Variables that control the basic build.
#------------------------------------------------------------------------------#

SPACK_ROOT=/scratch/vendors/spack.20180425
export PATH=$SPACK_ROOT/bin:$PATH
syscompiler="gcc@4.8.5"


echo -e "\nInitial tool rollout with spack.\n"
echo -e " - Using SPACK_ROOT = $SPACK_ROOT"
echo -e " - System compiler (Core) is $syscompiler"

#------------------------------------------------------------------------------#
# Helper functions
#------------------------------------------------------------------------------#
function run ()
{
  echo "==> $1"; if test ${dry_run:-no} = "no"; then eval $1; fi
}

print_use()
{
  echo "Usage: ${0##*/} [-bcp]"
}

#------------------------------------------------------------------------------#
# Environment
#------------------------------------------------------------------------------#

echo -e "\nPurging all current modules."
module purge
echo -e "\nUsing spack found at $SPACK_ROOT\n"

if ! [[ -f $SPACK_ROOT/etc/spack/linux/compilers.yaml ]]; then
  spack compilers
fi

# spack config get config
# 'blame' added 2018-05-10
spack config blame config

core_mods_registered=`echo $MODULEPATH | grep -c "spack/lmod/linux-rhel7-x86_64/Core"`
if [[ $core_mods_registered == 0 ]]; then
  module use $SPACK_ROOT/share/spack/lmod/`spack arch`/Core
fi

# module load cmake?
echo -e "\nModules availability\n"
run "module avail"

#------------------------------------------------------------------------------#
# End
#------------------------------------------------------------------------------#
