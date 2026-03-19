package repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import util.DatabaseConnection;

/**
 * Repository pour l'historique de deplacement des vehicules.
 */
public class VehiculeDeplacementHistoriqueRepository {
    private DatabaseConnection dbConnection = DatabaseConnection.getInstance();

    /**
     * Retourne le dernier lieu connu d'un vehicule avant un instant donne.
     */
    public Long getDernierLieuIdAvant(long vehiculeId, String dateHeureReference) {
        String sql = "SELECT lieu_id " +
                "FROM vehicule_deplacement_historique " +
                "WHERE vehicule_id = ? " +
                "AND date_mouvement <= ?::timestamp " +
                "ORDER BY date_mouvement DESC " +
                "LIMIT 1";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, vehiculeId);
            stmt.setString(2, dateHeureReference);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    long lieuId = rs.getLong("lieu_id");
                    if (!rs.wasNull()) {
                        return lieuId;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Enregistre un evenement de deplacement (depart, ramassage, arrivee).
     */
    public void insertEvenement(long vehiculeId,
                                Long lieuId,
                                Long planningTrajetId,
                                Long reservationId,
                                String typeEvenement,
                                String dateMouvement,
                                String commentaire) {
        if (lieuId == null || dateMouvement == null || dateMouvement.isEmpty()) {
            return;
        }

        String sql = "INSERT INTO vehicule_deplacement_historique " +
                "(vehicule_id, lieu_id, planning_trajet_id, reservation_id, type_evenement, date_mouvement, commentaire) " +
                "VALUES (?, ?, ?, ?, ?, ?::timestamp, ?) " +
                "ON CONFLICT (vehicule_id, date_mouvement, type_evenement, reservation_id) " +
                "DO UPDATE SET lieu_id = EXCLUDED.lieu_id, " +
                "planning_trajet_id = EXCLUDED.planning_trajet_id, " +
                "commentaire = EXCLUDED.commentaire, " +
                "updated_at = NOW()";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, vehiculeId);
            stmt.setLong(2, lieuId);

            if (planningTrajetId != null) {
                stmt.setLong(3, planningTrajetId);
            } else {
                stmt.setNull(3, java.sql.Types.BIGINT);
            }

            if (reservationId != null) {
                stmt.setLong(4, reservationId);
            } else {
                stmt.setNull(4, java.sql.Types.BIGINT);
            }

            stmt.setString(5, typeEvenement);
            stmt.setString(6, dateMouvement);
            stmt.setString(7, commentaire);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
