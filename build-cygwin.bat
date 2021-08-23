@echo off

REM --- Need version at first parameter

if "%~1"=="" GOTO ERROR


REM --- Change to use different CygWin platform and final install path

set CYGSETUP=%1
REM set CYGSETUP=setup-x86.exe
REM set CYGSETUP=setup-x86_64.exe
set TARGETPATH=.

set POWERSHELL=%windir%\System32\WindowsPowerShell\v1.0\powershell.exe

REM --- Fetch Cygwin setup from internet using powershell

"%POWERSHELL%" -Command "(New-Object Net.WebClient).DownloadFile('https://cygwin.com/%CYGSETUP%', '%CYGSETUP%')"

REM --- Install build version of CygWin in a subfolder

set OURPATH=%cd%
set CYGBUILD=%OURPATH%\CygWin
set CYGMIRROR=http://mirrors.kernel.org/sourceware/cygwin/
set BUILDPKGS=python38,python38-devel,python38-setuptools,binutils,gcc-g++,openssl,openssl-devel,git,make,openssh,liblz4-devel,liblz4_1,libzstd1,libzstd-devel,libcrypt-devel

%CYGSETUP% -q -B -o -n -g -R %CYGBUILD% -L -D -l %OURPATH% -s %CYGMIRROR% -P %BUILDPKGS%

REM --- Build borgbackup

cd %CYGBUILD%
bin\bash --login -c 'easy_install-3.8 pip'
bin\bash --login -c 'pip install -U pip'
bin\bash --login -c 'pip install -U borgbackup'
cd %OURPATH%

REM --- Install release version of CygWin in a subfolder

set CYGPATH=%OURPATH%\Borg-installer
del /s /q %CYGPATH%
set INSTALLPKGS=python38,openssh,python38-setuptools,liblz4_1,libzstd1,openssl,libcrypt2
set REMOVEPKGS=csih,gawk,man-db,groff,vim-minimal,tzcode,ncurses,info,util-linux

%CYGSETUP% -q -B -o -n -L -R %CYGPATH% -l %OURPATH% -P %INSTALLPKGS% -x %REMOVEPKGS%

REM --- Adjust final CygWin environment

echo @"%TARGETPATH%\bin\bash" --login -c "cd $(cygpath '%cd%'); /bin/borg %%*" >%CYGPATH%\borg.bat
copy /Y nsswitch.conf %CYGPATH%\etc\
copy /Y fstab %CYGPATH%\etc\

REM --- Copy built packages into release path

cd %CYGBUILD%

copy usr\local\bin\borg %CYGPATH%\bin
for /d %%d in (usr\local\lib\python3.8\site-packages\borg*) do xcopy /s /y %%d %CYGPATH%\%%d\
for /d %%d in (usr\local\lib\python3.8\site-packages\packaging*) do xcopy /s /y %%d %CYGPATH%\%%d\
copy lib\libc.a %CYGPATH%\lib

REM --- Remove all locales except EN (borg does not use them)

del /s /q %CYGPATH%\usr\share\locale\
for /d %%d in (usr\share\locale\en*) do xcopy /s /y %%d %CYGPATH%\%%d\

REM --- Remove all documentation

del /s /q %CYGPATH%\usr\share\doc\
del /s /q %CYGPATH%\usr\share\info\
del /s /q %CYGPATH%\usr\share\man\

REM --- Remove gcc libs (gcc is installed only for ldconfig support)

del /s /q %CYGPATH%\lib\libbfd.a
del /s /q %CYGPATH%\lib\libopcodes.a
del /s /q %CYGPATH%\bin\objdump.exe
del /s /q %CYGPATH%\bin\ld.exe
del /s /q %CYGPATH%\bin\ld.bfd.exe

REM --- Remove extra files

del /s /q %CYGPATH%\*.h
del /s /q %CYGPATH%\var\log
del /s /q %CYGPATH%\var\cache
del /s /q %CYGPATH%\usr\x86_64-pc-cygwin
del /s /q %CYGPATH%\usr\i686-pc-cygwin

REM --- Remove 0b files to avoid NSIS "File: failed opening file ..."

del /s /q %CYGPATH%\bin\pip3
del /s /q %CYGPATH%\bin\pydoc3
del /s /q %CYGPATH%\bin\python
del /s /q %CYGPATH%\bin\python3

cd %OURPATH%

goto :EOF

:ERROR
echo Don't launch this script use build32.bat or build64.bat instead
pause
exit