-- ===========================================
-- RESET COMPLET DES TABLES
-- ===========================================
TRUNCATE TABLE
    reservations,
    clients,
    hotels,
    user_sessions,
    users,
    sexes,
    type_clients,
    app_health
RESTART IDENTITY CASCADE;


-- ===========================================
-- EXTENSIONS
-- ===========================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


-- ===========================================
-- TABLES UTILITAIRES
-- ===========================================
CREATE TABLE IF NOT EXISTS app_health (
    id SERIAL PRIMARY KEY,
    status VARCHAR(10) DEFAULT 'OK',
    checked_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO app_health (status) VALUES ('OK');


-- ===========================================
-- TABLES DE REFERENCE
-- ===========================================
CREATE TABLE IF NOT EXISTS sexes (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(20) NOT NULL,
    description VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS type_clients (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(20) NOT NULL,
    description VARCHAR(100)
);


-- ===========================================
-- TABLES PRINCIPALES
-- ===========================================
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    role VARCHAR(20) DEFAULT 'USER',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_sessions (
    session_id VARCHAR(255) PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    ip_address INET,
    user_agent TEXT
);

CREATE TABLE IF NOT EXISTS hotels (
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

CREATE TABLE IF NOT EXISTS clients (
    id SERIAL PRIMARY KEY,
    denomination VARCHAR(50) NOT NULL,
    sexe_id INTEGER REFERENCES sexes(id) ON DELETE SET NULL,
    type_id INTEGER REFERENCES type_clients(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS reservations (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    date_arrivee TIMESTAMP NOT NULL,
    heure VARCHAR(5) NOT NULL CHECK (heure ~ '^([01]?[0-9]|2[0-3]):[0-5][0-9]$'),
    nombre_personnes INT NOT NULL CHECK (nombre_personnes > 0),
    hotel_id INT NOT NULL REFERENCES hotels(id) ON DELETE CASCADE,
    is_confirmed BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ===========================================
-- INDEX
-- ===========================================
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_active ON users(is_active);
CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_expires ON user_sessions(expires_at);
CREATE INDEX IF NOT EXISTS idx_clients_sexe ON clients(sexe_id);
CREATE INDEX IF NOT EXISTS idx_clients_type ON clients(type_id);
CREATE INDEX IF NOT EXISTS idx_reservations_hotel ON reservations(hotel_id);
CREATE INDEX IF NOT EXISTS idx_reservations_date ON reservations(date_arrivee);


-- ===========================================
-- TRIGGER UPDATED_AT
-- ===========================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER update_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_hotels_updated_at
BEFORE UPDATE ON hotels
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_clients_updated_at
BEFORE UPDATE ON clients
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reservations_updated_at
BEFORE UPDATE ON reservations
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- ===========================================
-- VUES
-- ===========================================
CREATE OR REPLACE VIEW active_users AS
SELECT id, username, email, first_name, last_name, role, created_at, updated_at
FROM users WHERE is_active = true;

CREATE OR REPLACE VIEW active_sessions AS
SELECT s.session_id, u.username, u.first_name, u.last_name, s.created_at, s.expires_at, s.ip_address
FROM user_sessions s
JOIN users u ON s.user_id = u.id
WHERE s.expires_at > CURRENT_TIMESTAMP;

CREATE OR REPLACE VIEW vue_reservations_completes AS
SELECT
    r.id, r.nom, r.email, r.date_arrivee, r.heure, r.nombre_personnes,
    h.nom AS nom_hotel, h.adresse, h.ville, h.pays, h.nombre_etoiles,
    r.is_confirmed, r.created_at, r.updated_at
FROM reservations r
JOIN hotels h ON r.hotel_id = h.id
ORDER BY r.date_arrivee DESC;

CREATE OR REPLACE VIEW health_status AS
SELECT
    'database' as component,
    'OK' as status,
    CURRENT_TIMESTAMP as timestamp,
    (SELECT COUNT(*) FROM users) as users_count;


-- ===========================================
-- DONNEES
-- ===========================================
INSERT INTO users (username,password_hash,email,first_name,last_name,role)
VALUES
('admin','$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','admin@controltower.com','Admin','Control Tower','ADMIN'),
('testuser','$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','test@controltower.com','Test','User','USER');


INSERT INTO sexes(libelle,description) VALUES
('Homme','Sexe masculin'),
('Femme','Sexe feminin'),
('Autre','Autre');


INSERT INTO type_clients(libelle,description) VALUES
('Standard','Client standard'),
('Premium','Client fidelite'),
('VIP','Client VIP'),
('Entreprise','Client professionnel');


INSERT INTO hotels(nom,adresse,ville,pays,nombre_etoiles,description) VALUES
('Hotel Plaza','123 Avenue des Champs Elysees','Paris','France',5,'Hotel de luxe au coeur de Paris'),
('Hotel Riviera','45 Promenade des Anglais','Nice','France',4,'Hotel avec vue sur la mer'),
('Hotel Alpina','78 Route des Alpes','Chamonix','France',3,'Hotel de montagne confortable'),
('Hotel Central','12 Rue de la Republique','Lyon','France',3,'Hotel au centre ville'),
('Hotel Bordeaux','56 Cours de l''Intendance','Bordeaux','France',4,'Hotel elegant pres du vignoble');


INSERT INTO clients(denomination,sexe_id,type_id) VALUES
('Jean Dupont',1,1),
('Marie Martin',2,2),
('Societe ABC',3,4);


INSERT INTO reservations(nom,email,date_arrivee,heure,nombre_personnes,hotel_id) VALUES
('Jean Dupont','jean.dupont@email.com','2023-12-15 14:00:00','14:00',2,1),
('Marie Martin','marie.martin@email.com','2023-12-20 18:30:00','18:30',4,2),
('Pierre Durand','pierre.durand@email.com','2023-12-25 12:00:00','12:00',3,3),
('Sophie Lefebvre','sophie.lefebvre@email.com','2023-12-30 19:00:00','19:00',2,4),
('Lucas Bernard','lucas.bernard@email.com','2024-01-05 16:00:00','16:00',5,5);


-- ===========================================
-- ROLE + PERMISSIONS
-- ===========================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'controltower_user') THEN
        CREATE ROLE controltower_user LOGIN PASSWORD 'controltower123';
    END IF;
END$$;

GRANT SELECT,INSERT,UPDATE,DELETE ON ALL TABLES IN SCHEMA public TO controltower_user;
GRANT USAGE,SELECT ON ALL SEQUENCES IN SCHEMA public TO controltower_user;


-- ===========================================
-- MESSAGE FINAL
-- ===========================================
DO $$
BEGIN
  RAISE NOTICE 'Database Control Tower initialized successfully';
  RAISE NOTICE 'Users: admin / testuser';
  RAISE NOTICE 'Default password: password';
END $$;
-- Insérer les utilisateurs avec hash BCrypt
-- Hash généré pour le mot de passe "password"
INSERT INTO users (username,password_hash,email,first_name,last_name,role)
VALUES
('admin2','$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyQI0t9qUg4S','admin5@controltower.com','Admin2','Control Tower','ADMIN2'),
('testuser2','$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyQI0t9qUg4S','test2@controltower.com','Test2','User2','USER2');

-- Note: Ces hash correspondent au mot de passe "password"
-- Pour générer de nouveaux hash, utilisez la classe PasswordUtil en Java