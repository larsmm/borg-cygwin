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
set BUILDPKGS=python3,python3-devel,python3-setuptools,binutils,gcc-g++,libopenssl,openssl-devel,git,make,openssh,liblz4-devel,liblz4_1,libzstd1,libzstd-devel

%CYGSETUP% -q -B -o -n -g -R %CYGBUILD% -L -D -l %OURPATH% -s %CYGMIRROR% -P %BUILDPKGS%

REM --- Build borgbackup

cd %CYGBUILD%
bin\bash --login -c 'easy_install-3.6 pip'
bin\bash --login -c 'pip install -U borgbackup'
cd %OURPATH%

REM --- Install release version of CygWin in a subfolder

set CYGPATH=%OURPATH%\Borg-installer
del /s /q %CYGPATH%
set INSTALLPKGS=python3,openssh,liblz4_1,python3-setuptools,libzstd1,gcc-core
set REMOVEPKGS=csih,gawk,lynx,man-db,groff,vim-minimal,tzcode,ncurses,info,util-linux

%CYGSETUP% -q -B -o -n -L -R %CYGPATH% -l %OURPATH% -P %INSTALLPKGS% -x %REMOVEPKGS%

REM --- Adjust final CygWin environment

echo @"%TARGETPATH%\bin\bash" --login -c "cd $(cygpath '%cd%'); /bin/borg %%*" >%CYGPATH%\borg.bat
copy nsswitch.conf %CYGPATH%\etc\
copy fstab %CYGPATH%\etc\

REM --- Copy built packages into release path

cd %CYGBUILD%

copy bin\borg %CYGPATH%\bin
for /d %%d in (lib\python3.6\site-packages\borg*) do xcopy /s /y %%d %CYGPATH%\%%d\
for /d %%d in (lib\python3.6\site-packages\msgpack*) do xcopy /s /y %%d %CYGPATH%\%%d\
for /d %%d in (lib\python3.6\site-packages\pkg_resources) do xcopy /s /y %%d %CYGPATH%\%%d\

REM --- Remove all locales except EN (borg does not use them)

del /s /q %CYGPATH%\usr\share\locale\
for /d %%d in (usr\share\locale\en*) do xcopy /s /y %%d %CYGPATH%\%%d\

REM --- Remove all documentation

del /s /q %CYGPATH%\usr\share\doc\
del /s /q %CYGPATH%\usr\share\info\
del /s /q %CYGPATH%\usr\share\man\

REM --- Remove gcc libs (gcc is installed only for ldconfig support)

del /s /q %CYGPATH%\lib\gcc
del /s /q %CYGPATH%\lib\w32api
del /s /q %CYGPATH%\usr\include\w32api

REM --- Remove extra files

del /s /q %CYGPATH%\*.h
del /s /q %CYGPATH%\var\log
del /s /q %CYGPATH%\var\cache

cd %OURPATH%

goto :EOF

:ERROR
echo Don't launch this script use build32.bat or build64.bat instead
pause
exit