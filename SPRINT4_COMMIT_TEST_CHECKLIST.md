# Sprint 4 - Checklist Tests et Commits
## Regroupement des Réservations avec Temps d'Attente

---

## 🎯 Objectif Sprint 4

Ajouter la gestion du temps d'attente entre réservations lors du regroupement de véhicules. Les réservations arrivant dans la marge définie (≤ TEMPS_ATTENTE_MAX_MINUTES) sont assignées au même véhicule avec ajustement automatique de l'heure de départ.

**Problème identifié:** Avant, le système assignait une ligne par réservation même si elles étaient groupables par temps d'attente. Exemple: Deux réservations à 08:00 et 08:15 (écart 15 min ≤ 30 min) produisaient 2 lignes au lieu de 1.

**Solution métier:** 
- Regrouper réservations avec écart ≤ temps d'attente max
- Créer UNE SEULE ligne par groupe
- Énumérer toutes les réservations du groupe
- Ajuster heure de départ à la dernière réservation du groupe

---

## ✅ Changements implémentés dans la branche

### 1️⃣ Backend - Service de Planification (Logique Métier)
**Fichier:** `src/main/java/service/PlanningTrajetService.java`

#### Ajout: `grouperParTempsAttente(List<Reservation> reservations, int maxMinutes)`
```
Responsabilité:
  - Prend une liste de réservations
  - Les trie par heure d'arrivée
  - Crée des groupes: écart entre réservations consécutives ≤ maxMinutes
  - Retourne Map<Integer, List<Reservation>> (clé=groupe index, valeur=réservations)

Logique:
  1. Trier réservations par heure
  2. Comparer chaque paire: écart = heure_n+1 - heure_n
  3. Si écart ≤ maxMinutes → même groupe
  4. Si écart > maxMinutes → groupe suivant
```

#### Ajout: `calculerTempsAttente(String heure1, String heure2)`
```
Responsabilité:
  - Parse deux heures format HH:MM
  - Calcule la différence en minutes
  - Retourne int (minutes)

Format de retour: minutes entre deux heures
  Exemple: 08:00 et 08:15 → 15 minutes
```

#### Ajout: `peutEtreGroupee(Reservation res1, Reservation res2, int maxMinutes)`
```
Responsabilité:
  - Teste si deux réservations peuvent être groupées
  - Condition: |heure_res2 - heure_res1| ≤ maxMinutes
  - Condition: même date d'arrivée
  
Retourne: boolean (true si groupable)
```

#### Ajout: `calculerHeureDepart(List<Reservation> groupe)`
```
Responsabilité:
  - Retourne l'heure de la DERNIÈRE réservation du groupe
  - C'est l'heure de départ du véhicule (après avoir ramassé tous les clients)
  
Exemple: groupe [08:00, 08:15, 08:20] → heure départ = 08:20
```

#### Ajout: `calculerTempsAttenteGroupe(List<Reservation> groupe)`
```
Responsabilité:
  - Calcule le temps d'attente total du groupe
  - = heure_dernière - heure_première
  
Exemple: groupe [08:00, 08:15] → attente = 15 minutes
```

#### Ajout: `obtenirTempsAttentMaxConfig()`
```
Responsabilité:
  - Récupère le paramètre TEMPS_ATTENTE_MAX_MINUTES de la configuration
  - Valeur par défaut: 30 minutes
  - Utilisé pour décider si réservations sont groupables
```

#### Modification: `externaliserDetailAssignationVehicule(vehiculeId, reservationPivot)`
**Avant (Sprint 3):**
- Boucle chaque réservation → crée 1 ligne par réservation
- Distance/Durée partagées mais création multiple ligne

**Après (Sprint 4):**  CHANGEMENT CRITIQUE
```java
// Étape 1: Récupérer toutes les réservations du véhicule pour la date
List<Reservation> reservationsVehiculeDate = getPlanningsByVehicule(...)

// Étape 2: GROUPER PAR TEMPS D'ATTENTE (NEW)
int tempsAttentMaxMinutes = obtenirTempsAttentMaxConfig();
Map<Integer, List<Reservation>> groupesParTempsAttente = grouperParTempsAttente(
  reservationsVehiculeDate,
  tempsAttentMaxMinutes    // Par défaut 30 min
);

// Étape 3: Exporter chaque GROUPE en UNE SEULE LIGNE (NEW)
for (Map.Entry<Integer, List<Reservation>> entryGroupe : groupesParTempsAttente) {
  List<Reservation> reservationsGroupeTriees = entryGroupe.getValue();
  
  // Calculer métriques du GROUPE
  String tempsAttenteGroupeMinutes = calculerTempsAttente(...);
  String heureDeprtAjustee = calculerHeureDepart(...);
  String plageHeuresGroupe = "heure_première → heure_dernière (attente: X min)";
  
  // Énumérer toutes les réservations du groupe
  String reservationClient = "Client1(Xp) + Client2(Yp) + ...";
  
  // Créer UNE SEULE ligne d'assignation
  PlanningAssignationDetail detail = new PlanningAssignationDetail();
  detail.setReservationClient(reservationClient);
  detail.setTempsAttenteGroupeMinutes(tempsAttenteGroupeMinutes);
  detail.setHeureDeprtAjustee(heureDeprtAjustee);
  detail.setPlageHeuresGroupe(plageHeuresGroupe);
  detail.setReservationIdsGroupees("7,8,9");  // CSV des IDs
  detail.setNombreReservationsGroupe(3);       // Count
  ...
}
```

---

### 2️⃣ Backend - Modèle Assignation
**Fichier:** `src/main/java/model/PlanningAssignationDetail.java`

#### Ajout: 5 nouveaux champs
```java
private String reservationIdsGroupees;        // CSV: "7,8,9"
private int nombreReservationsGroupe;         // Count: 3
private int tempsAttenteGroupeMinutes;        // minutes: 15
private String heureDeprtAjustee;             // "08:20"
private String plageHeuresGroupe;             // "08:00 → 08:20 (attente: 20 min)"
```

#### Ajout: Getters/Setters pour 5 champs
- `getReservationIdsGroupees()` / `setReservationIdsGroupees(String)`
- `getNombreReservationsGroupe()` / `setNombreReservationsGroupe(int)`
- `getTempsAttenteGroupeMinutes()` / `setTempsAttenteGroupeMinutes(int)`
- `getHeureDeprtAjustee()` / `setHeureDeprtAjustee(String)`
- `getPlageHeuresGroupe()` / `setPlageHeuresGroupe(String)`

---

### 3️⃣ Backend - Repository Assignation
**Fichier:** `src/main/java/repository/PlanningAssignationDetailRepository.java`

#### Modification: `upsert()` method
**Avant:** 15 paramètres (15 colonnes originales)
**Après:** 20 paramètres (15 + 5 Sprint 4 columns)

```java
INSERT INTO planning_trajet_detail (
  vehicule_id, date_arrivee, heure_arrivee, reservation_id, 
  premiere_reservation_id, reservation_client, nombre_passagers_total,
  capacite_vehicule, places_libres, distance_estimee_km, duree_estimee,
  premier_point_depart, dernier_point_arrivee, points_depart, points_arrivee,
  // === Sprint 4 Columns ===
  reservation_ids_groupees, nombre_reservations_groupe,
  temps_attente_groupe_minutes, heure_depart_ajustee, plage_heures_groupe
) VALUES (?, ?, ?, ..., ?)
ON CONFLICT ... UPDATE
  reservation_ids_groupees = ?,
  nombre_reservations_groupe = ?,
  temps_attente_groupe_minutes = ?,
  heure_depart_ajustee = ?,
  plage_heures_groupe = ?
```

#### Modification: `findAll()` SELECT
- Ajoute 5 nouveaux colonnes à la projection
- Retourne complète avec Sprint 4 metadata

#### Modification: `findByFilters()` SELECT
- Idem, ajoute 5 colonnes

#### Modification: `mapResultSet()`
```java
detail.setReservationIdsGroupees(rs.getString("reservation_ids_groupees"));
detail.setNombreReservationsGroupe(rs.getInt("nombre_reservations_groupe"));
detail.setTempsAttenteGroupeMinutes(rs.getInt("temps_attente_groupe_minutes"));
detail.setHeureDeprtAjustee(rs.getString("heure_depart_ajustee"));
detail.setPlageHeuresGroupe(rs.getString("plage_heures_groupe"));
```

---

### 4️⃣ Backend - DTO View Model
**Fichier:** `src/main/java/dto/PlanningTrajetGroupeView.java`

#### Ajout: 5 nouveaux champs
```java
private String reservationIdsGroupees;
private int nombreReservationsGroupe;
private int tempsAttenteGroupeMinutes;
private String heureDeprtAjustee;
private String plageHeuresGroupe;
```

#### Ajout: 5 Getters/Setters pour affichage JSP

---

### 5️⃣ Database - Migration Schema
**Fichier:** `database/init/08-sprint4-correction-regroupement.sql` *(créé)*

#### Ajout: 5 colonnes à `planning_trajet_detail`
```sql
ALTER TABLE planning_trajet_detail ADD COLUMN (
  reservation_ids_groupees VARCHAR(500),         -- CSV des IDs
  nombre_reservations_groupe INT DEFAULT 1,      -- Nombre de réservations
  temps_attente_groupe_minutes INT DEFAULT 0,    -- Temps d'attente en min
  heure_depart_ajustee VARCHAR(5),               -- HH:MM ajustée
  plage_heures_groupe VARCHAR(100)               -- "08:00 → 08:20 (..."
);

CREATE INDEX idx_planning_trajet_detail_premiere_reservation 
  ON planning_trajet_detail(premiere_reservation_id);

CREATE INDEX idx_planning_trajet_detail_groupe 
  ON planning_trajet_detail(vehicule_id, date_arrivee, heure_arrivee);
```

#### Documentation SQL commentée
- Explique la règle métier: UNE ligne par groupe
- Explique les colonnes et leur usage

---

### 6️⃣ Database - Test Data
**Fichier:** `database/init/07-sprint4-temps-attente-test-data.sql` *(créé)*

#### Configuration paramètre
```sql
INSERT INTO parametres_configuration (cle, valeur) 
VALUES ('TEMPS_ATTENTE_MAX_MINUTES', '30');
```

#### 10 réservations de test couvrant 5 cas métier
| CAS | Description | Résultat attendu |
|-----|-------------|------------------|
| CAS 1 | 2 rés. groupables (08:00, 08:15, écart 15 ≤ 30) | 1 groupe |
| CAS 2 | 2 rés. NON groupables (09:00, 09:45, écart 45 > 30) | 2 groupes |
| CAS 3 | 3 rés. groupables (10:00, 10:10, 10:20, écart max 20) | 1 groupe |
| CAS 4 | 2 rés. groupables + capacité respectée (11:00, 11:20, 4p+2p ≤ 5lv) | 1 groupe |
| CAS 5 | 1 rés. isolée (12:00, TA=0) | 1 groupe seule |

---

## 🗄️ Structure de données - Changements Sprint 4

### Table `planning_trajet_detail` - AVANT vs APRÈS

**AVANT (Sprint 3 - 15 colonnes):**
```
vehicule_id, date_arrivee, heure_arrivee, reservation_id,
premiere_reservation_id, reservation_client, nombre_passagers_total,
capacite_vehicule, places_libres, distance_estimee_km, duree_estimee,
premier_point_depart, dernier_point_arrivee, points_depart, points_arrivee
```

**APRÈS (Sprint 4 - 20 colonnes):**
```
[15 colonnes originales] +
reservation_ids_groupees,           ← CSV "7,8,9"
nombre_reservations_groupe,         ← int 3
temps_attente_groupe_minutes,       ← int 15
heure_depart_ajustee,              ← "08:20"
plage_heures_groupe                ← "08:00 → 08:20 (attente: 20 min)"
```

---

## 📋 Tâches Sprint 4 - État Actuel

### Backend - Logique Métier ✅ COMPLÉTÉ
- [x] Implémenter `grouperParTempsAttente()`
- [x] Implémenter `calculerTempsAttente()`
- [x] Implémenter `peutEtreGroupee()`
- [x] Implémenter `calculerHeureDepart()`
- [x] Implémenter `calculerTempsAttenteGroupe()`
- [x] Implémenter `obtenirTempsAttentMaxConfig()`
- [x] Refactoriser `externaliserDetailAssignationVehicule()` pour créer 1 ligne/groupe
- [x] Énumérer réservations du groupe en `reservation_client`
- [x] Stocker `reservation_ids_groupees` (CSV)
- [x] Stocker `nombreReservationsGroupe` (count)
- [x] Stocker `tempsAttenteGroupeMinutes` (dur totalDd)
- [x] Stocker `heureDeprtAjustee` (dernière réservation)
- [x] Stocker `plageHeuresGroupe` (affichage)

### Backend - Données ✅ COMPLÉTÉ
- [x] Migration 08-sprint4-correction-regroupement.sql
- [x] Test data 07-sprint4-temps-attente-test-data.sql
- [x] 10 réservations couvrant 5 cas métier
- [x] Paramètre TEMPS_ATTENTE_MAX_MINUTES = 30

### Backend - Repository ✅ COMPLÉTÉ
- [x] `PlanningAssignationDetail` model + 5 champs
- [x] `PlanningAssignationDetailRepository.upsert()` → 20 paramètres
- [x] `findAll()` avec 5 nouvelles colonnes
- [x] `findByFilters()` avec 5 nouvelles colonnes
- [x] `mapResultSet()` populate 5 champs

### Backend - DTO ✅ COMPLÉTÉ
- [x] `PlanningTrajetGroupeView` + 5 champs

### Backend - Compilation ✅ RÉUSSI
- [x] `mvn clean package -DskipTests` → SUCCESS

### Frontend - Page Assignation (assignation.jsp) ⏳ **À FAIRE**
- [ ] Ajouter colonnes Sprint 4:
  - [ ] "Temps d'attente" avec `wait-time-badge` styling
  - [ ] "Heure départ" avec `departure-time` styling
  - [ ] "Nombre clients groupés" (nombre_reservations_groupe)
- [ ] Afficher `plage_heures_groupe` en tooltip
- [ ] Afficher `tempsAttenteGroupeMinutes` en valeur numérique + "min"
- [ ] Afficher `heureDeprtAjustee` en format HH:MM
- [ ] Styling: `.wait-time-badge`, `.departure-time`

### Frontend - Page Visualisation (visualisation.jsp) ⏳ **À FAIRE**
- [ ] Ajouter colonnes Sprint 4 (idem assignation.jsp)
- [ ] Afficher données pour chaque réservation du groupe
- [ ] Synchroniser affichage avec assignation.jsp

### Frontend - CSS ⏳ **À FAIRE**
- [ ] `.wait-time-badge` styling (couleur basée sur durée: vert ≤15, orange 15-30, rouge >30)
- [ ] `.departure-time` styling (bleu, gras)
- [ ] `.grouped-indicator` badge
- [ ] `.text-ellipsis-3lines` pour texte long
- [ ] Responsive design (mobile/tablet/desktop)
- [ ] `.hide-mobile`, `.hide-tablet`, `.hide-desktop` classes

### Frontend - Component (sidebar) ⏳ **À FAIRE**
- [ ] Créer ou mettre à jour `sidebar.jsp`
- [ ] Toggle hamburger (mobile)
- [ ] Filtres: date, heure, vehicule
- [ ] Responsive layout

### Frontend - Testing ⏳ **À FAIRE**
- [ ] Tester CAS 1 (1 groupe avec 2 réservations)
- [ ] Tester CAS 2 (2 groupes séparés)
- [ ] Tester CAS 3 (1 groupe avec 3 réservations)
- [ ] Vérifier affichage assignation.jsp = visualisation.jsp
- [ ] Vérifier responsive sur mobile/tablet/desktop
- [ ] Vérifier tooltips temps d'attente

---

## 🔍 Cas de Test Critiques Sprint 4

### ✅ Cas 1 - Deux réservations groupables par temps d'attente
```
INPUT:
  Réservation 1:
    - ID: 1
    - Nom: Client A
    - Passagers: 2
    - Heure Arrivée: 08:00
  
  Réservation 2:
    - ID: 2
    - Nom: Client B
    - Passagers: 3
    - Heure Arrivée: 08:15
  
  Écart: 15 minutes ≤ 30 minutes (TEMPS_ATTENTE_MAX) → GROUPABLE ✅

EXPECTED:
  Assignation.jsp Section 2:
    ✓ Une seule ligne (véhicule+date+heure)
    ✓ Temps d'attente: "15 min" avec badge
    ✓ Heure départ: "08:15"
    ✓ Réservations client: "Client A(2p) + Client B(3p)"
    ✓ Nombre clients groupe: 2
  
  DB planning_trajet_detail:
    ✓ nombre_reservations_groupe = 2
    ✓ temps_attente_groupe_minutes = 15
    ✓ heure_depart_ajustee = "08:15"
    ✓ plage_heures_groupe = "08:00 → 08:15 (attente: 15 min)"
    ✓ reservation_ids_groupees = "1,2"
```

### ❌ Cas 2 - Deux réservations NON groupables (écart > 30 min)
```
INPUT:
  Réservation 1:
    - ID: 3
    - Heure Arrivée: 09:00
  
  Réservation 2:
    - ID: 4
    - Heure Arrivée: 09:45
  
  Écart: 45 minutes > 30 minutes → NON GROUPABLE ❌

EXPECTED:
  Assignation.jsp Section 2:
    ✓ DEUX lignes différentes
    ✓ Ligne 1: Temps attente = N/A (seule)
    ✓ Ligne 2: Temps attente = N/A (seule)
  
  DB planning_trajet_detail:
    ✓ 2 lignes distinctes
    ✓ nombre_reservations_groupe = 1 (chacune)
    ✓ temps_attente_groupe_minutes = 0 (chacune)
```

### ✅ Cas 3 - Trois réservations groupables en cascade
```
INPUT:
  Réservation 1: 10:00
  Réservation 2: 10:10 (écart 10 min ≤ 30) → groupe réservation 1 ✓
  Réservation 3: 10:20 (écart 20 min de rés 2 ≤ 30) → groupe réservations 1,2 ✓

EXPECTED:
  Assignation.jsp:
    ✓ Une seule ligne
    ✓ Temps attente: "20 min" (10:00 → 10:20)
    ✓ Heure départ: "10:20"
    ✓ Réservations: "Client1 + Client2 + Client3"
    ✓ Nombre groupe: 3
```

### ✅ Cas 4 - Réservations groupables respectant la capacité
```
INPUT:
  Réservation 1: 2 passagers, 11:00
  Réservation 2: 3 passagers, 11:20 (écart 20 ≤ 30)
  Véhicule: 5 places
  
  Total: 2+3 = 5 passagers ≤ 5 places ✅ RESPECTE CAPACITÉ

EXPECTED:
  ✓ Une seule ligne
  ✓ Nombre passagers total: 5
  ✓ Places libres: 0
  ✓ Statut: "VALIDE"
```

### ✅ Cas 5 - Seule réservation (TA=0)
```
INPUT:
  Réservation 1: 12:00 (seule, pas d'autre résa même jour/heure)

EXPECTED:
  ✓ Une ligne solitaire
  ✓ Temps attente: "N/A" ou "0 min"
  ✓ nombre_reservations_groupe = 1
  ✓ plage_heures_groupe: pas de flèche, juste "12:00"
```

---

## 📋 Checklist Tests Détaillée

### Catégorie 1: Compilation & Déploiement
- [x] `mvn clean package -DskipTests` réussit
- [x] WAR généré sans erreur
- [ ] `docker compose up -d --build` redémarre sans erreur
- [ ] DB tables/colonnes crées via migrations

### Catégorie 2: Regroupement par Temps d'Attente
- [ ] CAS 1: 2 réservations groupables (15 min écart ≤ 30) → **1 ligne**
- [ ] CAS 2: 2 réservations NON groupables (45 min écart > 30) → **2 lignes**
- [ ] CAS 3: 3 réservations groupables en cascade → **1 ligne**
- [ ] Ordre réservations: triées par heure d'arrivée ✓
- [ ] Pas de doublons ligne même groupe ✓

### Catégorie 3: Énumération Réservations Groupe
- [ ] Format: "Client1(Xp) + Client2(Yp) + ..."
- [ ] Nombres passagers corrects
- [ ] Pas d'eclipse (tous les clients visibles)
- [ ] Ordre: ordre chronologique arrivée

### Catégorie 4: Temps d'Attente Calculé
- [ ] Temps attente = heure_dernière - heure_première
- [ ] CAS 1 [08:00, 08:15]: TA = 15 minutes ✓
- [ ] CAS 3 [10:00, 10:10, 10:20]: TA = 20 minutes ✓
- [ ] CAS 5 (seule): TA = 0 ✓
- [ ] Format: entier en minutes (int)

### Catégorie 5: Heure Départ Ajustée
- [ ] Heure départ = heure DERNIER réservation du groupe
- [ ] Format: HH:MM (VARCHAR(5))
- [ ] CAS 1 [08:00, 08:15]: départ = 08:15 ✓
- [ ] CAS 3 [10:00, 10:10, 10:20]: départ = 10:20 ✓

### Catégorie 6: Plage Heures Groupe
- [ ] Format: "HH:MM → HH:MM (attente: X min)"
- [ ] CAS 1: "08:00 → 08:15 (attente: 15 min)"
- [ ] Utilisable en tooltip
- [ ] Lisible et complet

### Catégorie 7: Réservation IDs Groupées
- [ ] Format CSV: "1,2,3"
- [ ] Tous les IDs du groupe présents
- [ ] Pas de doublon
- [ ] Pour audit/traçabilité

### Catégorie 8: Nombre Réservations Groupe
- [ ] Count des réservations du groupe
- [ ] CAS 1: 2
- [ ] CAS 3: 3
- [ ] CAS 5: 1 (seule)

### Catégorie 9: Affichage Assignation.jsp
- [ ] Colonne "Temps d'attente" visible
- [ ] Colonne "Heure départ" visible
- [ ] Styling badge temps d'attente ✓
- [ ] Styling heure départ ✓
- [ ] Responsif (mobile/tablet/desktop)

### Catégorie 10: Affichage Visualisation.jsp
- [ ] Colonnes Sprint 4 synchronisées
- [ ] Données identiques aux deux pages
- [ ] Temps d'attente = assignation ✓
- [ ] Heure départ = assignation ✓

### Catégorie 11: Base de Données
- [ ] Colonne `reservation_ids_groupees` exists ✓
- [ ] Colonne `nombre_reservations_groupe` exists ✓
- [ ] Colonne `temps_attente_groupe_minutes` exists ✓
- [ ] Colonne `heure_depart_ajustee` exists ✓
- [ ] Colonne `plage_heures_groupe` exists ✓
- [ ] Données peuplées correctement
- [ ] Index de performance OK

### Catégorie 12: Génération Planning
- [ ] Cliquer "Générer Planning" fonctionne
- [ ] Champs Sprint 4 sauvegardés en DB
- [ ] Pas d'erreur SQL
- [ ] Statut groupe = PLANIFIE

### Catégorie 13: Filtrage
- [ ] Filtrer par date fonctionne
- [ ] Filtrer par heure fonctionne
- [ ] Filtrer par véhicule fonctionne
- [ ] Groupes affichent temps d'attente correct

### Catégorie 14: Non-Régression
- [ ] Frontoffice réservations toujours OK
- [ ] Sprint 3 regroupement toujours OK
- [ ] Aucune perte de données
- [ ] Assignation véhicule toujours cohérente
- [ ] Distance groupe toujours OK

---

## 🚀 Procédure Déploiement

### Étape 1: Validation Git
```bash
git log --oneline -5
# Voir commits Sprint 4:
# - 434ac07 (perf)
# - 578c98d (test data)
# - 98eb723 (feature)
```

### Étape 2: Build
```bash
mvn clean package -DskipTests
```

### Étape 3: Deploy Docker
```bash
docker compose -f docker-compose.dev.yml up -d --build
```

### Étape 4: Vérifier DB
```bash
# Tables et colonnes created
SELECT column_name 
FROM information_schema.columns 
WHERE table_name = 'planning_trajet_detail'
ORDER BY ordinal_position;
```

### Étape 5: Tester UI
- [ ] Accéder `http://localhost:8080/planning/assignation`
- [ ] Accéder `http://localhost:8080/planning/visualisation`
- [ ] Vérifier CAS 1: 1 ligne avec 2 réservations
- [ ] Vérifier temps d'attente = 15 min
- [ ] Vérifier heure départ = 08:15

### Étape 6: Tester API
```bash
# GET /api/planning/assignation
# Vérifier réponse contient champs Sprint 4
```

### Étape 7: Commit Final
```bash
git add .
git commit -m "Sprint 4: Wait time grouping - Frontend implementation (assignation + visualisation JSP + CSS)"
```

---

## 📊 Résumé État Tâches - Croisant avec TODO.md

### ✅ COMPLÉTÉ (Commits appliqués)
| Tâche | TODO.md | Commit | Status |
|-------|---------|--------|--------|
| Backend métier (regroupement TA) | Sprint 4 - Refactorisation moteur | 98eb723 | ✅ |
| Test data (5 CAS) | Sprint 4 - Données test | 578c98d | ✅ |
| Migration DB (5 colonnes) | Sprint 4 - Données | 434ac07 | ✅ |
| Model PlanningAssignationDetail | Sprint 4 - Backend | Impliqué | ✅ |
| Repository upsert (20 params) | Sprint 4 - Backend | Impliqué | ✅ |
| DTO PlanningTrajetGroupeView | Sprint 4 - Backend | Impliqué | ✅ |
| PlanningTrajetService methods (7) | Sprint 4 - Refactorisation | 98eb723 | ✅ |

### ⏳ EN COURS (À faire)
| Tâche | TODO.md | Détails | Priority |
|-------|---------|---------|----------|
| Frontend assignation.jsp | Sprint 4 - Interface | Ajouter 2 colonnes Sprint 4 | HIGH |
| Frontend visualisation.jsp | Sprint 4 - Interface | Synchro colonnes Sprint 4 | HIGH |
| CSS styling (.wait-time-badge) | Sprint 4 - Design | Badges color-coded | MEDIUM |
| CSS responsive (.hide-*) | Sprint 4 - Design | Mobile/tablet/desktop | MEDIUM |
| Sidebar component (optionnel) | Sprint 4 - UX | Toggle hamburger | LOW |

### ❌ NON COMMENCÉ (Sprint 5+)
| Tâche | Sprint | Notes |
|-------|--------|-------|
| Priorité min trajets | Sprint 5 | Dépend Sprint 4 ✓ |
| Fractionnement réservations | Sprint 6 | Dépend Sprint 4 + 5 |

---

## 📝 Notes Développement

### À Retenir Sprint 4
1. **UNE ligne par GROUPE, pas par réservation**
   - Avant: Réservation A → ligne 1, Réservation B → ligne 2
   - Après: Groupe(A+B) → ligne 1 (enumérées ensemble)

2. **Tiempo d'attente est la clé de groupage**
   - Écart ≤ TEMPS_ATTENTE_MAX_MINUTES → même groupe
   - Écart > → groupe séparé

3. **Énumération client unique**
   - "Client A(2p) + Client B(3p)" → visibilité totale
   - Pas d'eclipse

4. **Heure départ = heure DERNIÈRE réservation**
   - Logique: véhicule départ APRÈS ramasser tous les clients
   - HH:MM format exact

5. **Sprint 4 colonnes en AUDIT/TRAÇABILITÉ**
   - reservation_ids_groupees: qui sont les clients du groupe
   - nombre_reservations_groupe: combien
   - temps_attente_groupe_minutes: délai
   - heure_depart_ajustee: quand départ
   - plage_heures_groupe: affichage lisible

---

## 🐛 Checklist Issues Connues

- [ ] **1 ligne au lieu de 2** → `grouperParTempsAttente()` non appelée
- [ ] **Réservations non énumérées** → boucle dans le groupe manquante
- [ ] **TA = null/0** → `calculerTempsAttente()` défaillante
- [ ] **Heure départ incorrecte** → pas de dernier() ou mauvaise heure
- [ ] **Colonnes DB vides** → `mapResultSet()` non implémenté
- [ ] **Affichage JSP manquant** → colonnes non ajoutées au tableau HTML

---

**Status Global Sprint 4:** ✅ Backend & DB | ⏳ Frontend (Assignation, Visualisation, CSS)
**Date:** 19 mars 2026
**Pipeline:** Compilation ✅ | Package ✅ | DB Migration ✅ | UI Tests → À Faire
