@echo off
rem psp2psarc_create v1.1 by Yoti
title Wait
if "%1"=="" (
	echo Error: no XML
	goto thisistheend
)
for %%i in (%~n1.*) do (
	if not "%%i"=="%~n1.xml" del /q %%i
)
psp2psarc.exe --xml=%1
:thisistheend
title Done