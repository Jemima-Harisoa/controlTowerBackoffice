package repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import model.Vehicule;
import util.DatabaseConnection;

/**
 * Repository pour la table vehicules
 */
public class VehiculeRepository {
    private DatabaseConnection dbConnection = DatabaseConnection.getInstance();

    private Vehicule mapRow(ResultSet rs) throws SQLException {
        Vehicule v = new Vehicule();
        v.setId(rs.getLong("id"));
        v.setImmatriculation(rs.getString("immatriculation"));
        v.setMarque(rs.getString("marque"));
        v.setModele(rs.getString("modele"));
        v.setAnnee(rs.getInt("annee"));
        v.setTypeCarburantId(rs.getLong("type_carburant_id"));
        v.setTypeCarburant(rs.getString("type_carburant"));
        v.setCapacitePassagers(rs.getInt("capacite_passagers"));
        v.setAvailable(rs.getBoolean("is_available"));
        v.setHeureDisponibleDebut(rs.getString("heure_disponible_debut"));
        v.setHeureDisponibleCourante(rs.getString("heure_disponible_courante"));
        return v;
    }

    public List<Vehicule> findAll() {
        List<Vehicule> list = new ArrayList<>();
        String sql = "SELECT v.*, tc.libelle as type_carburant " +
                     "FROM vehicules v " +
                     "LEFT JOIN type_carburant tc ON v.type_carburant_id = tc.id " +
                     "ORDER BY v.immatriculation";
        try (Connection conn = dbConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public Vehicule findById(long id) {
        String sql = "SELECT v.*, tc.libelle as type_carburant " +
                     "FROM vehicules v " +
                     "LEFT JOIN type_carburant tc ON v.type_carburant_id = tc.id " +
                     "WHERE v.id = ?";
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public List<Vehicule> findByIsAvailable(boolean available) {
        List<Vehicule> list = new ArrayList<>();
        String sql = "SELECT v.*, tc.libelle as type_carburant " +
                     "FROM vehicules v " +
                     "LEFT JOIN type_carburant tc ON v.type_carburant_id = tc.id " +
                     "WHERE v.is_available = ? " +
                     "ORDER BY v.immatriculation";
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setBoolean(1, available);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<Vehicule> findByCapacitePassagers(int minCapacite) {
        List<Vehicule> list = new ArrayList<>();
        String sql = "SELECT v.*, tc.libelle as type_carburant " +
                     "FROM vehicules v " +
                     "LEFT JOIN type_carburant tc ON v.type_carburant_id = tc.id " +
                     "WHERE v.capacite_passagers >= ? AND v.is_available = true " +
                     "ORDER BY v.capacite_passagers ASC";
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, minCapacite);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<Vehicule> findByTypeCarburant(long typeCarburantId) {
        List<Vehicule> list = new ArrayList<>();
        String sql = "SELECT v.*, tc.libelle as type_carburant " +
                     "FROM vehicules v " +
                     "LEFT JOIN type_carburant tc ON v.type_carburant_id = tc.id " +
                     "WHERE v.type_carburant_id = ? AND v.is_available = true";
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, typeCarburantId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public void create(Vehicule vehicule) {
        String sql = "INSERT INTO vehicules (immatriculation, marque, modele, annee, " +
                     "type_carburant_id, capacite_passagers, is_available, heure_disponible_debut, heure_disponible_courante) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?::time, ?::time)";
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, vehicule.getImmatriculation());
            stmt.setString(2, vehicule.getMarque());
            stmt.setString(3, vehicule.getModele());
            stmt.setInt(4, vehicule.getAnnee());
            stmt.setLong(5, vehicule.getTypeCarburantId());
            stmt.setInt(6, vehicule.getCapacitePassagers());
            stmt.setBoolean(7, vehicule.isAvailable());
            stmt.setString(8, vehicule.getHeureDisponibleDebut() != null ? vehicule.getHeureDisponibleDebut() : "00:00:00");
            stmt.setString(9, vehicule.getHeureDisponibleCourante() != null ? vehicule.getHeureDisponibleCourante() : "00:00:00");
            stmt.executeUpdate();
            ResultSet keys = stmt.getGeneratedKeys();
            if (keys.next()) vehicule.setId(keys.getLong(1));
        } catch (SQLException e) { e.printStackTrace(); }
    }

    public void update(Vehicule vehicule) {
        String sql = "UPDATE vehicules SET immatriculation = ?, marque = ?, modele = ?, annee = ?, " +
                     "type_carburant_id = ?, capacite_passagers = ?, is_available = ?, " +
                     "heure_disponible_debut = ?::time, heure_disponible_courante = ?::time, " +
                     "updated_at = NOW() WHERE id = ?";
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, vehicule.getImmatriculation());
            stmt.setString(2, vehicule.getMarque());
            stmt.setString(3, vehicule.getModele());
            stmt.setInt(4, vehicule.getAnnee());
            stmt.setLong(5, vehicule.getTypeCarburantId());
            stmt.setInt(6, vehicule.getCapacitePassagers());
            stmt.setBoolean(7, vehicule.isAvailable());
            stmt.setString(8, vehicule.getHeureDisponibleDebut() != null ? vehicule.getHeureDisponibleDebut() : "00:00:00");
            stmt.setString(9, vehicule.getHeureDisponibleCourante() != null ? vehicule.getHeureDisponibleCourante() : "00:00:00");
            stmt.setLong(10, vehicule.getId());
            stmt.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }

    public void delete(long id) {
        String sql = "DELETE FROM vehicules WHERE id = ?";
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            stmt.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }
}
