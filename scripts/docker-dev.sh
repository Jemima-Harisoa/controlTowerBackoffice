#!/bin/bash

# =================================
# SCRIPT DOCKER DÉVELOPPEMENT
# Control Tower Backoffice (Linux/macOS)
# =================================

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "================================="
echo "Control Tower - Environnement Docker"
echo "================================="
echo -e "${NC}"

# Vérifier Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}ERREUR: Docker n'est pas installé${NC}"
    exit 1
fi

if ! command -v docker compose &> /dev/null; then
    echo -e "${RED}ERREUR: Docker Compose n'est pas installé${NC}"
    exit 1
fi

# Fonction pour afficher le menu
show_menu() {
    echo
    echo "Choisissez une action:"
    echo "1) Démarrer l'environnement (dev + adminer)"
    echo "2) Démarrer l'environnement (production)" 
    echo "3) Arrêter tous les services"
    echo "4) Reconstruire et démarrer"
    echo "5) Voir les logs"
    echo "6) Status des services"
    echo "7) Nettoyer (supprimer volumes)"
    echo "8) Ouvrir une session dans le conteneur app"
    echo "9) Backup base de données"
    echo "0) Quitter"
    echo
}

# Fonction pour démarrer en mode dev
dev_start() {
    echo -e "${GREEN}Démarrage de l'environnement de développement...${NC}"
    docker compose -f docker-compose.yml -f docker-compose.dev.yml --profile dev up -d
    echo
    echo -e "${GREEN}Services démarrés:${NC}"
    echo "- Application: http://localhost:8080"
    echo "- Adminer: http://localhost:8081"
    echo "- MailHog: http://localhost:8025"
    echo
}

# Fonction pour démarrer en mode production
prod_start() {
    echo -e "${GREEN}Démarrage de l'environnement de production...${NC}"
    docker compose up -d
    echo
    echo -e "${GREEN}Application disponible sur: http://localhost:8080${NC}"
    echo
}

# Fonction pour arrêter les services
stop_services() {
    echo -e "${YELLOW}Arrêt de tous les services...${NC}"
    docker compose down
    echo -e "${GREEN}Services arrêtés.${NC}"
}

# Fonction pour reconstruire
rebuild() {
    echo -e "${YELLOW}Reconstruction et démarrage...${NC}"
    docker compose down
    docker compose build --no-cache
    docker compose up -d
    echo -e "${GREEN}Reconstruction terminée.${NC}"
}

# Fonction pour voir les logs
show_logs() {
    echo -e "${BLUE}Affichage des logs (Ctrl+C pour arrêter)...${NC}"
    docker compose logs -f --tail=100
}

# Fonction pour voir le status
show_status() {
    echo -e "${BLUE}Status des services:${NC}"
    docker compose ps
    echo
    echo -e "${BLUE}Utilisation des ressources:${NC}"
    docker stats --no-stream
}

# Fonction pour nettoyer
clean() {
    echo -e "${RED}ATTENTION: Cette action va supprimer tous les volumes et données!${NC}"
    read -p "Êtes-vous sûr? (oui/non): " confirm
    if [ "$confirm" = "oui" ]; then
        docker compose down -v
        docker system prune -f
        echo -e "${GREEN}Nettoyage terminé.${NC}"
    else
        echo -e "${YELLOW}Opération annulée.${NC}"
    fi
}

# Fonction pour ouvrir un shell
open_shell() {
    echo -e "${BLUE}Ouverture d'une session dans le conteneur app...${NC}"
    docker exec -it controltower_app /bin/bash
}

# Fonction pour backup
backup_db() {
    echo -e "${BLUE}Création d'un backup de la base de données...${NC}"
    timestamp=$(date +"%Y%m%d_%H%M%S")
    docker exec controltower_db pg_dump -U controltower_user -d controltower > database/backups/backup_${timestamp}.sql
    echo -e "${GREEN}Backup créé: database/backups/backup_${timestamp}.sql${NC}"
}

# Boucle principale
while true; do
    show_menu
    read -p "Votre choix: " choice
    
    case $choice in
        1) dev_start ;;
        2) prod_start ;;
        3) stop_services ;;
        4) rebuild ;;
        5) show_logs ;;
        6) show_status ;;
        7) clean ;;
        8) open_shell ;;
        9) backup_db ;;
        0) echo -e "${GREEN}Au revoir!${NC}"; exit 0 ;;
        *) echo -e "${RED}Choix invalide${NC}" ;;
    esac
done