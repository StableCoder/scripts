#!/bin/bash
set -e

confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}

# Get the latest release from SVN
latest=$(svn ls http://llvm.org/svn/llvm-project/llvm/tags | grep RELEASE | tail -1)
latest=${latest::-1}
printf "\n\nLatest Clang release is: %s\n" $latest

confirm "Use the latest? [y/N]" && release=latest

if [ "$release" == "" ]
then
    printf "\nThese are the available release tags available:\n"
    svn ls http://llvm.org/svn/llvm-project/llvm/tags | grep RELEASE
    read -p "Which release you would like instead? " release
fi

# Checkout LLVM

   svn co http://llvm.org/svn/llvm-project/llvm/tags/${release}/final llvm
   cd llvm

# Checkout Clang:
    cd tools
    svn co http://llvm.org/svn/llvm-project/cfe/tags/${release}/final clang
    cd ..

# Checkout Extra Clang Tools [Optional]:

    cd tools/clang/tools
    svn co http://llvm.org/svn/llvm-project/clang-tools-extra/tags/${release}/final extra
    cd ../../..

# Checkout LLD linker [Optional]:

    cd tools
    svn co http://llvm.org/svn/llvm-project/lld/tags/${release}/final lld
    cd ..

# Checkout Polly Loop Optimizer [Optional]:

    cd tools
    svn co http://llvm.org/svn/llvm-project/polly/tags/${release}/final polly
    cd ..

# Checkout Compiler-RT (required to build the sanitizers) [Optional]:

    cd projects
    svn co http://llvm.org/svn/llvm-project/compiler-rt/tags/${release}/final compiler-rt
    cd ..

# Checkout Libomp (required for OpenMP support) [Optional]:

    cd projects
    svn co http://llvm.org/svn/llvm-project/openmp/tags/${release}/final openmp
    cd ..

# Checkout libcxx and libcxxabi [Optional]:

    cd projects
    svn co http://llvm.org/svn/llvm-project/libcxx/trunk libcxx
    svn co http://llvm.org/svn/llvm-project/libcxxabi/trunk libcxxabi
    cd ..

# Get the Test Suite Source Code [Optional]

    cd projects
    svn co http://llvm.org/svn/llvm-project/test-suite/tags/${release}/final test-suite
    cd ..

# Build LLVM & Clang

    NUM_PROCS=`nproc --a`
    if [ $NUM_PROCS != 1 ]; then
        NUM_PROCS=`expr $NUM_PROCS - 1`
    fi

    mkdir build
    cd build
    cmake .. -DCMAKE_BUILD_TYPE=Release
    make -j $(NUM_PROCS)
