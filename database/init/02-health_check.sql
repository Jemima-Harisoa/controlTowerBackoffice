-- =================================
-- HEALTH CHECK TABLE
-- =================================

-- Table pour le health check de l'application
CREATE TABLE IF NOT EXISTS app_health (
    id SERIAL PRIMARY KEY,
    status VARCHAR(10) DEFAULT 'OK',
    checked_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Insérer un enregistrement initial
INSERT INTO app_health (status) VALUES ('OK');

-- Vue pour le health check
CREATE OR REPLACE VIEW health_status AS 
SELECT 
    'database' as component,
    'OK' as status,
    CURRENT_TIMESTAMP as timestamp,
    (SELECT COUNT(*) FROM users) as users_count;

-- Commentaire
COMMENT ON VIEW health_status IS 'Vue pour vérifier l''état de la base de données';