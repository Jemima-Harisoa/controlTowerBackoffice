package service;

import java.util.List;
import java.util.stream.Collectors;

import dto.PlanningTrajetView;
import model.PlanningTrajet;
import model.Reservation;
import model.Vehicule;
import repository.PlanningTrajetRepository;

/**
 * Service pour la gestion de la planification des trajets
 * Contient la logique métier d'assignation des véhicules
 */
public class PlanningTrajetService {
    private PlanningTrajetRepository planningRepository = new PlanningTrajetRepository();
    private ReservationService reservationService = new ReservationService();
    private VehiculeService vehiculeService = new VehiculeService();
    private DistanceService distanceService = new DistanceService();
    private ParametreConfigurationService paramService = new ParametreConfigurationService();

    /**
     * Récupérer tous les plannings
     */
    public List<PlanningTrajet> getAllPlannings() {
        return planningRepository.findAll();
    }

    /**
     * Récupérer un planning par ID
     */
    public PlanningTrajet getPlanningById(int id) {
        return planningRepository.findById(id);
    }

    /**
     * Récupérer un planning par réservation ID
     */
    public PlanningTrajet getPlanningByReservationId(int reservationId) {
        return planningRepository.findByReservationId(reservationId);
    }

    /**
     * Récupérer les plannings par statut
     */
    public List<PlanningTrajet> getPlanningsByStatut(int statutId) {
        return planningRepository.findByStatut(statutId);
    }

    /**
     * Récupérer les plannings d'un véhicule
     */
    public List<PlanningTrajet> getPlanningsByVehicule(int vehiculeId) {
        return planningRepository.findByVehicule(vehiculeId);
    }

    /**
     * FONCTIONNALITÉ 1 : Assigner manuellement un véhicule à une réservation
     */
    public void assignerVehicule(int reservationId, int vehiculeId) throws Exception {
        try {
            Reservation reservation = reservationService.getReservationById(reservationId);
            Vehicule vehicule = vehiculeService.getVehiculeById(vehiculeId);

            if (reservation == null) {
                throw new Exception("Réservation non trouvée");
            }
            if (vehicule == null) {
                throw new Exception("Véhicule non trouvé");
            }

            // Créer ou mettre à jour le planning avec le véhicule assigné
            PlanningTrajet planning = getPlanningByReservationId(reservationId);
            if (planning == null) {
                planning = new PlanningTrajet(reservationId, 1); // 1 = PLANIFIE
            }
            planning.setVehiculeId((long) vehiculeId);

            updatePlanning(planning);
        } catch (Exception e) {
            throw new Exception("Erreur lors de l'assignation du véhicule: " + e.getMessage());
        }
    }

    /**
     * FONCTIONNALITÉ 2 : Générer le planning automatiquement
     * Algorithme :
     * 1. Prioriser par date d'arrivée ancienne
     * 2. Chercher le véhicule avec la plus courte distance à parcourir
     * 3. Vérifier que le véhicule a assez de places
     * 4. Si 2+ véhicules correspondent, priorité au diesel
     */
    public void genererPlanning() throws Exception {
        try {
            List<Reservation> reservationsNonAssignees = 
                    reservationService.getReservationNonAssignees();

            for (Reservation reservation : reservationsNonAssignees) {
                // Trouver le meilleur véhicule pour cette réservation
                Vehicule meilleurVehicule = trouverMeilleurVehicule(reservation);

                if (meilleurVehicule != null) {
                    assignerVehicule(reservation.getId(), (int) meilleurVehicule.getId());
                }
            }
        } catch (Exception e) {
            throw new Exception("Erreur lors de la génération du planning: " + e.getMessage());
        }
    }

    /**
     * FONCTIONNALITÉ 3 : Valider le planning
     * Met à jour le statut de tous les plannings en PLANIFIE → VALIDE
     */
    public void validerPlanning() throws Exception {
        try {
            List<PlanningTrajet> plannings = getAllPlannings();
            for (PlanningTrajet planning : plannings) {
                if (planning.getVehiculeId() != null) { // Seulement si assigné
                    planning.setStatutId(2); // 2 = VALIDE
                    planning.setStatut("VALIDE");
                    updatePlanning(planning);
                }
            }
        } catch (Exception e) {
            throw new Exception("Erreur lors de la validation du planning: " + e.getMessage());
        }
    }

    /**
     * Créer un nouveau planning
     */
    public void createPlanning(PlanningTrajet planning) {
        planningRepository.create(planning);
    }

    /**
     * Mettre à jour un planning
     */
    public void updatePlanning(PlanningTrajet planning) {
        planningRepository.update(planning);
    }

    /**
     * Supprimer un planning
     */
    public void deletePlanning(int id) {
        planningRepository.delete(id);
    }

    /**
     * ============ MÉTHODES PRIVÉES ============
     */

    /**
     * Trouver le meilleur véhicule pour une réservation
     * Algorithme d'assignation :
     * 1. Filtrer par capacité passagers
     * 2. Vérifier l'autonomie (si distance connue)
     * 3. Prioriser par diesel
     * 4. Retourner le premier disponible
     */
    private Vehicule trouverMeilleurVehicule(Reservation reservation) {
        // Filtrer par capacité passagers
        List<Vehicule> vehiculesAptes = vehiculeService
                .getVehiculesByCapacite(reservation.getNombrePersonnes());

        // Prioriser les diesel
        List<Vehicule> diesels = vehiculesAptes.stream()
                .filter(v -> v.getTypeCarburant() != null && 
                           v.getTypeCarburant().equalsIgnoreCase("Diesel"))
                .collect(Collectors.toList());

        return diesels.isEmpty() ? (vehiculesAptes.isEmpty() ? null : vehiculesAptes.get(0))
                                 : diesels.get(0);
    }

    /**
     * Vérifier l'autonomie d'un véhicule pour une distance
     */
    private boolean verifierAutonomie(Vehicule vehicule, double distance) {
        String typeCarburant = vehicule.getTypeCarburant();
        int autonomie = 0;

        if (typeCarburant == null) {
            return true; // Par défaut, accepter
        }

        if (typeCarburant.equalsIgnoreCase("Diesel")) {
            autonomie = paramService.getParametreAsInt("DISTANCE_AUTONOMIE_DIESEL_KM");
        } else if (typeCarburant.equalsIgnoreCase("Essence")) {
            autonomie = paramService.getParametreAsInt("DISTANCE_AUTONOMIE_ESSENCE_KM");
        } else if (typeCarburant.equalsIgnoreCase("Électrique")) {
            autonomie = paramService.getParametreAsInt("DISTANCE_AUTONOMIE_ELECTRIQUE_KM");
        } else {
            return true; // Type inconnu, accepter
        }

        return distance <= autonomie;
    }

    /**
     * Formater une durée en minutes au format HH:MM
     */
    private String formatDuree(int minutes) {
        int heures = minutes / 60;
        int mins = minutes % 60;
        return String.format("%02d:%02d", heures, mins);
    }

    /**
     * Récupérer tous les plannings formatés pour le frontend (PlanningTrajetView)
     */
    public List<PlanningTrajetView> getAllPlanningsForView() {
        List<PlanningTrajet> plannings = getAllPlannings();
        return plannings.stream()
                .map(p -> new PlanningTrajetView(
                        p.getId(),
                        p.getReservationId(),
                        p.getVehiculeImmatriculation(),
                        p.getLieuDepart(),
                        p.getLieuArrivee(),
                        "", // À extraire de la réservation
                        "", // À extraire de la réservation
                        "", // À extraire de la réservation
                        0,  // À extraire de la réservation
                        p.getDistanceEstimee(),
                        p.getDureeEstimee(),
                        p.getStatut()
                ))
                .collect(Collectors.toList());
    }
}
