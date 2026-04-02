-- =============================================================
-- Verification Sprint 3 : historique de deplacement et assignation
-- Usage:
--   1) Adapter les valeurs dans le CTE params de chaque section
--   2) Executer dans psql / DBeaver sur la base controltower
-- =============================================================

-- -------------------------------------------------------------
-- A. Chronologie des positions par vehicule (jour donne)
-- -------------------------------------------------------------
WITH params AS (
    SELECT
        CAST(NULL AS INT) AS vehicule_id_filter, -- ex: 1 ; NULL = tous les vehicules
        DATE '2026-03-19' AS date_service
)
SELECT
    vdh.vehicule_id,
    vdh.date_mouvement,
    vdh.type_evenement,
    vdh.reservation_id,
    vdh.planning_trajet_id,
    vdh.lieu_id,
    l.nom AS lieu_nom,
    vdh.commentaire
FROM vehicule_deplacement_historique vdh
LEFT JOIN lieux l ON l.id = vdh.lieu_id
CROSS JOIN params p
WHERE vdh.date_mouvement::date = p.date_service
  AND (p.vehicule_id_filter IS NULL OR vdh.vehicule_id = p.vehicule_id_filter)
ORDER BY vdh.vehicule_id, vdh.date_mouvement, vdh.id;


-- -------------------------------------------------------------
-- B. Etat d'un vehicule a l'instant t
--    - dernier lieu connu
--    - occupation theorique (historique assignation)
-- -------------------------------------------------------------
WITH params AS (
    SELECT
        1::INT AS vehicule_id,
        TIMESTAMP '2026-03-19 08:30:00' AS instant_t
),
last_position AS (
    SELECT
        vdh.vehicule_id,
        vdh.lieu_id,
        l.nom AS lieu_nom,
        vdh.type_evenement,
        vdh.date_mouvement,
        vdh.reservation_id
    FROM vehicule_deplacement_historique vdh
    JOIN params p ON p.vehicule_id = vdh.vehicule_id
    LEFT JOIN lieux l ON l.id = vdh.lieu_id
    WHERE vdh.date_mouvement <= p.instant_t
    ORDER BY vdh.date_mouvement DESC, vdh.id DESC
    LIMIT 1
),
active_assignation AS (
    SELECT
        pah.vehicule_id,
        pah.reservation_id,
        pah.date_service,
        pah.heure_depart_prevue,
        pah.heure_arrivee_prevue,
        pah.statut
    FROM planning_trajet_assignation_historique pah
    JOIN params p ON p.vehicule_id = pah.vehicule_id
    WHERE pah.date_service = p.instant_t::date
      AND pah.heure_depart_prevue::time <= p.instant_t::time
      AND COALESCE(pah.heure_arrivee_prevue::time, TIME '23:59:59') >= p.instant_t::time
      AND COALESCE(pah.statut, 'PLANIFIE') NOT IN ('ANNULE', 'TERMINE')
)
SELECT
    p.vehicule_id,
    p.instant_t,
    lp.lieu_id AS dernier_lieu_id,
    lp.lieu_nom AS dernier_lieu_nom,
    lp.type_evenement AS dernier_evenement,
    lp.date_mouvement AS date_dernier_evenement,
    EXISTS (SELECT 1 FROM active_assignation) AS est_occupe,
    (
        SELECT string_agg(
            'reservation ' || aa.reservation_id ||
            ' [' || aa.heure_depart_prevue || ' -> ' || COALESCE(aa.heure_arrivee_prevue, '?') || ']',
            ' ; ' ORDER BY aa.heure_depart_prevue, aa.reservation_id
        )
        FROM active_assignation aa
    ) AS details_occupation
FROM params p
LEFT JOIN last_position lp ON lp.vehicule_id = p.vehicule_id;


-- -------------------------------------------------------------
-- C. Verification des choix d'assignation sur un creneau
--    Compare:
--      - position connue juste avant le creneau
--      - distance theorique vers chaque ramassage
--      - ordre reel des RAMASSAGE enregistres
-- -------------------------------------------------------------
WITH params AS (
    SELECT
        DATE '2026-03-19' AS date_slot,
        '09:00:00'::VARCHAR(8) AS heure_slot,
        CAST(NULL AS INT) AS vehicule_id_filter -- ex: 1 ; NULL = tous
),
slot_reservations AS (
    SELECT
        ptd.vehicule_id,
        ptd.reservation_id,
        r.lieu_depart_id,
        ld.nom AS lieu_depart_nom
    FROM planning_trajet_detail ptd
    JOIN reservations r ON r.id = ptd.reservation_id
    LEFT JOIN lieux ld ON ld.id = r.lieu_depart_id
    CROSS JOIN params p
    WHERE ptd.date_arrivee = p.date_slot
      AND ptd.heure_arrivee = p.heure_slot
      AND (p.vehicule_id_filter IS NULL OR ptd.vehicule_id = p.vehicule_id_filter)
),
vehicule_position_avant_slot AS (
    SELECT
        sr.vehicule_id,
        vdh.lieu_id AS lieu_reference_id,
        l.nom AS lieu_reference_nom,
        vdh.date_mouvement AS reference_mouvement
    FROM (
        SELECT DISTINCT vehicule_id FROM slot_reservations
    ) sr
    LEFT JOIN LATERAL (
        SELECT x.*
        FROM vehicule_deplacement_historique x
        CROSS JOIN params p
        WHERE x.vehicule_id = sr.vehicule_id
          AND x.date_mouvement <= (p.date_slot::text || ' ' || p.heure_slot)::timestamp
        ORDER BY x.date_mouvement DESC, x.id DESC
        LIMIT 1
    ) vdh ON TRUE
    LEFT JOIN lieux l ON l.id = vdh.lieu_id
),
ordre_theorique AS (
    SELECT
        sr.vehicule_id,
        sr.reservation_id,
        sr.lieu_depart_id,
        sr.lieu_depart_nom,
        vp.lieu_reference_id,
        vp.lieu_reference_nom,
        vp.reference_mouvement,
        d.distance_km AS distance_depuis_position,
        ROW_NUMBER() OVER (
            PARTITION BY sr.vehicule_id
            ORDER BY COALESCE(d.distance_km, 999999), sr.reservation_id
        ) AS rang_theorique
    FROM slot_reservations sr
    LEFT JOIN vehicule_position_avant_slot vp ON vp.vehicule_id = sr.vehicule_id
    LEFT JOIN distances d
           ON d.lieu_depart_id = vp.lieu_reference_id
          AND d.lieu_arrivee_id = sr.lieu_depart_id
),
ordre_reel AS (
    SELECT
        vdh.vehicule_id,
        vdh.reservation_id,
        vdh.date_mouvement,
        ROW_NUMBER() OVER (
            PARTITION BY vdh.vehicule_id
            ORDER BY vdh.date_mouvement, vdh.id
        ) AS rang_reel
    FROM vehicule_deplacement_historique vdh
    CROSS JOIN params p
    WHERE vdh.type_evenement = 'RAMASSAGE'
      AND vdh.date_mouvement::date = p.date_slot
      AND (p.vehicule_id_filter IS NULL OR vdh.vehicule_id = p.vehicule_id_filter)
      AND EXISTS (
          SELECT 1
          FROM slot_reservations sr
          WHERE sr.vehicule_id = vdh.vehicule_id
            AND sr.reservation_id = vdh.reservation_id
      )
)
SELECT
    ot.vehicule_id,
    p.date_slot,
    p.heure_slot,
    ot.lieu_reference_id AS position_avant_slot_id,
    ot.lieu_reference_nom AS position_avant_slot_nom,
    ot.reference_mouvement,
    ot.reservation_id,
    ot.lieu_depart_id,
    ot.lieu_depart_nom,
    ot.distance_depuis_position,
    ot.rang_theorique,
    orr.rang_reel,
    orr.date_mouvement AS date_ramassage_reel,
    CASE
        WHEN orr.rang_reel IS NULL THEN 'RAMASSAGE_NON_ENREGISTRE'
        WHEN orr.rang_reel = ot.rang_theorique THEN 'OK'
        ELSE 'ECART'
    END AS diagnostic
FROM ordre_theorique ot
LEFT JOIN ordre_reel orr
       ON orr.vehicule_id = ot.vehicule_id
      AND orr.reservation_id = ot.reservation_id
CROSS JOIN params p
ORDER BY ot.vehicule_id, ot.rang_theorique, ot.reservation_id;
