#!/bin/bash
set -euo pipefail
trap 'echo "Erreur à la ligne $LINENO"; exit 1' ERR

# Exécuter depuis Test/
TEST_DIR="$(pwd)"
TEST_APP_NAME="$(basename "$TEST_DIR")"

TEST_SRC_DIR="$TEST_DIR/src/main/java"
# détecte src/main/webapp ou src/webapp
TEST_WEBAPP_DIR="$TEST_DIR/src/webapp"

TEST_WEBINF_DIR="$TEST_WEBAPP_DIR/WEB-INF"
TEST_WEBINF_LIB="$TEST_WEBINF_DIR/lib"
TEST_WEBINF_CLASSES="$TEST_WEBINF_DIR/classes"

BUILD_DIR="$TEST_DIR/build"                    # build contient la webapp entière
BUILD_WAR="$TEST_DIR/${TEST_APP_NAME}.war"
TEST_TOP_LIB="$TEST_DIR/lib"                   # jars fournis au niveau Test/

# Tomcat (modifie si besoin)
TOMCAT_DIR="/opt/tomcat"
TOMCAT_WEBAPPS_DIR="$TOMCAT_DIR/webapps"
TOMCAT_START="$TOMCAT_DIR/bin/startup.sh"

# Optionnel : passer "open" pour tenter d'ouvrir l'URL dans le navigateur
OPEN_BROWSER=false
if [ "${1:-}" = "open" ]; then
  OPEN_BROWSER=true
fi

echo "--------------------------------------------"
echo "Déploiement (Test) — dossier : $TEST_DIR"
echo "App name : $TEST_APP_NAME"
echo "Webapp dir: $TEST_WEBAPP_DIR"
echo

# Vérifications basiques
command -v javac >/dev/null 2>&1 || { echo "ERROR: javac introuvable dans le PATH"; exit 1; }
command -v jar >/dev/null 2>&1 || { echo "ERROR: jar introuvable dans le PATH"; exit 1; }

# Préparations
mkdir -p "$TEST_WEBINF_CLASSES" "$BUILD_DIR"

# 1) Construire le classpath pour la compilation (si des jars existent dans Test/lib)
CLASSPATH=""
if compgen -G "$TEST_TOP_LIB/*.jar" >/dev/null 2>&1; then
    CLASSPATH="$TEST_TOP_LIB/*"
    echo "Classpath pour compilation : $CLASSPATH"
else
    echo "Aucun jar trouvé dans $TEST_TOP_LIB — compilation sans classpath externe"
fi
echo

# 2) Compiler les sources -> directement dans webapp/WEB-INF/classes
echo "=== Compilation des sources (src -> ${TEST_WEBINF_CLASSES}) ==="
if [ -d "$TEST_SRC_DIR" ] && find "$TEST_SRC_DIR" -name "*.java" | grep -q . 2>/dev/null; then
    echo "Destination classes: $TEST_WEBINF_CLASSES"
    mkdir -p "$TEST_WEBINF_CLASSES"

    if [ -n "$CLASSPATH" ]; then
        find "$TEST_SRC_DIR" -name "*.java" -print0 | xargs -0 javac -cp "$CLASSPATH" -d "$TEST_WEBINF_CLASSES"
    else
        find "$TEST_SRC_DIR" -name "*.java" -print0 | xargs -0 javac -d "$TEST_WEBINF_CLASSES"
    fi
    echo "Compilation terminée."
else
    echo "Aucun fichier .java trouvé dans $TEST_SRC_DIR — skip compilation."
fi
echo

# 2.b) warning si pas de web.xml (aide debugging 404)
if [ ! -f "$TEST_WEBINF_DIR/web.xml" ]; then
    echo "WARN: $TEST_WEBINF_DIR/web.xml introuvable — vérifie le mapping des servlets (peut causer 404)."
fi
echo

# 3) Copier **le contenu** de webapp -> build/
echo "=== Copie du contenu de webapp -> build/ ==="
if [ ! -d "$TEST_WEBAPP_DIR" ]; then
    echo "ERREUR: $TEST_WEBAPP_DIR introuvable. Place ta webapp dans src/main/webapp ou src/webapp."
    exit 1
fi

# suppression du build précédent puis copie simple
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cp -r "$TEST_WEBAPP_DIR"/* "$BUILD_DIR"/
echo "Copie du contenu de webapp -> build/ effectuée."
echo

# vérifie que build/ n'est pas vide avant de créer le WAR
if ! find "$BUILD_DIR" -mindepth 1 -print -quit >/dev/null 2>&1; then
    echo "ERREUR: build/ est vide après copie — impossible de créer un WAR vide."
    echo "Vérifie que $TEST_WEBAPP_DIR contient bien des fichiers (JSP, index.html, WEB-INF, ...)."
    exit 1
fi

# 4) Créer le WAR depuis build/
echo "=== Packaging WAR depuis $BUILD_DIR ==="
[ -f "$BUILD_WAR" ] && rm -f "$BUILD_WAR"

pushd "$BUILD_DIR" >/dev/null
jar -cvf "$BUILD_WAR" . || { popd >/dev/null; echo "Erreur lors de la création du WAR"; exit 1; }
popd >/dev/null

echo "WAR créé: $BUILD_WAR"
echo

# 5) Déployer sur Tomcat (copie du WAR dans webapps)
echo "=== Vérification Tomcat & déploiement ==="
if pgrep -f "org.apache.catalina.startup.Bootstrap" > /dev/null; then
    echo "Tomcat déjà en cours d'exécution."
else
    if [ -x "$TOMCAT_START" ]; then
        echo "Démarrage de Tomcat..."
        "$TOMCAT_START"
        sleep 5
    else
        echo "WARN: startup Tomcat introuvable ($TOMCAT_START). Continuer sans démarrage automatique."
    fi
fi

if [ -d "$TOMCAT_WEBAPPS_DIR" ]; then
    echo "Déploiement du WAR dans $TOMCAT_WEBAPPS_DIR ..."
    if cp -v "$BUILD_WAR" "$TOMCAT_WEBAPPS_DIR/"; then
        echo "WAR copié dans $TOMCAT_WEBAPPS_DIR"
    else
        echo "Erreur: copie du WAR échouée (vérifie les permissions)."
        exit 1
    fi
else
    echo "ERREUR: répertoire Tomcat webapps introuvable: $TOMCAT_WEBAPPS_DIR"
    exit 1
fi
echo

# 6) Afficher lien simple et optionnellement ouvrir navigateur
URL="http://localhost:8080/${TEST_APP_NAME}/"
echo "Application disponible -> $URL"

if [ "$OPEN_BROWSER" = true ]; then
    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$URL" >/dev/null 2>&1 || true
    elif command -v sensible-browser >/dev/null 2>&1; then
        sensible-browser "$URL" >/dev/null 2>&1 || true
    elif command -v open >/dev/null 2>&1; then
        open "$URL" >/dev/null 2>&1 || true
    else
        echo "Aucun utilitaire d'ouverture de navigateur trouvé."
    fi
fi

echo
echo "Terminé."
