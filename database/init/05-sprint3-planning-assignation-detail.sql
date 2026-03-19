-- ===========================================
-- SPRINT 3 – DETAIL ASSIGNATION VEHICULE
-- Externaliser les details de planning trajet
-- ===========================================

-- Ce script suppose que la fonction update_updated_at_column() existe deja (script 01).

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

DROP INDEX IF EXISTS idx_planning_assignation_vehicule;
DROP INDEX IF EXISTS idx_planning_assignation_date_heure;

CREATE INDEX IF NOT EXISTS idx_planning_trajet_detail_vehicule
    ON planning_trajet_detail(vehicule_id);

CREATE INDEX IF NOT EXISTS idx_planning_trajet_detail_date_heure
    ON planning_trajet_detail(date_arrivee, heure_arrivee);

CREATE INDEX IF NOT EXISTS idx_planning_trajet_detail_first_reservation
    ON planning_trajet_detail(premiere_reservation_id);

DROP TRIGGER IF EXISTS update_planning_trajet_detail_updated_at ON planning_trajet_detail;
CREATE TRIGGER update_planning_trajet_detail_updated_at
    BEFORE UPDATE ON planning_trajet_detail
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================================
-- MIGRATION DE COMPATIBILITE : ancienne table planning_assignation_detail
-- =============================================================
DO $$
BEGIN
    IF to_regclass('public.planning_assignation_detail') IS NOT NULL THEN
        IF EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema = 'public'
              AND table_name = 'planning_assignation_detail'
              AND column_name = 'reservation_id'
        ) THEN
            INSERT INTO planning_trajet_detail (
                vehicule_id,
                date_arrivee,
                heure_arrivee,
                reservation_id,
                premiere_reservation_id,
                reservation_client,
                nombre_passagers_total,
                capacite_vehicule,
                places_libres,
                distance_estimee_km,
                duree_estimee,
                premier_point_depart,
                dernier_point_arrivee,
                points_depart,
                points_arrivee,
                created_at,
                updated_at
            )
            SELECT
                old.vehicule_id,
                old.date_arrivee,
                old.heure_arrivee,
                old.reservation_id,
                old.reservation_id,
                old.reservation_client,
                old.nombre_passagers_total,
                old.capacite_vehicule,
                old.places_libres,
                old.distance_estimee_km,
                old.duree_estimee,
                old.points_depart,
                old.points_arrivee,
                old.points_depart,
                old.points_arrivee,
                old.created_at,
                old.updated_at
            FROM planning_assignation_detail old
            ON CONFLICT (vehicule_id, date_arrivee, heure_arrivee, reservation_id)
            DO UPDATE SET
                premiere_reservation_id = EXCLUDED.premiere_reservation_id,
                reservation_client = EXCLUDED.reservation_client,
                nombre_passagers_total = EXCLUDED.nombre_passagers_total,
                capacite_vehicule = EXCLUDED.capacite_vehicule,
                places_libres = EXCLUDED.places_libres,
                distance_estimee_km = EXCLUDED.distance_estimee_km,
                duree_estimee = EXCLUDED.duree_estimee,
                premier_point_depart = EXCLUDED.premier_point_depart,
                dernier_point_arrivee = EXCLUDED.dernier_point_arrivee,
                points_depart = EXCLUDED.points_depart,
                points_arrivee = EXCLUDED.points_arrivee,
                updated_at = NOW();
        ELSIF EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema = 'public'
              AND table_name = 'planning_assignation_detail'
              AND column_name = 'reservation_ids'
        ) THEN
            INSERT INTO planning_trajet_detail (
                vehicule_id,
                date_arrivee,
                heure_arrivee,
                reservation_id,
                premiere_reservation_id,
                reservation_client,
                nombre_passagers_total,
                capacite_vehicule,
                places_libres,
                distance_estimee_km,
                duree_estimee,
                premier_point_depart,
                dernier_point_arrivee,
                points_depart,
                points_arrivee,
                created_at,
                updated_at
            )
            SELECT
                old.vehicule_id,
                old.date_arrivee,
                old.heure_arrivee,
                CAST(TRIM(res_id_txt) AS INT) AS reservation_id,
                CAST(TRIM(split_part(old.reservation_ids, ',', 1)) AS INT) AS premiere_reservation_id,
                old.reservations_clients,
                old.nombre_passagers_total,
                old.capacite_vehicule,
                old.places_libres,
                old.distance_estimee_km,
                old.duree_estimee,
                old.points_depart,
                old.points_arrivee,
                old.points_depart,
                old.points_arrivee,
                old.created_at,
                old.updated_at
            FROM planning_assignation_detail old,
                 unnest(string_to_array(COALESCE(old.reservation_ids, ''), ',')) AS res_id_txt
            WHERE TRIM(res_id_txt) <> ''
            ON CONFLICT (vehicule_id, date_arrivee, heure_arrivee, reservation_id)
            DO UPDATE SET
                premiere_reservation_id = EXCLUDED.premiere_reservation_id,
                reservation_client = EXCLUDED.reservation_client,
                nombre_passagers_total = EXCLUDED.nombre_passagers_total,
                capacite_vehicule = EXCLUDED.capacite_vehicule,
                places_libres = EXCLUDED.places_libres,
                distance_estimee_km = EXCLUDED.distance_estimee_km,
                duree_estimee = EXCLUDED.duree_estimee,
                premier_point_depart = EXCLUDED.premier_point_depart,
                dernier_point_arrivee = EXCLUDED.dernier_point_arrivee,
                points_depart = EXCLUDED.points_depart,
                points_arrivee = EXCLUDED.points_arrivee,
                updated_at = NOW();
        END IF;
    END IF;
END $$;

-- =============================================================
-- BACKFILL : synchroniser les donnees existantes de planning_trajet
-- vers la structure detaillee du sprint 3.
-- =============================================================
WITH base AS (
    SELECT
        p.id AS planning_trajet_id,
        p.vehicule_id,
        r.id AS reservation_id,
        COALESCE(r.date_arrivee::date, p.date_planification::date) AS date_arrivee,
        COALESCE(NULLIF(r.heure, ''), to_char(p.date_planification, 'HH24:MI:SS')) AS heure_arrivee,
        COALESCE(r.nom, 'Client') || '(' || COALESCE(r.nombre_personnes, 0) || 'p)' AS reservation_client,
        COALESCE(r.nombre_personnes, 0) AS nombre_personnes,
        COALESCE(v.capacite_passagers, 0) AS capacite_vehicule,
        p.distance_estimee AS distance_estimee_km,
        p.duree_estimee,
        ld.nom AS point_depart,
        la.nom AS point_arrivee
    FROM planning_trajet p
    JOIN reservations r ON r.id = p.reservation_id
    LEFT JOIN vehicules v ON v.id = p.vehicule_id
    LEFT JOIN lieux ld ON ld.id = p.lieu_depart_id
    LEFT JOIN lieux la ON la.id = p.lieu_arrivee_id
    WHERE p.vehicule_id IS NOT NULL
), enrichi AS (
    SELECT
        b.*,
        SUM(b.nombre_personnes) OVER (
            PARTITION BY b.vehicule_id, b.date_arrivee, b.heure_arrivee
        ) AS nombre_passagers_total,
        MIN(b.reservation_id) OVER (
            PARTITION BY b.vehicule_id, b.date_arrivee, b.heure_arrivee
        ) AS premiere_reservation_id,
        FIRST_VALUE(b.point_depart) OVER (
            PARTITION BY b.vehicule_id, b.date_arrivee, b.heure_arrivee
            ORDER BY b.heure_arrivee, b.reservation_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS premier_point_depart,
        LAST_VALUE(b.point_arrivee) OVER (
            PARTITION BY b.vehicule_id, b.date_arrivee, b.heure_arrivee
            ORDER BY b.heure_arrivee, b.reservation_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS dernier_point_arrivee
    FROM base b
)
INSERT INTO planning_trajet_detail (
    vehicule_id,
    date_arrivee,
    heure_arrivee,
    reservation_id,
    premiere_reservation_id,
    reservation_client,
    nombre_passagers_total,
    capacite_vehicule,
    places_libres,
    distance_estimee_km,
    duree_estimee,
    premier_point_depart,
    dernier_point_arrivee,
    points_depart,
    points_arrivee
)
SELECT
    e.vehicule_id,
    e.date_arrivee,
    e.heure_arrivee,
    e.reservation_id,
    e.premiere_reservation_id,
    e.reservation_client,
    e.nombre_passagers_total,
    e.capacite_vehicule,
    GREATEST(e.capacite_vehicule - e.nombre_passagers_total, 0) AS places_libres,
    e.distance_estimee_km,
    e.duree_estimee,
    e.premier_point_depart,
    e.dernier_point_arrivee,
    e.point_depart,
    e.point_arrivee
FROM enrichi e
ON CONFLICT (vehicule_id, date_arrivee, heure_arrivee, reservation_id)
DO UPDATE SET
    premiere_reservation_id = EXCLUDED.premiere_reservation_id,
    reservation_client = EXCLUDED.reservation_client,
    nombre_passagers_total = EXCLUDED.nombre_passagers_total,
    capacite_vehicule = EXCLUDED.capacite_vehicule,
    places_libres = EXCLUDED.places_libres,
    distance_estimee_km = EXCLUDED.distance_estimee_km,
    duree_estimee = EXCLUDED.duree_estimee,
    premier_point_depart = EXCLUDED.premier_point_depart,
    dernier_point_arrivee = EXCLUDED.dernier_point_arrivee,
    points_depart = EXCLUDED.points_depart,
    points_arrivee = EXCLUDED.points_arrivee,
    updated_at = NOW();

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

-- Backfill historique a partir des plannings existants.
INSERT INTO planning_trajet_assignation_historique (
    vehicule_id,
    reservation_id,
    planning_trajet_id,
    date_service,
    heure_depart_prevue,
    heure_arrivee_prevue,
    statut
)
SELECT
    p.vehicule_id,
    p.reservation_id,
    p.id,
    COALESCE(r.date_arrivee::date, p.date_planification::date) AS date_service,
    COALESCE(NULLIF(r.heure, ''), to_char(p.date_planification, 'HH24:MI:SS')) AS heure_depart_prevue,
    CASE
        WHEN p.duree_estimee IS NOT NULL THEN to_char(
            COALESCE(NULLIF(r.heure, ''), to_char(p.date_planification, 'HH24:MI:SS'))::time + p.duree_estimee,
            'HH24:MI:SS'
        )
        ELSE NULL
    END AS heure_arrivee_prevue,
    COALESCE(st.libelle, 'PLANIFIE') AS statut
FROM planning_trajet p
JOIN reservations r ON r.id = p.reservation_id
LEFT JOIN status_trajet st ON st.id = p.statut_id
WHERE p.vehicule_id IS NOT NULL
ON CONFLICT (vehicule_id, date_service, heure_depart_prevue, reservation_id)
DO UPDATE SET
    planning_trajet_id = EXCLUDED.planning_trajet_id,
    heure_arrivee_prevue = EXCLUDED.heure_arrivee_prevue,
    statut = EXCLUDED.statut,
    updated_at = NOW();

-- Historique de deplacement pour connaitre la localisation d'un vehicule a t.
CREATE TABLE IF NOT EXISTS vehicule_deplacement_historique (
    id SERIAL PRIMARY KEY,
    vehicule_id INT NOT NULL REFERENCES vehicules(id) ON DELETE CASCADE,
    lieu_id INT NOT NULL REFERENCES lieux(id) ON DELETE RESTRICT,
    planning_trajet_id INT REFERENCES planning_trajet(id) ON DELETE SET NULL,
    reservation_id INT REFERENCES reservations(id) ON DELETE SET NULL,
    type_evenement VARCHAR(20) NOT NULL,
    date_mouvement TIMESTAMP NOT NULL,
    commentaire TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_vehicule_deplacement_event UNIQUE (vehicule_id, date_mouvement, type_evenement, reservation_id)
);

CREATE INDEX IF NOT EXISTS idx_vehicule_deplacement_vehicule_date
    ON vehicule_deplacement_historique(vehicule_id, date_mouvement DESC);

CREATE INDEX IF NOT EXISTS idx_vehicule_deplacement_lieu
    ON vehicule_deplacement_historique(lieu_id);

DROP TRIGGER IF EXISTS update_vehicule_deplacement_historique_updated_at ON vehicule_deplacement_historique;
CREATE TRIGGER update_vehicule_deplacement_historique_updated_at
    BEFORE UPDATE ON vehicule_deplacement_historique
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Backfill initial : depart au lieu_depart puis arrivee au lieu_arrivee.
INSERT INTO vehicule_deplacement_historique (
    vehicule_id,
    lieu_id,
    planning_trajet_id,
    reservation_id,
    type_evenement,
    date_mouvement,
    commentaire
)
SELECT
    p.vehicule_id,
    p.lieu_depart_id,
    p.id,
    p.reservation_id,
    'RAMASSAGE',
    COALESCE(r.date_arrivee, p.date_planification),
    'Backfill ramassage depuis planning_trajet'
FROM planning_trajet p
JOIN reservations r ON r.id = p.reservation_id
WHERE p.vehicule_id IS NOT NULL
  AND p.lieu_depart_id IS NOT NULL
ON CONFLICT (vehicule_id, date_mouvement, type_evenement, reservation_id)
DO UPDATE SET
    lieu_id = EXCLUDED.lieu_id,
    planning_trajet_id = EXCLUDED.planning_trajet_id,
    commentaire = EXCLUDED.commentaire,
    updated_at = NOW();

INSERT INTO vehicule_deplacement_historique (
    vehicule_id,
    lieu_id,
    planning_trajet_id,
    reservation_id,
    type_evenement,
    date_mouvement,
    commentaire
)
SELECT
    p.vehicule_id,
    p.lieu_arrivee_id,
    p.id,
    p.reservation_id,
    'ARRIVEE',
    COALESCE(r.date_arrivee, p.date_planification) + COALESCE(p.duree_estimee, INTERVAL '0 minute'),
    'Backfill arrivee depuis planning_trajet'
FROM planning_trajet p
JOIN reservations r ON r.id = p.reservation_id
WHERE p.vehicule_id IS NOT NULL
  AND p.lieu_arrivee_id IS NOT NULL
ON CONFLICT (vehicule_id, date_mouvement, type_evenement, reservation_id)
DO UPDATE SET
    lieu_id = EXCLUDED.lieu_id,
    planning_trajet_id = EXCLUDED.planning_trajet_id,
    commentaire = EXCLUDED.commentaire,
    updated_at = NOW();

-- =============================================================
-- DONNEES DE TEST SPRINT 3
-- Cas cible: 2 reservations meme heure, nombres de passagers differents,
-- plusieurs vehicules disponibles.
-- =============================================================

INSERT INTO vehicules (immatriculation, marque, modele, annee, type_carburant_id, capacite_passagers, is_available)
VALUES
    ('CT-SP3-010', 'Mercedes', 'Vito', 2024, (SELECT id FROM type_carburant WHERE libelle = 'Diesel'), 6, true),
    ('CT-SP3-011', 'Renault', 'Trafic', 2023, (SELECT id FROM type_carburant WHERE libelle = 'Essence'), 4, true)
ON CONFLICT (immatriculation) DO NOTHING;

INSERT INTO reservations (nom, email, date_arrivee, heure, nombre_personnes, hotel_id, is_confirmed)
SELECT 'Test Sprint3 Groupe 4P', 'test.s3.g1.4p@controltower.local', '2026-06-10 09:00:00+00', '09:00', 4, 1, false
WHERE NOT EXISTS (
    SELECT 1 FROM reservations WHERE email = 'test.s3.g1.4p@controltower.local'
);

INSERT INTO reservations (nom, email, date_arrivee, heure, nombre_personnes, hotel_id, is_confirmed)
SELECT 'Test Sprint3 Groupe 2P', 'test.s3.g1.2p@controltower.local', '2026-06-10 09:00:00+00', '09:00', 2, 2, false
WHERE NOT EXISTS (
    SELECT 1 FROM reservations WHERE email = 'test.s3.g1.2p@controltower.local'
);

UPDATE reservations r
SET
    lieu_arrivee_id = (
        SELECT l.id
        FROM lieux l
        WHERE l.hotel_id = r.hotel_id
        LIMIT 1
    ),
    lieu_depart_id = CASE
        WHEN r.email = 'test.s3.g1.4p@controltower.local' THEN (
            SELECT l.id FROM lieux l WHERE l.nom = 'Gare de Lyon' LIMIT 1
        )
        WHEN r.email = 'test.s3.g1.2p@controltower.local' THEN (
            SELECT l.id FROM lieux l WHERE l.nom = 'Aéroport Paris-Charles de Gaulle' LIMIT 1
        )
        ELSE r.lieu_depart_id
    END
WHERE r.email IN ('test.s3.g1.4p@controltower.local', 'test.s3.g1.2p@controltower.local');

-- =============================================================
-- BACKFILL FINAL : remplir planning_trajet_detail apres les donnees test
-- =============================================================
WITH base AS (
    SELECT
        p.id AS planning_trajet_id,
        p.vehicule_id,
        r.id AS reservation_id,
        COALESCE(r.date_arrivee::date, p.date_planification::date) AS date_arrivee,
        COALESCE(NULLIF(r.heure, ''), to_char(p.date_planification, 'HH24:MI:SS')) AS heure_arrivee,
        COALESCE(r.nom, 'Client') || '(' || COALESCE(r.nombre_personnes, 0) || 'p)' AS reservation_client,
        COALESCE(r.nombre_personnes, 0) AS nombre_personnes,
        COALESCE(v.capacite_passagers, 0) AS capacite_vehicule,
        p.distance_estimee AS distance_estimee_km,
        p.duree_estimee,
        ld.nom AS point_depart,
        la.nom AS point_arrivee
    FROM planning_trajet p
    JOIN reservations r ON r.id = p.reservation_id
    LEFT JOIN vehicules v ON v.id = p.vehicule_id
    LEFT JOIN lieux ld ON ld.id = p.lieu_depart_id
    LEFT JOIN lieux la ON la.id = p.lieu_arrivee_id
    WHERE p.vehicule_id IS NOT NULL
), enrichi AS (
    SELECT
        b.*,
        SUM(b.nombre_personnes) OVER (
            PARTITION BY b.vehicule_id, b.date_arrivee, b.heure_arrivee
        ) AS nombre_passagers_total,
        MIN(b.reservation_id) OVER (
            PARTITION BY b.vehicule_id, b.date_arrivee, b.heure_arrivee
        ) AS premiere_reservation_id,
        FIRST_VALUE(b.point_depart) OVER (
            PARTITION BY b.vehicule_id, b.date_arrivee, b.heure_arrivee
            ORDER BY b.heure_arrivee, b.reservation_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS premier_point_depart,
        LAST_VALUE(b.point_arrivee) OVER (
            PARTITION BY b.vehicule_id, b.date_arrivee, b.heure_arrivee
            ORDER BY b.heure_arrivee, b.reservation_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS dernier_point_arrivee
    FROM base b
)
INSERT INTO planning_trajet_detail (
    vehicule_id,
    date_arrivee,
    heure_arrivee,
    reservation_id,
    premiere_reservation_id,
    reservation_client,
    nombre_passagers_total,
    capacite_vehicule,
    places_libres,
    distance_estimee_km,
    duree_estimee,
    premier_point_depart,
    dernier_point_arrivee,
    points_depart,
    points_arrivee
)
SELECT
    e.vehicule_id,
    e.date_arrivee,
    e.heure_arrivee,
    e.reservation_id,
    e.premiere_reservation_id,
    e.reservation_client,
    e.nombre_passagers_total,
    e.capacite_vehicule,
    GREATEST(e.capacite_vehicule - e.nombre_passagers_total, 0) AS places_libres,
    e.distance_estimee_km,
    e.duree_estimee,
    e.premier_point_depart,
    e.dernier_point_arrivee,
    e.point_depart,
    e.point_arrivee
FROM enrichi e
ON CONFLICT (vehicule_id, date_arrivee, heure_arrivee, reservation_id)
DO UPDATE SET
    premiere_reservation_id = EXCLUDED.premiere_reservation_id,
    reservation_client = EXCLUDED.reservation_client,
    nombre_passagers_total = EXCLUDED.nombre_passagers_total,
    capacite_vehicule = EXCLUDED.capacite_vehicule,
    places_libres = EXCLUDED.places_libres,
    distance_estimee_km = EXCLUDED.distance_estimee_km,
    duree_estimee = EXCLUDED.duree_estimee,
    premier_point_depart = EXCLUDED.premier_point_depart,
    dernier_point_arrivee = EXCLUDED.dernier_point_arrivee,
    points_depart = EXCLUDED.points_depart,
    points_arrivee = EXCLUDED.points_arrivee,
    updated_at = NOW();
