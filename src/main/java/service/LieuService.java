package service;

import java.util.List;
import java.util.stream.Collectors;
import model.Lieu;
import repository.LieuRepository;
import dto.LieuView;

/**
 * Service pour la gestion des lieux
 */
public class LieuService {
    private LieuRepository lieuRepository = new LieuRepository();

    /**
     * Récupérer tous les lieux actifs
     */
    public List<Lieu> getAllLieux() {
        return lieuRepository.findAll();
    }

    /**
     * Récupérer un lieu par ID
     */
    public Lieu getLieuById(long id) {
        return lieuRepository.findById(id);
    }

    /**
     * Récupérer les lieux par type (aéroports, gares, hôtels, etc.)
     */
    public List<Lieu> getLieuxByType(long typeLieuId) {
        return lieuRepository.findByTypeLieu(typeLieuId);
    }

    /**
     * Récupérer les lieux par ville
     */
    public List<Lieu> getLieuxByVille(String ville) {
        return lieuRepository.findByVille(ville);
    }

    /**
     * Récupérer les lieux d'un hôtel
     */
    public List<Lieu> getLieuxByHotel(long hotelId) {
        return lieuRepository.findByHotelId(hotelId);
    }

    /**
     * Récupérer tous les lieux formatés pour le frontend (LieuView)
     */
    public List<LieuView> getAllLieuxForView() {
        List<Lieu> lieux = getAllLieux();
        return lieux.stream()
                .map(l -> new LieuView(
                        l.getId(),
                        l.getNom(),
                        l.getTypeLieu(),
                        l.getVille(),
                        l.getPays()
                ))
                .collect(Collectors.toList());
    }

    /**
     * Créer un nouveau lieu
     */
    public void createLieu(Lieu lieu) {
        lieuRepository.create(lieu);
    }

    /**
     * Mettre à jour un lieu
     */
    public void updateLieu(Lieu lieu) {
        lieuRepository.update(lieu);
    }

    /**
     * Supprimer un lieu
     */
    public void deleteLieu(long id) {
        lieuRepository.delete(id);
    }

    /**
     * Obtenir les lieux de départ/arrivée possibles pour les trajets
     */
    public List<Lieu> getLieuxPourTrajets() {
        List<Lieu> lieux = getAllLieux();
        // Filtrer pour ne garder que les lieux principaux (hôtels, aéroports, gares)
        return lieux.stream()
                .filter(l -> l.getTypeLieu() != null && 
                           (l.getTypeLieu().contains("Hôtel") || 
                            l.getTypeLieu().contains("Aéroport") || 
                            l.getTypeLieu().contains("Gare")))
                .collect(Collectors.toList());
    }
}
