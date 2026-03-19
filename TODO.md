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
  [X] liste :  vehicule 
  [X] table :  date, heure arrivee, reservations
  [X] filtre : date, heure arrivee
  [X] action : afficher les reservation non assignees, valider le planning, voir reservation  a la date, assigneer un voiture manuellement a une reservation, generer le planning automatiquement

- Page de visualisation du planning des trajets - considerons les reservation comme des trajets a planifier (1 reservation = 1 tarajet a planifier)
  
  [X] table :  date, heure arrivee, reservations, vehicule , nb places, distance a parcourir, duree du trajet, point arrive  - point depart
  [X] filtre : date, heure arrivee, vehicule
  
#### fonctionnalité :
[X] afficher les reservation non assignees : getReservationNonAssignees() - classe ReservationService - > requete sql : select * from reservation where vehicule_id is null (ReservationRepository)
[X] generer le planning : genererPlanning() - classe PlanningTrajetService - > fonction de planification des trajets (PlanningTrajetService) - > assignation des reservations aux vehicules (PlanningTrajetRepository)
- Prioriser par date ancienne
- Voir les distance la plus courte a parcourir -> table distance 
- Assignation de voiture nb>= nb places 
- Si 2 vehicule correspondent au condition enonce precedement, prioriser les vehicule diesel

[X] valider le planning : validerPlanning() - classe PlanningTrajetService - > fonction de planification des trajets (PlanningTrajetService) - > assignation des reservations aux vehicules (PlanningTrajetRepository)

[X] caluler la durer du trajet : calculerDureeTrajet() - classe PlanningTrajetService - > fonction de planification des trajets (PlanningTrajetService) - > assignation des reservations aux vehicules (PlanningTrajetRepository) - > calcul de la distance a parcourir (table distance) / vitesse moyenne (table parametre de configuration)

[X] securite asignation de vehicule : seul ceux avec autorisation peuve acceder a la page de planning des trajets et faire l'assignation des vehicules aux reservations => les session utilisateur serons gerer avec des token - base de donnée utilisateur (table user) - login / mot de passe - token d'authentification 

## 3. Modif code existant : 
Ajout des token pour les logins des utilisateurs du backoffice - classe UserService - table user (id, username, password, role) - session (date connexion, token, user permission) - dans param mettre la duree d'un token (ex 30 min, 1j)  fonction de generation de token d'authentification (UserService) - securisation de l'interface de planification des trajets (PlanningTrajetController) - verification du token d'authentification dans les requetes vers l'interface de planification des trajets (PlanningTrajetController)

# Sprint 3 – Feature de planning des assignation de vehicule avec plusieurs clients
Objectif : sachant un client = une reservation permettre l'assignation d'un même vehicule a plusieurs reservations pour le même trajet , en respectant les règles de gestion suivantes :
  - prioriser les reservation avec le plus de places demandes ex reservation 1 : 4 places, reservation 2 : 2 places, reservation 3 : 1 place => assigner d'abord la reservation 1 au vehicule puis les autres reservation en fonction du nombre de place restante dans le vehicule 
  - assigner d'autre reservation a ce meme vehicule pour le reste des places disponibles dans le vehicule
  - le nombre de personne dans une meme reservation ne peuvent pas encore etre separer dans plusieurs vehicules different, ex reservation 1 : 4 places => assigner la reservation 1 a un seul vehicule qui a au moins 4 places disponibles
  - le trajet sera contitue de l'ensemble des points de depart et d'arrivee (hotel, aeroport, gare) de l'ensemble des reservations assignées a ce vehicule pour ce trajet 
  - point de ramassage les plus proche du point de depart du trajet seront prioriser pour l'assignation au vehicule. Si un vehicule a 4 places disponibles et 2 reservation de 2 places chacune, la reservation avec le point de depart le plus proche du vehicule sera prioriser pour l'assignation supposant que le vehicule fait une commission et est proche de la gare pour le ramassage de la reservation 1 et loin de l'hotel pour le ramassage de la reservation 2, la reservation 1 sera prioriser pour l'assignation au vehicule.
  - Les reservation meme jour mme heure peuvenet etre automatiquement regrouper si il y des vehicule disponible

## Data :
  - table detail planning assignation : date, heure arrivee, reservations (afficher l'ensemble des reservations assignées a un même vehicule pour le même trajet), vehicule , nb places, distance a parcourir, duree du trajet, point arrive  - point depart, nplace libre dans le vehicule apres assignation
  nplace libre sera pris en compte pour l'ajout des reservation suivante dans le meme vehicule pour le meme trajet, si nplace libre = 0 alors le vehicule ne sera plus disponible pour l'assignation d'autre reservation pour le meme trajet
  

## To do :
  - [X] refactoriser la fonction de planification des trajets pour prendre en compte l'assignation de plusieurs reservation a un même vehicule pour le même trajet - classe PlanningTrajetService - fonction de planification des trajets (PlanningTrajetService) - > assignation des reservations aux vehicules (PlanningTrajetRepository) - > regle de gestion : prioriser les reservation avec le plus de places demandes, assigner d'autre reservation a ce meme vehicule pour le reste des places disponibles dans le vehicule, le nombre de personne dans une meme reservation ne peuvent pas encore etre separer dans plusieurs vehicules different, le trajet sera contitue de l'ensemble des points de depart et d'arrivee (hotel, aeroport, gare) de l'ensemble des reservations assignées a ce vehicule pour ce trajet, point de ramassage les plus proche du point de depart du trajet seront prioriser pour l'assignation au vehicule
  - [X] refactoriser la page de visualisation du planning des trajets pour afficher l'ensemble des reservations assignées a un même vehicule pour le même trajet - classe PlanningTrajetController - page de visualisation du planning des trajets - table : date, heure arrivee, reservations (afficher l'ensemble des reservations assignées a un même vehicule pour le même trajet), vehicule , nb places, distance a parcourir, duree du trajet, point arrive  - point depart
  - [X] considere la durer de chaque trajet pour savoir si le vehicule peut etre assigner a une autre reservation pour un autre trajet dans la même journée ou pas - classe PlanningTrajetService - fonction de planification des trajets (PlanningTrajetService) - > assignation des reservations aux vehicules (PlanningTrajetRepository) - > regle de gestion : considerer la durer de chaque trajet pour savoir si le vehicule peut etre assigner a une autre reservation pour un autre trajet dans la même journée ou pas


## Reconfiguration des donnes   de test existante : 
- A cet instant les reservation reste assigner un seul et meme vehicule vu que les heure se chevachent pas : la durre du trajet doit etre la somme des temps estimmer pour chaque trajet avec allez retour vers le point de rammassage. Ex :  reservation 1 : hotel A a aeroport B, distance 20 km, duree du trajet 30 min, reservation 2 : hotel C a aeroport B, distance 10 km, duree du trajet 15 min, disatnce hotel A a hotel C 5 km les 2 reservation arrive a la mme heure a l'aeroport B, point de rammassage donc le vehicule va pouvoir aller chercher la reservation 1 a hotel A, puis aller chercher la reservation 2 a hotel C et ensuite aller a l'aeroport B, la duree totale du trajet on va dire la voiture vient de retourvner d;une commission a pres avoir deposer qqun a hotel B, on a les disatnce entre hotel B et C 5 km, distance entre hotel B et A 20 km, distance entre hotel A et C 5 km, la duree totale du trajet va etre : 20 km (hotel B a hotel A) + 5 km (hotel A a hotel C) + 10 km (hotel C a aeroport B) + 5 km (hotel C a hotel A) = 40 km, la duree totale du trajet va etre de 1h (30 min pour le trajet hotel A a aeroport B + 15 min pour le trajet hotel C a aeroport B + 5 min pour le trajet hotel A a hotel C) => la voiture va prioriser le plus proche a  partir de sa dernieret localisation enregistrer et va faire chaque trajet en fonction de la distance et de la duree du trajet pour savoir si elle peut faire les 2 trajets dans la même journée ou pas, si oui elle va assigner les 2 reservation au meme vehicule sinon elle va assigner une reservation a un vehicule et l'autre reservation a un autre vehicule


# Sprint 4 : Regroupement des réservations avec temps d'attente

## Objectif

Ajouter la gestion du temps d'attente entre réservations lors du regroupement de véhicules. Les réservations arrivant dans la marge définie sont assignées au même véhicule avec ajustement automatique de l'heure de départ.

## Données

* [x] Table "Détail du planning" contenant :

  * Date
  * Heure d'arrivée
  * Réservations assignées (liste)
  * Véhicule
  * Nombre de places
  * Distance
  * Durée du trajet
  * Point de départ
  * Point d'arrivée
  * Places libres après assignation
* [x] Temps d'attente calculé à partir des dates/heures d'arrivée
* [x] Paramètre de configuration :

  * Temps d'attente maximum (ex : 30 min, 1h)

## Règles de gestion

* [x] Regrouper les réservations dont l'écart ≤ temps d'attente max
* [x] Assigner un seul véhicule par groupe
* [x] Définir l'heure de départ = heure de la dernière réservation du groupe
* [x] Respecter les règles existantes (capacité, proximité, etc.)
* [x] Laisser non assignées les réservations hors délai

## Tâches de développement

### Refactorisation du moteur de planification

* [x] Intégrer le calcul du temps d'attente
* [x] Adapter la logique multi-clients 
* [x] Ajouter le paramètre temps d'attente max
* [x] Implémenter l'ajustement automatique de l'heure de départ
* [x] Grouper les réservations selon l'écart de temps

### Données de test

* [ ] Réservations dans la marge (ex : 8h, 8h15 avec TA=30min)
* [ ] Réservations hors marge (8h, 8h45 avec TA=30min)
* [ ] Vérification de l'heure de départ ajustée
* [ ] Respect des règles existantes
* [ ] Cas limite : une seule réservation / TA = 0

### Interface de visualisation

* [ ] Ajouter colonnes :

  * Date
  * Heure arrivée
  * Réservations
  * Véhicule
  * Places
  * Distance
  * Durée
  * Point départ
  * Point arrivée
  * Temps d'attente
* [ ] Afficher le temps d'attente entre réservations
* [ ] Implémenter layout responsive
* [ ] Ajouter sidebar toggle
* [ ] Ajouter header fixe
* [ ] Gérer le wrapping du texte

---

# Sprint 5 : Assignation avec priorité au nombre minimum de trajets

## Objectif

Prioriser les véhicules avec le nombre minimum de trajets, sauf si un véhicule déjà utilisé est le seul disponible.

## Logique

* [ ] Priorité d'assignation :

  * Proximité
  * Nombre minimum de trajets
  * Nombre de places disponibles
* [ ] Gérer les cas d'égalité
* [ ] Favoriser les véhicules les moins utilisés

## Tâches de développement

### Implémentation logique

* [ ] Ajouter le paramètre nombre de trajets par véhicule
* [ ] Implémenter la priorité (proximité → min trajets → places)
* [ ] Adapter la fonction d'assignation
* [ ] Gérer les cas d'égalité

### Données de test

* [ ] Tous véhicules à 0 trajet
* [ ] Cas mix : V1=2, V2=1, V3=2
* [ ] Cas égalité : V1=2, V2=2, V3=2
* [ ] Cas égalité : V1=1, V2=1, V3=1
* [ ] Vérifier l'ordre de priorité complet

---

## Sprint 6 : Séparation des clients sur plusieurs véhicules

## Objectif

Permettre le fractionnement des réservations lorsque la capacité du véhicule est insuffisante.

## Logique

* [ ] Priorité :

  * Proximité
  * Nombre minimum de trajets
  * Nombre de places disponibles
* [ ] Autoriser le partage de réservation sur plusieurs véhicules
* [ ] Trier par ancienneté de réservation

## Exemple

* [ ] Réservation de 5 personnes
* [ ] Véhicule avec 4 places → assigner 4 personnes
* [ ] 1 personne restante → assignation sur autre véhicule
* [ ] Continuer jusqu'à assignation complète

## Tâches de développement

### Fractionnement des réservations

* [ ] Implémenter la logique de partage
* [ ] Gérer les sous-assignations
* [ ] Trier par ancienneté
* [ ] Gérer les états partiellement assignés

### Adaptation du service

* [ ] Intégrer le fractionnement dans le workflow
* [ ] Maintenir les priorités (proximité → min trajets → places)
* [ ] Respecter les règles Sprint 4 et 5
* [ ] Gérer les boucles d'assignation

### Données de test

* [ ] Réservations multi-personnes avec capacité partielle
* [ ] Mix ancien / nouveau
* [ ] Vérifier ordre par ancienneté
* [ ] Cas limite : 1 place / véhicule
* [ ] Chaîne complète de réservations
* [ ] Vérifier la traçabilité

### Mise à jour UI/UX

* [ ] Afficher les réservations fragmentées
* [ ] Indiquer les partages (ex : R1 [3p] / R1 [2p])
* [ ] Ajouter indicateur de fragment
* [ ] Afficher la réservation parent

---

## Résumé des étapes transversales

## Sprint 4

* [ ] Backend : calcul temps d'attente
* [ ] Tests : assignation multi-clients
* [ ] Frontend : dashboard + affichage temps d'attente

## Sprint 5

* [ ] Backend : logique min trajets
* [ ] Tests : validation priorités
* [ ] Frontend : aucun changement

## Sprint 6

* [ ] Backend : fractionnement + ancienneté
* [ ] Tests : partage + ordre
* [ ] Frontend : affichage fragments

---

## Dépendances entre sprints

* [ ] Sprint 4 terminé avant Sprint 5
* [ ] Sprint 5 dépend de Sprint 4
* [ ] Sprint 6 dépend de Sprint 4 et 5
* [ ] Sprint 5 peut démarrer en parallèle partiel de Sprint 4

---

## Checklist de livraison

* [ ] Sprint 4 terminé (backend + tests + UI)
* [ ] Sprint 5 terminé (logique + tests)
* [ ] Sprint 6 terminé (fractionnement + tests + UI)
* [ ] Documentation technique mise à jour
* [ ] Code review effectuée
* [ ] Validation métier effectuée
* [ ] Tests d'intégration validés
