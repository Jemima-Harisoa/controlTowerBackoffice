# Nettoyer les docker , effacer les volume, et demarrer le docker
docker compose -f .\docker-compose.dev.yml down -v ; docker compose -f .\docker-compose.dev.yml up -d
