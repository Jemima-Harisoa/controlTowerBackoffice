# 🚀 GUIDE DE DÉMARRAGE - CONTROL TOWER

## 📋 Prérequis

Avant de commencer, assure-toi d'avoir installé :

- **Docker Desktop** (ou Docker Engine + Docker Compose)
- **Maven** (pour build local en dev)
- **Java JDK 11 ou 17**

## 🌍 Comprendre les 3 environnements

### 1️⃣ DÉVELOPPEMENT LOCAL (`docker-compose.dev.yml`)

**Quand l'utiliser ?**
- Tu codes et veux voir tes changements rapidement
- Tu veux debugger avec des logs détaillés
- Tu as besoin d'Adminer pour gérer la DB

**Comment ça marche ?**
```
┌─────────────────────┐
│  Ta machine locale  │
│                     │
│  1. Tu modifies     │
│     le code         │
│                     │
│  2. Tu build avec:  │
│     mvn clean       │
│     package         │
│                     │
│  3. Le WAR est      │
│     généré dans     │
│     target/         │
└──────────┬──────────┘
           │
           │ Volume partagé
           │ (pas de copie, juste un lien)
           ▼
┌─────────────────────┐
│  Conteneur Docker   │
│                     │
│  Tomcat lit         │
│  directement ton    │
│  WAR depuis         │
│  target/            │
└─────────────────────┘
```

**Avantages :**
- ✅ Pas besoin de rebuild l'image Docker à chaque fois
- ✅ Changements visibles après un simple `mvn package`
- ✅ Logs accessibles dans `dev/logs/`

**Commandes :**
```bash
# Première fois : créer le dossier pour les logs
mkdir -p dev/logs

# Builder ton application
mvn clean package

# Démarrer l'environnement
docker-compose -f docker-compose.dev.yml up

# Accès :
# - Application : http://localhost:8080
# - Adminer : http://localhost:8081
# - PostgreSQL : localhost:5432
```

---

### 2️⃣ STAGING (`docker-compose.staging.yml`)

**Quand l'utiliser ?**
- Avant de merger sur `main`
- Pour tester dans un environnement proche de la prod
- Pour vérifier que le build complet fonctionne

**Comment ça marche ?**
```
┌─────────────────────┐
│  Build Docker       │
│                     │
│  1. Maven build     │
│     dans conteneur  │
│                     │
│  2. WAR copié       │
│     dans l'image    │
│                     │
│  3. Image complète  │
│     créée           │
└──────────┬──────────┘
           │
           │ Image autonome
           ▼
┌─────────────────────┐
│  Conteneur Docker   │
│                     │
│  Tout est déjà      │
│  dans l'image       │
│  (autonome)         │
└─────────────────────┘
```

**Avantages :**
- ✅ Teste le processus de build complet
- ✅ Image autonome (pas de dépendance avec l'hôte)
- ✅ Configuration proche de la prod

**Commandes :**
```bash
# Créer le fichier .env.staging avec les bons paramètres
cp .env .env.staging

# Modifier .env.staging :
# - APP_ENV=staging
# - APP_PORT=8082
# - POSTGRES_PORT=5433

# Builder et démarrer
docker-compose -f docker-compose.staging.yml --env-file .env.staging up --build

# Accès :
# - Application : http://localhost:8082
# - PostgreSQL : localhost:5433
```

---

### 3️⃣ PRODUCTION (Render)

**Quand l'utiliser ?**
- Déploiement sur `main`
- Environnement accessible aux utilisateurs

**Comment ça marche ?**
- Render utilise ton `Dockerfile` principal
- Build automatique à chaque push sur `main`
- Pas de volumes, tout est dans l'image

---

## 🔧 Workflow de développement recommandé

### Scénario 1 : Développement quotidien

```bash
# 1. Démarrer l'environnement dev
docker-compose -f docker-compose.dev.yml up -d

# 2. Développer ton code
# (éditer les fichiers dans src/)

# 3. Rebuild après chaque modification
mvn clean package

# 4. Redémarrer juste l'app (pas la DB)
docker-compose -f docker-compose.dev.yml restart app

# 5. Voir les logs
docker-compose -f docker-compose.dev.yml logs -f app
```

### Scénario 2 : Préparer une release

```bash
# 1. S'assurer que dev fonctionne
mvn clean package
docker-compose -f docker-compose.dev.yml up

# 2. Tester en staging
docker-compose -f docker-compose.staging.yml --env-file .env.staging up --build

# 3. Si OK → commit et push sur staging/sprint/X

# 4. Merger vers main après validation
```

---

## 🐛 Résoudre les problèmes courants

### Problème : "Cannot access page" (page non accessible)

**Causes possibles :**

1. **Le WAR n'existe pas**
   ```bash
   # Vérifier que le WAR est généré
   ls -lh target/ControlTowerBackoffice.war
   
   # Si absent, builder :
   mvn clean package
   ```

2. **Tomcat n'a pas démarré**
   ```bash
   # Voir les logs
   docker-compose -f docker-compose.dev.yml logs app
   
   # Chercher des erreurs dans les logs
   ```

3. **Port déjà utilisé**
   ```bash
   # Vérifier les ports utilisés
   docker ps
   
   # Changer le port dans .env :
   APP_PORT=8085
   ```

### Problème : "Permission denied" sur le WAR

**Solution pour dev :**
```bash
# Donner les permissions
chmod 644 target/ControlTowerBackoffice.war

# Redémarrer
docker-compose -f docker-compose.dev.yml restart app
```

### Problème : Changements non visibles

```bash
# 1. Rebuild le WAR
mvn clean package

# 2. Redémarrer l'application
docker-compose -f docker-compose.dev.yml restart app

# 3. Vider le cache du navigateur (Ctrl+Shift+R)
```

---

## 📊 Tableau récapitulatif

| Critère      | DEV                      | STAGING                      | PROD             |
|--------------|--------------------------|------------------------------|------------------|
| **Fichier**  | `docker-compose.dev.yml` | `docker-compose.staging.yml` | `Dockerfile`     |
| **Build**    | Local (Maven)            | Dans Docker                  | Dans Docker      |
| **WAR**      | Volume partagé           | Copié dans image             | Copié dans image |
| **Port app** | 8080                     | 8082                         | 8080             |
| **Port DB**  | 5432                     | 5433                         | (Render)         |
| **Adminer**  | ✅ Oui                   | ❌ Non                      | ❌ Non           |
| **Logs**     | DEBUG                    | INFO                         | WARN             |
| **Hot reload** | ✅ Oui | ❌ Non | ❌ Non |


## 💡 Bonnes pratiques

### ✅ À FAIRE
- Toujours builder avec `mvn clean package` avant de démarrer
- Utiliser `.env.dev` et `.env.staging` séparés
- Vérifier les logs avec `docker-compose logs -f app`
- Arrêter proprement avec `docker-compose down`

### ❌ À NE PAS FAIRE
- Ne pas commiter le fichier `.env`
- Ne pas utiliser les mêmes ports pour dev et staging
- Ne pas oublier de rebuild après modification du code
- Ne pas mélanger les configurations d'environnement

---
