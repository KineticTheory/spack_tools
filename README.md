# spack_tools


## Initial setup of spack soruces

```
  ssh -AY ccscs7
  cd /scratch/vendors
  git clone git@github.com:KineticTheory/spack.git spack.20180425
  cd spack.20180425
  git remote add upstream git@github.com:spack/spack.git
  git fetch --all --prune
  git merge usptream/develop
  export SPACK_ROOT=`pwd`
  exprt PATH=$SPACK_ROOT/bin:$PATH
```

## Initial setup of spack config files

```
  cd $HOME
  rm -rf .spack

  spack compilers # creates ~/.spack/linux/compilers.yaml
  cp ~/spack_tools/ccscs7-201804/config.yaml ~/.spack/.
  cp ~/spack_tools/ccscs7-201804/mirrors.yaml ~/.spack/.
  cp ~/spack_tools/ccscs7-201804/modules.yaml ~/.spack/.
  cp ~/spack_tools/ccscs7-201804/repos.yaml ~/.spack/.
  cp ~/spack_tools/ccscs7-201804/linux/packages.yaml ~/.spack/linux/.
```

## Update 3 lines in ~/spack_tools/build_vendors.sh

``
  spack compiler list -> gcc@4.8.5
  echo $SPACK_ROOT
```

Now, update these lines in the build_vendors*.sh scripts.

```
  SPACK_ROOT=/scratch/vendors/spack.20180425
  export PATH=$SPACK_ROOT/bin:$PATH
  syscompiler="gcc@4.8.5"
```

## Build some general tools

```
  module purge
  module unuse ... # as needed

  ~/spack_tools/build_vendors.sh -b
```

## Build some python modules

`  ~/spack_tools/build_vendors.sh -b`

## Build some compilers

`  ~/spack_tools/build_vendors.sh -c`

## Add new compiler information to ~/.spack/linux/compilers.yaml

```
(module load gcc/7.3.0; spack compiler add)
(module load llvm/6.0.0; spack compiler add)
``

-> Modify clang@6.0.0 entry in  ~/.spack/linux/compilers.yaml to look
   something like this...

```
# - compiler:
#     environment: {}
#     extra_rpaths: [/scratch/vendors/spack.20180415/opt/spack/linux-rhel7-x86_64/gcc-4.8.5/llvm-6.0.0-qtihyueuqp7m7meo6lq26yne5f7qoech/lib]
#     flags:
#       cxxflags: -std=c++11 -stdlib=libc++
#     modules: []
#     operating_system: rhel7
#     paths:
#       cc: /scratch/vendors/spack.20180415/opt/spack/linux-rhel7-x86_64/gcc-4.8.5/llvm-6.0.0-qtihyueuqp7m7meo6lq26yne5f7qoech/bin/clang
#       cxx: /scratch/vendors/spack.20180415/opt/spack/linux-rhel7-x86_64/gcc-4.8.5/llvm-6.0.0-qtihyueuqp7m7meo6lq26yne5f7qoech/bin/clang++
#       f77: gfortran
#       fc: gfortran
#     spec: clang@6.0.0
#     target: x86_64
```

## build compiler and MPI dependent TPLs.

`~/spack_tools/build_vendors2.sh`
