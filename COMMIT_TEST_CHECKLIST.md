# Checklist Tests - Suite de Commits

## Points corrigés dans le code

- Ajout de la vérification véhicule + réservation avant mise à jour du planning.
- Correction de la logique insert/update dans l'assignation des véhicules.
- Alignement des lieux de départ/arrivée du planning avec ceux de la réservation.
- Calcul de la distance via la table `distances` (prise en charge des deux sens A->B et B->A).
- Calcul de la durée estimée à partir de `distance / VITESSE_MOYENNE_KMH`.
- Implémentation complète de `DistanceRepository` (lecture + recherche + CRUD).
- Implémentation complète de `ParametreConfigurationRepository` (lecture + recherche + CRUD).
- `date_planification` alignée sur `date_arrivee` de la réservation.
- Ajout de la vue statut planning dans la page d'assignation (détails par trajet).
- Filtre de la page assignation appliqué sur les plannings (date, heure, véhicule).
- Simplification MVC du filtre: endpoint GET unique `/planning/assignation`.
- Amélioration UI: barre actions + filtre sticky, meilleure ergonomie du formulaire.

## Liste des tests à effectuer

### 1) Tests build et démarrage

- Lancer `mvn clean package -DskipTests`.
- Vérifier que le WAR est généré sans erreur bloquante.
- Redémarrer l'app: `docker compose -f .\docker-compose.dev.yml restart app`.

### 2) Tests base de données

- Vérifier que `distances` contient les trajets dans les deux sens.
- Vérifier que `parametres_configuration` contient `VITESSE_MOYENNE_KMH`.
- Vérifier que `planning_trajet.date_planification = reservations.date_arrivee`.

### 3) Tests génération planning

- Cliquer sur "Générer Planning" depuis la page assignation.
- Vérifier pour chaque ligne planning:
  - `vehicule_id` renseigné,
  - `lieu_depart_id` / `lieu_arrivee_id` renseignés,
  - `distance_estimee > 0`,
  - `duree_estimee` non nulle,
  - `date_planification` = date d'arrivée réservation.

### 4) Tests règle métier assignation

- Tenter de réassigner la même réservation au même véhicule.
- Vérifier qu'il n'y a pas de doublon incohérent.
- Vérifier le comportement update vs insert attendu.

### 5) Tests validation planning

- Cliquer sur "Valider Planning".
- Vérifier passage du statut de `PLANIFIE` vers `VALIDE`.
- Vérifier que les lignes sans véhicule ne sont pas validées.

### 6) Tests filtre planning

- Filtrer par date: résultats cohérents.
- Filtrer par heure: résultats cohérents.
- Filtrer par véhicule: seuls les trajets du véhicule choisi.
- Réinitialiser: retour à la liste complète.

### 7) Tests non-régression frontoffice

- Vérifier que la page frontoffice réservations fonctionne toujours.
- Vérifier que les filtres frontoffice ne sont pas impactés.

## Critères d'acceptation

- Aucun trajet généré avec distance à 0 si distance existe en table.
- Aucune durée estimée vide si distance > 0 et vitesse configurée.
- Date de planification cohérente avec la date d'arrivée client.
- Filtre assignation agit uniquement sur la table planning.

## Issues à corriger (priorité haute)

- Gestion de disponibilité véhicule:
  - Quand un véhicule est assigné à un trajet, son statut doit être `non disponible` sur la plage occupée.
  - Un véhicule non disponible ne doit pas être proposé pour une nouvelle assignation en conflit horaire.
- Révision de la disponibilité des voitures selon les trajets (structure du code):
  - `PlanningTrajetService.genererPlanning()` doit vérifier la disponibilité temporelle avant `assignerVehicule(...)`.
  - `PlanningTrajetService.assignerVehicule(...)` doit refuser l'assignation si un trajet existant chevauche le créneau.
  - `PlanningTrajetService.validerPlanning()` ne doit pas valider un planning en conflit avec un autre trajet du même véhicule.
  - Le calcul de la fin de trajet doit utiliser `date_planification + duree_estimee`.
  - `VehiculeService.getVehiculesDisponibles()` doit intégrer la disponibilité réelle par créneau (pas uniquement un booléen statique).
  - `PlanningTrajetRepository.findByVehicule(...)` doit être utilisé pour contrôler les conflits de planning d'un véhicule.
  - Les mises à jour de statut véhicule (disponible/non disponible) doivent être cohérentes entre assignation, validation et fin théorique de trajet.
- Gestion des conflits horaires (anti-chevauchement):
  - Si un trajet démarre à `10:00` et dure `30 min`, le véhicule est occupé jusqu'à `10:30`.
  - Une réservation à `10:15` ne peut pas être assignée au même véhicule.
  - Une réservation à `10:30` peut être assignée (borne de fin incluse selon règle métier à confirmer).
- Prise en compte du temps réel de disponibilité:
  - Vérifier collision avec `date_arrivee + duree_estimee` des trajets déjà planifiés.
  - La vérification doit se faire avant validation de l'assignation automatique et manuelle.

## Données de test à injecter (assignation véhicules)

### Véhicules de test (diversifiés)

- `CT-TEST-001` - Diesel - 4 places
- `CT-TEST-002` - Essence - 4 places
- `CT-TEST-003` - Électrique - 6 places
- `CT-TEST-004` - Hybride - 8 places
- `CT-TEST-005` - Diesel - 8 places

Objectif:
- Ne pas avoir tous les trajets affectés au même véhicule.
- Vérifier arbitrage carburant + capacité + disponibilité horaire.

### Réservations de test (même date, heures proches)

- `R1` client A - 2 passagers - arrivée `10:00`
- `R2` client B - 3 passagers - arrivée `10:15`
- `R3` client C - 5 passagers - arrivée `10:20`
- `R4` client D - 7 passagers - arrivée `10:25`
- `R5` client E - 2 passagers - arrivée `10:30`
- `R6` client F - 4 passagers - arrivée `10:45`

Hypothèse de distance:
- Durée estimée entre 25 et 40 minutes selon trajet (non nulle pour tous).

## Résultats attendus (assignation)

### Résultats fonctionnels obligatoires

- `R1` et `R2` ne doivent jamais partager le même véhicule si `R1` est encore en cours à `10:15`.
- `R3` (5 passagers) ne doit pas être assignée à un véhicule 4 places.
- `R4` (7 passagers) doit être assignée uniquement à 8 places (`CT-TEST-004` ou `CT-TEST-005`).
- `R5` à `10:30` peut prendre un véhicule libéré à `10:30` (si règle borne incluse conservée).
- `R6` doit être assignée en respectant capacité + disponibilité horaire.

### Résultats techniques à vérifier en base

- `planning_trajet.vehicule_id` varié (pas 100% sur un seul véhicule).
- `planning_trajet.duree_estimee` renseignée pour toutes les lignes assignées.
- `planning_trajet.distance_estimee > 0` pour toutes les lignes assignées.
- Aucun chevauchement de créneau pour un même `vehicule_id`.

## Cas de tests à exécuter

### Cas 1 - Collision directe

- Créer un trajet à `10:00` avec durée `30 min` sur `CT-TEST-001`.
- Tenter assignation d'une réservation à `10:15` sur `CT-TEST-001`.
- Attendu: refus d'assignation (véhicule occupé).

### Cas 2 - Capacités limites

- Réservation 4 passagers -> autorisée sur 4, 6, 8 places.
- Réservation 5 passagers -> refus sur 4 places, autorisée sur 6/8.
- Réservation 7 passagers -> autorisée uniquement sur 8 places.

### Cas 3 - Priorité carburant sans casser la disponibilité

- Si Diesel disponible et compatible, il peut être priorisé.
- Si Diesel prioritaire mais en conflit horaire, choisir un autre carburant disponible.
- Attendu: la disponibilité horaire prime sur la préférence carburant.

### Cas 4 - Réaffectation après libération

- Une fois la fin théorique du trajet atteinte, le véhicule redevient assignable.
- Vérifier à `heure fin + 0 min` et `heure fin + 1 min`.
