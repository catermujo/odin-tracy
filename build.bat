@echo off

setlocal EnableDelayedExpansion

if not exist tracy\NUL (
    git clone --recurse-submodules https://github.com/wolfpld/tracy -b v0.13.0 --depth=1
)

echo Configuring build...
CXX=clang++ CC=clang cmake -G Ninja -S tracy\profiler -B build\tracy-profiler -D CMAKE_BUILD_TYPE=Release

echo Building project...
cmake --build build\tracy-profiler --config Release --parallel
cl -MT -O2 -DTRACY_ENABLE -c tracy\public\TracyClient.cpp -Fotracy
lib tracy.obj

REM copy /y %binaries_dir%\Release\Jolt.lib joltc.lib
REM copy /y %binaries_dir%\Release\Jolt.pdb joltc.pdb

echo Build completed successfully!
