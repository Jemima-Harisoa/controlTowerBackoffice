@echo off
title Deploiement Back-Office Control Tower
echo ================================================
echo        DEPLOIEMENT BACK-OFFICE
echo ================================================
echo.

setlocal enabledelayedexpansion

:: -------------------------------------------------
:: CONFIGURATION TOMCAT
:: -------------------------------------------------
set "CATALINA_HOME=C:\apache-tomcat-10.1.28"
set "TOMCAT_BIN=%CATALINA_HOME%\bin"
set "TOMCAT_WEBAPPS=%CATALINA_HOME%\webapps"

:: -------------------------------------------------
:: VERIFICATION TOMCAT
:: -------------------------------------------------
if not exist "%CATALINA_HOME%" (
    echo ERREUR: Tomcat introuvable a %CATALINA_HOME%
    pause
    exit /b 1
)

if not exist "%TOMCAT_BIN%\startup.bat" (
    echo ERREUR: startup.bat introuvable
    pause
    exit /b 1
)

echo Tomcat detecte: %CATALINA_HOME%
echo.

:: -------------------------------------------------
:: SE POSITIONNER DANS LE DOSSIER DU SCRIPT
:: -------------------------------------------------
cd /d "%~dp0"
echo Repertoire courant: %CD%
echo.

:: -------------------------------------------------
:: 1) COMPILATION MAVEN
:: -------------------------------------------------
echo [1/5] Compilation du projet...
call mvn clean package
if %ERRORLEVEL% NEQ 0 (
    echo ERREUR: Compilation echouee
    pause
    exit /b 1
)
echo Compilation terminee avec succes.
echo.

:: -------------------------------------------------
:: 2) DETECTION DU WAR
:: -------------------------------------------------
echo [2/5] Recherche du fichier WAR...
set "WAR_FILE="
for %%f in (target\*.war) do (
    set "WAR_FILE=%%f"
)

if "!WAR_FILE!"=="" (
    echo ERREUR: Aucun WAR trouve dans target\
    dir target\
    pause
    exit /b 1
)

echo WAR detecte: !WAR_FILE!
echo.

:: -------------------------------------------------
:: 3) ARRET DE TOMCAT
:: -------------------------------------------------
echo [3/5] Arret de Tomcat...
call "%TOMCAT_BIN%\shutdown.bat"
timeout /t 5 /nobreak >nul
echo Tomcat arrete.
echo.

:: -------------------------------------------------
:: 4) NETTOYAGE ANCIEN DEPLOIEMENT
:: -------------------------------------------------
echo [4/5] Nettoyage ancien deploiement...

if exist "%TOMCAT_WEBAPPS%\ControlTowerBackoffice" (
    echo Suppression dossier existant...
    rmdir /s /q "%TOMCAT_WEBAPPS%\ControlTowerBackoffice"
)

if exist "%TOMCAT_WEBAPPS%\ControlTowerBackoffice.war" (
    echo Suppression ancien WAR...
    del /q "%TOMCAT_WEBAPPS%\ControlTowerBackoffice.war"
)

echo Nettoyage termine.
echo.

:: -------------------------------------------------
:: 5) COPIE DU WAR + DEMARRAGE
:: -------------------------------------------------
echo [5/5] Deploiement du nouveau WAR...

copy /Y "!WAR_FILE!" "%TOMCAT_WEBAPPS%\ControlTowerBackoffice.war"
if %ERRORLEVEL% NEQ 0 (
    echo ERREUR: Echec de copie du WAR
    pause
    exit /b 1
)

echo WAR copie avec succes.
echo.

echo Demarrage de Tomcat...
call "%TOMCAT_BIN%\startup.bat"

echo.
echo Attente du deploiement (10 secondes)...
timeout /t 10 /nobreak >nul

echo.
echo =================================================
echo            DEPLOIEMENT TERMINE
echo =================================================
echo.
echo Ouvrir dans le navigateur :
echo http://localhost:9090/ControlTowerBackoffice/
echo.
echo Si erreur :
echo Verifier les logs dans :
echo %CATALINA_HOME%\logs\catalina.out
echo.
pause
