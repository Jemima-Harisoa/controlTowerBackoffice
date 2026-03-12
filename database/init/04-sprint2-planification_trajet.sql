-- ===========================================
-- SPRINT 2 – PLANIFICATION DES TRAJETS
-- Script de création des tables pour la planification des trajets
-- 
-- CONTINUITÉ AVEC LES SPRINTS PRÉCÉDENTS :
-- - Sprint 0 (01): Tables users et user_sessions
-- - Sprint 1 (03): Tables hotels, reservations, clients, sexes, type_clients
-- - Sprint 2 (04): Tables vehicules, lieux (lien vers hotels), distances, planning_trajet
--
-- Ce script :
-- 1. Crée les nouvelles tables pour le planning
-- 2. Améliore user_sessions (added updated_at, is_revoked)
-- 3. Modifie les tables existantes (ALTERs pour lieux_depart/arrivee, vehicule)
-- 4. Crée les lieux à partir des hôtels existants + aéroports/gares
-- 5. Ajoute des véhicules et distances de test
-- ===========================================

-- ===========================================
-- 1. TABLES DE RÉFÉRENCE (sans dépendances)
-- ===========================================

-- Table des types de carburant
CREATE TABLE IF NOT EXISTS type_carburant (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(20) NOT NULL UNIQUE,
    description VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE type_carburant IS 'Types de carburant disponibles pour les véhicules';

-- Table des types de lieux
CREATE TABLE IF NOT EXISTS type_lieu (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE type_lieu IS 'Types de lieux (Hôtel, Aéroport, Gare, etc.)';

-- Table des statuts de trajet
CREATE TABLE IF NOT EXISTS status_trajet (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(20) NOT NULL UNIQUE,
    description VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE status_trajet IS 'Statuts possibles pour un trajet planifié';

-- ===========================================
-- 2. TABLES PRINCIPALES
-- ===========================================

-- Table des véhicules
CREATE TABLE IF NOT EXISTS vehicules (
    id SERIAL PRIMARY KEY,
    immatriculation VARCHAR(20) UNIQUE NOT NULL,
    marque VARCHAR(50),
    modele VARCHAR(50),
    annee INT,
    type_carburant_id INT REFERENCES type_carburant(id) ON DELETE SET NULL,
    capacite_passagers INT NOT NULL DEFAULT 4,
    is_available BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE vehicules IS 'Flotte de véhicules disponibles';
CREATE INDEX IF NOT EXISTS idx_vehicules_disponible ON vehicules(is_available);
CREATE INDEX IF NOT EXISTS idx_vehicules_carburant ON vehicules(type_carburant_id);
CREATE INDEX IF NOT EXISTS idx_vehicules_immatriculation ON vehicules(immatriculation);

-- Table des lieux (avec localisation GPS)
CREATE TABLE IF NOT EXISTS lieux (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    type_lieu_id INT NOT NULL REFERENCES type_lieu(id) ON DELETE RESTRICT,
    adresse VARCHAR(255),
    ville VARCHAR(100),
    pays VARCHAR(100),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    description TEXT,
    hotel_id INT REFERENCES hotels(id) ON DELETE SET NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE lieux IS 'Catalogue des lieux (hôtels, aéroports, gares) - lien optionnel vers la table hotels existante';
CREATE INDEX IF NOT EXISTS idx_lieux_type ON lieux(type_lieu_id);
CREATE INDEX IF NOT EXISTS idx_lieux_hotel ON lieux(hotel_id);
CREATE INDEX IF NOT EXISTS idx_lieux_ville ON lieux(ville);
CREATE INDEX IF NOT EXISTS idx_lieux_active ON lieux(is_active);

-- Table des paramètres de configuration
CREATE TABLE IF NOT EXISTS parametres_configuration (
    id SERIAL PRIMARY KEY,
    cle VARCHAR(50) UNIQUE NOT NULL,
    valeur VARCHAR(255) NOT NULL,
    type_valeur VARCHAR(20) NOT NULL, -- string, int, float, boolean
    description TEXT,
    effective_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE parametres_configuration IS 'Paramètres de configuration (vitesse moyenne, durée tokens, etc.)';
CREATE INDEX IF NOT EXISTS idx_param_cle ON parametres_configuration(cle);

-- Table des distances entre les lieux
CREATE TABLE IF NOT EXISTS distances (
    id SERIAL PRIMARY KEY,
    lieu_depart_id INT NOT NULL REFERENCES lieux(id) ON DELETE CASCADE,
    lieu_arrivee_id INT NOT NULL REFERENCES lieux(id) ON DELETE CASCADE,
    distance_km DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(lieu_depart_id, lieu_arrivee_id)
);

COMMENT ON TABLE distances IS 'Distances précalculées entre les lieux (en km)';
CREATE INDEX IF NOT EXISTS idx_distances_depart ON distances(lieu_depart_id);
CREATE INDEX IF NOT EXISTS idx_distances_arrivee ON distances(lieu_arrivee_id);

-- ===========================================
-- 3. MODIFICATION DE LA TABLE RESERVATIONS
-- ===========================================
ALTER TABLE reservations 
    ADD COLUMN IF NOT EXISTS lieu_depart_id INT REFERENCES lieux(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS lieu_arrivee_id INT REFERENCES lieux(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS vehicule_id INT REFERENCES vehicules(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_reservations_lieu_depart ON reservations(lieu_depart_id);
CREATE INDEX IF NOT EXISTS idx_reservations_lieu_arrivee ON reservations(lieu_arrivee_id);
CREATE INDEX IF NOT EXISTS idx_reservations_vehicule ON reservations(vehicule_id);

-- ===========================================
-- 3B. MODIFICATION DE LA TABLE USER_SESSIONS (amélioration tokens)
-- ===========================================
ALTER TABLE user_sessions 
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ADD COLUMN IF NOT EXISTS is_revoked BOOLEAN DEFAULT false;

CREATE INDEX IF NOT EXISTS idx_sessions_revoked ON user_sessions(is_revoked);

-- ===========================================
-- 4. TABLE DE PLANIFICATION DES TRAJETS
-- ===========================================

CREATE TABLE IF NOT EXISTS planning_trajet (
    id SERIAL PRIMARY KEY,
    reservation_id INT NOT NULL REFERENCES reservations(id) ON DELETE CASCADE,
    vehicule_id INT REFERENCES vehicules(id) ON DELETE SET NULL,
    lieu_depart_id INT REFERENCES lieux(id) ON DELETE SET NULL,
    lieu_arrivee_id INT REFERENCES lieux(id) ON DELETE SET NULL,
    date_planification TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    duree_estimee INTERVAL,
    distance_estimee DECIMAL(10, 2),
    statut_id INT REFERENCES status_trajet(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE planning_trajet IS 'Planification des trajets - assignation des véhicules aux réservations';
CREATE INDEX IF NOT EXISTS idx_planning_reservation ON planning_trajet(reservation_id);
CREATE INDEX IF NOT EXISTS idx_planning_vehicule ON planning_trajet(vehicule_id);
CREATE INDEX IF NOT EXISTS idx_planning_statut ON planning_trajet(statut_id);
CREATE INDEX IF NOT EXISTS idx_planning_date ON planning_trajet(date_planification);

-- ===========================================
-- 5. TRIGGERS POUR UPDATED_AT
-- ===========================================

DROP TRIGGER IF EXISTS update_lieux_updated_at ON lieux;
CREATE TRIGGER update_lieux_updated_at BEFORE UPDATE ON lieux
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_vehicules_updated_at ON vehicules;
CREATE TRIGGER update_vehicules_updated_at BEFORE UPDATE ON vehicules
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_distances_updated_at ON distances;
CREATE TRIGGER update_distances_updated_at BEFORE UPDATE ON distances
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_planning_trajet_updated_at ON planning_trajet;
CREATE TRIGGER update_planning_trajet_updated_at BEFORE UPDATE ON planning_trajet
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_parametres_configuration_updated_at ON parametres_configuration;
CREATE TRIGGER update_parametres_configuration_updated_at BEFORE UPDATE ON parametres_configuration
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_user_sessions_updated_at ON user_sessions;
CREATE TRIGGER update_user_sessions_updated_at BEFORE UPDATE ON user_sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ===========================================
-- 6. DONNÉES DE TEST
-- ===========================================

-- Types de carburant
INSERT INTO type_carburant (libelle, description) VALUES 
    ('Essence', 'Carburant essence'),
    ('Diesel', 'Carburant diesel'),
    ('Électrique', 'Véhicule électrique'),
    ('Hybride', 'Véhicule hybride')
ON CONFLICT (libelle) DO NOTHING;

-- Types de lieux
INSERT INTO type_lieu (libelle, description) VALUES 
    ('Hôtel', 'Hôtel partenaire'),
    ('Aéroport', 'Aéroport'),
    ('Gare', 'Gare ferroviaire'),
    ('Gare routière', 'Gare routière')
ON CONFLICT (libelle) DO NOTHING;

-- Statuts de trajet
INSERT INTO status_trajet (libelle, description) VALUES 
    ('PLANIFIE', 'Trajet planifié'),
    ('EN_COURS', 'Trajet en cours'),
    ('TERMINE', 'Trajet terminé'),
    ('ANNULE', 'Trajet annulé')
ON CONFLICT (libelle) DO NOTHING;

-- Paramètres de configuration
INSERT INTO parametres_configuration (cle, valeur, type_valeur, description) VALUES 
    ('VITESSE_MOYENNE_KMH', '80', 'int', 'Vitesse moyenne de trajet en km/h'),
    ('DUREE_TOKEN_MINUTES', '30', 'int', 'Durée de validité d''un token en minutes'),
    ('DISTANCE_AUTONOMIE_ESSENCE_KM', '500', 'int', 'Autonomie moyenne pour essence en km'),
    ('DISTANCE_AUTONOMIE_DIESEL_KM', '700', 'int', 'Autonomie moyenne pour diesel en km'),
    ('DISTANCE_AUTONOMIE_ELECTRIQUE_KM', '300', 'int', 'Autonomie moyenne pour électrique en km')
ON CONFLICT (cle) DO NOTHING;

-- ===========================================
-- 6B. LIEUX - Créer les lieux pour les hôtels existants (Sprint 1)
-- ===========================================

-- Récupérer les IDs des types de lieux
WITH type_hotel AS (SELECT id FROM type_lieu WHERE libelle = 'Hôtel'),
     type_aeroport AS (SELECT id FROM type_lieu WHERE libelle = 'Aéroport'),
     type_gare AS (SELECT id FROM type_lieu WHERE libelle = 'Gare')
INSERT INTO lieux (nom, type_lieu_id, adresse, ville, pays, latitude, longitude, description, hotel_id, is_active) 
SELECT 
    h.nom,
    type_hotel.id,
    h.adresse,
    h.ville,
    h.pays,
    CASE WHEN h.ville = 'Paris' THEN 48.8566 ELSE 43.7102 END,
    CASE WHEN h.ville = 'Paris' THEN 2.3522 ELSE 7.2620 END,
    h.description,
    h.id,
    h.is_active
FROM hotels h, type_hotel
WHERE NOT EXISTS (
    SELECT 1 FROM lieux l 
    WHERE l.hotel_id = h.id
);

-- Aéroports (ajout manuel)
INSERT INTO lieux (nom, type_lieu_id, adresse, ville, pays, latitude, longitude, description, is_active) VALUES 
    ('Aéroport Paris-Charles de Gaulle', (SELECT id FROM type_lieu WHERE libelle = 'Aéroport'), 
     '95700 Roissy en France', 'Paris', 'France', 49.0097, 2.5479, 'Principal aéroport de Paris', true),
    ('Aéroport Nice-Côte d''Azur', (SELECT id FROM type_lieu WHERE libelle = 'Aéroport'), 
     '06206 Nice', 'Nice', 'France', 43.6645, 7.2120, 'Aéroport principal de la côte d''azur', true)
ON CONFLICT DO NOTHING;

-- Gares
INSERT INTO lieux (nom, type_lieu_id, adresse, ville, pays, latitude, longitude, description, is_active) VALUES 
    ('Gare de Lyon', (SELECT id FROM type_lieu WHERE libelle = 'Gare'), 
     '20 Boulevard Diderot', 'Paris', 'France', 48.8445, 2.3738, 'Principale gare de Paris', true),
    ('Gare Nice-Ville', (SELECT id FROM type_lieu WHERE libelle = 'Gare'), 
     'Rue Alfred Beau', 'Nice', 'France', 43.7108, 7.2597, 'Gare principale de Nice', true)
ON CONFLICT DO NOTHING;

-- ===========================================
-- 6C. VÉHICULES - Données de test
-- ===========================================

INSERT INTO vehicules (immatriculation, marque, modele, annee, type_carburant_id, capacite_passagers, is_available) VALUES 
    ('CT-ADM-001', 'Mercedes', 'Sprinter', 2022, (SELECT id FROM type_carburant WHERE libelle = 'Diesel'), 8, true),
    ('CT-ADM-002', 'BMW', 'X7', 2023, (SELECT id FROM type_carburant WHERE libelle = 'Diesel'), 7, true),
    ('CT-ADM-003', 'Tesla', 'Model S', 2023, (SELECT id FROM type_carburant WHERE libelle = 'Électrique'), 5, true),
    ('CT-ADM-004', 'Peugeot', '308', 2021, (SELECT id FROM type_carburant WHERE libelle = 'Essence'), 5, true),
    ('CT-ADM-005', 'Renault', 'Scenic', 2022, (SELECT id FROM type_carburant WHERE libelle = 'Hybride'), 7, true)
ON CONFLICT (immatriculation) DO NOTHING;

-- ===========================================
-- 6D. DISTANCES - Entre les lieux
-- ===========================================

INSERT INTO distances (lieu_depart_id, lieu_arrivee_id, distance_km) 
SELECT 
    l1.id,
    l2.id,
    CASE 
        WHEN l1.ville = 'Paris' AND l2.ville = 'Paris' THEN 15
        WHEN l1.ville = 'Nice' AND l2.ville = 'Nice' THEN 10
        WHEN (l1.ville = 'Paris' AND l2.ville = 'Paris') OR (l1.ville = 'Nice' AND l2.ville = 'Nice') THEN CASE 
            WHEN ABS(l1.latitude - l2.latitude) < 0.1 THEN 25 
            ELSE 900
        END
        ELSE 900
    END as distance
FROM lieux l1
CROSS JOIN lieux l2
WHERE l1.id < l2.id
ON CONFLICT (lieu_depart_id, lieu_arrivee_id) DO NOTHING;

-- ===========================================
-- 7. PERMISSIONS
-- ===========================================

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO controltower_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO controltower_user;

-- ===========================================
-- FIN SCRIPT SPRINT 2
-- ===========================================

DO $$
BEGIN
  RAISE NOTICE 'Tables Sprint 2 créées avec succès!';
  RAISE NOTICE 'Tables: vehicules, lieux, distances, planning_trajet, parametres_configuration';
  RAISE NOTICE 'Véhicules: 5 véhicules créés (Mercedes, BMW, Tesla, Peugeot, Renault)';
  RAISE NOTICE 'Lieux: Hôtels existants + 4 nouveaux lieux (aéroports et gares)';
  RAISE NOTICE 'Distances: Calculées automatiquement entre tous les lieux';
  RAISE NOTICE 'Configuration: Paramètres de vitesse et autonomie configurés';
  RAISE NOTICE 'Sécurité: Table user_sessions améliorée avec updated_at et is_revoked';
END $$;