-- ===========================================
-- SPRINT 3 – DETAIL ASSIGNATION VEHICULE
-- Externaliser les details de planning trajet
-- ===========================================

CREATE TABLE IF NOT EXISTS planning_trajet_detail (
    id SERIAL PRIMARY KEY,
    vehicule_id INT NOT NULL REFERENCES vehicules(id) ON DELETE CASCADE,
    date_arrivee DATE NOT NULL,
    heure_arrivee VARCHAR(8) NOT NULL,
    reservation_id INT NOT NULL REFERENCES reservations(id) ON DELETE CASCADE,
    premiere_reservation_id INT NOT NULL REFERENCES reservations(id) ON DELETE CASCADE,
    reservation_client TEXT,
    nombre_passagers_total INT NOT NULL DEFAULT 0,
    capacite_vehicule INT NOT NULL DEFAULT 0,
    places_libres INT NOT NULL DEFAULT 0,
    distance_estimee_km DECIMAL(10, 2),
    duree_estimee INTERVAL,
    premier_point_depart TEXT,
    dernier_point_arrivee TEXT,
    points_depart TEXT,
    points_arrivee TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_planning_trajet_detail_slot_reservation UNIQUE (vehicule_id, date_arrivee, heure_arrivee, reservation_id)
);

COMMENT ON TABLE planning_trajet_detail IS 'Details de trajet par reservation, vehicule et slot horaire';

CREATE INDEX IF NOT EXISTS idx_planning_assignation_vehicule
    ON planning_trajet_detail(vehicule_id);

CREATE INDEX IF NOT EXISTS idx_planning_assignation_date_heure
    ON planning_trajet_detail(date_arrivee, heure_arrivee);

CREATE INDEX IF NOT EXISTS idx_planning_trajet_detail_first_reservation
    ON planning_trajet_detail(premiere_reservation_id);

DROP TRIGGER IF EXISTS update_planning_trajet_detail_updated_at ON planning_trajet_detail;
CREATE TRIGGER update_planning_trajet_detail_updated_at
    BEFORE UPDATE ON planning_trajet_detail
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Historique d'assignation pour determiner la disponibilite d'un vehicule a t.
CREATE TABLE IF NOT EXISTS planning_trajet_assignation_historique (
    id SERIAL PRIMARY KEY,
    vehicule_id INT NOT NULL REFERENCES vehicules(id) ON DELETE CASCADE,
    reservation_id INT NOT NULL REFERENCES reservations(id) ON DELETE CASCADE,
    planning_trajet_id INT REFERENCES planning_trajet(id) ON DELETE SET NULL,
    date_service DATE NOT NULL,
    heure_depart_prevue VARCHAR(8) NOT NULL,
    heure_arrivee_prevue VARCHAR(8),
    statut VARCHAR(20) NOT NULL DEFAULT 'PLANIFIE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_historique_slot UNIQUE (vehicule_id, date_service, heure_depart_prevue, reservation_id)
);

CREATE INDEX IF NOT EXISTS idx_historique_vehicule_date
    ON planning_trajet_assignation_historique(vehicule_id, date_service);

CREATE INDEX IF NOT EXISTS idx_historique_statut
    ON planning_trajet_assignation_historique(statut);

DROP TRIGGER IF EXISTS update_planning_trajet_assignation_historique_updated_at ON planning_trajet_assignation_historique;
CREATE TRIGGER update_planning_trajet_assignation_historique_updated_at
    BEFORE UPDATE ON planning_trajet_assignation_historique
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
