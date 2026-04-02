-- ===========================================
-- SPRINT 4 – CORRECTION REGROUPEMENT TEMPS D'ATTENTE
-- Modification table planning_trajet_detail pour stocker les réservations groupées
-- et assurer une seule ligne par groupe
-- ===========================================

-- ===========================================
-- 1. AJOUTER COLONNES POUR TRACER GROUPEMENT PAR TEMPS D'ATTENTE
-- ===========================================

-- Colonne pour stocker les IDs des réservations groupées (JSON array ou CSV)
ALTER TABLE planning_trajet_detail 
    ADD COLUMN IF NOT EXISTS reservation_ids_groupees TEXT DEFAULT NULL,
    ADD COLUMN IF NOT EXISTS nombre_reservations_groupe INTEGER DEFAULT 1,
    ADD COLUMN IF NOT EXISTS temps_attente_groupe_minutes INTEGER DEFAULT 0,
    ADD COLUMN IF NOT EXISTS heure_depart_ajustee CHARACTER VARYING(8) DEFAULT NULL;

-- Index pour recherche rapide par groupe
CREATE INDEX IF NOT EXISTS idx_planning_trajet_detail_premiere_reservation 
    ON planning_trajet_detail(premiere_reservation_id);

CREATE INDEX IF NOT EXISTS idx_planning_trajet_detail_groupe 
    ON planning_trajet_detail(vehicule_id, date_arrivee, premiere_reservation_id);

-- ===========================================
-- 2. MAINTENIR STRUCTURE DE CLÉS UNIQUES
-- ===========================================

-- NOTER: Garder l'ancienne contrainte unique pour compatibilité des données existantes
-- La logique de regroupement sera gérée au niveau applicatif dans PlanningTrajetService
-- via grouperParTempsAttente() et externaliserDetailAssignationVehicule()
--
-- Les données FUTURES seront formatées avec :
-- - Une seule ligne par GROUPE (identifiée par premiere_reservation_id)
-- - Les réservations groupées listées dans reservation_ids_groupees

-- ===========================================
-- 3. AJOUTER COLONNE POUR TRACER HEURES DU GROUPE
-- ===========================================

-- Plage d'heures du groupe (ex: "08:00-08:15")
ALTER TABLE planning_trajet_detail 
    ADD COLUMN IF NOT EXISTS plage_heures_groupe TEXT DEFAULT NULL;

ALTER TABLE planning_trajet_detail
    ALTER COLUMN plage_heures_groupe TYPE TEXT;

-- ===========================================
-- 4. DOCUMENTATION MÉTIER
-- ===========================================

-- NOTES MÉTIER :
-- Une seule ligne par GROUPE de réservations groupables par temps d'attente
-- 
-- Champs clés :
-- - premiere_reservation_id : ID de la PREMIÈRE réservation du groupe (chef)
-- - reservation_id : ID de la PREMIÈRE réservation (même valeur que premiere_reservation_id)
-- - reservation_ids_groupees : LIST d'IDs des toutes les réservations du groupe (JSON ou CSV)
-- - nombre_reservations_groupe : Nombre de réservations dans le groupe
-- - temps_attente_groupe_minutes : Temps d'attente total entre première et dernière
-- - heure_depart_ajustee : Heure de départ = heure de la DERNIÈRE réservation
-- - plage_heures_groupe : Affichage lisible (ex: "08:00-08:15")
--
-- Logique d'insertion :
-- Lors d'une assignation de groupe :
-- 1. Vérifier si les réservations peuvent être groupées par temps d'attente (écart ≤ TEMPS_ATTENTE_MAX_MINUTES)
-- 2. Si oui : créer UNE SEULE ligne avec premiere_reservation_id = ID de la plus ancienne
-- 3. Remplir reservation_ids_groupees avec tous les IDs du groupe
-- 4. Mettre à jour nombre_reservations_groupe et temps_attente_groupe_minutes
-- 5. Mettre à jour heure_depart_ajustee = heure de la dernière réservation
--
-- Affichage :
-- - Une ligne représente UN GROUPE COMPLET
-- - Afficher : "Réservation 1 (2p) + Réservation 2 (3p) = 5 personnes"
-- - Montrer la plage : "08:00 → 08:15 (attente: 15 min)"
-- - Heure départ ajustée : 08:15 (attendre la dernière arrivée)
