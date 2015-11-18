@echo off
call "%~dp0stopnncron.bat" %1 %2 %3 %4 %5 %6 %7 %8 %9
start "nnCron remove service" /wait /MIN "%~dp0nncron.exe" -q %1 %2 %3 %4 %5 %6 %7 %8 %9 -remove 
start "nnCron install service" /wait /MIN "%~dp0nncron.exe" -q %1 %2 %3 %4 %5 %6 %7 %8 %9 -install 
call "%~dp0startnncron.bat" %1 %2 %3 %4 %5 %6 %7 %8 %9

