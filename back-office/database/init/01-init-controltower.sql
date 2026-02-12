-- ===========================================
-- Script d'initialisation de la base de données
-- Control Tower Backoffice
-- ===========================================

-- Création de la base de données si elle n'existe pas
-- (Normalement créée automatiquement par PostgreSQL via POSTGRES_DB)

-- Créer l'extension pour les UUIDs si nécessaire
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ===========================================
-- TABLE USERS
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

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_active ON users(is_active);

-- ===========================================
-- TABLE SESSIONS (pour gestion des sessions)
-- ===========================================
CREATE TABLE IF NOT EXISTS user_sessions (
    session_id VARCHAR(255) PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    ip_address INET,
    user_agent TEXT
);

-- Index pour améliorer les performances des sessions
CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_expires ON user_sessions(expires_at);

-- ===========================================
-- DONNÉES DE TEST
-- ===========================================

-- Utilisateur admin par défaut (mot de passe: "admin123")
-- Hash password généré avec un algorithme compatible Java
INSERT INTO users (username, password_hash, email, first_name, last_name, role) 
VALUES (
    'admin',
    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- password: "password"
    'admin@controltower.com',
    'Admin',
    'Control Tower',
    'ADMIN'
) ON CONFLICT (username) DO NOTHING;

-- Utilisateur test
INSERT INTO users (username, password_hash, email, first_name, last_name, role) 
VALUES (
    'testuser',
    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- password: "password"
    'test@controltower.com',
    'Test',
    'User',
    'USER'
) ON CONFLICT (username) DO NOTHING;

-- ===========================================
-- TRIGGERS pour updated_at automatique
-- ===========================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Appliquer le trigger sur la table users
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- ===========================================
-- VUES UTILES POUR LE DÉVELOPPEMENT
-- ===========================================

-- Vue des utilisateurs actifs
CREATE OR REPLACE VIEW active_users AS
SELECT 
    id,
    username,
    email,
    first_name,
    last_name,
    role,
    created_at,
    updated_at
FROM users 
WHERE is_active = true;

-- Vue des sessions actives
CREATE OR REPLACE VIEW active_sessions AS
SELECT 
    s.session_id,
    u.username,
    u.first_name,
    u.last_name,
    s.created_at,
    s.expires_at,
    s.ip_address
FROM user_sessions s
JOIN users u ON s.user_id = u.id
WHERE s.expires_at > CURRENT_TIMESTAMP;

-- ===========================================  
-- PERMISSIONS
-- ===========================================
-- Donner les permissions nécessaires à l'utilisateur de l'application
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO controltower_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO controltower_user;

-- Message de fin
DO $$
BEGIN
  RAISE NOTICE '✅ Base de données Control Tower initialisée avec succès!';
  RAISE NOTICE '👤 Utilisateurs créés: admin (admin@controltower.com), testuser (test@controltower.com)';
  RAISE NOTICE '🔑 Mot de passe par défaut: "password"';
END $$;