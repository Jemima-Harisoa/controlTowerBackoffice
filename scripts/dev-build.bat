@echo off
REM =================================
REM SCRIPT DÉVELOPPEMENT RAPIDE
REM Control Tower Backoffice
REM =================================

echo.
echo =================================
echo Control Tower - Build et Deploy Rapide
echo =================================
echo.

REM Vérifier que Maven est accessible
mvn --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERREUR: Maven n'est pas installé ou accessible
    echo Veuillez installer Maven et l'ajouter au PATH
    pause
    exit /b 1
)

REM Build Maven
echo [1/3] Build Maven en cours...
mvn clean install -q
if %errorlevel% neq 0 (
    echo ERREUR: Build Maven a échoué
    pause
    exit /b 1
)

REM Vérifier que le WAR a été généré
if not exist "target\ControlTowerBackoffice.war" (
    echo ERREUR: Le fichier WAR n'a pas été généré
    pause
    exit /b 1
)

echo ✅ WAR généré: target\ControlTowerBackoffice.war

REM Redémarrer le conteneur app pour charger le nouveau WAR
echo [2/3] Redémarrage du conteneur...
docker compose restart app
if %errorlevel% neq 0 (
    echo ERREUR: Impossible de redémarrer le conteneur
    pause
    exit /b 1
)

echo [3/3] Attendre que l'application démarre...
timeout /t 5 /nobreak >nul

REM Vérifier le statut
echo.
echo Status des services:
docker compose ps

echo.
echo ========================================
echo ✅ Application mise à jour avec succès!
echo ========================================
echo URLs disponibles:
echo - Application: http://localhost:8080/
echo - Welcome:     http://localhost:8080/welcome  
echo - API Test:    http://localhost:8080/api/welcome
echo - Adminer:     http://localhost:8081
echo ========================================
echo.

REM Ouvrir automatiquement dans le navigateur
set /p openBrowser="Ouvrir l'application dans le navigateur? (o/n): "
if /i "%openBrowser%"=="o" (
    start http://localhost:8080/welcome
)

pause