-- =====================================================================
-- SPRINT 4-6 INTEGRATED TEST DATA
-- =====================================================================
-- Objectif: Données de test complètes pour valider Sprints 4, 5, et 6
-- - Sprint 4: Regroupement par temps d'attente (30 min max)
-- - Sprint 5: Priorité nombre minimum de trajets
-- - Sprint 6: Fractionnement des réservations + disponibilité horaire
-- =====================================================================

-- === CLEANUP: Supprimer les données de test antérieures ===
DELETE FROM planning_trajet_detail WHERE reservation_id IN (
    SELECT id FROM reservations WHERE nom LIKE 'SPRINT%'
);
DELETE FROM planning_trajet WHERE reservation_id IN (
    SELECT id FROM reservations WHERE nom LIKE 'SPRINT%'
);
DELETE FROM reservations WHERE nom LIKE 'SPRINT%';

-- =====================================================================
-- SECTION 1: SPRINT 4 - REGROUPEMENT PAR TEMPS D'ATTENTE (30 MIN MAX)
-- =====================================================================

INSERT INTO reservations (nom, email, date_arrivee, heure, nombre_personnes, hotel_id)
VALUES 
('SPRINT4_CAS1_RES1_Alice', 'alice.cas1@test.com', '2026-03-20', '08:00:00', 3, 1),
('SPRINT4_CAS1_RES2_Bob', 'bob.cas1@test.com', '2026-03-20', '08:15:00', 2, 1),
('SPRINT4_CAS2_RES1_Charlie', 'charlie.cas2@test.com', '2026-03-20', '09:00:00', 2, 1),
('SPRINT4_CAS2_RES2_Diana', 'diana.cas2@test.com', '2026-03-20', '09:45:00', 1, 1),
('SPRINT4_CAS3_RES1_Eve', 'eve.cas3@test.com', '2026-03-20', '10:00:00', 2, 1),
('SPRINT4_CAS3_RES2_Frank', 'frank.cas3@test.com', '2026-03-20', '10:10:00', 2, 1),
('SPRINT4_CAS3_RES3_Grace', 'grace.cas3@test.com', '2026-03-20', '10:20:00', 1, 1),
('SPRINT4_CAS4_RES1_Henry', 'henry.cas4@test.com', '2026-03-20', '11:00:00', 4, 1),
('SPRINT4_CAS4_RES2_Iris', 'iris.cas4@test.com', '2026-03-20', '11:20:00', 2, 1),
('SPRINT4_CAS5_RES1_Jack', 'jack.cas5@test.com', '2026-03-20', '12:00:00', 1, 1);

-- =====================================================================
-- SECTION 2: SPRINT 5 - PRIORITÉ NOMBRE MINIMUM DE TRAJETS
-- =====================================================================

INSERT INTO reservations (nom, email, date_arrivee, heure, nombre_personnes, hotel_id)
VALUES 
('SPRINT5_CAS5A_RES1_Karen', 'karen.cas5a@test.com', '2026-03-21', '08:00:00', 2, 1),
('SPRINT5_CAS5A_RES2_Liam', 'liam.cas5a@test.com', '2026-03-21', '08:05:00', 2, 1),
('SPRINT5_CAS5A_RES3_Mia', 'mia.cas5a@test.com', '2026-03-21', '08:10:00', 2, 1),
('SPRINT5_CAS5B_RES1_Noah', 'noah.cas5b@test.com', '2026-03-21', '09:00:00', 2, 1),
('SPRINT5_CAS5B_RES2_Olivia', 'olivia.cas5b@test.com', '2026-03-21', '09:10:00', 2, 1);

-- =====================================================================
-- SECTION 3: SPRINT 6 - FRACTIONNEMENT DES RÉSERVATIONS
-- =====================================================================

INSERT INTO reservations (nom, email, date_arrivee, heure, nombre_personnes, hotel_id)
VALUES 
('SPRINT6_CAS6A_RES1_Paul', 'paul.cas6a@test.com', '2026-03-22', '08:00:00', 5, 1),
('SPRINT6_CAS6B_RES1_Quinn', 'quinn.cas6b@test.com', '2026-03-22', '09:00:00', 6, 1),
('SPRINT6_CAS6C_RES1_Rachel', 'rachel.cas6c@test.com', '2026-03-22', '10:00:00', 7, 1),
('SPRINT6_CAS6D_RES1_Samuel', 'samuel.cas6d@test.com', '2026-03-22', '11:00:00', 5, 1),
('SPRINT6_CAS6D_RES2_Tina', 'tina.cas6d@test.com', '2026-03-22', '11:10:00', 1, 1),
('SPRINT6_CAS6E_RES1_Ulysse', 'ulysse.cas6e@test.com', '2026-03-22', '12:00:00', 3, 1),
('SPRINT6_CAS6E_RES2_Viola', 'viola.cas6e@test.com', '2026-03-22', '13:00:00', 2, 1);

-- =====================================================================
-- SECTION 4: CONFIGURATION VÉHICULES POUR SPRINT 6 (DISPONIBILITÉ)
-- =====================================================================

UPDATE vehicules SET 
    heure_disponible_debut = '08:00:00',
    heure_disponible_courante = '08:00:00'
WHERE id = 1;

UPDATE vehicules SET 
    heure_disponible_debut = '10:00:00',
    heure_disponible_courante = '10:00:00'
WHERE id = 2;

UPDATE vehicules SET 
    heure_disponible_debut = '12:00:00',
    heure_disponible_courante = '12:00:00'
WHERE id = 3;

-- =====================================================================
-- SECTION 5: VALIDATION ET STATISTIQUES
-- =====================================================================

SELECT 'Test data loaded successfully' as Status;

SELECT 
    CASE 
        WHEN nom LIKE 'SPRINT4%' THEN 'Sprint 4 - Temps d''attente'
        WHEN nom LIKE 'SPRINT5%' THEN 'Sprint 5 - Min trajets'
        WHEN nom LIKE 'SPRINT6%' THEN 'Sprint 6 - Fractionnement'
    END AS Test_Group,
    COUNT(*) AS Count
FROM reservations 
WHERE nom LIKE 'SPRINT%'
GROUP BY Test_Group
ORDER BY Test_Group;

-- =====================================================================
-- NOTES et CONFIGURATION
-- =====================================================================
--
-- SPRINT 4: Regroupement par temps d'attente (30 min max)
-- - CAS 4.1: RES1 (08:00, 3p) + RES2 (08:15, 2p) = groupable, écart 15 min
-- - CAS 4.2: RES1 (09:00, 2p) + RES2 (09:45, 1p) = pas groupable, écart 45 min
-- - CAS 4.3: RES1 (10:00, 2p) + RES2 (10:10, 2p) + RES3 (10:20, 1p) = cascadable
-- - CAS 4.4: RES1 (11:00, 4p) + RES2 (11:20, 2p) = groupable, total 6p > 5-seat
-- - CAS 4.5: RES1 (12:00, 1p) = isolé, pas de groupement possible
--
-- SPRINT 5: Priorité nombre minimum de trajets
-- - Configuration véhicules:
--   V1 (ID=1): 2 trajets (diesel/fioul)
--   V2 (ID=2): 1 trajet (essence)
--   V3 (ID=3): 0 trajet (essence) <- Devrait être préféré
-- - CAS 5A: 3 réservations, attendre assignation sur V3, V2, V1
-- - CAS 5B: 2 réservations avec égalité, tiebreaker diesel pour V1
--
-- SPRINT 6: Fractionnement des réservations
-- - CAS 6A: 5 personnes, V1 (4 places) -> split 4+1
-- - CAS 6B: 6 personnes -> cascading assignments
-- - CAS 6C: 7 personnes -> multiple splits
-- - CAS 6D: 5 personnes + 1 personne -> smart capacity selection
-- - CAS 6E: Disponibilité horaire (V1:08h, V2:10h, V3:12h)
--
-- PROCHAINES ÉTAPES:
-- 1. Exécuter: .\init-data.ps1 (charge ce fichier par défaut)
-- 2. Vérifier: SELECT COUNT(*) FROM reservations WHERE nom LIKE 'SPRINT%';
-- 3. Tester: Lancer planning generation, vérifier assignations
--
-- =====================================================================
