# Dockerfile pour Control Tower Backoffice
# Multi-stage build : build stage + runtime stage

# === STAGE 1: Build Stage ===
FROM maven:3.9.6-eclipse-temurin-11 AS builder

WORKDIR /app

# Copier les fichiers de configuration Maven
COPY pom.xml .
COPY lib/ lib/

# Copier le code source
COPY src/ src/

# Builder l'application (sans go-offline qui peut être problématique)
RUN mvn clean package -DskipTests -B

# === STAGE 2: Runtime Stage ===
FROM tomcat:10.1-jdk11

# Métadonnées
LABEL maintainer="Control Tower Team"
LABEL version="1.0.0"
LABEL description="Control Tower Backoffice Application"

# Variables d'environnement
ENV CATALINA_OPTS="-Djava.security.egd=file:/dev/./urandom"
ENV JAVA_OPTS="-Xms512m -Xmx1024m"

# Créer un utilisateur non-root pour la sécurité
RUN groupadd -r tomcat && useradd -r -g tomcat tomcat

# Installer curl pour le health check
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Supprimer les applications par défaut de Tomcat
RUN rm -rf /usr/local/tomcat/webapps/*

# Copier le WAR depuis le build stage
COPY --from=builder /app/target/ControlTowerBackoffice.war /usr/local/tomcat/webapps/ROOT.war

# Copier la configuration Tomcat si nécessaire
# COPY tomcat-config/server.xml /usr/local/tomcat/conf/

# Changer les permissions
RUN chown -R tomcat:tomcat /usr/local/tomcat
RUN chmod +x /usr/local/tomcat/bin/*.sh

# Exposer le port Tomcat
EXPOSE 8080

# Changer vers l'utilisateur non-root
USER tomcat

# Point de santé pour Docker
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/index.html || exit 1

# Commande par défaut
CMD ["catalina.sh", "run"]