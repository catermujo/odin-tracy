#!/usr/bin/env bash

set -e

[ -d tracy ] || git clone --recurse-submodules https://github.com/wolfpld/tracy -b v0.13.0 --depth=1

echo "Building project..."
CXX=clang++ CC=clang cmake -G Ninja -S tracy/profiler -B build/tracy-profiler -D CMAKE_BUILD_TYPE=Release
cmake --build build/tracy-profiler --config Release --parallel
if [ $(uname -s) = 'Darwin' ]; then
    c++ -stdlib=libc++ -mmacosx-version-min=10.8 -std=c++11 -DTRACY_ENABLE -O2 -dynamiclib tracy/public/TracyClient.cpp -o tracy.dylib
    # cp build/lib/libjoltc.dylib ../
else
    c++ -std=c++11 -DTRACY_ENABLE -O2 tracy/public/TracyClient.cpp -shared -fPIC -o tracy.so
    # cp build/lib/libjoltc.so ../
fi
