@echo off
rem psp2psarc_create by Yoti
title Wait
if "%1"=="" (
	echo Error: no XML
	goto thisistheend
)
psp2psarc.exe --xml=%1
:thisistheend
title Done