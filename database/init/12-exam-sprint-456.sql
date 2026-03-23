
TRUNCATE TABLE planning_trajet_assignation_historique CASCADE;
TRUNCATE TABLE vehicule_deplacement_historique CASCADE;
TRUNCATE TABLE planning_trajet_detail CASCADE;
TRUNCATE TABLE planning_trajet CASCADE;
TRUNCATE TABLE reservations CASCADE;
TRUNCATE TABLE clients CASCADE;
TRUNCATE TABLE vehicules CASCADE;
TRUNCATE TABLE lieux CASCADE;
TRUNCATE TABLE type_clients CASCADE;
TRUNCATE TABLE sexes CASCADE;
TRUNCATE TABLE hotel CASCADE;
TRUNCATE TABLE parametres_configuration CASCADE;

-- =====================================================================
-- EXAM DATASET - SCHÉMA COMPLET (Sprints 4, 5, 6)
-- Hypothèse: un seul aéroport pour toutes les réservations
-- Date des réservations: aujourd'hui (CURRENT_DATE)
-- =====================================================================

-- Types de base nécessaires
INSERT INTO sexes (libelle, description) VALUES
	('Homme', 'Sexe masculin'),
	('Femme', 'Sexe feminin'),
	('Autre', 'Autre')
ON CONFLICT DO NOTHING;

INSERT INTO type_clients (libelle, description) VALUES
	('Standard', 'Client standard'),
	('Premium', 'Client premium'),
	('VIP', 'Client VIP')
ON CONFLICT DO NOTHING;

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

-- Paramètres de configuration demandés
INSERT INTO parametres_configuration (cle, valeur, type_valeur, description) VALUES
	('TEMPS_ATTENTE_MAX_MINUTES', '30', 'int', 'Temps d attente max pour regroupement'),
	('VITESSE_MOYENNE_KMH', '50', 'int', 'Vitesse moyenne de calcul des durees'),
	('DISTANCE_AUTONOMIE_ESSENCE_KM', '500', 'int', 'Autonomie essence'),
	('DISTANCE_AUTONOMIE_DIESEL_KM', '700', 'int', 'Autonomie diesel')
ON CONFLICT (cle) DO UPDATE SET
	valeur = EXCLUDED.valeur,
	type_valeur = EXCLUDED.type_valeur,
	description = EXCLUDED.description,
	updated_at = NOW();

-- Hôtels
INSERT INTO hotel (nom, adresse, ville, pays, nombre_etoiles, description, is_active) VALUES
	('HOTEL_1', '10 Rue Hotel One', 'Paris', 'France', 4, 'Hotel destination 1', true),
	('HOTEL_2', '20 Rue Hotel Two', 'Paris', 'France', 4, 'Hotel destination 2', true);

-- Lieux: 1 seul aéroport + lieux hôtel
WITH 
tl_hotel AS (SELECT id AS id_type FROM type_lieu WHERE libelle = 'Hôtel' LIMIT 1),
tl_airport AS (SELECT id AS id_type FROM type_lieu WHERE libelle = 'Aéroport' LIMIT 1)
INSERT INTO lieux (nom, type_lieu_id, adresse, ville, pays, latitude, longitude, description, hotel_id, is_active)
SELECT 'AEROPORT_UNIQUE', tl_airport.id_type, '1 Airport Road', 'Paris', 'France', 49.0097, 2.5479, 'Unique aeroport pour toutes les reservations', NULL, true
FROM tl_airport
UNION ALL
SELECT 'LIEU_HOTEL_1', tl_hotel.id_type, h.adresse, h.ville, h.pays, 48.8566, 2.3522, 'Lieu hotel 1', h.id, true
FROM hotel h, tl_hotel
WHERE h.nom = 'HOTEL_1'
UNION ALL
SELECT 'LIEU_HOTEL_2', tl_hotel.id_type, h.adresse, h.ville, h.pays, 48.8666, 2.3622, 'Lieu hotel 2', h.id, true
FROM hotel h, tl_hotel
WHERE h.nom = 'HOTEL_2';

-- Distances demandées (dans les 2 sens)
WITH
ap AS (SELECT id FROM lieux WHERE nom = 'AEROPORT_UNIQUE' LIMIT 1),
h1 AS (SELECT id FROM lieux WHERE nom = 'LIEU_HOTEL_1' LIMIT 1),
h2 AS (SELECT id FROM lieux WHERE nom = 'LIEU_HOTEL_2' LIMIT 1)
INSERT INTO distances (lieu_depart_id, lieu_arrivee_id, distance_km)
SELECT ap.id, h1.id, 90 FROM ap, h1
UNION ALL SELECT h1.id, ap.id, 90 FROM ap, h1
UNION ALL SELECT ap.id, h2.id, 35 FROM ap, h2
UNION ALL SELECT h2.id, ap.id, 35 FROM ap, h2
UNION ALL SELECT h1.id, h2.id, 60 FROM h1, h2
UNION ALL SELECT h2.id, h1.id, 60 FROM h1, h2
ON CONFLICT (lieu_depart_id, lieu_arrivee_id) DO UPDATE SET
	distance_km = EXCLUDED.distance_km,
	updated_at = NOW();

-- Véhicules demandés
WITH
diesel AS (SELECT id FROM type_carburant WHERE libelle = 'Diesel' LIMIT 1),
essence AS (SELECT id FROM type_carburant WHERE libelle = 'Essence' LIMIT 1)
INSERT INTO vehicules (
	immatriculation, marque, modele, annee, type_carburant_id, capacite_passagers, is_available,
	heure_disponible_debut, heure_disponible_courante
)
SELECT 'EXM-VEH-001', 'Renault', 'Trafic', 2023, diesel.id, 5, true, TIME '09:00:00', TIME '09:00:00' FROM diesel
UNION ALL
SELECT 'EXM-VEH-002', 'Peugeot', 'Expert', 2022, essence.id, 5, true, TIME '09:00:00', TIME '09:00:00' FROM essence
UNION ALL
SELECT 'EXM-VEH-003', 'Mercedes', 'Sprinter', 2024, diesel.id, 12, true, TIME '08:00:00', TIME '08:00:00' FROM diesel
UNION ALL
SELECT 'EXM-VEH-004', 'Iveco', 'Daily', 2021, diesel.id, 9, true, TIME '09:00:00', TIME '09:00:00' FROM diesel
UNION ALL
SELECT 'EXM-VEH-005', 'Ford', 'Transit', 2023, essence.id, 12, true, TIME '13:00:00', TIME '13:00:00' FROM essence;

-- Réservations demandées (1 seul aéroport en lieu de départ)
WITH
ap AS (SELECT id FROM lieux WHERE nom = 'AEROPORT_UNIQUE' LIMIT 1),
h1 AS (SELECT h.id AS hotel_id, l.id AS lieu_id
	   FROM hotel h JOIN lieux l ON l.hotel_id = h.id
	   WHERE h.nom = 'HOTEL_1' LIMIT 1),
h2 AS (SELECT h.id AS hotel_id, l.id AS lieu_id
	   FROM hotel h JOIN lieux l ON l.hotel_id = h.id
	   WHERE h.nom = 'HOTEL_2' LIMIT 1)
INSERT INTO reservations (
	nom, email, date_arrivee, heure, nombre_personnes, hotel_id,
	lieu_depart_id, lieu_arrivee_id, is_confirmed
)
SELECT 'FULL_CLIENT_1', 'client1@exam.test', (CURRENT_DATE + TIME '09:00')::timestamptz, '09:00', 7, h1.hotel_id, ap.id, h1.lieu_id, true
FROM ap, h1
UNION ALL
SELECT 'FULL_CLIENT_2', 'client2@exam.test', (CURRENT_DATE + TIME '08:00')::timestamptz, '08:00', 20, h2.hotel_id, ap.id, h2.lieu_id, true
FROM ap, h2
UNION ALL
SELECT 'FULL_CLIENT_3', 'client3@exam.test', (CURRENT_DATE + TIME '09:10')::timestamptz, '09:10', 3, h1.hotel_id, ap.id, h1.lieu_id, true
FROM ap, h1
UNION ALL
SELECT 'FULL_CLIENT_4', 'client4@exam.test', (CURRENT_DATE + TIME '09:15')::timestamptz, '09:15', 10, h1.hotel_id, ap.id, h1.lieu_id, true
FROM ap, h1
UNION ALL
SELECT 'FULL_CLIENT_5', 'client5@exam.test', (CURRENT_DATE + TIME '09:20')::timestamptz, '09:20', 5, h1.hotel_id, ap.id, h1.lieu_id, true
FROM ap, h1
UNION ALL
SELECT 'FULL_CLIENT_6', 'client6@exam.test', (CURRENT_DATE + TIME '13:30')::timestamptz, '13:30', 12, h1.hotel_id, ap.id, h1.lieu_id, true
FROM ap, h1;

-- Vérifications rapides
SELECT 'RESERVATIONS_FULL' AS metric, COUNT(*) AS total
FROM reservations
WHERE nom LIKE 'FULL_CLIENT_%';

SELECT 'AEROPORT_UNIQUE_USED' AS metric, COUNT(DISTINCT lieu_depart_id) AS nb_aeroports_differents
FROM reservations
WHERE nom LIKE 'FULL_CLIENT_%';


