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


# Sprint 1 – Feature de reservation pour les clients
# Module Réservation
---

# I. BACKOFFICE (Administration)
> Le backoffice est responsable de **l’insertion des réservations**, de la **validation** et de **toute la logique métier**.  
Il peut utiliser des vues serveur (MVC) et n’est pas consommé par le public.

---

## A. Interface Backoffice (UI)

### A1. Formulaire de réservation
- **Champs**
  - Nom
  - Email
  - Date d’arrivée
  - Heure
  - Nombre de personnes
  - Hôtel de destination
- **Validation côté client**
  - Champs obligatoires
  - Email valide
  - Date future
  - Heure valide
  - Nombre de personnes > 0
- **Rôle**
  - Création des réservations
  - Aide à la saisie (UX)
- **UI**
  - Simple
  - Responsive
  - Accessible

---

## B. Backend Backoffice

### B1. Endpoints (MVC)
- **GET `/reservations/create`**
  - Affiche le formulaire de réservation
  - Fournit la liste des hôtels disponibles
  - Retourne une vue (`ModelAndView`)
- **POST `/reservations/create`**
  - Traite la soumission du formulaire
  - Validation serveur
  - Appel de la logique métier
  - Insertion en base de données

---

## C. Logique Métier (Backoffice uniquement)

### C1. Services
- **HotelService**
  - `getAvailableHotels()`
  - Requête : `SELECT * FROM hotels`
- **ReservationService**
  - `createReservation(Reservation reservation)`
    - Validation métier
    - Insertion en base  
    - `INSERT INTO reservations (...)`

---

## D. Modèles (Persistence)
- **Hotel**
  - Champs correspondant à la table `hotels`
  - Getters / Setters
  - Constructeurs
- **Reservation**
  - Champs :
    - id
    - nom
    - email
    - date_arrivee
    - heure
    - nombre_personnes
    - hotel

---

---

# II. FRONTOFFICE (Consultation)
> Le frontoffice est dédié **à l’affichage des réservations**.  
Il ne contient **aucune logique métier** et consomme uniquement l’API REST exposée par le backend.

---

## E. Interface Frontoffice (UI)

### E1. Vue Liste des réservations
- Affichage sous forme de **tableau / liste**
- Données **formatées pour l’utilisateur**
  - Nom formaté (ex : `Jean Dupont`)
  - Date lisible (ex : `12 mars 2026`)
  - Heure formatée (`14:30`)
  - Nom de l’hôtel (libellé)
- **Filtres**
  - Par date
  - Par hôtel
- **UI**
  - Responsive
  - Orientée consultation
  - Lecture claire des données

---

## F. API REST (Backend partagé)

### F1. Endpoints Frontoffice
- **GET `/api/reservations`**
  - Retourne toutes les réservations formatées
- **GET `/api/reservations?date=YYYY-MM-DD`**
  - Filtre par date
- **GET `/api/reservations?hotelId=ID`**
  - Filtre par hôtel
- **GET `/api/reservations?date=YYYY-MM-DD&hotelId=ID`**
  - Filtres combinés

---

## G. View Models / DTO (Frontoffice)
- **ReservationView**
  - nomFormate
  - email
  - dateAffichee
  - heureAffichee
  - nombrePersonnes
  - nomHotel
- Données prêtes à l’affichage
- Aucun champ technique (ID, clés, etc.)

---

## H. Services exposés au Frontoffice
- `getAllReservationsForView()`
- `getReservationsForViewByDate(...)`
- `getReservationsForViewByHotel(...)`
- Mapping :
  - Entités → `ReservationView`
  - Source : `vue_reservations_completes`

---

---

# III. INFRASTRUCTURE COMMUNE

## I. Base de Données
- Script : `database/init/03-sprint1_form_reservation.sql`
- Tables :
  - `hotels`
  - `reservations`
- Vue :
  - `vue_reservations_completes`
  - Jointure + données prêtes pour affichage

---

## J. Configuration
- PostgreSQL
- `DataSource` Java
- Configuration via `.env`
- Pool de connexions

---

## K. Tests

### K1. Backoffice
- Tests unitaires :
  - Validation
  - Logique métier
- Tests E2E :
  - Création complète d’une réservation

### K2. Frontoffice
- Tests d’intégration :
  - API REST
  - Filtres date / hôtel
- Tests E2E :
  - Affichage des données formatées

# Sprint 2 - Crud de gestion des voitures

# Sprint 3 - Assignation des courses aux vehicules
Estimation du cycle des vehicules selon les courses: vehicule => vitesse moyenne => temps de course => disponibilité 
- CRUD de gestion des courses

Base de données:
Lieux 
Distance  from - to 
Parametre : vitesse moyenne des vehicules