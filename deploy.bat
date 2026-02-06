@echo off
setlocal enabledelayedexpansion

:: Configuration des variables
set "TEST_DIR=%CD%"
for %%I in ("%TEST_DIR%") do set "TEST_APP_NAME=%%~nxI"

set "TEST_SRC_DIR=%TEST_DIR%\src\main\java"
:: Votre structure utilise src/webapp (pas src/main/webapp)
set "TEST_WEBAPP_DIR=%TEST_DIR%\src\webapp"

set "TEST_WEBINF_DIR=%TEST_WEBAPP_DIR%\WEB-INF"
set "TEST_WEBINF_LIB=%TEST_WEBINF_DIR%\lib"
set "TEST_WEBINF_CLASSES=%TEST_WEBINF_DIR%\classes"

set "BUILD_DIR=%TEST_DIR%\build"
set "BUILD_WAR=%TEST_DIR%\%TEST_APP_NAME%.war"
set "TEST_TOP_LIB=%TEST_DIR%\lib"

:: Tomcat (modifie selon ton installation)
set "TOMCAT_DIR=C:\Users\Public\apache-tomcat-11.0.1-windows-x64\apache-tomcat-11.0.1"
set "TOMCAT_WEBAPPS_DIR=%TOMCAT_DIR%\webapps"
set "TOMCAT_START=%TOMCAT_DIR%\bin\startup.bat"

:: Optionnel : passer "open" pour ouvrir le navigateur
set "OPEN_BROWSER=false"
if "%1"=="open" set "OPEN_BROWSER=true"

echo ============================================
echo Deploiement Test-Framework
echo ============================================
echo Dossier : %TEST_DIR%
echo App name : %TEST_APP_NAME%
echo Webapp dir: %TEST_WEBAPP_DIR%
echo.

:: Verifications basiques
where javac >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] javac introuvable dans le PATH
    pause
    exit /b 1
)

where jar >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] jar introuvable dans le PATH
    pause
    exit /b 1
)

:: Preparations
if not exist "%TEST_WEBINF_CLASSES%" mkdir "%TEST_WEBINF_CLASSES%"
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"

:: 1) Construire le classpath pour la compilation
echo.
echo === ETAPE 1: Construction du classpath ===
set "CLASSPATH="
if exist "%TEST_TOP_LIB%\*.jar" (
    set "CLASSPATH=%TEST_TOP_LIB%\*"
    echo Classpath: !CLASSPATH!
) else (
    echo [WARN] Aucun jar trouve dans %TEST_TOP_LIB%
)

:: Copier les JARs de lib/ vers WEB-INF/lib/ si necessaire
if not exist "%TEST_WEBINF_LIB%" mkdir "%TEST_WEBINF_LIB%"

echo Copie des JARs vers WEB-INF/lib...
if exist "%TEST_TOP_LIB%\*.jar" (
    copy /Y "%TEST_TOP_LIB%\*.jar" "%TEST_WEBINF_LIB%\" >nul 2>&1
    echo JARs copies depuis lib/ vers WEB-INF/lib/
)

:: Ajouter les JARs de WEB-INF/lib au classpath
if exist "%TEST_WEBINF_LIB%\*.jar" (
    for %%J in ("%TEST_WEBINF_LIB%\*.jar") do (
        if "!CLASSPATH!"=="" (
            set "CLASSPATH=%%J"
        ) else (
            set "CLASSPATH=!CLASSPATH!;%%J"
        )
    )
    echo Classpath etendu avec WEB-INF/lib
) else (
    echo [WARN] Aucun JAR dans WEB-INF/lib
)

:: 2) Compiler les sources -> directement dans webapp/WEB-INF/classes
echo.
echo === ETAPE 2: Compilation des sources Java ===

set "SRC_FILES="
for /r "%TEST_SRC_DIR%" %%F in (*.java) do (
    set "SRC_FILES=!SRC_FILES! %%F"
)

javac ^
 -parameters ^
 -cp "%CLASSPATH%" ^
 -d "%TEST_WEBINF_CLASSES%" ^
 %SRC_FILES%

if errorlevel 1 (
    echo [ERREUR] Echec compilation
    pause
    exit /b 1
)

echo [OK] Compilation terminee

:: 2.b) Verification web.xml
echo.
if not exist "%TEST_WEBINF_DIR%\web.xml" (
    echo [WARN] web.xml introuvable dans %TEST_WEBINF_DIR%
    echo        Peut causer des erreurs 404 si les servlets ne sont pas mappes
)

:: 3) Copier le contenu de webapp -> build/
echo.
echo === ETAPE 3: Copie webapp vers build ===
if not exist "%TEST_WEBAPP_DIR%" (
    echo [ERREUR] %TEST_WEBAPP_DIR% introuvable
    echo          Verifie que src/webapp existe
    pause
    exit /b 1
)

:: Suppression du build precedent
if exist "%BUILD_DIR%" (
    echo Nettoyage de build/...
    rmdir /s /q "%BUILD_DIR%"
)
mkdir "%BUILD_DIR%"

echo Copie: %TEST_WEBAPP_DIR% -^> %BUILD_DIR%
xcopy "%TEST_WEBAPP_DIR%\*" "%BUILD_DIR%\" /E /I /Y /Q
if errorlevel 1 (
    echo [ERREUR] Echec de la copie
    pause
    exit /b 1
)
echo [OK] Copie terminee

:: Verifier que build/ n'est pas vide
dir "%BUILD_DIR%\*" >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] build/ est vide apres copie
    echo          Verifie que %TEST_WEBAPP_DIR% contient des fichiers
    pause
    exit /b 1
)

:: 4) Creer le WAR depuis build/
echo.
echo === ETAPE 4: Creation du WAR ===
if exist "%BUILD_WAR%" (
    echo Suppression ancien WAR...
    del "%BUILD_WAR%"
)

pushd "%BUILD_DIR%"
echo Creation: %TEST_APP_NAME%.war
jar -cf "%BUILD_WAR%" .
if errorlevel 1 (
    popd
    echo [ERREUR] Echec creation du WAR
    pause
    exit /b 1
)
popd

echo [OK] WAR cree: %BUILD_WAR%

:: Afficher le contenu du WAR (verification)
echo.
echo Contenu du WAR:
jar -tf "%BUILD_WAR%" | findstr /i "WEB-INF"

:: 5) Deployer sur Tomcat
echo.
echo === ETAPE 5: Deploiement Tomcat ===

:: Verifier si Tomcat tourne
tasklist /fi "imagename eq java.exe" /fo csv 2>nul | find /i "catalina" >nul
if not errorlevel 1 (
    echo [INFO] Tomcat deja en cours d'execution
) else (
    if exist "%TOMCAT_START%" (
        echo Demarrage de Tomcat...
        start "" "%TOMCAT_START%"
        echo Attente 8 secondes pour le demarrage...
        timeout /t 8 /nobreak >nul
    ) else (
        echo [WARN] Script startup Tomcat introuvable: %TOMCAT_START%
        echo        Demarre Tomcat manuellement et relance ce script
        pause
        exit /b 1
    )
)

:: Verifier le dossier webapps
if not exist "%TOMCAT_WEBAPPS_DIR%" (
    echo [ERREUR] Dossier webapps Tomcat introuvable: %TOMCAT_WEBAPPS_DIR%
    echo          Verifie la variable TOMCAT_DIR dans ce script
    pause
    exit /b 1
)

:: Copier le WAR
echo Copie du WAR vers %TOMCAT_WEBAPPS_DIR%...
copy /Y "%BUILD_WAR%" "%TOMCAT_WEBAPPS_DIR%\"
if errorlevel 1 (
    echo [ERREUR] Echec copie du WAR (verifie les permissions)
    pause
    exit /b 1
)
echo [OK] WAR deploye dans Tomcat

:: 6) Afficher l'URL et ouvrir le navigateur
echo.
echo ============================================
echo DEPLOIEMENT TERMINE
echo ============================================
set "URL=http://localhost:8080/%TEST_APP_NAME%/"
echo URL application: %URL%
echo.
echo Pour tester le scan des controllers:
echo   %URL%
echo.

if "%OPEN_BROWSER%"=="true" (
    echo Ouverture du navigateur...
    start "" "%URL%"
    timeout /t 2 /nobreak >nul
)

echo Attente du deploiement Tomcat (15 sec)...
timeout /t 15 /nobreak >nul

echo.
echo Pour voir les logs Tomcat:
echo   %TOMCAT_DIR%\logs\catalina.out (ou .log sur Windows)
echo.
pause
