@echo off
if "%OS%"=="Windows_NT" goto WinNT

:Win95
"%~dp0nncrond.exe" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto exit

:WinNT
if not "%1"=="" goto runasapp
net start nncron >nul 2>&1
if "%ERRORLEVEL%"=="2" goto runasapp

goto exit

:runasapp
start "nnCron starting..." /MIN "%~dp0nncrond.exe" -ns %1 %2 %3 %4 %5 %6 %7 %8 %9

:exit
