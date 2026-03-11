package service;

import java.util.List;

import model.Hotel;
import repository.HotelRepository;

/**
 * Service pour la logique métier des hôtels
 * Responsable : logique métier uniquement
 * Exécution SQL déléguée à HotelRepository
 */
public class HotelService {
    private HotelRepository hotelRepository = new HotelRepository();

    /**
     * Récupère tous les hôtels disponibles
     */
    public List<Hotel> getAvailableHotels() {
        return hotelRepository.findAllActive();
    }

    /**
     * Récupère tous les hôtels
     */
    public List<Hotel> getAllHotels() {
        return hotelRepository.findAll();
    }

    /**
     * Récupère un hôtel par son ID
     */
    public Hotel getHotelById(int id) {
        return hotelRepository.findById(id);
    }

    /**
     * Crée un nouvel hôtel
     */
    public boolean createHotel(Hotel hotel) {
        Hotel created = hotelRepository.create(hotel);
        return created != null;
    }

    /**
     * Met à jour un hôtel
     */
    public boolean updateHotel(Hotel hotel) {
        return hotelRepository.update(hotel);
    }

    /**
     * Supprime un hôtel
     */
    public boolean deleteHotel(int id) {
        return hotelRepository.delete(id);
    }
}
