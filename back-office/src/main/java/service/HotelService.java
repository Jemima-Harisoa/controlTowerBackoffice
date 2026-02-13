package service;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.Hotel;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import util.DatabaseConnection;

public class HotelService {
    private DatabaseConnection dbConnection = DatabaseConnection.getInstance();

    /**
     * Récupère tous les hôtels disponibles
     * @return Liste des hôtels disponibles
     */
    public List<Hotel> getAvailableHotels() {
        List<Hotel> hotels = new ArrayList<>();
        String query = "SELECT * FROM hotels WHERE is_active = true ORDER BY nom";
        
        try (Connection conn = dbConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {
            
            while (rs.next()) {
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
                hotels.add(hotel);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return hotels;
    }

    /**
     * Récupère un hôtel par son ID
     * @param id ID de l'hôtel
     * @return L'hôtel correspondant ou null si non trouvé
     */
    public Hotel getHotelById(int id) {
        String query = "SELECT * FROM hotels WHERE id = ?";
        
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
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
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
    /**
 * Crée un nouvel hôtel dans la base de données
 * @param hotel L'hôtel à créer
 * @return true si la création a réussi, false sinon
 */
public boolean createHotel(Hotel hotel) {
    String query = "INSERT INTO hotels (nom, adresse, ville, pays, nombre_etoiles, description, is_active, created_at, updated_at) " +
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
            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    hotel.setId(generatedKeys.getInt(1));
                }
            }
            return true;
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    
    return false;
}

/**
 * Met à jour un hôtel existant dans la base de données
 * @param hotel L'hôtel à mettre à jour
 * @return true si la mise à jour a réussi, false sinon
 */
public boolean updateHotel(Hotel hotel) {
    String query = "UPDATE hotels SET nom = ?, adresse = ?, ville = ?, pays = ?, " +
                  "nombre_etoiles = ?, description = ?, updated_at = NOW() " +
                  "WHERE id = ?";
    
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
 * Supprime un hôtel de la base de données
 * @param id L'identifiant de l'hôtel à supprimer
 * @return true si la suppression a réussi, false sinon
 */
public boolean deleteHotel(int id) {
    String query = "DELETE FROM hotels WHERE id = ?";
    
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
/**
 * Récupère tous les hôtels (actifs ou non)
 */
public List<Hotel> getAllHotels() {
    List<Hotel> hotels = new ArrayList<>();
    String query = "SELECT * FROM hotels ORDER BY id";

    try (Connection conn = dbConnection.getConnection();
         Statement stmt = conn.createStatement();
         ResultSet rs = stmt.executeQuery(query)) {

        while (rs.next()) {
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

            hotels.add(hotel);
        }

    } catch (SQLException e) {
        e.printStackTrace();
    }

    return hotels;
}


}
