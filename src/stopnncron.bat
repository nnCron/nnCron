@echo off
if not "%1"=="" goto stopapp
if "%OS%"=="Windows_NT" goto WinNT

:stopapp
start "nnCron stop" /wait /MIN "%~dp0nncrond.exe" -ns %1 %2 %3 %4 %5 %6 %7 %8 %9 -stop
start "..." /wait /MIN "%~dp0nncrond.exe" 2000 PAUSE BYE
goto exit

:WinNT
net stop nncron >nul 2>&1
if "%ERRORLEVEL%"=="2" goto stopapp

:exit
