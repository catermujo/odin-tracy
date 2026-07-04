#!/usr/bin/env bash

set -e

[ -d tracy ] || git clone --recurse-submodules https://github.com/wolfpld/tracy -b v0.13.0 --depth=1

linux_arch_dir() {
    case "$(uname -m)" in
        x86_64 | amd64) echo "linux_x64" ;;
        aarch64 | arm64) echo "linux_arm64" ;;
        *) echo "linux_$(uname -m)" ;;
    esac
}

darwin_arch_dir() {
    case "$(uname -m)" in
        x86_64 | amd64) echo "darwin_x64" ;;
        aarch64 | arm64) echo "darwin_arm64" ;;
        *) echo "darwin_$(uname -m)" ;;
    esac
}

echo "Building project..."
CMAKE_OPTS=(-D CMAKE_BUILD_TYPE=Release)
if [ "$(uname -s)" = 'Linux' ]; then
    USE_LEGACY_BACKEND=0
    CMAKE_OPTS+=(-D "CMAKE_CXX_FLAGS=-include cstdint -include cinttypes")
    if ! pkg-config --exists egl wayland-egl wayland-cursor xkbcommon; then
        echo "Wayland dev packages missing; enabling LEGACY backend"
        USE_LEGACY_BACKEND=1
    fi
    if ! command -v wayland-scanner >/dev/null 2>&1; then
        echo "wayland-scanner missing; enabling LEGACY backend"
        USE_LEGACY_BACKEND=1
    fi
    if [ "$USE_LEGACY_BACKEND" -eq 1 ]; then
        CMAKE_OPTS+=(-D LEGACY=ON -D GLFW_BUILD_WAYLAND=OFF -D GLFW_BUILD_X11=ON)
    fi
fi
CXX=clang++ CC=clang cmake -G Ninja -S tracy/profiler -B build/tracy-profiler "${CMAKE_OPTS[@]}"
cmake --build build/tracy-profiler --config Release --parallel
if [ $(uname -s) = 'Darwin' ]; then
    ARCH_DIR=$(darwin_arch_dir)
    mkdir -p "$ARCH_DIR"
    c++ -stdlib=libc++ -mmacosx-version-min=10.8 -std=c++11 -DTRACY_ENABLE -O2 -dynamiclib tracy/public/TracyClient.cpp -o "$ARCH_DIR/tracy.dylib"
else
    ARCH_DIR=$(linux_arch_dir)
    mkdir -p "$ARCH_DIR"
    c++ -std=c++11 -DTRACY_ENABLE -O2 tracy/public/TracyClient.cpp -shared -fPIC -o "$ARCH_DIR/tracy.so"
fi
