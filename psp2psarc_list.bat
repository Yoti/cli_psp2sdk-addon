@echo off
rem psp2psarc_list by Yoti
if "%1"=="" (
	echo Error: no PSARC
	goto thisistheend
)
psp2psarc.exe list %~nx1 > %~n1_list.txt
:thisistheend
