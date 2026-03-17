package service;

import java.util.List;
import model.Distance;
import repository.DistanceRepository;

/**
 * Service pour la gestion des distances
 */
public class DistanceService {
    private DistanceRepository distanceRepository = new DistanceRepository();

    /**
     * Récupérer toutes les distances
     */
    public List<Distance> getAllDistances() {
        return distanceRepository.findAll();
    }

    /**
     * Récupérer la distance entre deux lieux
     */
    public Distance getDistance(long lieuDepartId, long lieuArriveeId) {
        return distanceRepository.findByLieux(lieuDepartId, lieuArriveeId);
    }

    /**
     * Récupérer les distances à partir d'un lieu
     */
    public List<Distance> getDistancesFromLieu(long lieuDepartId) {
        return distanceRepository.findByLieuDepart(lieuDepartId);
    }

    /**
     * Calculer la distance entre deux lieux
     * Retourne la distance en km, 0 si non trouvée
     */
    public double calculerDistance(long lieuDepartId, long lieuArriveeId) {
        Distance unidirectionnelle = distanceRepository.findByLieux(lieuDepartId, lieuArriveeId);
        if (unidirectionnelle != null) {
            return unidirectionnelle.getDistanceKm();
        }
        return 0.0;
    }

    /**
     * Créer une nouvelle distance
     */
    public void createDistance(Distance distance) {
        distanceRepository.create(distance);
    }

    /**
     * Mettre à jour une distance
     */
    public void updateDistance(Distance distance) {
        distanceRepository.update(distance);
    }

    /**
     * Supprimer une distance
     */
    public void deleteDistance(long id) {
        distanceRepository.delete(id);
    }
}
