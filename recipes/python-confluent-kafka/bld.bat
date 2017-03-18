set LIB=%LIBRARY_LIB%;%LIB%
set LIBPATH=%LIBRARY_LIB%;%LIBPATH%
set INCLUDE=%LIBRARY_INC%;%INCLUDE%

python setup.py install --single-version-externally-managed --record=record.txt
if errorlevel 1 exit 1
