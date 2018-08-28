@echo off
rem psp2psarc_extract v1.1 by Yoti
if "%1"=="" (
	echo Error: no PSARC
	goto thisistheend
)
rmdir /s /q %~n1
psp2psarc.exe extract %~nx1 --to=%~n1
:thisistheend
