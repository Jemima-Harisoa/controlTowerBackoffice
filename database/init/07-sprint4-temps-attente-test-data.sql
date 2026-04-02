-- ===========================================
-- SPRINT 4 – TEMPS D'ATTENTE & REGROUPEMENT
-- Données de test pour le calcul du temps d'attente
-- et le regroupement de réservations
--
-- Cette migration ajoute:
-- 1. Colonne 'observation' à la table reservations
-- 2. Paramètre de configuration TEMPS_ATTENTE_MAX_MINUTES (30 min en dur)
-- 3. Réservations de test (5 cas métier)
-- ===========================================

-- ===========================================
-- 1. AMÉLIORATION TABLE RESERVATIONS
-- ===========================================

-- Ajouter la colonne 'observation' pour les notes de test/métier
ALTER TABLE reservations 
    ADD COLUMN IF NOT EXISTS observation TEXT DEFAULT NULL;

CREATE INDEX IF NOT EXISTS idx_reservations_observation ON reservations(observation);

-- ===========================================
-- 2. PARAMÈTRE DE CONFIGURATION
-- ===========================================

-- Ajouter le paramètre temps d'attente max (EN DUR: 30 minutes)
INSERT INTO parametres_configuration (cle, valeur, type_valeur, description) VALUES 
    ('TEMPS_ATTENTE_MAX_MINUTES', '30', 'int', 'Temps d''attente maximum pour regroupement de reservations en minutes')
ON CONFLICT (cle) DO NOTHING;

-- ===========================================
-- 3. DONNÉES DE TEST - RÉSERVATIONS
-- ===========================================

-- Cas 1: Deux réservations groupables (écart 15 min ≤ max 30)
BEGIN;
INSERT INTO reservations (nom, email, date_arrivee, heure, nombre_personnes, hotel_id, lieu_depart_id, lieu_arrivee_id, observation)
VALUES 
    ('TEST_CAS1_R1_GROUPABLE', 'test.cas1.r1@hotel.test', '2026-04-15 08:00:00', '08:00', 2, 
     (SELECT id FROM hotel LIMIT 1),
     (SELECT id FROM lieux WHERE nom LIKE '%Charles de Gaulle%' LIMIT 1),
     (SELECT id FROM lieux WHERE nom LIKE '%Nice%' AND nom LIKE '%Aéroport%' LIMIT 1),
     'CAS 1 - Réservation 1/2 groupable (08:00, écart 15 min)'),
    ('TEST_CAS1_R2_GROUPABLE', 'test.cas1.r2@hotel.test', '2026-04-15 08:15:00', '08:15', 3, 
     (SELECT id FROM hotel LIMIT 1),
     (SELECT id FROM lieux WHERE nom LIKE '%Nice%' AND nom LIKE '%Aéroport%' LIMIT 1),
     (SELECT id FROM lieux WHERE nom LIKE '%Charles de Gaulle%' LIMIT 1),
     'CAS 1 - Réservation 2/2 groupable (08:15, écart 15 min)');

-- Cas 2: Deux réservations non-groupables (écart 45 min > max 30)
INSERT INTO reservations (nom, email, date_arrivee, heure, nombre_personnes, hotel_id, lieu_depart_id, lieu_arrivee_id, observation)
VALUES 
    ('TEST_CAS2_R1_NONGROUPABLE', 'test.cas2.r1@hotel.test', '2026-04-16 09:00:00', '09:00', 1, 
     (SELECT id FROM hotel LIMIT 1),
     (SELECT id FROM lieux WHERE nom LIKE '%Charles de Gaulle%' LIMIT 1),
     (SELECT id FROM lieux WHERE nom LIKE '%Nice%' AND nom LIKE '%Aéroport%' LIMIT 1),
     'CAS 2 - Réservation 1/2 non-groupable (09:00, écart > 30 min)'),
    ('TEST_CAS2_R2_NONGROUPABLE', 'test.cas2.r2@hotel.test', '2026-04-16 09:45:00', '09:45', 4, 
     (SELECT id FROM hotel LIMIT 1),
     (SELECT id FROM lieux WHERE nom LIKE '%Nice%' AND nom LIKE '%Aéroport%' LIMIT 1),
     (SELECT id FROM lieux WHERE nom LIKE '%Charles de Gaulle%' LIMIT 1),
     'CAS 2 - Réservation 2/2 non-groupable (09:45, écart 45 min > max 30)');

-- Cas 3: Trois réservations groupées (heure_depart = max heure_arrivee = 10:20)
INSERT INTO reservations (nom, email, date_arrivee, heure, nombre_personnes, hotel_id, lieu_depart_id, lieu_arrivee_id, observation)
VALUES 
    ('TEST_CAS3_R1_GROUPE', 'test.cas3.r1@hotel.test', '2026-04-17 10:00:00', '10:00', 2, 
     (SELECT id FROM hotel LIMIT 1),
     (SELECT id FROM lieux WHERE nom LIKE '%Charles de Gaulle%' LIMIT 1),
     (SELECT id FROM lieux WHERE nom LIKE '%Nice%' AND nom LIKE '%Aéroport%' LIMIT 1),
     'CAS 3 - Réservation 1/3 groupe (10:00)'),
    ('TEST_CAS3_R2_GROUPE', 'test.cas3.r2@hotel.test', '2026-04-17 10:10:00', '10:10', 1, 
     (SELECT id FROM hotel LIMIT 1),
     (SELECT id FROM lieux WHERE nom LIKE '%Nice%' AND nom LIKE '%Aéroport%' LIMIT 1),
     (SELECT id FROM lieux WHERE nom LIKE '%Charles de Gaulle%' LIMIT 1),
     'CAS 3 - Réservation 2/3 groupe (10:10)'),
    ('TEST_CAS3_R3_GROUPE', 'test.cas3.r3@hotel.test', '2026-04-17 10:20:00', '10:20', 3, 
     (SELECT id FROM hotel LIMIT 1),
     (SELECT id FROM lieux WHERE nom LIKE '%Charles de Gaulle%' LIMIT 1),
     (SELECT id FROM lieux WHERE nom LIKE '%Nice%' AND nom LIKE '%Aéroport%' LIMIT 1),
     'CAS 3 - Réservation 3/3 groupe (10:20) → DERNIÈRE, heure_depart = 10:20');

-- Cas 4: Respect règles existantes (capacité 4 places < véhicule 5 places)
INSERT INTO reservations (nom, email, date_arrivee, heure, nombre_personnes, hotel_id, lieu_depart_id, lieu_arrivee_id, observation)
VALUES 
    ('TEST_CAS4_R1_CAPACITE', 'test.cas4.r1@hotel.test', '2026-04-18 11:00:00', '11:00', 2, 
     (SELECT id FROM hotel LIMIT 1),
     (SELECT id FROM lieux WHERE nom LIKE '%Charles de Gaulle%' LIMIT 1),
     (SELECT id FROM lieux WHERE nom LIKE '%Nice%' AND nom LIKE '%Aéroport%' LIMIT 1),
     'CAS 4 - Réservation 1/2 groupe (11:00, 2 places)'),
    ('TEST_CAS4_R2_CAPACITE', 'test.cas4.r2@hotel.test', '2026-04-18 11:20:00', '11:20', 2, 
     (SELECT id FROM hotel LIMIT 1),
     (SELECT id FROM lieux WHERE nom LIKE '%Charles de Gaulle%' LIMIT 1),
     (SELECT id FROM lieux WHERE nom LIKE '%Nice%' AND nom LIKE '%Aéroport%' LIMIT 1),
     'CAS 4 - Réservation 2/2 groupe (11:20, 2 places) → Total 4 places (respecte capacité 5)');

-- Cas 5: Une seule réservation (TA = 0)
INSERT INTO reservations (nom, email, date_arrivee, heure, nombre_personnes, hotel_id, lieu_depart_id, lieu_arrivee_id, observation)
VALUES 
    ('TEST_CAS5_SEULE', 'test.cas5.seule@hotel.test', '2026-04-19 12:00:00', '12:00', 5, 
     (SELECT id FROM hotel LIMIT 1),
     (SELECT id FROM lieux WHERE nom LIKE '%Charles de Gaulle%' LIMIT 1),
     (SELECT id FROM lieux WHERE nom LIKE '%Nice%' AND nom LIKE '%Aéroport%' LIMIT 1),
     'CAS 5 - Cas limite: réservation unique (TA = 0, groupe à 1 élément)');
COMMIT;


-- ===========================================
-- 4. VÉRIFICATION DES DONNÉES INSÉRÉES
-- ===========================================

-- Afficher les réservations de test créées
SELECT 
    r.id,
    r.nom,
    r.date_arrivee,
    r.heure,
    r.nombre_personnes,
    r.observation
FROM reservations r
WHERE r.nom LIKE 'TEST_%'
ORDER BY r.date_arrivee, r.heure;

-- Afficher le paramètre de configuration temps d'attente
SELECT 
    cle,
    valeur,
    type_valeur,
    description
FROM parametres_configuration
WHERE cle = 'TEMPS_ATTENTE_MAX_MINUTES';

-- ===========================================
-- 5. VALIDATION DE COHÉRENCE
-- ===========================================

-- Vérifier que les lieux existent
SELECT COUNT(*) as nb_lieux FROM lieux WHERE nom LIKE '%Charles de Gaulle%' OR nom LIKE '%Nice%' AND nom LIKE '%Aéroport%';

-- Vérifier que la colonne observation existe
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'reservations' AND column_name = 'observation';

-- ===========================================
-- FIN SCRIPT SPRINT 4 - DONNÉES DE TEST
-- ===========================================

-- STRUCTURE CRÉÉE/MODIFIÉE:
-- 1. ✅ Nouvelle colonne reservations.observation (TEXT)
-- 2. ✅ Paramètre TEMPS_ATTENTE_MAX_MINUTES = 30 (int)

-- CAS DE TEST IMPLÉMENTÉS :
-- Cas 1 : Deux réservations groupables (écart 15 min ≤ max 30)
--   - TEST_CAS1_R1_GROUPABLE : 2026-04-15 08:00 (2 personnes)
--   - TEST_CAS1_R2_GROUPABLE : 2026-04-15 08:15 (3 personnes)
--   → GROUPE 1 : durée attente = 15 min

-- Cas 2 : Deux réservations non-groupables (écart 45 min > max 30)
--   - TEST_CAS2_R1_NONGROUPABLE : 2026-04-16 09:00 (1 personne)
--   - TEST_CAS2_R2_NONGROUPABLE : 2026-04-16 09:45 (4 personnes)
--   → GROUPE 1 + GROUPE 2 : groupement impossible

-- Cas 3 : Trois réservations groupées (heure_depart = max heure_arrivee = 10:20)
--   - TEST_CAS3_R1_GROUPE : 2026-04-17 10:00 (2 personnes)
--   - TEST_CAS3_R2_GROUPE : 2026-04-17 10:10 (1 personne)
--   - TEST_CAS3_R3_GROUPE : 2026-04-17 10:20 (3 personnes)
--   → GROUPE UNIQUE : heure_depart = 10:20, durée attente = 20 min

-- Cas 4 : Respect des règles (capacité 4 places < véhicule 5 places)
--   - TEST_CAS4_R1_CAPACITE : 2026-04-18 11:00 (2 personnes)
--   - TEST_CAS4_R2_CAPACITE : 2026-04-18 11:20 (2 personnes)
--   → GROUPE UNIQUE : 4 places utilisées ≤ capacité 5

-- Cas 5 : Cas limite (une réservation unique, TA = 0)
--   - TEST_CAS5_SEULE : 2026-04-19 12:00 (5 personnes)
--   → GROUPE À 1 ÉLÉMENT : durée attente = 0 min

-- VALIDATIONS MÉTIER SPRINT 4:
-- ✅ calculerTempsAttente(heure1, heure2) → int (minutes)
-- ✅ peutEtreGroupee(res1, res2, maxMinutes) → boolean
-- ✅ grouperParTempsAttente(reservations, maxMinutes) → Map<Integer, List<Reservation>>
-- ✅ calculerHeureDepart(groupe) → String (last reservation heure)
-- ✅ calculerTempsAttenteGroupe(groupe) → int (min-max écart)
-- ✅ adapterPlanningGroupe(groupe, heureDepart) → void (logging)
-- ✅ obtenirTempsAttentMaxConfig() → int (default 30)

-- STRUCTURE DE DONNÉES COHÉRENTE:
-- • Table reservations : id, nom, email, date_arrivee, heure, nombre_personnes, hotel_id, 
--                       lieu_depart_id, lieu_arrivee_id, vehicule_id, observation, 
--                       is_confirmed, created_at, updated_at
-- • Table parametres_configuration : id, cle, valeur, type_valeur, description, 
--                                    effective_date, created_at, updated_at
-- • Table lieux : id, nom, type_lieu_id, adresse, ville, pays, latitude, longitude, 
--                 description, hotel_id, is_active, created_at, updated_at
-- • Table hotel : id, nom, adresse, ville, pays, nombre_etoiles, description, 
--                 is_active, created_at, updated_at

-- DÉPENDANCES EXTERNES:
-- ✓ Sprints 1-3 doivent être exécutés en premier
-- ✓ Lieux (aéroports) doivent être créés dans Sprint 2
-- ✓ Hôtels doivent exister dans Sprint 1
