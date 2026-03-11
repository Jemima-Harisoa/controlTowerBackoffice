#!/bin/bash

# =================================
# SCRIPT DÉVELOPPEMENT RAPIDE  
# Control Tower Backoffice (Linux/macOS)
# =================================

set -e

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'  
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}"
echo "================================="
echo "Control Tower - Build et Deploy Rapide"
echo "=================================" 
echo -e "${NC}"

# Vérifier Maven
if ! command -v mvn &> /dev/null; then
    echo -e "${RED}ERREUR: Maven n'est pas installé${NC}"
    exit 1
fi

# Build Maven
echo -e "${YELLOW}[1/3] Build Maven en cours...${NC}"
mvn clean install -q
if [ $? -ne 0 ]; then
    echo -e "${RED}ERREUR: Build Maven a échoué${NC}"
    exit 1
fi

# Vérifier que le WAR a été généré
if [ ! -f "target/ControlTowerBackoffice.war" ]; then
    echo -e "${RED}ERREUR: Le fichier WAR n'a pas été généré${NC}"
    exit 1
fi

echo -e "${GREEN}✅ WAR généré: target/ControlTowerBackoffice.war${NC}"

# Redémarrer le conteneur app
echo -e "${YELLOW}[2/3] Redémarrage du conteneur...${NC}"
docker compose restart app
if [ $? -ne 0 ]; then
    echo -e "${RED}ERREUR: Impossible de redémarrer le conteneur${NC}"
    exit 1
fi

echo -e "${YELLOW}[3/3] Attendre que l'application démarre...${NC}"
sleep 5

# Vérifier le statut
echo
echo -e "${BLUE}Status des services:${NC}"
docker compose ps

echo
echo -e "${GREEN}========================================"
echo "✅ Application mise à jour avec succès!"
echo "========================================"
echo "URLs disponibles:"
echo "- Application: http://localhost:8080/"
echo "- Welcome:     http://localhost:8080/welcome"
echo "- API Test:    http://localhost:8080/api/welcome" 
echo "- Adminer:     http://localhost:8081"
echo "========================================"
echo -e "${NC}"

# Ouvrir automatiquement dans le navigateur (Linux)
if command -v xdg-open &> /dev/null; then
    read -p "Ouvrir l'application dans le navigateur? (o/n): " openBrowser
    if [[ "$openBrowser" == "o" || "$openBrowser" == "O" ]]; then
        xdg-open http://localhost:8080/welcome
    fi
fi