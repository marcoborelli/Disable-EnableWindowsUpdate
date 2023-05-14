@echo off
color a

set val=0x0

for /F "tokens=3" %%A in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DoNotConnectToWindowsUpdateInternetLocations"') DO (
	set val= %%A
)

cls rem se da errore perchè non trova la chiave almeno così non lo vedo

if %val% == 0x1 (
	echo STATO ATTUALE: AGGIORNAMENTI DISABILITATI
) else (
	echo STATO ATTUALE: AGGIORNAMENTI ABILITATI
)

net session >nul 2>&1
if not %errorLevel% == 0 (
	echo NON SEI AMMINISTRATORE. RIAVVIA IL PROGRAMMA
	pause
	exit
) 

set /p input= "VUOI DISATTIVARE [INVIO] O ATTIVARE GLI AGGIORNAMENTI? "
if %input%a==a (
	goto disabilita
)
else (
	goto abilita
)



:abilita

	reg copy HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate.old /f /s
	reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /f
	sc config wuauserv start=auto 

	exit

:disabilita
	
	goto creazioneTempFile
	:dentroDisabilita
	regedit /s "wu.reg" 
	sc config wuauserv start=disabled

	del wu.reg
	
	exit




:creazioneTempFile

	echo Windows Registry Editor Version 5.00 > wu.reg
	echo [HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate] >> wu.reg
	echo "WUServer"="fakeup1" >> wu.reg
	echo "WUStatusServer"="fakeupd1" >> wu.reg
	echo "UpdateServiceUrlAlternate"="fakeupd2" >> wu.reg
	echo "DoNotConnectToWindowsUpdateInternetLocations"=dword:00000001 >> wu.reg
	echo [HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU] >> wu.reg
	echo "NoAutoRebootWithLoggedOnUsers"=dword:00000001 >> wu.reg
	echo "UseWUServer"=dword:00000001 >> wu.reg

goto dentroDisabilita


