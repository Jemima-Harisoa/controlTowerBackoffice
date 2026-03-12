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


### Todo : fix filtre date 
Probleme : le filtre date ne fonctionne pas correctement, il retourne des résultats vides
- [X] mettre les date et les hotel en paramettre optionnel dans le controller  
- [X] appler directement les fonction de service dans le controller au lieu de faire un mapping complexe
- [X] utiliser un formulaire de type post derriere le filtre pour envoyer les parametres de date et hotel au lieu de les envoyer en query params 

### Todo : refactorisation code - separation des requete sql dans des repository et logique métier dans des services


# Sprint 2 – Feature de planning des trajets pour les vehicules
## 1. Database : Nouvel migration pour les tables de planification des trajets
  - script de creation de table
     - vehicule
     - planning_trajet
     - disatnce 
     - lieu (hotel, aeroport, gare)
     - reservation (ajout de champ lieu_depart et lieu_arrivee)
     - paramatre de configuration (vitesse moyenne, etc)
     - code carburant (essence, diesel, electrique, ect)
     - token d'authentification (pour la securite de l'interface de planification des trajets) 
## 2. Backoffice : Metier de planification des trajets
### A. Interface Backoffice (UI)
- page de planning des trajets
#### affichage :
- Page assignation des vehicules aux reservations
  [] liste :  vehicule 
  [] table :  date, heure arrivee, reservations
  [] filtre : date, heure arrivee
  [] action : afficher les reservation non assignees, valider le planning, voir reservation  a la date, assigneer un voiture manuellement a une reservation, generer le planning automatiquement

- Page de visualisation du planning des trajets - considerons les reservation comme des trajets a planifier (1 reservation = 1 tarajet a planifier)
  
  [] table :  date, heure arrivee, reservations, vehicule , nb places, distance a parcourir, duree du trajet, point arrive  - point depart
  [] filtre : date, heure arrivee, vehicule
  
#### fonctionnalité :
[] afficher les reservation non assignees : getReservationNonAssignees() - classe ReservationService - > requete sql : select * from reservation where vehicule_id is null (ReservationRepository)
[] generer le planning : genererPlanning() - classe PlanningTrajetService - > fonction de planification des trajets (PlanningTrajetService) - > assignation des reservations aux vehicules (PlanningTrajetRepository)
- Prioriser par date ancienne
- Voir les distance la plus courte a parcourir -> table distance 
- Assignation de voiture nb>= nb places 
- Si 2 vehicule correspondent au condition enonce precedement, prioriser les vehicule diesel

[] valider le planning : validerPlanning() - classe PlanningTrajetService - > fonction de planification des trajets (PlanningTrajetService) - > assignation des reservations aux vehicules (PlanningTrajetRepository)

[] caluler la durer du trajet : calculerDureeTrajet() - classe PlanningTrajetService - > fonction de planification des trajets (PlanningTrajetService) - > assignation des reservations aux vehicules (PlanningTrajetRepository) - > calcul de la distance a parcourir (table distance) / vitesse moyenne (table parametre de configuration)

[] securite asignation de vehicule : seul ceux avec autorisation peuve acceder a la page de planning des trajets et faire l'assignation des vehicules aux reservations => les session utilisateur serons gerer avec des token - base de donnée utilisateur (table user) - login / mot de passe - token d'authentification 

## 3. Modif code existant : 
Ajout des token pour les logins des utilisateurs du backoffice - classe UserService - table user (id, username, password, role) - session (date connexion, token, user permission) - dans param mettre la duree d'un token (ex 30 min, 1j)  fonction de generation de token d'authentification (UserService) - securisation de l'interface de planification des trajets (PlanningTrajetController) - verification du token d'authentification dans les requetes vers l'interface de planification des trajets (PlanningTrajetController)