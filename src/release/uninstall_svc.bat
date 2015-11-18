@echo off
call "%~dp0stopnncron.bat" %1 %2 %3 %4 %5 %6 %7 %8 %9

start/wait /MIN "nnCron remove service" "%~dp0nncron.exe" -q %1 %2 %3 %4 %5 %6 %7 %8 %9 -remove

