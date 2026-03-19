package repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import model.ParametreConfiguration;
import util.DatabaseConnection;

/**
 * Repository pour la table parametres_configuration
 */
public class ParametreConfigurationRepository {
    private DatabaseConnection dbConnection = DatabaseConnection.getInstance();

    private ParametreConfiguration mapRow(ResultSet rs) throws SQLException {
        ParametreConfiguration p = new ParametreConfiguration();
        p.setId(rs.getLong("id"));
        p.setCle(rs.getString("cle"));
        p.setValeur(rs.getString("valeur"));
        p.setTypeValeur(rs.getString("type_valeur"));
        p.setDescription(rs.getString("description"));
        p.setEffectiveDate(rs.getString("effective_date"));
        p.setCreatedAt(rs.getString("created_at"));
        p.setUpdatedAt(rs.getString("updated_at"));
        return p;
    }

    /**
     * Récupérer tous les paramètres
     */
    public List<ParametreConfiguration> findAll() {
        String sql = "SELECT * FROM parametres_configuration";
        List<ParametreConfiguration> list = new ArrayList<>();
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
     * Récupérer un paramètre par clé
     */
    public ParametreConfiguration findByCle(String cle) {
        String sql = "SELECT * FROM parametres_configuration WHERE cle = ?";
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, cle);
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
     * Créer un nouveau paramètre
     */
    public void create(ParametreConfiguration param) {
        String sql = "INSERT INTO parametres_configuration " +
                     "(cle, valeur, type_valeur, description) " +
                     "VALUES (?, ?, ?, ?)";
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, param.getCle());
            stmt.setString(2, param.getValeur());
            stmt.setString(3, param.getTypeValeur());
            stmt.setString(4, param.getDescription());
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * Mettre à jour un paramètre
     */
    public void update(ParametreConfiguration param) {
        String sql = "UPDATE parametres_configuration SET valeur = ?, updated_at = NOW() WHERE cle = ?";
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, param.getValeur());
            stmt.setString(2, param.getCle());
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * Supprimer un paramètre
     */
    public void deleteByCle(String cle) {
        String sql = "DELETE FROM parametres_configuration WHERE cle = ?";
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, cle);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
