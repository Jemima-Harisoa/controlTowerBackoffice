package service;

import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
import model.Reservation;
import model.Client;
import dto.ReservationView;
import util.DatabaseConnection;

public class ReservationService {
    private DatabaseConnection dbConnection = DatabaseConnection.getInstance();
    private HotelService hotelService = new HotelService();
    private ClientService clientService = new ClientService();

    /**
     * Crée une nouvelle réservation avec un client
     * @param reservation La réservation à créer
     * @param client Le client associé
     * @return true si la création a réussi, false sinon
     */
    public boolean createReservationWithClient(Reservation reservation, Client client) {
        Connection conn = null;
        PreparedStatement stmtReservation = null;
        PreparedStatement stmtClient = null;
        ResultSet generatedKeys = null;
        
        try {
            conn = dbConnection.getConnection();
            conn.setAutoCommit(false); // Début de transaction
            
            // Création du client
            String clientQuery = "INSERT INTO clients (denomination, sexe_id, type_id) VALUES (?, ?, ?)";
            stmtClient = conn.prepareStatement(clientQuery, Statement.RETURN_GENERATED_KEYS);
            stmtClient.setString(1, client.getDenomination());
            
            if (client.getSexeId() != null) {
                stmtClient.setInt(2, client.getSexeId());
            } else {
                stmtClient.setNull(2, java.sql.Types.INTEGER);
            }
            
            if (client.getTypeId() != null) {
                stmtClient.setInt(3, client.getTypeId());
            } else {
                stmtClient.setNull(3, java.sql.Types.INTEGER);
            }
            
            stmtClient.executeUpdate();
            
            // Récupération de l'ID du client créé
            generatedKeys = stmtClient.getGeneratedKeys();
            int clientId = 0;
            if (generatedKeys.next()) {
                clientId = generatedKeys.getInt(1);
            }
            generatedKeys.close();
            stmtClient.close();
            
            // Création de la réservation
            String reservationQuery = "INSERT INTO reservations (nom, email, date_arrivee, heure, nombre_personnes, hotel_id, is_confirmed, created_at, updated_at) " +
                                     "VALUES (?, ?, ?, ?, ?, ?, false, NOW(), NOW())";
            stmtReservation = conn.prepareStatement(reservationQuery, Statement.RETURN_GENERATED_KEYS);
            
            stmtReservation.setString(1, reservation.getNom());
            stmtReservation.setString(2, reservation.getEmail());
            stmtReservation.setTimestamp(3, reservation.getDateArrivee());
            stmtReservation.setString(4, reservation.getHeure());
            stmtReservation.setInt(5, reservation.getNombrePersonnes());
            stmtReservation.setInt(6, reservation.getHotelId());
            
            int affectedRows = stmtReservation.executeUpdate();
            
            if (affectedRows > 0) {
                // Récupération de l'ID de la réservation créée
                generatedKeys = stmtReservation.getGeneratedKeys();
                if (generatedKeys.next()) {
                    reservation.setId(generatedKeys.getInt(1));
                }
                generatedKeys.close();
            }
            
            stmtReservation.close();
            conn.commit(); // Validation de la transaction
            conn.setAutoCommit(true);
            
            return affectedRows > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback(); // Annulation de la transaction en cas d'erreur
                    conn.setAutoCommit(true);
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            return false;
        } finally {
            // Fermeture des ressources
            try {
                if (generatedKeys != null) generatedKeys.close();
                if (stmtReservation != null) stmtReservation.close();
                if (stmtClient != null) stmtClient.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Récupère toutes les réservations pour l'affichage
     * @return Liste des réservations formatées pour l'affichage
     */
    public List<ReservationView> getAllReservationsForView() {
        List<ReservationView> reservations = new ArrayList<>();
        String query = "SELECT r.id, r.nom, r.email, r.date_arrivee, r.heure, r.nombre_personnes, " +
                      "h.nom as nom_hotel, r.is_confirmed " +
                      "FROM reservations r " +
                      "JOIN hotels h ON r.hotel_id = h.id " +
                      "ORDER BY r.date_arrivee DESC";
        
        try (Connection conn = dbConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {
            
            SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMMM yyyy");
            
            while (rs.next()) {
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
                
                reservations.add(reservationView);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return reservations;
    }

    /**
     * Récupère les réservations filtrées par date pour l'affichage
     * @param date Date de filtrage
     * @return Liste des réservations formatées pour l'affichage
     */
    public List<ReservationView> getReservationsForViewByDate(String date) {
        List<ReservationView> reservations = new ArrayList<>();
        String query = "SELECT r.id, r.nom, r.email, r.date_arrivee, r.heure, r.nombre_personnes, " +
                      "h.nom as nom_hotel, r.is_confirmed " +
                      "FROM reservations r " +
                      "JOIN hotels h ON r.hotel_id = h.id " +
                      "WHERE DATE(r.date_arrivee) = ? " +
                      "ORDER BY r.date_arrivee DESC";
        
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setString(1, date);
            ResultSet rs = stmt.executeQuery();
            
            SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMMM yyyy");
            
            while (rs.next()) {
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
                
                reservations.add(reservationView);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return reservations;
    }

    /**
     * Récupère les réservations filtrées par hôtel pour l'affichage
     * @param hotelId ID de l'hôtel
     * @return Liste des réservations formatées pour l'affichage
     */
    public List<ReservationView> getReservationsForViewByHotel(int hotelId) {
        List<ReservationView> reservations = new ArrayList<>();
        String query = "SELECT r.id, r.nom, r.email, r.date_arrivee, r.heure, r.nombre_personnes, " +
                      "h.nom as nom_hotel, r.is_confirmed " +
                      "FROM reservations r " +
                      "JOIN hotels h ON r.hotel_id = h.id " +
                      "WHERE r.hotel_id = ? " +
                      "ORDER BY r.date_arrivee DESC";
        
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, hotelId);
            ResultSet rs = stmt.executeQuery();
            
            SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMMM yyyy");
            
            while (rs.next()) {
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
                
                reservations.add(reservationView);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return reservations;
    }

    /**
     * Récupère les réservations filtrées par date et hôtel pour l'affichage
     * @param date Date de filtrage
     * @param hotelId ID de l'hôtel
     * @return Liste des réservations formatées pour l'affichage
     */
    public List<ReservationView> getReservationsForViewByDateAndHotel(String date, int hotelId) {
        List<ReservationView> reservations = new ArrayList<>();
        String query = "SELECT r.id, r.nom, r.email, r.date_arrivee, r.heure, r.nombre_personnes, " +
                      "h.nom as nom_hotel, r.is_confirmed " +
                      "FROM reservations r " +
                      "JOIN hotels h ON r.hotel_id = h.id " +
                      "WHERE DATE(r.date_arrivee) = ? AND r.hotel_id = ? " +
                      "ORDER BY r.date_arrivee DESC";
        
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setString(1, date);
            stmt.setInt(2, hotelId);
            ResultSet rs = stmt.executeQuery();
            
            SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMMM yyyy");
            
            while (rs.next()) {
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
                
                reservations.add(reservationView);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return reservations;
    }

    /**
     * Récupère toutes les réservations
     */
    public List<Reservation> getAllReservations() {
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
     * @param id ID de la réservation
     * @return La réservation correspondante ou null si non trouvée
     */
    public Reservation getReservationById(int id) {
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
     * Met à jour une réservation avec un client
     * @param reservation La réservation à mettre à jour
     * @param client Le client associé
     * @return true si la mise à jour a réussi, false sinon
     */
    public boolean updateReservationWithClient(Reservation reservation, Client client) {
        Connection conn = null;
        PreparedStatement stmtReservation = null;
        PreparedStatement stmtClient = null;
        
        try {
            conn = dbConnection.getConnection();
            conn.setAutoCommit(false); // Début de transaction
            
            // Mise à jour du client
            String clientQuery = "UPDATE clients SET denomination = ?, sexe_id = ?, type_id = ? WHERE id = " +
                               "(SELECT c.id FROM clients c JOIN reservations r ON c.denomination = r.nom WHERE r.id = ?)";
            stmtClient = conn.prepareStatement(clientQuery);
            stmtClient.setString(1, client.getDenomination());
            
            if (client.getSexeId() != null) {
                stmtClient.setInt(2, client.getSexeId());
            } else {
                stmtClient.setNull(2, java.sql.Types.INTEGER);
            }
            
            if (client.getTypeId() != null) {
                stmtClient.setInt(3, client.getTypeId());
            } else {
                stmtClient.setNull(3, java.sql.Types.INTEGER);
            }
            
            stmtClient.setInt(4, reservation.getId());
            stmtClient.executeUpdate();
            stmtClient.close();
            
            // Mise à jour de la réservation
            String reservationQuery = "UPDATE reservations SET nom = ?, email = ?, date_arrivee = ?, " +
                                     "heure = ?, nombre_personnes = ?, hotel_id = ?, is_confirmed = ?, updated_at = NOW() " +
                                     "WHERE id = ?";
            stmtReservation = conn.prepareStatement(reservationQuery);
            
            stmtReservation.setString(1, reservation.getNom());
            stmtReservation.setString(2, reservation.getEmail());
            stmtReservation.setTimestamp(3, reservation.getDateArrivee());
            stmtReservation.setString(4, reservation.getHeure());
            stmtReservation.setInt(5, reservation.getNombrePersonnes());
            stmtReservation.setInt(6, reservation.getHotelId());
            stmtReservation.setBoolean(7, reservation.isConfirmed());
            stmtReservation.setInt(8, reservation.getId());
            
            int affectedRows = stmtReservation.executeUpdate();
            stmtReservation.close();
            
            conn.commit(); // Validation de la transaction
            conn.setAutoCommit(true);
            
            return affectedRows > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback(); // Annulation de la transaction en cas d'erreur
                    conn.setAutoCommit(true);
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            return false;
        } finally {
            // Fermeture des ressources
            try {
                if (stmtReservation != null) stmtReservation.close();
                if (stmtClient != null) stmtClient.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Supprime une réservation
     * @param id ID de la réservation à supprimer
     * @return true si la suppression a réussi, false sinon
     */
    public boolean deleteReservation(int id) {
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
    
    /**
     * Récupère le client associé à une réservation
     * @param reservationId ID de la réservation
     * @return Le client associé ou null si non trouvé
     */
    public Client getClientByReservationId(int reservationId) {
        String query = "SELECT c.* FROM clients c JOIN reservations r ON c.denomination = r.nom WHERE r.id = ?";
        
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, reservationId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                Client client = new Client();
                client.setId(rs.getInt("id"));
                client.setDenomination(rs.getString("denomination"));
                client.setSexeId(rs.getObject("sexe_id", Integer.class));
                client.setTypeId(rs.getObject("type_id", Integer.class));
                return client;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
}
