:: This rougly follow what projects' appveyor file does.

:: Build
if "%ARCH%"=="32" (
    set PLATFORM=Win32
    set ADDITIONALPARAM=""
) else (
    set PLATFORM=x64
    set ADDITIONALPARAM=/p:LibraryPath="C:\Program Files\Microsoft SDKs\Windows\v7.1\lib\x64;c:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\lib\amd64;C:\Program Files (x86)\Microsoft Visual Studio 10.0\;C:\Program Files (x86)\Microsoft Visual Studio 10.0\lib\amd64;"
)
set CONFIGURATION=Release
set VSPROJ_DIR=%SRC_DIR%\visual\VS2010
set BUILD_DIR=%VSPROJ_DIR%\bin\%PLATFORM%_%CONFIGURATION%
msbuild.exe /m ^
    /p:PlatformToolset=v140 ^
    /p:Platform=%PLATFORM% ^
    /p:Configuration=%CONFIGURATION% %ADDITIONALPARAM% ^
    /p:AdditionalDependencies=legacy_stdio_definitions.lib ^
    /t:Clean,Build ^
    %VSPROJ_DIR%\lz4.sln 

:: Test.
cd %BUILD_DIR%
if errorlevel 1 exit 1
lz4 -i1b lz4.exe
if errorlevel 1 exit 1
lz4 -i1b5 lz4.exe
if errorlevel 1 exit 1
lz4 -i1b10 lz4.exe
if errorlevel 1 exit 1
lz4 -i1b15 lz4.exe
if errorlevel 1 exit 1

:: This is a shorter version of `make lz4-test-basic`.
datagen -g0     | lz4 -v     | lz4 -t
if errorlevel 1 exit 1
datagen -g16KB  | lz4 -9     | lz4 -t
if errorlevel 1 exit 1
datagen         | lz4        | lz4 -t
if errorlevel 1 exit 1
datagen -g6M -P99 | lz4 -9BD | lz4 -t
if errorlevel 1 exit 1
datagen -g17M   | lz4 -9v    | lz4 -qt
if errorlevel 1 exit 1
datagen -g33M   | lz4 --no-frame-crc | lz4 -t
if errorlevel 1 exit 1
datagen -g256MB | lz4 -vqB4D | lz4 -t
if errorlevel 1 exit 1

:: Install.
COPY %SRC_DIR%\lib\lz4.h %LIBRARY_INC%
if errorlevel 1 exit 1
COPY %SRC_DIR%\lib\lz4hc.h %LIBRARY_INC%
if errorlevel 1 exit 1
COPY %SRC_DIR%\lib\lz4frame.h %LIBRARY_INC%
if errorlevel 1 exit 1
COPY %BUILD_DIR%\liblz4_static.lib %LIBRARY_LIB%
if errorlevel 1 exit 1
COPY %BUILD_DIR%\liblz4.dll %LIBRARY_LIB%
if errorlevel 1 exit 1
COPY %BUILD_DIR%\lz4.exe %LIBRARY_BIN%
if errorlevel 1 exit 1
