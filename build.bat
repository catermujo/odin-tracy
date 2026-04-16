@echo off

setlocal EnableDelayedExpansion

call :ensure_msvc || exit /b 1

if not exist tracy (
    git clone --recurse-submodules https://github.com/wolfpld/tracy -b v0.13.0 --depth=1 || exit /b 1
)

echo Configuring build...
REM DUMBAI: Use the bootstrapped MSVC toolchain because cmd.exe does not understand Unix-style CXX=... prefixes.
cmake -G Ninja -S tracy\profiler -B build\tracy-profiler -D CMAKE_BUILD_TYPE=Release || exit /b 1

echo Building project...
cmake --build build\tracy-profiler --config Release --parallel || exit /b 1

REM DUMBAI: Emit the static library name the Odin bindings link against on Windows.
cl /c /MT /O2 /DTRACY_ENABLE tracy\public\TracyClient.cpp /Fotracy.obj || exit /b 1
lib /OUT:tracy.lib tracy.obj || exit /b 1
if exist tracy.obj del tracy.obj

echo Build completed successfully!
exit /b 0

:ensure_msvc
where cl >nul 2>nul
if not errorlevel 1 goto :eof

REM DUMBAI: Bootstrap the MSVC environment so Tracy can build from a normal shell session.
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%VSWHERE%" (
    echo ERROR: Could not find vswhere.exe.
    exit /b 1
)
for /f "usebackq delims=" %%I in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set "VSINSTALL=%%I"
if not defined VSINSTALL (
    echo ERROR: Could not find a Visual Studio installation with MSVC tools.
    exit /b 1
)
call "%VSINSTALL%\VC\Auxiliary\Build\vcvarsall.bat" x64 >nul || exit /b 1
goto :eof
