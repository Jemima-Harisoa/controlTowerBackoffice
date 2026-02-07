@echo off
REM =================================
REM SCRIPT DOCKER DÉVELOPPEMENT
REM Control Tower Backoffice
REM =================================

echo.
echo =================================
echo Control Tower - Environnement Docker
echo =================================
echo.

REM Vérifier que Docker est installé
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERREUR: Docker n'est pas installé ou accessible
    echo Veuillez installer Docker Desktop
    pause
    exit /b 1
)

REM Vérifier que Docker Compose est installé
docker compose version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERREUR: Docker Compose n'est pas installé
    pause
    exit /b 1
)

REM Menu principal
:menu
echo.
echo Choisissez une action:
echo 1) Démarrer l'environnement (dev + adminer)
echo 2) Démarrer l'environnement (production)
echo 3) Arrêter tous les services
echo 4) Reconstruire et démarrer
echo 5) Voir les logs
echo 6) Status des services
echo 7) Nettoyer (supprimer volumes)
echo 8) Ouvrir une session dans le conteneur app
echo 9) Backup base de données
echo 0) Quitter
echo.
set /p choice="Votre choix: "

if "%choice%"=="1" goto dev_start
if "%choice%"=="2" goto prod_start
if "%choice%"=="3" goto stop
if "%choice%"=="4" goto rebuild
if "%choice%"=="5" goto logs
if "%choice%"=="6" goto status
if "%choice%"=="7" goto clean
if "%choice%"=="8" goto shell
if "%choice%"=="9" goto backup
if "%choice%"=="0" goto exit
echo Choix invalide
goto menu

:dev_start
echo Démarrage de l'environnement de développement...
docker compose -f docker-compose.yml -f docker-compose.dev.yml --profile dev up -d
echo.
echo Services démarrés:
echo - Application: http://localhost:8080
echo - Adminer: http://localhost:8081
echo - MailHog: http://localhost:8025
echo.
goto menu

:prod_start
echo Démarrage de l'environnement de production...
docker compose up -d
echo.
echo Application disponible sur: http://localhost:8080
echo.
goto menu

:stop
echo Arrêt de tous les services...
docker compose down
echo Services arrêtés.
goto menu

:rebuild
echo Reconstruction et démarrage...
docker compose down
docker compose build --no-cache
docker compose up -d
echo Reconstruction terminée.
goto menu

:logs
echo Affichage des logs (Ctrl+C pour arrêter)...
docker compose logs -f --tail=100
goto menu

:status
echo Status des services:
docker compose ps
echo.
echo Utilisation des ressources:
docker stats --no-stream
goto menu

:clean
echo ATTENTION: Cette action va supprimer tous les volumes et données!
set /p confirm="Êtes-vous sûr? (oui/non): "
if /i "%confirm%"=="oui" (
    docker compose down -v
    docker system prune -f
    echo Nettoyage terminé.
) else (
    echo Opération annulée.
)
goto menu

:shell
echo Ouverture d'une session dans le conteneur app...
docker exec -it controltower_app /bin/bash
goto menu

:backup
echo Création d'un backup de la base de données...
set timestamp=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set timestamp=%timestamp: =0%
docker exec controltower_db pg_dump -U controltower_user -d controltower > database\backups\backup_%timestamp%.sql
echo Backup créé: database\backups\backup_%timestamp%.sql
goto menu

:exit
echo Au revoir!
exit /b 0