@echo off

call build.bat

pause

if exist s1built.bin (
	start s1built.bin
)
