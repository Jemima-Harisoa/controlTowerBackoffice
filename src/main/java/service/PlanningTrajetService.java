package service;

import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.stream.Collectors;

import dto.PlanningTrajetView;
import model.PlanningAssignationDetail;
import model.PlanningTrajet;
import model.Reservation;
import model.Vehicule;
import repository.PlanningAssignationDetailRepository;
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
    private PlanningAssignationDetailRepository planningAssignationDetailRepository = new PlanningAssignationDetailRepository();

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
     * Vérifier si un véhicule est déjà planifié pour une réservation donnée
     */
    public boolean getPlanningByVehiculeAndReservation(int vehiculeId, int reservationId) {
        return planningRepository.existsByVehiculeAndReservation(vehiculeId, reservationId);
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
            if (reservation.getDateArrivee() != null) {
                planning.setDatePlanification(reservation.getDateArrivee().toString());
            }

            boolean vehiculeDejaPlanifie = getPlanningByVehiculeAndReservation(vehiculeId, reservationId);

            // Vérification préalable avant update via véhicule + réservation
            // Si aucun planning n'existe encore pour cette réservation : insert
            if (planning.getId() == 0 && !vehiculeDejaPlanifie) {
                createPlanning(planning);
            } else {
                updatePlanning(planning);
            }

            // Mettre a jour les metadonnees de trajet et externaliser un detail agrege
            remplirDetailsPlanification(reservation);
            externaliserDetailAssignationVehicule(vehiculeId, reservation);
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
     * 5. Remplir lieux de départ/arrivée depuis la réservation
     * 6. Calculer distance et durée estimées
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
     * Remplir les détails de planification d'une réservation
     * - lieux de départ/arrivée
     * - distance estimée (depuis table distances)
     * - durée estimée (distance / vitesse_moyenne)
     */
    private void remplirDetailsPlanification(Reservation reservation) {
        try {
            PlanningTrajet planning = getPlanningByReservationId((int) reservation.getId());
            
            if (planning == null) {
                return;
            }

            // Récupérer les lieux depuis la réservation
            if (reservation.getLieuDepartId() != null && reservation.getLieuDepartId() > 0) {
                planning.setLieuDepartId(reservation.getLieuDepartId());
            }
            
            if (reservation.getLieuArriveeId() != null && reservation.getLieuArriveeId() > 0) {
                planning.setLieuArriveeId(reservation.getLieuArriveeId());
            }

            // Calculer distance et durée si les lieux sont disponibles
            if (planning.getLieuDepartId() != null && planning.getLieuArriveeId() != null) {
                double distance = distanceService.calculerDistance(
                        planning.getLieuDepartId(), 
                        planning.getLieuArriveeId()
                );
                
                if (distance > 0) {
                    planning.setDistanceEstimee(distance);
                    
                    // Calculer durée estimée = distance / vitesse_moyenne
                    int vitesseMoyenne = paramService.getParametreAsInt("VITESSE_MOYENNE_KMH");
                    if (vitesseMoyenne > 0) {
                        double heures = distance / vitesseMoyenne;
                        int minutes = (int) Math.round(heures * 60);
                            planning.setDureeEstimee(formatDureeForInterval(minutes));
                    }
                }
            }

            // Mettre à jour le planning avec les détails calculés
            updatePlanning(planning);

            } catch (Exception e) {
                System.err.println("Erreur lors du remplissage des détails: " + e.getMessage());
                e.printStackTrace();
            }
        }

        /**
         * Formater une durée en minutes au format HH:MM:SS pour INTERVAL PostgreSQL
         */
        private String formatDureeForInterval(int minutes) {
            int heures = minutes / 60;
            int mins = minutes % 60;
            int secs = 0;
            return String.format("%02d:%02d:%02d", heures, mins, secs);
        }

        /**
         * Exporte un detail d'assignation agrege par vehicule + date + heure.
         * Objectif sprint 3: stocker la liste des reservations assignees a un meme vehicule.
         */
        private void externaliserDetailAssignationVehicule(int vehiculeId, Reservation reservationPivot) {
            if (reservationPivot == null || reservationPivot.getDateArrivee() == null || reservationPivot.getHeure() == null) {
                return;
            }

            String dateArrivee = reservationPivot.getDateArrivee().toLocalDateTime().toLocalDate().toString();
            String heureArrivee = reservationPivot.getHeure();

            List<PlanningTrajet> planningsVehicule = getPlanningsByVehicule(vehiculeId);
            if (planningsVehicule == null || planningsVehicule.isEmpty()) {
                return;
            }

            List<PlanningTrajet> groupeMemeVehiculeDateHeure = new ArrayList<>();
            List<Reservation> reservationsGroupe = new ArrayList<>();

            for (PlanningTrajet p : planningsVehicule) {
                Reservation r = reservationService.getReservationById((int) p.getReservationId());
                if (r == null || r.getDateArrivee() == null || r.getHeure() == null) {
                    continue;
                }

                String rDate = r.getDateArrivee().toLocalDateTime().toLocalDate().toString();
                if (dateArrivee.equals(rDate) && heureArrivee.equals(r.getHeure())) {
                    groupeMemeVehiculeDateHeure.add(p);
                    reservationsGroupe.add(r);
                }
            }

            if (reservationsGroupe.isEmpty()) {
                return;
            }

            Vehicule vehicule = vehiculeService.getVehiculeById(vehiculeId);
            int capaciteVehicule = vehicule != null ? vehicule.getCapacitePassagers() : 0;
            int passagersTotal = reservationsGroupe.stream().mapToInt(Reservation::getNombrePersonnes).sum();
            int placesLibres = Math.max(capaciteVehicule - passagersTotal, 0);

                reservationsGroupe.sort(Comparator
                    .comparing(Reservation::getHeure, Comparator.nullsLast(String::compareTo))
                    .thenComparingInt(Reservation::getId));

                Map<Long, PlanningTrajet> planningByReservationId = new HashMap<>();
                for (PlanningTrajet planning : groupeMemeVehiculeDateHeure) {
                planningByReservationId.put(planning.getReservationId(), planning);
                }

                Reservation premiereReservation = reservationsGroupe.get(0);
                Reservation derniereReservation = reservationsGroupe.get(reservationsGroupe.size() - 1);
                PlanningTrajet planningPremiereReservation = planningByReservationId.get((long) premiereReservation.getId());
                PlanningTrajet planningDerniereReservation = planningByReservationId.get((long) derniereReservation.getId());

                String premierPointDepart = planningPremiereReservation != null
                    ? planningPremiereReservation.getLieuDepart()
                    : null;
                String dernierPointArrivee = planningDerniereReservation != null
                    ? planningDerniereReservation.getLieuArrivee()
                    : null;

                for (Reservation reservation : reservationsGroupe) {
                PlanningTrajet planningReservation = planningByReservationId.get((long) reservation.getId());

                String nomClient = reservation.getNom() == null ? "" : reservation.getNom();
                String pointsDepart = planningReservation != null ? planningReservation.getLieuDepart() : null;
                String pointsArrivee = planningReservation != null ? planningReservation.getLieuArrivee() : null;
                double distanceEstimee = planningReservation != null ? planningReservation.getDistanceEstimee() : 0;
                String dureeEstimee = planningReservation != null ? planningReservation.getDureeEstimee() : null;

                PlanningAssignationDetail detail = new PlanningAssignationDetail();
                detail.setVehiculeId(vehiculeId);
                detail.setDateArrivee(dateArrivee);
                detail.setHeureArrivee(reservation.getHeure());
                detail.setReservationId(reservation.getId());
                detail.setPremiereReservationId(premiereReservation.getId());
                detail.setReservationClient(nomClient + "(" + reservation.getNombrePersonnes() + "p)");
                detail.setNombrePassagersTotal(passagersTotal);
                detail.setCapaciteVehicule(capaciteVehicule);
                detail.setPlacesLibres(placesLibres);
                detail.setDistanceEstimee(distanceEstimee);
                detail.setDureeEstimee(dureeEstimee);
                detail.setPremierPointDepart(premierPointDepart);
                detail.setDernierPointArrivee(dernierPointArrivee);
                detail.setPointsDepart(pointsDepart);
                detail.setPointsArrivee(pointsArrivee);

                planningAssignationDetailRepository.upsert(detail);

                String heureArriveePrevue = calculerHeureArriveePrevue(reservation.getHeure(), dureeEstimee);
                planningAssignationDetailRepository.upsertHistoriqueAssignation(
                        vehiculeId,
                        reservation.getId(),
                        planningReservation != null ? planningReservation.getId() : null,
                        dateArrivee,
                        reservation.getHeure(),
                        heureArriveePrevue,
                        "PLANIFIE"
                );
                }
        }

        private String calculerHeureArriveePrevue(String heureDepart, String dureeInterval) {
            if (heureDepart == null || heureDepart.isEmpty() || dureeInterval == null || dureeInterval.isEmpty()) {
                return null;
            }

            try {
                LocalTime depart = LocalTime.parse(normaliserHeure(heureDepart));
                String[] parts = dureeInterval.split(":");
                if (parts.length < 2) {
                    return null;
                }

                int heures = Integer.parseInt(parts[0]);
                int minutes = Integer.parseInt(parts[1]);
                int secondes = parts.length > 2 ? Integer.parseInt(parts[2]) : 0;

                LocalTime arrivee = depart.plusHours(heures).plusMinutes(minutes).plusSeconds(secondes);
                return arrivee.toString();
            } catch (DateTimeParseException | NumberFormatException e) {
                return null;
            }
        }

        private String normaliserHeure(String heure) {
            String h = heure.trim();
            if (h.matches("^\\d{2}:\\d{2}$")) {
                return h + ":00";
            }
            return h;
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
                    boolean vehiculeDejaPlanifie = getPlanningByVehiculeAndReservation(
                            planning.getVehiculeId().intValue(),
                            (int) planning.getReservationId()
                    );
                    if (vehiculeDejaPlanifie) {
                        planning.setStatutId(2); // 2 = VALIDE
                        planning.setStatut("VALIDE");
                        updatePlanning(planning);
                    }
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

        if (reservation.getDateArrivee() != null && reservation.getHeure() != null && !reservation.getHeure().isEmpty()) {
            String dateService = reservation.getDateArrivee().toLocalDateTime().toLocalDate().toString();
            String heureReference = reservation.getHeure();

            vehiculesAptes = vehiculesAptes.stream()
                .filter(v -> planningAssignationDetailRepository.isVehiculeDisponibleAt(v.getId(), dateService, heureReference))
                .collect(Collectors.toList());
        }

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
        DateTimeFormatter formatterDateFr = DateTimeFormatter.ofPattern("dd MMMM yyyy", Locale.FRENCH);
        return plannings.stream()
            .map(p -> {
                Reservation reservation = reservationService.getReservationById((int) p.getReservationId());
                Vehicule vehicule = p.getVehiculeId() != null
                    ? vehiculeService.getVehiculeById((int) p.getVehiculeId().longValue())
                    : null;

                String dateArrivee = "";
                String dateArriveeIso = "";
                String heureArrivee = "";
                String nomClient = "";
                int nombrePersonnes = 0;

                if (reservation != null) {
                nomClient = reservation.getNom() != null ? reservation.getNom() : "";
                nombrePersonnes = reservation.getNombrePersonnes();
                heureArrivee = reservation.getHeure() != null ? reservation.getHeure() : "";
                if (reservation.getDateArrivee() != null) {
                    dateArriveeIso = reservation.getDateArrivee().toLocalDateTime().toLocalDate().toString();
                    dateArrivee = reservation.getDateArrivee().toLocalDateTime().toLocalDate().format(formatterDateFr);
                }
                }

                String typeCarburantVehicule = vehicule != null && vehicule.getTypeCarburant() != null
                    ? vehicule.getTypeCarburant()
                    : "";
                int capaciteVehicule = vehicule != null ? vehicule.getCapacitePassagers() : 0;

                return new PlanningTrajetView(
                    p.getId(),
                    p.getReservationId(),
                    p.getVehiculeId() != null ? p.getVehiculeId() : 0,
                    p.getVehiculeImmatriculation(),
                    p.getLieuDepart(),
                    p.getLieuArrivee(),
                    dateArrivee,
                    dateArriveeIso,
                    heureArrivee,
                    nomClient,
                    nombrePersonnes,
                    p.getDistanceEstimee(),
                    p.getDureeEstimee(),
                    p.getStatut(),
                    typeCarburantVehicule,
                    capaciteVehicule
                );
            })
                .collect(Collectors.toList());
    }
}
