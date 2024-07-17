# Tracy Profiler

## A real time, nanosecond resolution, remote telemetry, hybrid frame and sampling profiler for games and other applications.

This is a bindings/wrapper library for the Odin programming language.

![image](https://github.com/wolfpld/tracy/raw/master/doc/profiler.png)

![image](https://github.com/wolfpld/tracy/raw/master/doc/profiler2.png)

![image](https://github.com/wolfpld/tracy/raw/master/doc/profiler3.png)

## 0. Prerequisites
This assumes you are using the latest nightly build or GitHub master of the Odin compiler.   Since Odin is still under development this means these bindings might break in the future. Please create an issue or PR if that happens.

## 1. Cloning the sources
```console
git clone https://github.com/oskarnp/odin-tracy
```

## 2. Building the Tracy profiler server

Tracy profiler server is built using CMake version 3.16 or later.

Example (using Clang compiler and Ninja build system):

```console
CXX=clang++ CC=clang cmake -G Ninja -S vendor/tracy/profiler -B build/tracy-profiler
cmake --build build/tracy-profiler
```

> [!NOTE]
> Add `-D LEGACY=ON` to first line to configure for X11 instead of Wayland if you are on Linux.

Refer to official manual for more details.


## 3. Building the Tracy profiler client library

Tracy profiler library is _optionally_ built using CMake version 3.10 or later. See vendor/tracy/CMakeLists.txt for more information.

If you prefer to not use CMake you can build the client directly:

### Mac OS
```console
c++ -stdlib=libc++ -mmacosx-version-min=10.8 -std=c++11 -DTRACY_ENABLE -O2 -dynamiclib vendor/tracy/public/TracyClient.cpp  -o tracy.dylib
```
### Windows
```console
cl -MT -O2 -DTRACY_ENABLE -c vendor\tracy\public\TracyClient.cpp -Fotracy
lib tracy.obj
```
### Linux
```console
c++ -std=c++11 -DTRACY_ENABLE -O2 vendor/tracy/public/TracyClient.cpp -shared -fPIC -o tracy.so
```

## 4. (Optional) Run the demo application / profiler client

```console
odin run demo -define:TRACY_ENABLE=true
```

and then click Connect in Tracy profiler server.

> [!TIP]
> Run the profiled application (e.g. `demo`) in privileged mode
  (sudo/administrator) to enable even more features in Tracy.


---

> [!IMPORTANT]
> For more details on how to use Tracy, please refer to the [official manual](https://github.com/wolfpld/tracy/releases/download/v0.11.0/tracy.pdf).
