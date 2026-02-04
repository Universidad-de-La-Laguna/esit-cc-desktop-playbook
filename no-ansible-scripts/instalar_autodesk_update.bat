@echo off
echo ========================================
echo Configurando tarea de Autodesk Update
echo ========================================
echo.

REM Crear el directorio si no existe
if not exist "C:\Program Files\Autodesk\webdeploy\meta\" (
    echo Creando directorio...
    mkdir "C:\Program Files\Autodesk\webdeploy\meta"
)

REM Crear el archivo update.bat
echo Creando archivo update.bat...
(
echo @echo off
echo set "StreamerDir=c:\Program Files\Autodesk\webdeploy\meta\streamer"
echo setlocal
echo FOR /F %%%%i IN ^('dir /A:D /B /oN "%%StreamerDir%%"'^) DO ^(
echo SET a=%%%%i
echo ^)
echo endlocal ^& set StreamerVer=%%a%%
echo "%%StreamerDir%%\%%StreamerVer%%\streamer.exe" --globalinstall --process update --quiet
) > "C:\Program Files\Autodesk\webdeploy\meta\update.bat"

if %errorlevel% equ 0 (
    echo [OK] Archivo update.bat creado correctamente
    echo.
) else (
    echo [ERROR] No se pudo crear el archivo update.bat
    echo Asegurate de ejecutar este script como Administrador.
    pause
    exit /b 1
)

REM Crear la tarea programada
echo Creando tarea programada...
schtasks /create ^
  /tn "Autodesk Update Task" ^
  /tr "\"C:\Program Files\Autodesk\webdeploy\meta\update.bat\"" ^
  /sc daily ^
  /st 10:00 ^
  /ru SYSTEM ^
  /rl HIGHEST ^
  /f

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo [EXITO] Configuracion completada
    echo ========================================
    echo.
    echo - Archivo creado: C:\Program Files\Autodesk\webdeploy\meta\update.bat
    echo - Tarea programada: "Autodesk Update Task"
    echo - Se ejecutara todos los dias a las 10:00
    echo - Si el PC esta apagado, se ejecutara al encender
    echo.
) else (
    echo.
    echo [ERROR] No se pudo crear la tarea programada
    echo Asegurate de ejecutar este script como Administrador.
)

