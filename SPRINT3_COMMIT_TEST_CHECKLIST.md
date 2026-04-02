# Sprint 3 - Checklist Tests et Commits
## Optimisation des Trajets Groupés - Distance Calcul Complet

---

## 🎯 Objectif Sprint 3

Corriger le calcul de distance en considérant le **trajet complet du véhicule** (tous les points de départ et d'arrivée) plutôt que de calculer la distance pour chaque réservation individuellement.

**Problème identifié:** Le système calculait `Position véhicule → Ramassage 1 → Ramassage 2 → Dépôt 1 → Dépôt 2` individuellement par réservation au lieu de calculer le trajet complet du groupe.

**Quote métier:** "le trajet sera constitué de l'ensemble des points de départ et d'arrivée... du groupe"

---

## ✅ Changements implémentés dans la branche

### 1️⃣ Backend - Service de Planification
**Fichier:** `src/main/java/service/PlanningTrajetService.java`

#### Ajout: `calculerTrajetOptimiseGroupe(vehiculeId, reservationsGroupe, planningByReservationId)`
```
Responsabilité:
  - Récupère la position initiale du véhicule via getDerniereLieuDuVehicule()
  - Extrait les points de départ/arrivée de TOUTES les réservations du groupe
  - Optimise l'ordre par proximité (ramassage le plus proche en premier)
  - Accumule la distance à travers tous les arrêts intermédiaires
  - Retourne la distance totale en km pour le groupe entier
```

#### Modification: `externaliserDetailAssignationVehicule(vehiculeId, reservationPivot)`
- Appel `calculerTrajetOptimiseGroupe()` **UNE FOIS** par groupe (avant boucle réservations)
- Application distance/durée **unifiée** à TOUTES les réservations du groupe
- Création détails avec métriques partagées (pas individuelles)

#### Format: `formatDureeForInterval(int minutes)`
- Retourne format standardisé: `HH:MM:SS`

---

### 2️⃣ Backend - Repository Véhicule
**Fichier:** `src/main/java/repository/VehiculeDeplacementHistoriqueRepository.java`

#### Ajout: `getDerniereLieuDuVehicule(vehiculeId)`
```java
SELECT lieu_id FROM vehicule_deplacement_historique 
WHERE vehicule_id = ? 
ORDER BY date_mouvement DESC 
LIMIT 1
```
- Récupère le **dernier lieu connu** du véhicule (historique global)
- Utilisé comme point de départ initial du trajet optimisé

---

### 3️⃣ Backend - Repository Réservations
**Fichier:** `src/main/java/repository/ReservationRepository.java`

#### Modification: `findNonAssigneesForView()`
- **Avant:** `WHERE r.id NOT IN (SELECT reservation_id FROM planning_trajet WHERE vehicule_id IS NOT NULL)` (subquery complexe)
- **Après:** `WHERE r.vehiculeId IS NULL` (vérification directe NULL, plus rapide)
- Change: `JOIN hotel h ON ...` → `LEFT JOIN hotel h ON ...` (gestion hôtels NULL)
- Ajoute: `DISTINCT` et tri `ORDER BY r.id` (évite doublons)

---

### 4️⃣ Backend - Contrôleur
**Fichier:** `src/main/java/controller/PlanningTrajetController.java`

#### Ajout: `calculerDureeEstimee(double distanceKm)`
```
Objectif: Recalculer durée basée sur distance totale groupe
  - Input: distance en km
  - Vitesse moyenne: 90 km/h (configurable: VITESSE_MOYENNE_KMH)
  - Output: Format HH:MM:SS
  
Fallback: Si paramètre non trouvé, utilise vitesse par défaut 90 km/h
```

#### Modification: `buildPlanningGroupes(List<PlanningTrajetView> plannings)`
```
Avant:  Durée définie UNE FOIS (première réservation du groupe) = CORRECT POUR DURÉE UNIQUE
Après:  Durée RECALCULÉE après accumulation de distance groupe = CORRECT POUR DISTANCE TOTALE

        for (PlanningTrajetGroupeView groupe : groupes.values()) {
            ...
            groupe.setPlacesLibres(...);
            // ⭐ CORRECTION: Recalculer durée en fonction distance totale du groupe
            groupe.setDureeEstimee(calculerDureeEstimee(groupe.getDistanceTotale()));
        }
```

---

### 5️⃣ Frontend - Page Assignation
**Fichier:** `src/main/webapp/views/planning/assignation.jsp`

#### Architecture Dual-Table
```
┌─────────────────────────────────────────────┐
│  SECTION 1: "Réservation Non Assignée"      │
│  ─ Affiche réservations individuelles        │
│  ─ Une ligne par réservation non-assignée    │
│  ─ Colonnes: ID, CLIENT, EMAIL, DATE, HEURE,│
│    PERSONNES, HÔTEL, STATUT                 │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│ SECTION 2: "Statut Planification Groupée"   │
│ ─ Affiche groupes de trajets                │
│ ─ Une ligne par (véhicule+date+heure)      │
│ ─ Colonnes: Véhicule, Date, Heure,         │
│   Réservations (chips), Passagers,          │
│   Capacité, Places libres, Départs (chips), │
│   Arrivées (chips), Distance, DURÉE, Fuel  │
└─────────────────────────────────────────────┘
```

#### Ajout: Taglib fmt
```jsp
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
```

#### Formatage table "Statut Planification Groupée"
```jsp
<!-- Distance: 2 décimales + unité -->
<fmt:formatNumber value="${groupe.distanceTotale}" 
                  maxFractionDigits="2" 
                  minFractionDigits="2" /> km

<!-- Durée: Validation + couleur -->
${groupe.dureeEstimee != null && !groupe.dureeEstimee.isEmpty() 
    ? groupe.dureeEstimee 
    : 'N/A'}
```

#### Améliorations UI
- Clients affichés en **chips** (tags colorés)
- Départs/Arrivées en **chips** pour meilleure lisibilité
- Compteur mis à jour:
  - **Avant:** `${fn:length(plannings)}` "Trajets assignés (une par client)"
  - **Après:** `${fn:length(planningGroupes)}` "Trajets groupés (véhicule + créneau)"

---

### 6️⃣ Frontend - Page Visualisation
**Fichier:** `src/main/webapp/views/planning/visualisation.jsp`

#### Ajout: Taglib fmt
```jsp
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
```

#### Formatage affichage détail
```jsp
<!-- Distance: 2 décimales + unité -->
<fmt:formatNumber value="${detail.distanceEstimee}" 
                  maxFractionDigits="2" 
                  minFractionDigits="2" /> km

<!-- Durée: Format HH:MM:SS avec couleur bleu -->
<span style="font-weight: 700; color: #0066cc;">
    ${detail.dureeEstimee != null && !detail.dureeEstimee.isEmpty() 
        ? detail.dureeEstimee 
        : 'N/A'}
</span>
```

#### Améliorations
- Une ligne par réservation (détails granulaires)
- Distance/Durée identiques aux groupes (cohérence totale)
- Méilleure lisibilité avec unités et formatage

---

## 🗄️ Structure de données - Changements

### Tables concernées
| Table | Rôle | Impact Sprint 3 |
|-------|------|-----------------|
| `planning_trajet` | Enregistrement trajet/réservation | Distance groupe sauvegardée |
| `planning_trajet_detail` | Détails assignation groupée | **NOUVEAU - Stockage distances groupées** |
| `vehicule_deplacement_historique` | Historique mouvements véhicule | Initiation position véhicule |
| `distances` | Matrice distances entre lieux | Calcul trajet optimisé |
| `parametres_configuration` | Paramètres système | `VITESSE_MOYENNE_KMH` pour durée |

### Champs critiques
```
planning_trajet.distance_estimee
  ├─ AVANT: Distance individuelle par réservation
  └─ APRÈS: Distance DU GROUPE (partagée entre réservations)

planning_trajet.duree_estimee
  ├─ AVANT: Durée d'une réservation
  └─ APRÈS: Durée DU GROUPE recalculée (identique pour toutes)

planning_trajet_detail.distance_estimee_km
  └─ Sauvegarde distance groupe pour audit

planning_trajet_detail.duree_estimee
  └─ Sauvegarde durée groupe pour audit
```

---

## 📋 Checklist de Tests

### Catégorie 1: Build & Déploiement
- [ ] `mvn clean package -DskipTests` réussit
- [ ] WAR généré sans erreur
- [ ] `docker compose restart app` redémarre sans erreur

### Catégorie 2: Calcul Distance Optimisé
- [ ] Distance = trajet complet (position véhicule → ramassages → dépôts)
- [ ] Sophie Leclerc + Client Groupe = **même distance** (groupe)
- [ ] Distance groupe > distance individuelle (avant correction)
- [ ] Aucune distance = 0 si multi-points

### Catégorie 3: Durée Recalculée
- [ ] Durée = distance_totale / vitesse_moyenne
- [ ] Format HH:MM:SS en base et affichage
- [ ] Durée identique pour toutes réservations du groupe
- [ ] assignation.jsp durée = visualisation.jsp durée

### Catégorie 4: Page Assignation - Section 1
- [ ] Sophie Leclerc visible (pas d'eclipse avec Client Groupe)
- [ ] Client Groupe visible (pas d'eclipse avec Sophie)
- [ ] Une ligne per réservation non-assignée
- [ ] Colonnes correctes: ID, CLIENT, EMAIL, DATE, HEURE, PERSONNES, HÔTEL, STATUT

### Catégorie 5: Page Assignation - Section 2
- [ ] Une seule ligne pour groupe (véhicule+date+heure)
- [ ] Distance: `45.00 km` (2 décimales)
- [ ] Durée: `00:30:00` (HH:MM:SS)
- [ ] Clients chips: "Sophie Leclerc(4p)", "Client Groupe Sprint3(2p)"
- [ ] Départs chips: "Aéroport Paris" (un seul, pas dupliqué)
- [ ] Arrivées chips: "Hotel Royal Palace", "Grand Hotel Central"
- [ ] Compteur: "N Trajets groupés (véhicule + créneau)"

### Catégorie 6: Page Visualisation
- [ ] Distance toutes réservations groupe: `45.00 km` (identique)
- [ ] Durée toutes réservations groupe: `00:30:00` (identique)
- [ ] Format 2 décimales + " km"
- [ ] Format HH:MM:SS pour durée

### Catégorie 7: Base de Données
- [ ] `planning_trajet.distance_estimee` = 45.0 (groupe Sophie ET Client Groupe)
- [ ] `planning_trajet.duree_estimee` = '00:30:00' (groupe Sophie ET Client Groupe)
- [ ] `planning_trajet_detail.distance_estimee_km` = 45.0 (groupe)
- [ ] `planning_trajet_detail.duree_estimee` = '00:30:00' (groupe)

### Catégorie 8: SQL Non-Assignées
- [ ] `WHERE vehiculeId IS NULL` retourne exactement les non-assignées
- [ ] Sophie visible avant assignation
- [ ] Client Groupe visible avant assignation
- [ ] Pas de doublon (DISTINCT fonctionne)

### Catégorie 9: Intégration Groupe 3+ réservations
- [ ] Distance accumulée: `Pos → R1_dep → R1_arr → R2_dep → R2_arr → R3_dep → R3_arr`
- [ ] Durée calculée une fois pour groupe
- [ ] Détails sauvegardés en `planning_trajet_detail`

### Catégorie 10: Génération Planning
- [ ] Cliquer "Générer Planning"
- [ ] Tous les groupes reçoivent un véhicule
- [ ] Distance et durée correctes
- [ ] Statut = PLANIFIE

### Catégorie 11: Validation Planning
- [ ] Cliquer "Valider Planning"
- [ ] Groupes assignés passent à VALIDE
- [ ] Groupes vides restent vides

### Catégorie 12: Filtrage
- [ ] Filtrer date: seuls groupes de cette date
- [ ] Filtrer heure: seuls groupes de cette heure
- [ ] Filtrer véhicule: seuls trajets du véhicule
- [ ] Réinitialiser: retour liste complète

### Catégorie 13: Non-Régression
- [ ] Frontoffice réservations fonctionne
- [ ] Autres pages planning inchangées
- [ ] Aucun doublon réservation
- [ ] Aucune perte de données

---

## 🔍 Cas de Test Critiques

### ✅ Cas 1 - Deux réservations, même groupe
```
INPUT:
  Réservation 1:
    - Nom: Sophie Leclerc
    - Passagers: 4
    - Date Arrivée: 15 juin 2026
    - Heure Arrivée: 09:00
    - Départ: Aéroport Paris-Charles de Gaulle
    - Arrivée: Hotel Royal Palace
  
  Réservation 2:
    - Nom: Client Groupe Sprint3
    - Passagers: 2
    - Date Arrivée: 15 juin 2026
    - Heure Arrivée: 09:00
    - Départ: Aéroport Paris-Charles de Gaulle
    - Arrivée: Grand Hotel Central

EXPECTED (Assignation - Section 2):
  ✓ Une seule ligne (véhicule+date+heure)
  ✓ Distance: 45.00 km
  ✓ Durée: 00:30:00
  ✓ Clients chips: 
    - "Sophie Leclerc(4p)"
    - "Client Groupe Sprint3(2p)"
  ✓ Départs chips: 
    - "Aéroport Paris" (un seul)
  ✓ Arrivées chips: 
    - "Hotel Royal Palace"
    - "Grand Hotel Central"

EXPECTED (Visualisation):
  ✓ Ligne 1 (Sophie):
    - Distance: 45.00 km
    - Durée: 00:30:00
  ✓ Ligne 2 (Client Groupe):
    - Distance: 45.00 km (identique!)
    - Durée: 00:30:00 (identique!)
```

### ✅ Cas 2 - Trois réservations, ordre optimisé
```
INPUT:
  R1: 3p, Gare → Hotel A
  R2: 2p, Gare → Hotel B
  R3: 1p, Gare → Hotel C
  Tous: 15 juin, 10:00

EXPECTED:
  ✓ Distance = trajets optimisés par proximité
  ✓ Durée = distance_total / 90 km/h
  ✓ Visualisation: R1, R2, R3 ont TOUS:
    - Distance = X.XX km (identique)
    - Durée = HH:MM:SS (identique)
```

### ✅ Cas 3 - Mélange assigné/non-assigné
```
INPUT:
  R1: Assignée (groupe A)
  R2: Non assignée
  R3: Assignée (groupe B)

EXPECTED (Assignation):
  Section 1 (Non-assignées):
    ✓ Affiche R2 uniquement
  
  Section 2 (Groupes):
    ✓ Affiche groupe A (R1)
    ✓ Affiche groupe B (R3)
    ✓ Ne montre pas R2 (non-assignée)

FLOW: Après assignation R2 → groupe C
  Section 1 (Non-assignées):
    ✓ R2 disparaît
  
  Section 2 (Groupes):
    ✓ Groupe C apparaît avec R2
```

---

## ✨ Critères d'Acceptation Sprint 3

### Calcul Distance
- ✅ Distance non-nulle si 2+ lieux distincts
- ✅ Distance = somme trajets intermédiaires (pas saut direct)
- ✅ Optimisation proximité appliquée

### Durée Estimée
- ✅ Recalculée pour groupe complet
- ✅ Identique pour TOUTES réservations du groupe
- ✅ Format HH:MM:SS standardisé

### Affichage Concordance
- ✅ assignation.jsp = visualisation.jsp (même valeurs)
- ✅ Distance formatée 2 décimales + " km"
- ✅ Durée formatée HH:MM:SS

### Absence Doublon
- ✅ Pas de doublon réservation même date/heure identique
- ✅ Une seule ligne par groupe (véhicule+date+heure)

### SQL Optimisation
- ✅ Non-assignées: `WHERE vehiculeId IS NULL` (pas subquery)
- ✅ Pas de doublon (DISTINCT + tri)

---

## 🐛 Checklist Issues Connues à Surveiller

- [ ] **Distance NULL/0** → Vérifier table `distances` peuplée
- [ ] **Durée différente assignation vs visualisation** → Recalcul `calculerDureeEstimee()` non appelé
- [ ] **Sophie disparaît** → SQL `findNonAssigneesForView()` défaillante
- [ ] **Deux lignes au lieu d'une** → Clé de groupage `buildPlanningGroupes()` incorrecte
- [ ] **Durée "00:00:00" ou NULL** → Paramètre `VITESSE_MOYENNE_KMH` manquant ou = 0
- [ ] **Distance groupe incohérente** → `calculerTrajetOptimiseGroupe()` non appelée

---

## 📊 Données de Test Sprint 3

### Réservations de Test
| ID | Client | Passagers | Date | Heure | Départ | Arrivée | Statut |
|----|--------|-----------|------|-------|--------|---------|--------|
| 1 | Sophie Leclerc | 4 | 2026-06-15 | 09:00 | Aéroport Paris | Hotel Royal Palace | À assigner |
| 2 | Client Groupe Sprint3 | 2 | 2026-06-15 | 09:00 | Aéroport Paris | Grand Hotel Central | À assigner |

### Véhicules Disponibles
- CT-001 (Diesel, 4 places)
- CT-002 (Essence, 4 places)
- CT-003 (Électrique, 6 places)
- CT-004 (Hybride, 8 places)
- CT-005 (Diesel, 8 places)

### Configuration Base
- `VITESSE_MOYENNE_KMH` = 90
- Distance Aéroport→Hotel Royal Palace = 25 km
- Distance Aéroport→Grand Hotel Central = 30 km
- Distance Hotel Royal Palace→Grand Hotel Central = 15 km
- **Trajet groupe:** 25 + 15 + 30 = **70 km** (via optimisation)

*Ou si données réelles = 45 km selon cas du système*

---

## 🚀 Procédure de Déploiement

### Étape 1: Build
```bash
mvn clean package -DskipTests
```

### Étape 2: Déployer
```bash
docker compose -f .\docker-compose.dev.yml up -d
```

### Étape 3: Vérifier
- [ ] Accéder `http://localhost:8080/assignation`
- [ ] Accéder `http://localhost:8080/visualisation`
- [ ] Comparer distance/durée entre les deux pages

### Étape 4: Tester Cas Critiques
- [ ] Cas 1 (duo groupe)
- [ ] Cas 2 (trio optimisé)
- [ ] Cas 3 (mélange)

### Étape 5: Commit
```bash
git add .
git commit -m "Sprint 3: Optimize group trajectory distance calculation - Complete trajet per group"
```

---

## 📌 Notes de Développement

### À Retenir
1. **Distance groupe ≠ Distance individuelle**
   - Groupe: Somme tous les trajets intermédiaires
   - Individuel: Direct point A → point B

2. **Durée est recalculée EN DERNIER**
   - Après accumulation distance groupe
   - Une fois par groupe (pas par réservation)

3. **Formatage cohérent PARTOUT**
   - Distance: 2 décimales + " km"
   - Durée: HH:MM:SS

4. **SQL optimisée**
   - Non-assignées: `WHERE vehiculeId IS NULL`
   - Plus rapide qu'une subquery NOT IN

5. **Dual-table architecture**
   - Section 1: Réservations individuelles
   - Section 2: Groupes optimisés
   - Chacun sa responsabilité

---

**Status:** ✅ Prêt pour pull request et validation
**Date:** 19 mars 2026
**Pipeline:** Compilation ✅ | Package ✅ | Tests manuels → À Faire
