package repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import model.Hotel;
import util.DatabaseConnection;

/**
 * Repository pour l'accès aux données des hôtels
 * Responsable : exécution des requêtes SQL et gestion de la base de données
 */
public class HotelRepository {
    private DatabaseConnection dbConnection = DatabaseConnection.getInstance();

    /**
     * Récupère tous les hôtels
     */
    public List<Hotel> findAll() {
        List<Hotel> hotels = new ArrayList<>();
        String query = "SELECT * FROM hotel ORDER BY nom";
        
        try (Connection conn = dbConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {
            
            while (rs.next()) {
                hotels.add(mapRowToHotel(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return hotels;
    }

    /**
     * Récupère tous les hôtels actifs
     */
    public List<Hotel> findAllActive() {
        List<Hotel> hotels = new ArrayList<>();
        String query = "SELECT * FROM hotel WHERE is_active = true ORDER BY nom";
        
        try (Connection conn = dbConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {
            
            while (rs.next()) {
                hotels.add(mapRowToHotel(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return hotels;
    }

    /**
     * Récupère un hôtel par son ID
     */
    public Hotel findById(int id) {
        String query = "SELECT * FROM hotel WHERE id = ?";
        
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return mapRowToHotel(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }

    /**
     * Crée un nouvel hôtel
     */
    public Hotel create(Hotel hotel) {
        String query = "INSERT INTO hotel (nom, adresse, ville, pays, nombre_etoiles, description, is_active, created_at, updated_at) " +
                      "VALUES (?, ?, ?, ?, ?, ?, true, NOW(), NOW())";
        
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, hotel.getNom());
            stmt.setString(2, hotel.getAdresse());
            stmt.setString(3, hotel.getVille());
            stmt.setString(4, hotel.getPays());
            stmt.setInt(5, hotel.getNombreEtoiles());
            stmt.setString(6, hotel.getDescription());
            
            int affectedRows = stmt.executeUpdate();
            
            if (affectedRows > 0) {
                ResultSet generatedKeys = stmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    hotel.setId(generatedKeys.getInt(1));
                }
                generatedKeys.close();
            }
            
            return affectedRows > 0 ? hotel : null;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }

    /**
     * Met à jour un hôtel
     */
    public boolean update(Hotel hotel) {
        String query = "UPDATE hotel SET nom = ?, adresse = ?, ville = ?, pays = ?, nombre_etoiles = ?, description = ?, updated_at = NOW() WHERE id = ?";
        
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setString(1, hotel.getNom());
            stmt.setString(2, hotel.getAdresse());
            stmt.setString(3, hotel.getVille());
            stmt.setString(4, hotel.getPays());
            stmt.setInt(5, hotel.getNombreEtoiles());
            stmt.setString(6, hotel.getDescription());
            stmt.setInt(7, hotel.getId());
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }

    /**
     * Supprime un hôtel
     */
    public boolean delete(int id) {
        String query = "DELETE FROM hotel WHERE id = ?";
        
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, id);
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }

    // ==================== UTILITAIRES ====================

    /**
     * Mappe une ligne de ResultSet à un objet Hotel
     */
    private Hotel mapRowToHotel(ResultSet rs) throws SQLException {
        Hotel hotel = new Hotel();
        hotel.setId(rs.getInt("id"));
        hotel.setNom(rs.getString("nom"));
        hotel.setAdresse(rs.getString("adresse"));
        hotel.setVille(rs.getString("ville"));
        hotel.setPays(rs.getString("pays"));
        hotel.setNombreEtoiles(rs.getInt("nombre_etoiles"));
        hotel.setDescription(rs.getString("description"));
        hotel.setActive(rs.getBoolean("is_active"));
        hotel.setCreatedAt(rs.getTimestamp("created_at"));
        hotel.setUpdatedAt(rs.getTimestamp("updated_at"));
        return hotel;
    }
}
