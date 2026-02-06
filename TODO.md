# Sprint 0 – Mise en place du socle

## 1. Workflow Git / CI-CD

### Règles
- Interdiction de coder directement sur `main` et `dev`
- Tout changement passe par Pull Request
- Suppression des branches après merge

### Branches
- `main` : production  
- `dev` : intégration  
- `staging/sprint/<num>` : tests  
- `sprint/<num>/feature-<name>` : développement  
- `fix/sprint/<num>/<desc>` : correctifs  
- `release/sprint/<num>` : release

### Workflow
1. TL crée une issue et une branche `sprint/<num>/feature-<name>`
2. Dev développe et ouvre une PR vers `dev`
3. TL review et merge vers `dev`
4. TL crée `staging/sprint/<num>` et déploie en staging
5. Tests :
   - Erreur → branche `fix/sprint/<num>/<desc>` (PR vers staging)
   - OK → merge `staging` → `main` + cherry-pick vers `dev`
6. TL crée `release/sprint/<num>` et pousse en prod

---

## 2. Environnement Docker (local & staging)

- JDK 17+
- Maven
- PostgreSQL 15
- Tomcat 9+ (Jakarta)

Objectif : environnement reproductible

---

## 3. Déploiement sur Render

### Services
- Staging → branche `staging/sprint/<num>`
- Production → branche `main`

### Configuration
- Runtime : Docker
- Build :
  ```bash
  mvn clean package
