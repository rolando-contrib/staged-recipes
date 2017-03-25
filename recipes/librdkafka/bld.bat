set LIB=%LIBRARY_LIB%;%LIB%
set LIBPATH=%LIBRARY_LIB%;%LIBPATH%
set INCLUDE=%LIBRARY_INC%;%INCLUDE%;%RECIPE_DIR%
set UseEnv=true

:: Config
if %ARCH% == 32 (
  set ARCH=Win32
)
if %ARCH% == 64 (
  set ARCH=x64
)
set CONF=Release
set TOOLCHAIN=v140
set SLNFILE=win32\librdkafka.sln
set OUTDIR=win32\outdir\%TOOLCHAIN%\%ARCH%\%CONF%

:: Build
call devenv %SLNFILE% /Upgrade

msbuild %SLNFILE% ^
  /p:PlatformToolset=%TOOLCHAIN% ^
  /p:Configuration=%CONF% ^
  /p:Platform=%ARCH%
if errorlevel 1 exit 1

:: Install
for %%x in (dll lib pdb) do (
  copy /Y %OUTDIR%\librdkafka.%%x %LIBRARY_LIB%\rdkafka.%%x
  if errorlevel 1 exit 1
  copy /Y %OUTDIR%\librdkafkacpp.%%x %LIBRARY_LIB%\rdkafkacpp.%%x
  if errorlevel 1 exit 1
)

md %LIBRARY_INC%\librdkafka
copy src\rdkafka.h %LIBRARY_INC%\librdkafka\rdkafka.h
if errorlevel 1 exit 1
copy src-cpp\rdkafkacpp.h %LIBRARY_INC%\librdkafka\rdkafkacpp.h
if errorlevel 1 exit 1
