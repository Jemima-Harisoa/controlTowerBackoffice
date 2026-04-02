-- =========================================================================================
-- SCRIPT: NETTOYAGE + INSERTION DES DONNÉES (adapte a la structure actuelle)
-- Date: 02-04-2026
-- Base cible: PostgreSQL
-- =========================================================================================

-- =========================================================================================
-- ETAPE 1: NETTOYAGE DES TABLES (ordre dépendant des FK)
-- =========================================================================================

-- Respecter l'ordre inverse des FK pour éviter erreurs de contrainte
TRUNCATE TABLE vehicule_deplacement_historique RESTART IDENTITY CASCADE;
TRUNCATE TABLE planning_trajet_assignation_historique RESTART IDENTITY CASCADE;
TRUNCATE TABLE planning_trajet_detail RESTART IDENTITY CASCADE;
TRUNCATE TABLE planning_trajet RESTART IDENTITY CASCADE;
TRUNCATE TABLE reservations RESTART IDENTITY CASCADE;
TRUNCATE TABLE distances RESTART IDENTITY CASCADE;
TRUNCATE TABLE lieux RESTART IDENTITY CASCADE;
TRUNCATE TABLE vehicules RESTART IDENTITY CASCADE;
TRUNCATE TABLE hotel RESTART IDENTITY CASCADE;

-- =========================================================================================
-- ETAPE 2: INSERTION DES DONNÉES DE REFERENCE
-- =========================================================================================

-- Types de carburant (requis pour vehicules.type_carburant_id)
INSERT INTO type_carburant (libelle, description) VALUES
('Diesel', 'Carburant diesel'),
('Essence', 'Carburant essence')
ON CONFLICT (libelle) DO NOTHING;

-- Types de lieux (requis pour lieux.type_lieu_id)
INSERT INTO type_lieu (libelle, description) VALUES
('Aéroport', 'Aéroport'),
('Hôtel', 'Hôtel')
ON CONFLICT (libelle) DO NOTHING;

-- =========================================================================================
-- ETAPE 3: INSERTION DES DONNÉES - HOTELS
-- Anciennes colonnes: (nom, adresse) → Nouvelles colonnes: (nom, adresse, ville, pays, nombre_etoiles, description, is_active)
-- =========================================================================================

INSERT INTO hotel (nom, adresse, ville, pays, nombre_etoiles, description, is_active)
VALUES
('H1', 'H1', 'Antananarivo', 'Madagascar', 4, 'Hotel H1', true),
('H2', 'H2', 'Antananarivo', 'Madagascar', 4, 'Hotel H2', true);

-- =========================================================================================
-- ETAPE 4: INSERTION DES DONNÉES - LIEUX
-- Anciennes colonnes: (code, libelle) → Nouvelles colonnes: (nom, type_lieu_id, ...)
-- Crée des lieux pour : IVATO (aéroport), H1 (hôtel), H2 (hôtel)
-- =========================================================================================

-- IVATO (Aéroport)
INSERT INTO lieux (nom, type_lieu_id, adresse, ville, pays, description, is_active)
VALUES
('IVATO', (SELECT id FROM type_lieu WHERE libelle = 'Aéroport' LIMIT 1), 
 'Aéroport d''Ivato', 'Antananarivo', 'Madagascar', 'Aéroport principal', true);

-- H1 (Hôtel - lié à hotel.id)
INSERT INTO lieux (nom, type_lieu_id, adresse, ville, pays, description, hotel_id, is_active)
SELECT 'H1', (SELECT id FROM type_lieu WHERE libelle = 'Hôtel' LIMIT 1),
       h.adresse, h.ville, h.pays, 'Lieu Hotel H1', h.id, h.is_active
FROM hotel h WHERE h.nom = 'H1';

-- H2 (Hôtel - lié à hotel.id)
INSERT INTO lieux (nom, type_lieu_id, adresse, ville, pays, description, hotel_id, is_active)
SELECT 'H2', (SELECT id FROM type_lieu WHERE libelle = 'Hôtel' LIMIT 1),
       h.adresse, h.ville, h.pays, 'Lieu Hotel H2', h.id, h.is_active
FROM hotel h WHERE h.nom = 'H2';

-- =========================================================================================
-- ETAPE 5: INSERTION DES DONNÉES - DISTANCES
-- Anciennes colonnes: (from_lieu, to_lieu, km) → Nouvelles colonnes: (lieu_depart_id, lieu_arrivee_id, distance_km)
-- =========================================================================================

INSERT INTO distances (lieu_depart_id, lieu_arrivee_id, distance_km)
VALUES
((SELECT id FROM lieux WHERE nom = 'IVATO' LIMIT 1), 
 (SELECT id FROM lieux WHERE nom = 'H1' LIMIT 1), 90.0),
((SELECT id FROM lieux WHERE nom = 'IVATO' LIMIT 1), 
 (SELECT id FROM lieux WHERE nom = 'H2' LIMIT 1), 65.0),
((SELECT id FROM lieux WHERE nom = 'H1' LIMIT 1), 
 (SELECT id FROM lieux WHERE nom = 'H2' LIMIT 1), 10.0);

-- =========================================================================================
-- ETAPE 6: INSERTION DES DONNÉES - CONFIGURATION
-- Anciennes colonnes: (vitesse_moyenne, temps_attente, is_active) 
-- → Nouvelles colonnes: (cle, valeur, type_valeur, ...) dans parametres_configuration
-- =========================================================================================

INSERT INTO parametres_configuration (cle, valeur, type_valeur, description)
VALUES
('VITESSE_MOYENNE_KMH', '60', 'int', 'Vitesse moyenne de trajets en km/h'),
('TEMPS_ATTENTE_MAX_MINUTES', '30', 'int', 'Temps d''attente maximum pour regroupement en minutes')
ON CONFLICT (cle) DO NOTHING;

-- =========================================================================================
-- ETAPE 7: INSERTION DES DONNÉES - VEHICULES
-- Anciennes colonnes: (reference, place, type_carburant, heure_disponibilite)
-- → Nouvelles colonnes: (immatriculation, capacite_passagers, type_carburant_id, heure_disponible_debut, heure_disponible_courante, ...)
-- =========================================================================================

INSERT INTO vehicules (immatriculation, marque, modele, annee, type_carburant_id, capacite_passagers, is_available, heure_disponible_debut, heure_disponible_courante)
VALUES
('Vehicule1', 'Generic', 'VH1', 2026, (SELECT id FROM type_carburant WHERE libelle = 'Diesel' LIMIT 1), 
 10, true, '00:00:00', '00:00:00'),
('Vehicule2', 'Generic', 'VH2', 2026, (SELECT id FROM type_carburant WHERE libelle = 'Diesel' LIMIT 1), 
 8, true, '08:00:00', '08:00:00'),
('Vehicule3', 'Generic', 'VH3', 2026, (SELECT id FROM type_carburant WHERE libelle = 'Essence' LIMIT 1), 
 8, true, '08:00:00', '08:00:00'),
('Vehicule4', 'Generic', 'VH4', 2026, (SELECT id FROM type_carburant WHERE libelle = 'Essence' LIMIT 1), 
 12, true, '09:00:00', '09:00:00');

-- =========================================================================================
-- ETAPE 8: INSERTION DES DONNÉES - RESERVATIONS
-- Anciennes colonnes: (client, id_hotel, nb_passager, date_heure_depart)
-- → Nouvelles colonnes: (nom, email, date_arrivee, heure, nombre_personnes, hotel_id, lieu_depart_id, lieu_arrivee_id, ...)
-- =========================================================================================

INSERT INTO reservations (nom, email, date_arrivee, heure, nombre_personnes, hotel_id, 
                         lieu_depart_id, lieu_arrivee_id, is_confirmed, observation)
VALUES
('Client1', 'client1@hotel.test', '2026-04-02 06:00:00', '06:00', 20, 
 (SELECT id FROM hotel WHERE nom = 'H1' LIMIT 1),
 (SELECT id FROM lieux WHERE nom = 'IVATO' LIMIT 1),
 (SELECT id FROM lieux WHERE nom = 'H1' LIMIT 1), false, 'Import données test - Client1'),
 
('Client2', 'client2@hotel.test', '2026-04-02 08:15:00', '08:15', 6,
 (SELECT id FROM hotel WHERE nom = 'H1' LIMIT 1),
 (SELECT id FROM lieux WHERE nom = 'IVATO' LIMIT 1),
 (SELECT id FROM lieux WHERE nom = 'H1' LIMIT 1), false, 'Import données test - Client2'),
 
('Client3', 'client3@hotel.test', '2026-04-02 09:00:00', '09:00', 10,
 (SELECT id FROM hotel WHERE nom = 'H1' LIMIT 1),
 (SELECT id FROM lieux WHERE nom = 'IVATO' LIMIT 1),
 (SELECT id FROM lieux WHERE nom = 'H1' LIMIT 1), false, 'Import données test - Client3'),
 
('Client4', 'client4@hotel.test', '2026-04-02 09:10:00', '09:10', 6,
 (SELECT id FROM hotel WHERE nom = 'H2' LIMIT 1),
 (SELECT id FROM lieux WHERE nom = 'IVATO' LIMIT 1),
 (SELECT id FROM lieux WHERE nom = 'H2' LIMIT 1), false, 'Import données test - Client4');