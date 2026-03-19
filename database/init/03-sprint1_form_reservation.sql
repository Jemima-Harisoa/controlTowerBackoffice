-- ===========================================
-- SPRINT 1 - FORM RESERVATION
-- Tables pour la gestion des réservations d'hôtel
-- ===========================================
-- IMPORTANT : Les noms de tables et colonnes doivent correspondre
-- exactement au code Java (Models + Services) :
--   HotelService       → table "hotel"       (singulier)
--   ReservationService  → table "reservations" (pluriel)
--   ClientService       → table "clients"     (pluriel)
--   ClientService       → table "sexes"       (pluriel, colonne "libelle")
--   ClientService       → table "type_clients" (pluriel, colonne "libelle")
-- ===========================================

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

-- ===========================================
-- FONCTION: Mise à jour automatique de updated_at
-- ===========================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_updated_at_column() IS 
'Fonction trigger pour mettre à jour automatiquement le champ updated_at';

-- ===========================================
-- SUPPRESSION DES ANCIENNES TABLES (ordre inverse des FK)
-- ===========================================
DROP TABLE IF EXISTS reservations CASCADE;
DROP TABLE IF EXISTS clients CASCADE;
DROP TABLE IF EXISTS hotel CASCADE;
DROP TABLE IF EXISTS type_clients CASCADE;
DROP TABLE IF EXISTS sexes CASCADE;
-- Anciennes tables avec noms différents
DROP TABLE IF EXISTS reservation CASCADE;
DROP TABLE IF EXISTS client CASCADE;
DROP TABLE IF EXISTS hotels CASCADE;
DROP TABLE IF EXISTS type_client CASCADE;
DROP TABLE IF EXISTS sexe CASCADE;

-- ===========================================
-- TABLES PRINCIPALES
-- ===========================================

-- Table des sexes (Java: ClientService → FROM sexes, Model Sexe: id, libelle, description)
CREATE TABLE sexes (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(20) NOT NULL,
    description VARCHAR(100)
);

-- Table des types de clients (Java: ClientService → FROM type_clients, Model TypeClient: id, libelle, description)
CREATE TABLE type_clients (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(20) NOT NULL,
    description VARCHAR(100)
);

-- Table des hotel 
CREATE TABLE IF NOT EXISTS hotel (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    adresse VARCHAR(255),
    ville VARCHAR(100),
    pays VARCHAR(100),
    nombre_etoiles INT CHECK (nombre_etoiles BETWEEN 1 AND 5),
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des clients
CREATE TABLE IF NOT EXISTS clients (
    id SERIAL PRIMARY KEY,
    denomination VARCHAR(50) NOT NULL,
    sexe_id INTEGER REFERENCES sexes(id) ON DELETE SET NULL,
    type_id INTEGER REFERENCES type_clients(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des reservations
CREATE TABLE IF NOT EXISTS reservations (
    id SERIAL PRIMARY KEY, 
    nom VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    date_arrivee TIMESTAMP WITH TIME ZONE,
    heure VARCHAR(10),
    nombre_personnes SMALLINT DEFAULT 1,
    hotel_id INTEGER REFERENCES hotel(id) ON DELETE CASCADE,
    is_confirmed BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ===========================================
-- INDEX
-- ===========================================
CREATE INDEX IF NOT EXISTS idx_clients_sexe ON clients(sexe_id);
CREATE INDEX IF NOT EXISTS idx_clients_type ON clients(type_id);
CREATE INDEX IF NOT EXISTS idx_reservations_hotel ON reservations(hotel_id);
CREATE INDEX IF NOT EXISTS idx_reservations_date ON reservations(date_arrivee);
CREATE INDEX IF NOT EXISTS idx_hotel_active ON hotel(is_active);

-- ===========================================
-- TRIGGERS UPDATED_AT
-- ===========================================
DROP TRIGGER IF EXISTS update_hotel_updated_at ON hotel;
CREATE TRIGGER update_hotel_updated_at
    BEFORE UPDATE ON hotel
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_clients_updated_at ON clients;
CREATE TRIGGER update_clients_updated_at
    BEFORE UPDATE ON clients
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_reservations_updated_at ON reservations;
CREATE TRIGGER update_reservations_updated_at
    BEFORE UPDATE ON reservations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ===========================================
-- DONNÉES DE TEST
-- ===========================================

-- Sexes (colonne "libelle" comme attendu par Sexe.java)
INSERT INTO sexes (libelle, description) VALUES 
    ('Homme', 'Sexe masculin'),
    ('Femme', 'Sexe féminin'),
    ('Autre', 'Autre');

-- Types de clients (colonne "libelle" comme attendu par TypeClient.java)
INSERT INTO type_clients (libelle, description) VALUES 
    ('Standard', 'Client standard'),
    ('Premium', 'Client avec carte de fidélité'),
    ('VIP', 'Client VIP'),
    ('Entreprise', 'Client professionnel');

-- Hôtels (colonnes nom, adresse, ville, pays, nombre_etoiles comme attendu par Hotel.java)
INSERT INTO hotel (nom, adresse, ville, pays, nombre_etoiles, description) VALUES 
    ('Hotel Royal Palace', '123 Avenue des Champs', 'Paris', 'France', 5, 'Hôtel de luxe sur les Champs-Élysées'),
    ('Grand Hotel Central', '456 Rue de la Paix', 'Paris', 'France', 4, 'Hôtel central proche de l''Opéra'),
    ('Boutique Hotel Vue Mer', '789 Boulevard Maritime', 'Nice', 'France', 3, 'Hôtel avec vue sur la Méditerranée');

-- Clients
INSERT INTO clients (denomination, sexe_id, type_id) VALUES 
    ('Jean Dupont', 1, 1),
    ('Marie Martin', 2, 2),
    ('Société ABC', 3, 4);

-- Réservations de test
INSERT INTO reservations (nom, email, date_arrivee, heure, nombre_personnes, hotel_id, is_confirmed) VALUES 
    ('Jean Dupont', 'jean.dupont@email.com', '2026-04-15 14:00:00', '14:00', 2, 1, true),
    ('Marie Martin', 'marie.martin@email.com', '2026-05-01 10:00:00', '10:00', 3, 2, false),
    ('Pierre Durand', 'pierre.durand@email.com', '2026-03-20 16:00:00', '16:00', 1, 3, true);

-- ===========================================
-- COMMENTAIRES
-- ===========================================
COMMENT ON TABLE sexes IS 'Table de référence pour les types de sexe';
COMMENT ON TABLE type_clients IS 'Table de référence pour les types de clients';
COMMENT ON TABLE hotel IS 'Table des hôtels partenaires';
COMMENT ON TABLE clients IS 'Table des clients';
COMMENT ON TABLE reservations IS 'Table des réservations';

-- ===========================================
-- PERMISSIONS
-- ===========================================
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO controltower_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO controltower_user;

-- Message de confirmation
DO $$
BEGIN
  RAISE NOTICE 'Tables Sprint 1 créées avec succès!';
  RAISE NOTICE 'Tables: sexes, type_clients, hotel, clients, reservations';
  RAISE NOTICE 'Données de test ajoutées (3 hôtels, 3 clients, 3 réservations)';
END $$;