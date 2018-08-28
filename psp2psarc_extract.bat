rem psp2psarc_extract by Yoti
@echo off
if "%1"=="" (
	echo Error: no PSARC
	goto thisistheend
)
rmdir /s /q %~n1
psp2psarc.exe extract %~nx1 --to=%~n1
:thisistheend
