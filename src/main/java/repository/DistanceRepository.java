package repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import model.Distance;
import util.DatabaseConnection;

/**
 * Repository pour la table distances
 */
public class DistanceRepository {
    private DatabaseConnection dbConnection = DatabaseConnection.getInstance();

    private Distance mapRow(ResultSet rs) throws SQLException {
        Distance d = new Distance();
        d.setId(rs.getLong("id"));
        d.setLieuDepartId(rs.getLong("lieu_depart_id"));
        d.setLieuArriveeId(rs.getLong("lieu_arrivee_id"));
        d.setDistanceKm(rs.getDouble("distance_km"));
        d.setLieuDepartNom(rs.getString("lieu_depart_nom"));
        d.setLieuArriveeNom(rs.getString("lieu_arrivee_nom"));
        d.setCreatedAt(rs.getString("created_at"));
        d.setUpdatedAt(rs.getString("updated_at"));
        return d;
    }

    /**
     * Récupérer toutes les distances
     */
    public List<Distance> findAll() {
        List<Distance> list = new ArrayList<>();
        String sql = "SELECT d.*, l1.nom as lieu_depart_nom, l2.nom as lieu_arrivee_nom " +
                     "FROM distances d " +
                     "LEFT JOIN lieux l1 ON d.lieu_depart_id = l1.id " +
                     "LEFT JOIN lieux l2 ON d.lieu_arrivee_id = l2.id";
        try (Connection conn = dbConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Récupérer une distance entre deux lieux
     */
    public Distance findByLieux(long lieuDepartId, long lieuArriveeId) {
        String sql = "SELECT d.*, l1.nom as lieu_depart_nom, l2.nom as lieu_arrivee_nom " +
                     "FROM distances d " +
                     "LEFT JOIN lieux l1 ON d.lieu_depart_id = l1.id " +
                     "LEFT JOIN lieux l2 ON d.lieu_arrivee_id = l2.id " +
                     "WHERE (d.lieu_depart_id = ? AND d.lieu_arrivee_id = ?) " +
                     "OR (d.lieu_depart_id = ? AND d.lieu_arrivee_id = ?) " +
                     "LIMIT 1";
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, lieuDepartId);
            stmt.setLong(2, lieuArriveeId);
            stmt.setLong(3, lieuArriveeId);
            stmt.setLong(4, lieuDepartId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Récupérer les distances à partir d'un lieu
     */
    public List<Distance> findByLieuDepart(long lieuDepartId) {
        List<Distance> list = new ArrayList<>();
        String sql = "SELECT d.*, l1.nom as lieu_depart_nom, l2.nom as lieu_arrivee_nom " +
                     "FROM distances d " +
                     "LEFT JOIN lieux l1 ON d.lieu_depart_id = l1.id " +
                     "LEFT JOIN lieux l2 ON d.lieu_arrivee_id = l2.id " +
                     "WHERE d.lieu_depart_id = ?";
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, lieuDepartId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Créer une nouvelle distance
     */
    public void create(Distance distance) {
        String sql = "INSERT INTO distances (lieu_depart_id, lieu_arrivee_id, distance_km) " +
                     "VALUES (?, ?, ?)";
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, distance.getLieuDepartId());
            stmt.setLong(2, distance.getLieuArriveeId());
            stmt.setDouble(3, distance.getDistanceKm());
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * Mettre à jour une distance
     */
    public void update(Distance distance) {
        String sql = "UPDATE distances SET distance_km = ? WHERE id = ?";
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setDouble(1, distance.getDistanceKm());
            stmt.setLong(2, distance.getId());
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * Supprimer une distance
     */
    public void delete(long id) {
        String sql = "DELETE FROM distances WHERE id = ?";
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
