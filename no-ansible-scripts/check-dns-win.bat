@echo off
setlocal enabledelayedexpansion

REM Script de monitorización DNS y conectividad para Windows
REM Ejecutar con: check-dns-win.bat

REM Configuración
set DNS_SERVER=10.4.9.29
set HOST_TO_RESOLVE=gpu1.etsi.ull.es
set IP_TO_PING=10.209.32.231
set LOG_FILE=%USERPROFILE%\network_monitor.log

REM Encabezado
echo === Inicio de monitorizacion: %DATE% %TIME% === >> "%LOG_FILE%"
echo Monitorizando DNS: %DNS_SERVER% >> "%LOG_FILE%"
echo Guardando logs en: %LOG_FILE%
echo Presiona Ctrl+C para detener
echo.

:LOOP

REM Obtener timestamp
for /f "tokens=1-4 delims=/ " %%a in ('date /t') do set FECHA=%%a-%%b-%%c
for /f "tokens=1-2 delims=: " %%a in ('time /t') do set HORA=%%a:%%b
set TIMESTAMP=%FECHA% %TIME:~0,8%

REM Test DNS usando nslookup
nslookup %HOST_TO_RESOLVE% %DNS_SERVER% > nul 2>&1
if %ERRORLEVEL% EQU 0 (
    for /f "tokens=2" %%i in ('nslookup %HOST_TO_RESOLVE% %DNS_SERVER% 2^>nul ^| findstr /C:"Address:" ^| findstr /V "%DNS_SERVER%"') do set DNS_IP=%%i
    echo [%TIMESTAMP%] DNS OK - %HOST_TO_RESOLVE% -^> !DNS_IP! ^(via %DNS_SERVER%^)
    echo [%TIMESTAMP%] DNS OK - %HOST_TO_RESOLVE% -^> !DNS_IP! ^(via %DNS_SERVER%^) >> "%LOG_FILE%"
) else (
    echo [%TIMESTAMP%] DNS FAIL - %HOST_TO_RESOLVE% ^(servidor: %DNS_SERVER%^)
    echo [%TIMESTAMP%] DNS FAIL - %HOST_TO_RESOLVE% ^(servidor: %DNS_SERVER%^) >> "%LOG_FILE%"
)

REM Test Ping
ping -n 1 -w 2000 %IP_TO_PING% > nul 2>&1
if %ERRORLEVEL% EQU 0 (
    for /f "tokens=7 delims== " %%i in ('ping -n 1 %IP_TO_PING% ^| findstr /C:"tiempo="') do set PING_TIME=%%i
    echo [%TIMESTAMP%] PING OK - %IP_TO_PING% - !PING_TIME!
    echo [%TIMESTAMP%] PING OK - %IP_TO_PING% - !PING_TIME! >> "%LOG_FILE%"
) else (
    echo [%TIMESTAMP%] PING FAIL - %IP_TO_PING%
    echo [%TIMESTAMP%] PING FAIL - %IP_TO_PING% >> "%LOG_FILE%"
)

REM Esperar 60 segundos
timeout /t 60 /nobreak > nul

goto LOOP
