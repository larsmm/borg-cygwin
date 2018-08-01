@echo off
setlocal

REM --- NSIS zip must be in folder!  Get NSIS from http://nsis.sourceforge.net/Download

REM --- NSIS version
set NSISV=nsis-2.51

set OURPATH=%cd%
set MAKENSIS="%OURPATH%\%NSISV%\makensis.exe"

IF NOT EXIST "%OURPATH%\%NSISV%.zip" GOTO ERROR

IF NOT EXIST "%OURPATH%\%NSISV%" Call :UnZipFile "%OURPATH%" "%OURPATH%\%NSISV%.zip"

%MAKENSIS% nsis-installer.nsi

exit /b

:UnZipFile <ExtractTo> <newzipfile>
set vbs="%temp%\_.vbs"
if exist %vbs% del /f /q %vbs%
>%vbs%  echo Set fso = CreateObject("Scripting.FileSystemObject")
>>%vbs% echo If NOT fso.FolderExists(%1) Then
>>%vbs% echo fso.CreateFolder(%1)
>>%vbs% echo End If
>>%vbs% echo set objShell = CreateObject("Shell.Application")
>>%vbs% echo set FilesInZip=objShell.NameSpace(%2).items
>>%vbs% echo objShell.NameSpace(%1).CopyHere(FilesInZip)
>>%vbs% echo Set fso = Nothing
>>%vbs% echo Set objShell = Nothing
cscript //nologo %vbs%
if exist %vbs% del /f /q %vbs%
exit /b

:ERROR
echo Error missing %NSISV%.zip in folder
pause
exit /b