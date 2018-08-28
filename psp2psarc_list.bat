@echo off
rem psp2psarc_list v1.1 by Yoti
title Wait
if "%1"=="" (
	echo Error: no PSARC
	goto thisistheend
)
psp2psarc.exe list %~nx1 > %~n1_list.txt
:thisistheend
title Done