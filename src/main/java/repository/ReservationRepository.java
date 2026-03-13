package repository;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import dto.ReservationView;
import model.Reservation;
import util.DatabaseConnection;

/**
 * Repository pour l'accès aux données des réservations
 * Responsabile : exécution des requêtes SQL et gestion de la base de données
 */
public class ReservationRepository {
    private DatabaseConnection dbConnection = DatabaseConnection.getInstance();

    /**
     * Récupère toutes les réservations
     */
    public List<Reservation> findAll() {
        List<Reservation> reservations = new ArrayList<>();
        String query = "SELECT * FROM reservations ORDER BY date_arrivee DESC";

        try (Connection conn = dbConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {

            while (rs.next()) {
                Reservation r = new Reservation();
                r.setId(rs.getInt("id"));
                r.setNom(rs.getString("nom"));
                r.setEmail(rs.getString("email"));
                r.setDateArrivee(rs.getTimestamp("date_arrivee"));
                r.setHeure(rs.getString("heure"));
                r.setNombrePersonnes(rs.getInt("nombre_personnes"));
                r.setHotelId(rs.getInt("hotel_id"));
                r.setConfirmed(rs.getBoolean("is_confirmed"));
                r.setCreatedAt(rs.getTimestamp("created_at"));
                r.setUpdatedAt(rs.getTimestamp("updated_at"));
                reservations.add(r);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return reservations;
    }

    /**
     * Récupère une réservation par son ID
     */
    public Reservation findById(int id) {
        String query = "SELECT * FROM reservations WHERE id = ?";
        
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                Reservation reservation = new Reservation();
                reservation.setId(rs.getInt("id"));
                reservation.setNom(rs.getString("nom"));
                reservation.setEmail(rs.getString("email"));
                reservation.setDateArrivee(rs.getTimestamp("date_arrivee"));
                reservation.setHeure(rs.getString("heure"));
                reservation.setNombrePersonnes(rs.getInt("nombre_personnes"));
                reservation.setHotelId(rs.getInt("hotel_id"));
                reservation.setConfirmed(rs.getBoolean("is_confirmed"));
                reservation.setCreatedAt(rs.getTimestamp("created_at"));
                reservation.setUpdatedAt(rs.getTimestamp("updated_at"));
                return reservation;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }

    /**
     * Crée une nouvelle réservation
     */
    public Reservation create(Reservation reservation) {
        String query = "INSERT INTO reservations (nom, email, date_arrivee, heure, nombre_personnes, hotel_id, is_confirmed, created_at, updated_at) " +
                      "VALUES (?, ?, ?, ?, ?, ?, false, NOW(), NOW())";
        
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, reservation.getNom());
            stmt.setString(2, reservation.getEmail());
            stmt.setTimestamp(3, reservation.getDateArrivee());
            stmt.setString(4, reservation.getHeure());
            stmt.setInt(5, reservation.getNombrePersonnes());
            stmt.setInt(6, reservation.getHotelId());
            
            int affectedRows = stmt.executeUpdate();
            
            if (affectedRows > 0) {
                ResultSet generatedKeys = stmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    reservation.setId(generatedKeys.getInt(1));
                }
                generatedKeys.close();
            }
            
            return affectedRows > 0 ? reservation : null;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }

    /**
     * Met à jour une réservation
     */
    public boolean update(Reservation reservation) {
        String query = "UPDATE reservations SET nom = ?, email = ?, date_arrivee = ?, " +
                      "heure = ?, nombre_personnes = ?, hotel_id = ?, is_confirmed = ?, updated_at = NOW() " +
                      "WHERE id = ?";
        
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setString(1, reservation.getNom());
            stmt.setString(2, reservation.getEmail());
            stmt.setTimestamp(3, reservation.getDateArrivee());
            stmt.setString(4, reservation.getHeure());
            stmt.setInt(5, reservation.getNombrePersonnes());
            stmt.setInt(6, reservation.getHotelId());
            stmt.setBoolean(7, reservation.isConfirmed());
            stmt.setInt(8, reservation.getId());
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }

    /**
     * Supprime une réservation
     */
    public boolean delete(int id) {
        String query = "DELETE FROM reservations WHERE id = ?";
        
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

    // ==================== PLANNING OPERATIONS ====================

    /**
     * Récupère les réservations non assignées : celles dont l'id n'apparaît pas dans planning_trajet
     */
    public List<Reservation> findNonAssignees() {
        List<Reservation> reservations = new ArrayList<>();
        String query = "SELECT * FROM reservations WHERE id NOT IN (SELECT reservation_id FROM planning_trajet) ORDER BY date_arrivee ASC";

        try (Connection conn = dbConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {

            while (rs.next()) {
                Reservation r = new Reservation();
                r.setId(rs.getInt("id"));
                r.setNom(rs.getString("nom"));
                r.setEmail(rs.getString("email"));
                r.setDateArrivee(rs.getTimestamp("date_arrivee"));
                r.setHeure(rs.getString("heure"));
                r.setNombrePersonnes(rs.getInt("nombre_personnes"));
                r.setHotelId(rs.getInt("hotel_id"));
                r.setConfirmed(rs.getBoolean("is_confirmed"));
                r.setCreatedAt(rs.getTimestamp("created_at"));
                r.setUpdatedAt(rs.getTimestamp("updated_at"));
                reservations.add(r);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return reservations;
    }
    /**
     * Récupère les réservations non assignées : celles dont l'id n'apparaît pas dans planning_trajet
     */
    public List<ReservationView> findNonAssigneesForView() {
        List<ReservationView> reservations = new ArrayList<>();
        String query = "SELECT r.id, r.nom, r.email, r.date_arrivee, r.heure, r.nombre_personnes, " + 
                        "h.nom as nom_hotel, r.is_confirmed " + 
                        "FROM reservations r " + 
                        "JOIN hotel h ON r.hotel_id = h.id "  +
                        "WHERE r.id NOT IN (SELECT reservation_id FROM planning_trajet) ORDER BY date_arrivee ASC";

        try (Connection conn = dbConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {
                
                while (rs.next()) {
                    reservations.add(mapRowToReservationView(rs));
                }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return reservations;
    }
    // ==================== MÉTHODES D'AFFICHAGE (View) ====================

    /**
     * Récupère toutes les réservations formatées pour l'affichage
     */
    public List<ReservationView> findAllForView() {
        List<ReservationView> reservations = new ArrayList<>();
        String query = "SELECT r.id, r.nom, r.email, r.date_arrivee, r.heure, r.nombre_personnes, " +
                      "h.nom as nom_hotel, r.is_confirmed " +
                      "FROM reservations r " +
                      "JOIN hotel h ON r.hotel_id = h.id " +
                      "ORDER BY r.date_arrivee DESC";
        
        try (Connection conn = dbConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {
            
            while (rs.next()) {
                reservations.add(mapRowToReservationView(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return reservations;
    }

    /**
     * Récupère les réservations filtrées par date pour l'affichage
     */
    public List<ReservationView> findByDateForView(String date) {
        List<ReservationView> reservations = new ArrayList<>();
        String query = "SELECT r.id, r.nom, r.email, r.date_arrivee, r.heure, r.nombre_personnes, " +
                      "h.nom as nom_hotel, r.is_confirmed " +
                      "FROM reservations r " +
                      "JOIN hotel h ON r.hotel_id = h.id " +
                      "WHERE DATE(r.date_arrivee) = ? " +
                      "ORDER BY r.date_arrivee DESC";
        
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setDate(1, Date.valueOf(date));
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                reservations.add(mapRowToReservationView(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return reservations;
    }

    /**
     * Récupère les réservations filtrées par hôtel pour l'affichage
     */
    public List<ReservationView> findByHotelForView(int hotelId) {
        List<ReservationView> reservations = new ArrayList<>();
        String query = "SELECT r.id, r.nom, r.email, r.date_arrivee, r.heure, r.nombre_personnes, " +
                      "h.nom as nom_hotel, r.is_confirmed " +
                      "FROM reservations r " +
                      "JOIN hotel h ON r.hotel_id = h.id " +
                      "WHERE r.hotel_id = ? " +
                      "ORDER BY r.date_arrivee DESC";
        
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, hotelId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                reservations.add(mapRowToReservationView(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return reservations;
    }

    /**
     * Récupère les réservations filtrées par date et hôtel pour l'affichage
     */
    public List<ReservationView> findByDateAndHotelForView(String date, int hotelId) {
        List<ReservationView> reservations = new ArrayList<>();
        String query = "SELECT r.id, r.nom, r.email, r.date_arrivee, r.heure, r.nombre_personnes, " +
                      "h.nom as nom_hotel, r.is_confirmed " +
                      "FROM reservations r " +
                      "JOIN hotel h ON r.hotel_id = h.id " +
                      "WHERE DATE(r.date_arrivee) = ? AND r.hotel_id = ? " +
                      "ORDER BY r.date_arrivee DESC";
        
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setDate(1, Date.valueOf(date));
            stmt.setInt(2, hotelId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                reservations.add(mapRowToReservationView(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return reservations;
    }

    // ==================== UTILITAIRES ====================

    /**
     * Mappe une ligne de ResultSet à un objet ReservationView
     */
    private ReservationView mapRowToReservationView(ResultSet rs) throws SQLException {
        java.text.SimpleDateFormat dateFormat = new java.text.SimpleDateFormat("dd MMMM yyyy", java.util.Locale.FRENCH);
        
        ReservationView reservationView = new ReservationView();
        reservationView.setId(rs.getInt("id"));
        reservationView.setNomFormate(rs.getString("nom"));
        reservationView.setEmail(rs.getString("email"));
        
        Timestamp dateArrivee = rs.getTimestamp("date_arrivee");
        reservationView.setDateAffichee(dateFormat.format(dateArrivee));
        
        reservationView.setHeureAffichee(rs.getString("heure"));
        reservationView.setNombrePersonnes(rs.getInt("nombre_personnes"));
        reservationView.setNomHotel(rs.getString("nom_hotel"));
        reservationView.setConfirmed(rs.getBoolean("is_confirmed"));
        
        return reservationView;
    }
}
