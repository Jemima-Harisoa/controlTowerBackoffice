package repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import model.PlanningTrajet;
import util.DatabaseConnection;

/**
 * Repository pour la table planning_trajet
 */
public class PlanningTrajetRepository {
    private DatabaseConnection dbConnection = DatabaseConnection.getInstance();

    private static final String SELECT_BASE =
            "SELECT p.*, st.libelle as statut, " +
            "v.immatriculation, v.marque, v.modele, " +
            "l1.nom as lieu_depart, l2.nom as lieu_arrivee " +
            "FROM planning_trajet p " +
            "LEFT JOIN status_trajet st ON p.statut_id = st.id " +
            "LEFT JOIN vehicules v ON p.vehicule_id = v.id " +
            "LEFT JOIN lieux l1 ON p.lieu_depart_id = l1.id " +
            "LEFT JOIN lieux l2 ON p.lieu_arrivee_id = l2.id ";

    private PlanningTrajet mapRow(ResultSet rs) throws SQLException {
        PlanningTrajet p = new PlanningTrajet();
        p.setId(rs.getLong("id"));
        p.setReservationId(rs.getLong("reservation_id"));
        long vid = rs.getLong("vehicule_id");
        if (!rs.wasNull()) p.setVehiculeId(vid);
        long ldid = rs.getLong("lieu_depart_id");
        if (!rs.wasNull()) p.setLieuDepartId(ldid);
        long laid = rs.getLong("lieu_arrivee_id");
        if (!rs.wasNull()) p.setLieuArriveeId(laid);
        p.setDatePlanification(rs.getString("date_planification"));
        p.setDureeEstimee(rs.getString("duree_estimee"));
        p.setDistanceEstimee(rs.getDouble("distance_estimee"));
        long sid = rs.getLong("statut_id");
        if (!rs.wasNull()) p.setStatutId(sid);
        p.setStatut(rs.getString("statut"));
        p.setVehiculeImmatriculation(rs.getString("immatriculation"));
        p.setVehiculeMarque(rs.getString("marque"));
        p.setVehiculeModele(rs.getString("modele"));
        p.setLieuDepart(rs.getString("lieu_depart"));
        p.setLieuArrivee(rs.getString("lieu_arrivee"));
        return p;
    }

    public List<PlanningTrajet> findAll() {
        List<PlanningTrajet> list = new ArrayList<>();
        String sql = SELECT_BASE + "ORDER BY p.date_planification DESC";
        try (Connection conn = dbConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public PlanningTrajet findById(long id) {
        String sql = SELECT_BASE + "WHERE p.id = ?";
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public PlanningTrajet findByReservationId(long reservationId) {
        String sql = SELECT_BASE + "WHERE p.reservation_id = ?";
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, reservationId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public List<PlanningTrajet> findByStatut(long statutId) {
        List<PlanningTrajet> list = new ArrayList<>();
        String sql = SELECT_BASE + "WHERE p.statut_id = ?";
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, statutId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<PlanningTrajet> findByVehicule(long vehiculeId) {
        List<PlanningTrajet> list = new ArrayList<>();
        String sql = SELECT_BASE + "WHERE p.vehicule_id = ? ORDER BY p.date_planification DESC";
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, vehiculeId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public boolean existsByVehiculeAndReservation(long vehiculeId, long reservationId) {
        String sql = "SELECT 1 FROM planning_trajet WHERE vehicule_id = ? AND reservation_id = ? LIMIT 1";
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, vehiculeId);
            stmt.setLong(2, reservationId);
            ResultSet rs = stmt.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public void create(PlanningTrajet p) {
        String sql = "INSERT INTO planning_trajet " +
                     "(reservation_id, vehicule_id, lieu_depart_id, lieu_arrivee_id, " +
                     "duree_estimee, distance_estimee, statut_id) " +
                     "VALUES (?, ?, ?, ?, ?::interval, ?, ?)";
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setLong(1, p.getReservationId());
            if (p.getVehiculeId() != null) stmt.setLong(2, p.getVehiculeId()); else stmt.setNull(2, java.sql.Types.BIGINT);
            if (p.getLieuDepartId() != null) stmt.setLong(3, p.getLieuDepartId()); else stmt.setNull(3, java.sql.Types.BIGINT);
            if (p.getLieuArriveeId() != null) stmt.setLong(4, p.getLieuArriveeId()); else stmt.setNull(4, java.sql.Types.BIGINT);
            stmt.setString(5, p.getDureeEstimee());
            stmt.setDouble(6, p.getDistanceEstimee());
            stmt.setLong(7, p.getStatutId());
            stmt.executeUpdate();
            ResultSet keys = stmt.getGeneratedKeys();
            if (keys.next()) p.setId(keys.getLong(1));
        } catch (SQLException e) { e.printStackTrace(); }
    }

    public void update(PlanningTrajet p) {
        String sql = "UPDATE planning_trajet SET " +
                     "vehicule_id = ?, lieu_depart_id = ?, lieu_arrivee_id = ?, " +
                     "duree_estimee = ?::interval, distance_estimee = ?, statut_id = ?, " +
                     "updated_at = NOW() WHERE id = ?";
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            if (p.getVehiculeId() != null) stmt.setLong(1, p.getVehiculeId()); else stmt.setNull(1, java.sql.Types.BIGINT);
            if (p.getLieuDepartId() != null) stmt.setLong(2, p.getLieuDepartId()); else stmt.setNull(2, java.sql.Types.BIGINT);
            if (p.getLieuArriveeId() != null) stmt.setLong(3, p.getLieuArriveeId()); else stmt.setNull(3, java.sql.Types.BIGINT);
            stmt.setString(4, p.getDureeEstimee());
            stmt.setDouble(5, p.getDistanceEstimee());
            stmt.setLong(6, p.getStatutId());
            stmt.setLong(7, p.getId());
            stmt.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }

    public void delete(long id) {
        String sql = "DELETE FROM planning_trajet WHERE id = ?";
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            stmt.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }
}
