-- Sprint 6 - Disponibilite horaire des vehicules
-- Regle: par defaut, un vehicule est disponible a partir de minuit chaque jour.

ALTER TABLE vehicules
    ADD COLUMN IF NOT EXISTS heure_disponible_debut TIME DEFAULT '00:00:00',
    ADD COLUMN IF NOT EXISTS heure_disponible_courante TIME DEFAULT '00:00:00';

UPDATE vehicules
SET heure_disponible_debut = COALESCE(heure_disponible_debut, '00:00:00'::time),
    heure_disponible_courante = COALESCE(heure_disponible_courante, '00:00:00'::time)
WHERE heure_disponible_debut IS NULL OR heure_disponible_courante IS NULL;

CREATE INDEX IF NOT EXISTS idx_vehicules_disponibilite_horaire
    ON vehicules(is_available, heure_disponible_debut, heure_disponible_courante);
