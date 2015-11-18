@echo off
call stopnncron.bat -app-for-user
start/wait nncrond.exe -q -app-for-user -remove
start/wait nncrond.exe -q -app-for-user -install 
call startnncron.bat -app-for-user

