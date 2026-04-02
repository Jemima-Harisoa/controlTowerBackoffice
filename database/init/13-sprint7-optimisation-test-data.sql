-- =====================================================================
-- SPRINT 7 - OPTIMISATION AVANCEE - TEST DATA DEDIE
-- =====================================================================
-- Objectif: jeu de donnees pour etudier les cas metier Sprint 7:
-- 1) departs groupes (synchronisation sur la derniere reservation du groupe)
-- 2) regroupement des non assignes vers le prochain creneau utile
-- 3) fractionnement d'une reservation (optimisation du reliquat)
-- 4) priorite aux non assignes avant remplissage residuel
--
-- Date de test fixe: 2026-04-02
-- =====================================================================

TRUNCATE TABLE planning_trajet_assignation_historique CASCADE;
TRUNCATE TABLE vehicule_deplacement_historique CASCADE;
TRUNCATE TABLE planning_trajet_detail CASCADE;
TRUNCATE TABLE planning_trajet CASCADE;
DELETE FROM reservations WHERE nom LIKE 'S7_CLIENT_%';
DELETE FROM vehicules WHERE immatriculation LIKE 'S7-VEH-%';
DELETE FROM lieux WHERE nom IN ('S7_AEROPORT_UNIQUE', 'S7_LIEU_HOTEL_1', 'S7_LIEU_HOTEL_2');
DELETE FROM hotel WHERE nom IN ('S7_HOTEL_1', 'S7_HOTEL_2');

-- Types de reference
INSERT INTO type_carburant (libelle, description) VALUES
    ('Diesel', 'Carburant diesel'),
    ('Essence', 'Carburant essence')
ON CONFLICT (libelle) DO NOTHING;

INSERT INTO type_lieu (libelle, description) VALUES
    ('Hôtel', 'Hotel partenaire'),
    ('Aéroport', 'Aeroport')
ON CONFLICT (libelle) DO NOTHING;

INSERT INTO status_trajet (libelle, description) VALUES
    ('PLANIFIE', 'Trajet planifie'),
    ('EN_COURS', 'Trajet en cours'),
    ('TERMINE', 'Trajet termine'),
    ('ANNULE', 'Trajet annule')
ON CONFLICT (libelle) DO NOTHING;

-- Parametres metier Sprint 7
INSERT INTO parametres_configuration (cle, valeur, type_valeur, description) VALUES
    ('TEMPS_ATTENTE_MAX_MINUTES', '30', 'int', 'Temps d attente max pour regroupement'),
    ('VITESSE_MOYENNE_KMH', '50', 'int', 'Vitesse moyenne de calcul des durees')
ON CONFLICT (cle) DO UPDATE SET
    valeur = EXCLUDED.valeur,
    type_valeur = EXCLUDED.type_valeur,
    description = EXCLUDED.description,
    updated_at = NOW();

-- Hotels et lieux dedies Sprint 7
INSERT INTO hotel (nom, adresse, ville, pays, nombre_etoiles, description, is_active) VALUES
    ('S7_HOTEL_1', '10 Rue Sprint7 H1', 'Paris', 'France', 4, 'Destination Sprint7 H1', true),
    ('S7_HOTEL_2', '20 Rue Sprint7 H2', 'Paris', 'France', 4, 'Destination Sprint7 H2', true)
ON CONFLICT DO NOTHING;

WITH
tl_hotel AS (SELECT id AS type_id FROM type_lieu WHERE libelle = 'Hôtel' LIMIT 1),
tl_airport AS (SELECT id AS type_id FROM type_lieu WHERE libelle = 'Aéroport' LIMIT 1),
h1 AS (SELECT id AS hotel_id FROM hotel WHERE nom = 'S7_HOTEL_1' LIMIT 1),
h2 AS (SELECT id AS hotel_id FROM hotel WHERE nom = 'S7_HOTEL_2' LIMIT 1)
INSERT INTO lieux (nom, type_lieu_id, adresse, ville, pays, latitude, longitude, description, hotel_id, is_active)
SELECT 'S7_AEROPORT_UNIQUE', tl_airport.type_id, '1 Sprint7 Airport Road', 'Paris', 'France', 49.0097, 2.5479, 'Aeroport unique sprint7', NULL, true
FROM tl_airport
UNION ALL
SELECT 'S7_LIEU_HOTEL_1', tl_hotel.type_id, '10 Rue Sprint7 H1', 'Paris', 'France', 48.8566, 2.3522, 'Lieu hotel sprint7 1', h1.hotel_id, true
FROM tl_hotel, h1
UNION ALL
SELECT 'S7_LIEU_HOTEL_2', tl_hotel.type_id, '20 Rue Sprint7 H2', 'Paris', 'France', 48.8666, 2.3622, 'Lieu hotel sprint7 2', h2.hotel_id, true
FROM tl_hotel, h2
ON CONFLICT DO NOTHING;

-- Distances controlees pour calcul de duree:
-- H1: 40km aller => 48 min aller, 96 min mission aller/retour
-- H2: 20km aller => 24 min aller, 48 min mission aller/retour
WITH
ap AS (SELECT id FROM lieux WHERE nom = 'S7_AEROPORT_UNIQUE' LIMIT 1),
h1 AS (SELECT id FROM lieux WHERE nom = 'S7_LIEU_HOTEL_1' LIMIT 1),
h2 AS (SELECT id FROM lieux WHERE nom = 'S7_LIEU_HOTEL_2' LIMIT 1)
INSERT INTO distances (lieu_depart_id, lieu_arrivee_id, distance_km)
SELECT ap.id, h1.id, 40 FROM ap, h1
UNION ALL SELECT h1.id, ap.id, 40 FROM ap, h1
UNION ALL SELECT ap.id, h2.id, 20 FROM ap, h2
UNION ALL SELECT h2.id, ap.id, 20 FROM ap, h2
UNION ALL SELECT h1.id, h2.id, 18 FROM h1, h2
UNION ALL SELECT h2.id, h1.id, 18 FROM h1, h2
ON CONFLICT (lieu_depart_id, lieu_arrivee_id) DO UPDATE SET
    distance_km = EXCLUDED.distance_km,
    updated_at = NOW();

-- Flotte dediee Sprint 7
WITH
diesel AS (SELECT id FROM type_carburant WHERE libelle = 'Diesel' LIMIT 1),
essence AS (SELECT id FROM type_carburant WHERE libelle = 'Essence' LIMIT 1)
INSERT INTO vehicules (
    immatriculation, marque, modele, annee, type_carburant_id, capacite_passagers, is_available,
    heure_disponible_debut, heure_disponible_courante
)
SELECT 'S7-VEH-001', 'Renault', 'Master', 2023, diesel.id, 8, true, TIME '08:00:00', TIME '08:00:00' FROM diesel
UNION ALL
SELECT 'S7-VEH-002', 'Peugeot', 'Expert', 2022, essence.id, 5, true, TIME '09:00:00', TIME '09:00:00' FROM essence
UNION ALL
SELECT 'S7-VEH-003', 'Mercedes', 'Sprinter', 2024, diesel.id, 12, true, TIME '13:00:00', TIME '13:00:00' FROM diesel
ON CONFLICT (immatriculation) DO NOTHING;

-- Reservations Sprint 7 (date fixe)
WITH
ap AS (SELECT id FROM lieux WHERE nom = 'S7_AEROPORT_UNIQUE' LIMIT 1),
h1 AS (
    SELECT h.id AS hotel_id, l.id AS lieu_id
    FROM hotel h JOIN lieux l ON l.hotel_id = h.id
    WHERE h.nom = 'S7_HOTEL_1'
    LIMIT 1
),
h2 AS (
    SELECT h.id AS hotel_id, l.id AS lieu_id
    FROM hotel h JOIN lieux l ON l.hotel_id = h.id
    WHERE h.nom = 'S7_HOTEL_2'
    LIMIT 1
)
INSERT INTO reservations (
    nom, email, date_arrivee, heure, nombre_personnes, hotel_id,
    lieu_depart_id, lieu_arrivee_id, is_confirmed
)
SELECT 'S7_CLIENT_A', 's7.a@test.com', CAST('2026-04-02 08:00:00+00' AS timestamptz), '08:00', 6, h1.hotel_id, ap.id, h1.lieu_id, true FROM ap, h1
UNION ALL
SELECT 'S7_CLIENT_B', 's7.b@test.com', CAST('2026-04-02 08:10:00+00' AS timestamptz), '08:10', 2, h1.hotel_id, ap.id, h1.lieu_id, true FROM ap, h1
UNION ALL
SELECT 'S7_CLIENT_C', 's7.c@test.com', CAST('2026-04-02 09:00:00+00' AS timestamptz), '09:00', 7, h2.hotel_id, ap.id, h2.lieu_id, true FROM ap, h2
UNION ALL
SELECT 'S7_CLIENT_D', 's7.d@test.com', CAST('2026-04-02 09:15:00+00' AS timestamptz), '09:15', 3, h2.hotel_id, ap.id, h2.lieu_id, true FROM ap, h2
UNION ALL
SELECT 'S7_CLIENT_E', 's7.e@test.com', CAST('2026-04-02 09:50:00+00' AS timestamptz), '09:50', 4, h2.hotel_id, ap.id, h2.lieu_id, true FROM ap, h2
UNION ALL
SELECT 'S7_CLIENT_F', 's7.f@test.com', CAST('2026-04-02 13:10:00+00' AS timestamptz), '13:10', 10, h1.hotel_id, ap.id, h1.lieu_id, true FROM ap, h1
UNION ALL
SELECT 'S7_CLIENT_G', 's7.g@test.com', CAST('2026-04-02 13:20:00+00' AS timestamptz), '13:20', 2, h1.hotel_id, ap.id, h1.lieu_id, true FROM ap, h1;

-- Controle rapide
SELECT 'S7_RESERVATIONS' AS metric, COUNT(*) AS total
FROM reservations
WHERE nom LIKE 'S7_CLIENT_%';
