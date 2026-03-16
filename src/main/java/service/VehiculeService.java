package service;

import java.util.List;
import java.util.stream.Collectors;
import model.Vehicule;
import repository.VehiculeRepository;
import dto.VehiculeView;

/**
 * Service pour la gestion des véhicules
 */
public class VehiculeService {
    private VehiculeRepository vehiculeRepository = new VehiculeRepository();

    /**
     * Récupérer tous les véhicules
     */
    public List<Vehicule> getAllVehicules() {
        return vehiculeRepository.findAll();
    }

    /**
     * Récupérer un véhicule par ID
     */
    public Vehicule getVehiculeById(long id) {
        return vehiculeRepository.findById(id);
    }

    /**
     * Récupérer les véhicules disponibles
     */
    public List<Vehicule> getVehiculesDisponibles() {
        return vehiculeRepository.findByIsAvailable(true);
    }

    /**
     * Récupérer les véhicules avec capacité >= nombre de passagers
     */
    public List<Vehicule> getVehiculesByCapacite(int nombrePassagers) {
        return vehiculeRepository.findByCapacitePassagers(nombrePassagers);
    }

    /**
     * Récupérer les véhicules d'un type de carburant spécifique (diesel, essence, etc.)
     */
    public List<Vehicule> getVehiculesByCarburant(long typeCarburantId) {
        return vehiculeRepository.findByTypeCarburant(typeCarburantId);
    }

    /**
     * Récupérer les véhicules disponibles formatés pour le frontend (VehiculeView)
     */
    public List<VehiculeView> getVehiculesDisponiblesForView() {
        List<Vehicule> vehicules = getVehiculesDisponibles();
        return vehicules.stream()
                .map(v -> new VehiculeView(
                        v.getId(),
                        v.getImmatriculation(),
                        v.getMarque(),
                        v.getModele(),
                        v.getAnnee(),
                        v.getTypeCarburant(),
                        v.getCapacitePassagers(),
                        v.isAvailable()
                ))
                .collect(Collectors.toList());
    }

    /**
     * Récupérer les véhicules diesel disponibles (priorité dans l'algo d'assignation)
     */
    public List<Vehicule> getVehiculesDieselsDisponibles() {
        List<Vehicule> vehicules = getVehiculesDisponibles();
        return vehicules.stream()
                .filter(v -> v.getTypeCarburant() != null && v.getTypeCarburant().equalsIgnoreCase("Diesel"))
                .collect(Collectors.toList());
    }

    /**
     * Créer un nouveau véhicule
     */
    public void createVehicule(Vehicule vehicule) {
        vehiculeRepository.create(vehicule);
    }

    /**
     * Mettre à jour un véhicule
     */
    public void updateVehicule(Vehicule vehicule) {
        vehiculeRepository.update(vehicule);
    }

    /**
     * Supprimer un véhicule
     */
    public void deleteVehicule(long id) {
        vehiculeRepository.delete(id);
    }

    /**
     * Marquer un véhicule comme indisponible
     */
    public void setVehiculeIndisponible(long id) {
        Vehicule vehicule = getVehiculeById(id);
        if (vehicule != null) {
            vehicule.setAvailable(false);
            updateVehicule(vehicule);
        }
    }

    /**
     * Marquer un véhicule comme disponible
     */
    public void setVehiculeDisponible(long id) {
        Vehicule vehicule = getVehiculeById(id);
        if (vehicule != null) {
            vehicule.setAvailable(true);
            updateVehicule(vehicule);
        }
    }
}
