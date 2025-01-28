@echo off

:: Verificar si Python está instalado
python --version >nul 2>&1
if errorlevel 1 (
    echo Python no está instalado. Por favor, instálalo y vuelve a intentarlo.
    pause
    exit /b
)

:: Verifica si Git está instalado
git --version >nul 2>&1
if errorlevel 1 (
    echo Git no está instalado. Por favor, instálalo y vuelve a intentarlo.
    pause
    exit /b
)

:: Cambiar al directorio donde se ejecutará el script
cd /d %~dp0 

:: Clonar un subdirectorio específico usando sparse-checkout
echo Configurando sparse-checkout para descargar solo un directorio...
git init temp_repo
cd temp_repo
git remote add origin https://github.com/Universidad-de-La-Laguna/esit-cc-desktop-playbook.git
git config core.sparseCheckout true
echo agente-it-inventary/scripts >> .git/info/sparse-checkout
git pull origin master

cd agente-it-inventary\scripts

:: pause

:: Ejecutar el script principal
echo Ejecutando el script it-inventory-client.py...
python it-inventory-client.py

:: Limpiar
cd ..\..\..
rmdir /s /q temp_repo

:: pause
