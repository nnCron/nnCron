@echo off
call stopnncron.bat

start/wait nncrond.exe -q -remove

