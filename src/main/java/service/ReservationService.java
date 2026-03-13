package service;

import java.util.List;

import dto.ReservationView;
import model.Client;
import model.Reservation;
import repository.ReservationRepository;

/**
 * Service pour la logique métier des réservations
 * Responsable : logique métier uniquement
 * Exécution SQL déléguée à ReservationRepository
 */
public class ReservationService {
    private ReservationRepository reservationRepository = new ReservationRepository();
    private ClientService clientService = new ClientService();

    // ==================== CRUD OPERATIONS ====================

    /**
     * Récupère toutes les réservations
     */
    public List<Reservation> getAllReservations() {
        return reservationRepository.findAll();
    }

    /**
     * Récupère une réservation par son ID
     */
    public Reservation getReservationById(int id) {
        return reservationRepository.findById(id);
    }

    /**
     * Crée une nouvelle réservation avec un client
     * @param reservation La réservation à créer
     * @param client Le client associé
     * @return true si la création a réussi, false sinon
     */
    public boolean createReservationWithClient(Reservation reservation, Client client) {
        try {
            // Créer d'abord le client via ClientService
            boolean clientCreated = clientService.createClient(client);
            if (!clientCreated) {
                return false;
            }

            // Créer la réservation via Repository
            Reservation created = reservationRepository.create(reservation);
            return created != null;
            
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Met à jour une réservation avec un client
     * @param reservation La réservation à mettre à jour
     * @param client Le client associé
     * @return true si la mise à jour a réussi, false sinon
     */
    public boolean updateReservationWithClient(Reservation reservation, Client client) {
        try {
            // Mettre à jour le client via ClientService
            boolean clientUpdated = clientService.updateClient(client);
            if (!clientUpdated) {
                return false;
            }

            // Mettre à jour la réservation via Repository
            return reservationRepository.update(reservation);
            
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Supprime une réservation
     */
    public boolean deleteReservation(int id) {
        return reservationRepository.delete(id);
    }

    /**
     * Récupère le client associé à une réservation
     */
    public Client getClientByReservationId(int reservationId) {
        Reservation reservation = reservationRepository.findById(reservationId);
        if (reservation != null) {
            return clientService.getClientByDenomination(reservation.getNom());
        }
        return null;
    }

    // ==================== VIEW OPERATIONS (Affichage) ====================

    /**
     * Récupère toutes les réservations formatées pour l'affichage
     */
    public List<ReservationView> getAllReservationsForView() {
        return reservationRepository.findAllForView();
    }

    /**
     * Récupère les réservations filtrées par date pour l'affichage
     */
    public List<ReservationView> getReservationsForViewByDate(String date) {
        return reservationRepository.findByDateForView(date);
    }

    /**
     * Récupère les réservations filtrées par hôtel pour l'affichage
     */
    public List<ReservationView> getReservationsForViewByHotel(int hotelId) {
        return reservationRepository.findByHotelForView(hotelId);
    }

    /**
     * Récupère les réservations filtrées par date et hôtel pour l'affichage
     */
    public List<ReservationView> getReservationsForViewByDateAndHotel(String date, int hotelId) {
        return reservationRepository.findByDateAndHotelForView(date, hotelId);
    }

    // ==================== PLANNING OPERATIONS ====================

    /**
     * Récupère les réservations non assignées (sans véhicule)
     * Utilisé par le PlanningTrajetService pour la génération automatique du planning
     * @return Liste des réservations où vehicule_id IS NULL
     */
    public List<Reservation> getReservationNonAssignees() {
        return reservationRepository.findNonAssignees();
    }

    public List<ReservationView> getReservationNonAssigneesViews(){
        return  reservationRepository.findNonAssigneesForView();
    }
    /**
     * Mettre à jour une réservation (notamment le vehiculeId lors d'une assignation)
     */
    public void updateReservation(Reservation reservation) {
        reservationRepository.update(reservation);
    }
}

