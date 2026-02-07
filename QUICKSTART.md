# 🚀 QUICK START - Control Tower

## Démarrage rapide (3 minutes)

### 1️⃣ Première utilisation

```powershell
# Build du projet
mvn clean package

# Démarrer l'environnement de développement
.\dev.ps1 start
```

**Accès :**
- **Application :** http://localhost:8080
- **Base de données (Adminer) :** http://localhost:8081
- **Connexion DB :** controltower_user / controltower_pass_2024

### 2️⃣ Développement quotidien

```powershell
# Après modification du code
.\dev.ps1 restart

# Voir les logs
.\dev.ps1 logs

# Arrêter
.\dev.ps1 stop
```

### 3️⃣ Test avant merge (staging)

```powershell
# Test en environnement proche prod
.\staging.ps1 start

# Accès: http://localhost:8082
```

## 🔗 Liens utiles

- **Guide complet :** [GUIDE_DEMMARAGE.MD](GUIDE_DEMMARAGE.MD)
- **App Dev :** http://localhost:8080
- **App Staging :** http://localhost:8082
- **Adminer :** http://localhost:8081

## 🛠️ Comptes de test

| Utilisateur | Mot de passe | Rôle |
|-------------|--------------|------|
| admin | password | ADMIN |
| testuser | password | USER |

## 📝 Scripts disponibles

| Script | Action |
|--------|--------|
| `.\dev.ps1 start` | Démarrer dev |
| `.\dev.ps1 restart` | Redémarrer après code |
| `.\dev.ps1 logs` | Voir les logs |
| `.\dev.ps1 stop` | Arrêter dev |
| `.\staging.ps1 start` | Démarrer staging |

---

⚡ **Prêt en 3 commandes :** `mvn clean package` → `.\dev.ps1 start` → http://localhost:8080