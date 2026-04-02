# Arreter le docker et supprimer les volumes associés (pour une base propre au prochain démarrage)
docker compose -f .\docker-compose.dev.yml down -v 