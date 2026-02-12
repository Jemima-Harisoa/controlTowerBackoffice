package model;

public class Hotel {
    private int id;
    private String nom;
    private String adresse;
    private String ville;
    private int nombreEtoiles;
    
    // Getters et Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    public String getAdresse() { return adresse; }
    public void setAdresse(String adresse) { this.adresse = adresse; }
    public String getVille() { return ville; }
    public void setVille(String ville) { this.ville = ville; }
    public int getNombreEtoiles() { return nombreEtoiles; }
    public void setNombreEtoiles(int nombreEtoiles) { this.nombreEtoiles = nombreEtoiles; }
}
-- ===========================================
-- SPRINT 1 - FORM RESERVATION
-- Tables pour la gestion des réservations d'hôtel
-- ===========================================

-- Configuration
-- ===========================================
-- FONCTIONS UTILITAIRES
-- ===========================================

-- Configuration
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

-- ===========================================
-- FONCTION: Mise à jour automatique de updated_at
-- ===========================================
-- Cette fonction est utilisée par les triggers pour mettre à jour
-- automatiquement le champ updated_at lors d'un UPDATE

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Commentaire
COMMENT ON FUNCTION update_updated_at_column() IS 
'Fonction trigger pour mettre à jour automatiquement le champ updated_at';

-- Message de confirmation
DO $$
BEGIN
  RAISE NOTICE '✅ Fonction update_updated_at_column créée avec succès!';
END $$;

-- ===========================================
-- TABLES PRINCIPALES
-- ===========================================

-- Table des sexe
CREATE TABLE IF NOT EXISTS sexe (
    id SERIAL PRIMARY KEY,
    sexe VARCHAR(20) NOT NULL,
    description VARCHAR(100)
);

-- Table Types de clients
CREATE TABLE IF NOT EXISTS type_client (
    id SERIAL PRIMARY KEY,
    type VARCHAR(20) NOT NULL,
    description VARCHAR(100)
);

-- Table des hotel 
CREATE TABLE IF NOT EXISTS hotels (
    id SERIAL PRIMARY KEY,
    hotel VARCHAR(50) NOT NULL,
    adresse VARCHAR(50),
    contact VARCHAR(20)  
); 

-- Table des clients
CREATE TABLE IF NOT EXISTS clients (
    id SERIAL PRIMARY KEY,
    denomination VARCHAR(50) NOT NULL, 
    sexe_id INTEGER REFERENCES sexe(id) ON DELETE SET NULL, 
    type_id INTEGER REFERENCES type_client(id) ON DELETE SET NULL
);

-- Table des reservations
CREATE TABLE IF NOT EXISTS reservations (
    id SERIAL PRIMARY KEY, 
    numero VARCHAR(20) UNIQUE NOT NULL,
    contact VARCHAR(50),
    client_id INTEGER REFERENCES clients(id) ON DELETE CASCADE,
    hotel_id INTEGER REFERENCES hotels(id) ON DELETE CASCADE,
    passager SMALLINT DEFAULT 1, -- nombre de passager pour le vehicule 
    date_arrival TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ===========================================
-- INDEX POUR PERFORMANCES
-- ===========================================
CREATE INDEX IF NOT EXISTS idx_client_sexe ON client(sexe_id);
CREATE INDEX IF NOT EXISTS idx_client_type ON client(type_id);
CREATE INDEX IF NOT EXISTS idx_reservation_client ON reservation(client_id);
CREATE INDEX IF NOT EXISTS idx_reservation_hotel ON reservations(hotel_id);
CREATE INDEX IF NOT EXISTS idx_reservation_numero ON reservations(numero);
CREATE INDEX IF NOT EXISTS idx_reservation_date ON reservations(date_arrival);

-- ===========================================
-- DONNÉES DE TEST
-- ===========================================

-- Insertion des types de sexe
INSERT INTO sexe (sexe, description) VALUES 
    ('Homme', 'Sexe masculin'),
    ('Femme', 'Sexe féminin'),
    ('Autre', 'Autre')
ON CONFLICT DO NOTHING;

-- Insertion des types de clients
INSERT INTO type_client (type, description) VALUES 
    ('Standard', 'Client standard'),
    ('Premium', 'Client avec carte de fidélité'),
    ('VIP', 'Client VIP'),
    ('Entreprise', 'Client professionnel')
ON CONFLICT DO NOTHING;

-- Insertion d'hôtels de test
INSERT INTO hotel (hotel, adresse, contact) VALUES 
    ('Hotel Royal Palace', '123 Avenue des Champs', '+33 1 23 45 67 89'),
    ('Grand Hotel Central', '456 Rue de la Paix', '+33 1 98 76 54 32'),
    ('Boutique Hotel Vue Mer', '789 Boulevard Maritime', '+33 4 56 78 90 12')
ON CONFLICT DO NOTHING;

-- Insertion de clients de test
INSERT INTO client (denomination, sexe_id, type_id) VALUES 
    ('Jean Dupont', 1, 1),
    ('Marie Martin', 2, 2),
    ('Société ABC', 3, 4)
ON CONFLICT DO NOTHING;

-- ===========================================
-- TRIGGERS
-- ===========================================

-- Trigger pour updated_at sur reservations
DROP TRIGGER IF EXISTS update_reservation_updated_at ON reservation;
CREATE TRIGGER update_reservation_updated_at 
    BEFORE UPDATE ON reservation 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- ===========================================
-- VUES UTILES
-- ===========================================

-- Vue complète des réservations avec informations jointes
CREATE OR REPLACE VIEW vue_reservations_completes AS
SELECT 
    r.id as reservation_id,
    r.numero,
    r.contact,
    r.passager,
    r.date_arrival,
    r.created_at,
    c.denomination as client_nom,
    s.sexe as client_sexe,
    tc.type as client_type,
    h.hotel as hotel_nom,
    h.adresse as hotel_adresse,
    h.contact as hotel_contact
FROM reservation r
JOIN client c ON r.client_id = c.id
LEFT JOIN sexe s ON c.sexe_id = s.id
LEFT JOIN type_client tc ON c.type_id = tc.id
JOIN hotel h ON r.hotel_id = h.id;

-- Vue des réservations à venir
CREATE OR REPLACE VIEW vue_reservations_futures AS
SELECT *
FROM vue_reservations_completes
WHERE date_arrival > CURRENT_TIMESTAMP
ORDER BY date_arrival ASC;

-- ===========================================
-- COMMENTAIRES
-- ===========================================

COMMENT ON TABLE sexe IS 'Table de référence pour les types de sexe';
COMMENT ON TABLE type_client IS 'Table de référence pour les types de clients';
COMMENT ON TABLE hotel IS 'Table des hôtels partenaires';
COMMENT ON TABLE client IS 'Table des clients';
COMMENT ON TABLE reservation IS 'Table des réservations';

-- Message de confirmation
DO $$
BEGIN
  RAISE NOTICE '✅ Tables de réservation Sprint 1 créées avec succès!';
  RAISE NOTICE '🏨 Tables créées: sexe, type_client, hotel, client, reservation';
  RAISE NOTICE '📊 Données de test ajoutées';
END $$;