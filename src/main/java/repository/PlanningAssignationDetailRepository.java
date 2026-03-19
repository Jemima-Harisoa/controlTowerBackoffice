package repository;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import model.PlanningAssignationDetail;
import util.DatabaseConnection;

public class PlanningAssignationDetailRepository {
    private DatabaseConnection dbConnection = DatabaseConnection.getInstance();

    public void upsert(PlanningAssignationDetail detail) {
        // ⭐ SPRINT 4 : Inclure les colonnes de groupement par temps d'attente
        String sql = "INSERT INTO planning_trajet_detail " +
                "(vehicule_id, date_arrivee, heure_arrivee, reservation_id, premiere_reservation_id, reservation_client, " +
                "nombre_passagers_total, capacite_vehicule, places_libres, distance_estimee_km, " +
                "duree_estimee, premier_point_depart, dernier_point_arrivee, points_depart, points_arrivee, " +
                "reservation_ids_groupees, nombre_reservations_groupe, temps_attente_groupe_minutes, " +
                "heure_depart_ajustee, plage_heures_groupe) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?::interval, ?, ?, ?, ?, ?, ?, ?, ?, ?) " +
                "ON CONFLICT (vehicule_id, date_arrivee, heure_arrivee, reservation_id) " +
                "DO UPDATE SET premiere_reservation_id = EXCLUDED.premiere_reservation_id, " +
                "reservation_client = EXCLUDED.reservation_client, " +
                "nombre_passagers_total = EXCLUDED.nombre_passagers_total, " +
                "capacite_vehicule = EXCLUDED.capacite_vehicule, " +
                "places_libres = EXCLUDED.places_libres, " +
                "distance_estimee_km = EXCLUDED.distance_estimee_km, " +
                "duree_estimee = EXCLUDED.duree_estimee, " +
                "premier_point_depart = EXCLUDED.premier_point_depart, " +
                "dernier_point_arrivee = EXCLUDED.dernier_point_arrivee, " +
                "points_depart = EXCLUDED.points_depart, " +
                "points_arrivee = EXCLUDED.points_arrivee, " +
                "reservation_ids_groupees = EXCLUDED.reservation_ids_groupees, " +
                "nombre_reservations_groupe = EXCLUDED.nombre_reservations_groupe, " +
                "temps_attente_groupe_minutes = EXCLUDED.temps_attente_groupe_minutes, " +
                "heure_depart_ajustee = EXCLUDED.heure_depart_ajustee, " +
                "plage_heures_groupe = EXCLUDED.plage_heures_groupe, " +
                "updated_at = NOW()";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, detail.getVehiculeId());
            stmt.setDate(2, Date.valueOf(detail.getDateArrivee()));
            stmt.setString(3, detail.getHeureArrivee());
            stmt.setLong(4, detail.getReservationId());
            stmt.setLong(5, detail.getPremiereReservationId());
            stmt.setString(6, detail.getReservationClient());
            stmt.setInt(7, detail.getNombrePassagersTotal());
            stmt.setInt(8, detail.getCapaciteVehicule());
            stmt.setInt(9, detail.getPlacesLibres());
            stmt.setDouble(10, detail.getDistanceEstimee());
            stmt.setString(11, detail.getDureeEstimee());
            stmt.setString(12, detail.getPremierPointDepart());
            stmt.setString(13, detail.getDernierPointArrivee());
            stmt.setString(14, detail.getPointsDepart());
            stmt.setString(15, detail.getPointsArrivee());
            // ⭐ SPRINT 4 : Ajouter les champs de groupement
            stmt.setString(16, detail.getReservationIdsGroupees());
            stmt.setInt(17, detail.getNombreReservationsGroupe());
            stmt.setInt(18, detail.getTempsAttenteGroupeMinutes());
            stmt.setString(19, detail.getHeureDeprtAjustee());
            stmt.setString(20, detail.getPlageHeuresGroupe());
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void upsertHistoriqueAssignation(long vehiculeId,
                                            long reservationId,
                                            Long planningTrajetId,
                                            String dateService,
                                            String heureDepartPrevue,
                                            String heureArriveePrevue,
                                            String statut) {
        String sql = "INSERT INTO planning_trajet_assignation_historique " +
                "(vehicule_id, reservation_id, planning_trajet_id, date_service, heure_depart_prevue, heure_arrivee_prevue, statut) " +
                "VALUES (?, ?, ?, ?::date, ?, ?, ?) " +
                "ON CONFLICT (vehicule_id, date_service, heure_depart_prevue, reservation_id) " +
                "DO UPDATE SET planning_trajet_id = EXCLUDED.planning_trajet_id, " +
                "heure_arrivee_prevue = EXCLUDED.heure_arrivee_prevue, " +
                "statut = EXCLUDED.statut, " +
                "updated_at = NOW()";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, vehiculeId);
            stmt.setLong(2, reservationId);
            if (planningTrajetId != null) {
                stmt.setLong(3, planningTrajetId);
            } else {
                stmt.setNull(3, java.sql.Types.BIGINT);
            }
            stmt.setString(4, dateService);
            stmt.setString(5, heureDepartPrevue);
            stmt.setString(6, heureArriveePrevue);
            stmt.setString(7, statut);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public java.util.List<PlanningAssignationDetail> findAll() {
        java.util.List<PlanningAssignationDetail> details = new java.util.ArrayList<>();
        String sql = "SELECT id, vehicule_id, date_arrivee, heure_arrivee, reservation_id, " +
                "premiere_reservation_id, reservation_client, nombre_passagers_total, capacite_vehicule, " +
                "places_libres, distance_estimee_km, duree_estimee, premier_point_depart, " +
                "dernier_point_arrivee, points_depart, points_arrivee, " +
                "reservation_ids_groupees, nombre_reservations_groupe, temps_attente_groupe_minutes, " +
                "heure_depart_ajustee, plage_heures_groupe " +
                "FROM planning_trajet_detail " +
                "ORDER BY vehicule_id, date_arrivee, heure_arrivee, reservation_id";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                PlanningAssignationDetail detail = mapResultSet(rs);
                details.add(detail);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return details;
    }

    public java.util.List<PlanningAssignationDetail> findByFilters(String date, String heure, Long vehiculeId) {
        java.util.List<PlanningAssignationDetail> details = new java.util.ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT id, vehicule_id, date_arrivee, heure_arrivee, reservation_id, " +
                "premiere_reservation_id, reservation_client, nombre_passagers_total, capacite_vehicule, " +
                "places_libres, distance_estimee_km, duree_estimee, premier_point_depart, " +
                "dernier_point_arrivee, points_depart, points_arrivee, " +
                "reservation_ids_groupees, nombre_reservations_groupe, temps_attente_groupe_minutes, " +
                "heure_depart_ajustee, plage_heures_groupe " +
                "FROM planning_trajet_detail WHERE 1=1"
        );

        java.util.List<Object> params = new java.util.ArrayList<>();
        if (date != null && !date.isEmpty()) {
            sql.append(" AND date_arrivee = ?::date");
            params.add(date);
        }
        if (heure != null && !heure.isEmpty()) {
            sql.append(" AND heure_arrivee = ?");
            params.add(heure);
        }
        if (vehiculeId != null) {
            sql.append(" AND vehicule_id = ?");
            params.add(vehiculeId);
        }
        sql.append(" ORDER BY vehicule_id, date_arrivee, heure_arrivee, reservation_id");

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    PlanningAssignationDetail detail = mapResultSet(rs);
                    details.add(detail);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return details;
    }

    private PlanningAssignationDetail mapResultSet(ResultSet rs) throws SQLException {
        PlanningAssignationDetail detail = new PlanningAssignationDetail();
        detail.setId(rs.getLong("id"));
        detail.setVehiculeId(rs.getLong("vehicule_id"));
        detail.setDateArrivee(rs.getString("date_arrivee"));
        detail.setHeureArrivee(rs.getString("heure_arrivee"));
        detail.setReservationId(rs.getLong("reservation_id"));
        detail.setPremiereReservationId(rs.getLong("premiere_reservation_id"));
        detail.setReservationClient(rs.getString("reservation_client"));
        detail.setNombrePassagersTotal(rs.getInt("nombre_passagers_total"));
        detail.setCapaciteVehicule(rs.getInt("capacite_vehicule"));
        detail.setPlacesLibres(rs.getInt("places_libres"));
        detail.setDistanceEstimee(rs.getDouble("distance_estimee_km"));
        detail.setDureeEstimee(rs.getString("duree_estimee"));
        detail.setPremierPointDepart(rs.getString("premier_point_depart"));
        detail.setDernierPointArrivee(rs.getString("dernier_point_arrivee"));
        detail.setPointsDepart(rs.getString("points_depart"));
        detail.setPointsArrivee(rs.getString("points_arrivee"));
        
        // ⭐ SPRINT 4 : Ajouter les champs de groupement par temps d'attente
        detail.setReservationIdsGroupees(rs.getString("reservation_ids_groupees"));
        detail.setNombreReservationsGroupe(rs.getInt("nombre_reservations_groupe"));
        detail.setTempsAttenteGroupeMinutes(rs.getInt("temps_attente_groupe_minutes"));
        detail.setHeureDeprtAjustee(rs.getString("heure_depart_ajustee"));
        detail.setPlageHeuresGroupe(rs.getString("plage_heures_groupe"));
        
        return detail;
    }

    public boolean isVehiculeDisponibleAt(long vehiculeId, String dateService, String heureReference) {
        String sql = "SELECT COUNT(1) AS conflict_count " +
                "FROM planning_trajet_assignation_historique " +
                "WHERE vehicule_id = ? " +
                "AND date_service = ?::date " +
                "AND statut IN ('PLANIFIE', 'EN_COURS') " +
                "AND ?::time >= heure_depart_prevue::time " +
                "AND ?::time < COALESCE(heure_arrivee_prevue::time, heure_depart_prevue::time + INTERVAL '1 hour')";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, vehiculeId);
            stmt.setString(2, dateService);
            stmt.setString(3, heureReference);
            stmt.setString(4, heureReference);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("conflict_count") == 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return true;
    }
}
