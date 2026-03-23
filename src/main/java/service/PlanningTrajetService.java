package service;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
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
import repository.VehiculeDeplacementHistoriqueRepository;

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
    private VehiculeDeplacementHistoriqueRepository vehiculeDeplacementHistoriqueRepository = new VehiculeDeplacementHistoriqueRepository();

    /**
     * Récupérer tous les plannings
     */
    public List<PlanningTrajet> getAllPlannings() {
        return planningRepository.findAll();
    }

    /**
     * Récupérer tous les détails d'assignation (une ligne par réservation)
     */
    public List<PlanningAssignationDetail> getAllPlanningDetails() {
        return planningAssignationDetailRepository.findAll();
    }

    /**
     * Récupérer les détails d'assignation filtrés
     */
    public List<PlanningAssignationDetail> getPlanningDetailsFiltered(String date, String heure, Long vehiculeId) {
        return planningAssignationDetailRepository.findByFilters(date, heure, vehiculeId);
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

            PlanningTrajet planningMisAJour = getPlanningByReservationId(reservationId);
            enregistrerHistoriqueDeplacementVehicule(vehiculeId, reservation, planningMisAJour);
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

            // Sprint 6: démarrage journalier de la disponibilité à l'heure de début configurée.
            vehiculeService.resetDisponibilitesCourantes();

            Map<String, List<Reservation>> groupesParCreneau = reservationsNonAssignees.stream()
                    .filter(r -> r.getDateArrivee() != null && r.getHeure() != null && !r.getHeure().isEmpty())
                    .collect(Collectors.groupingBy(
                            this::buildCreneauKey,
                            LinkedHashMap::new,
                            Collectors.toList()
                    ));

            for (List<Reservation> groupe : groupesParCreneau.values()) {
                assignerGroupeReservations(groupe);
            }
            
            // ⭐ SynchroNIZER LES DÉTAILS D'ASSIGNATION
            // Après avoir assigné tous les réservations, remplir la table planning_trajet_detail
            reconstructirePlanningDetailsAprèsAssignation();
        } catch (Exception e) {
            throw new Exception("Erreur lors de la génération du planning: " + e.getMessage());
        }
    }
    
    /**
     * Reconstruire et remplir la table planning_trajet_detail après les assignations
     * Cette méthode synchronise les assignations effectuées avec la vue de visualisation
     */
    private void reconstructirePlanningDetailsAprèsAssignation() {
        try {
            // Récupérer tous les plannings 
            List<PlanningTrajet> tousLesPlannings = getAllPlannings();
            
            if (tousLesPlannings == null || tousLesPlannings.isEmpty()) {
                return;
            }
            
            // Grouper par véhicule et date
            Map<String, List<PlanningTrajet>> planningsGroupes = tousLesPlannings.stream()
                .filter(p -> p.getVehiculeId() != null && p.getVehiculeId() > 0)
                .collect(Collectors.groupingBy(p -> {
                    Reservation r = reservationService.getReservationById((int) p.getReservationId());
                    if (r == null || r.getDateArrivee() == null) {
                        return null;
                    }
                    String date = r.getDateArrivee().toLocalDateTime().toLocalDate().toString();
                    return p.getVehiculeId() + "|" + date;
                }, Collectors.toList()));
            
            // Externaliser les détails pour chaque groupe
            for (Map.Entry<String, List<PlanningTrajet>> entry : planningsGroupes.entrySet()) {
                if (entry.getKey() == null) continue;
                
                for (PlanningTrajet planning : entry.getValue()) {
                    Reservation reservation = reservationService.getReservationById((int) planning.getReservationId());
                    if (reservation != null && planning.getVehiculeId() != null) {
                        externaliserDetailAssignationVehicule(planning.getVehiculeId().intValue(), reservation);
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Erreur lors de la synchronisation des détails: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private void assignerGroupeReservations(List<Reservation> reservationsMemeCreneau) throws Exception {
        if (reservationsMemeCreneau == null || reservationsMemeCreneau.isEmpty()) {
            return;
        }

        List<Reservation> restantes = new ArrayList<>(reservationsMemeCreneau);
        trierReservationsPourAssignation(restantes);

        while (!restantes.isEmpty()) {
            Reservation reservationPivot = restantes.remove(0);
            Vehicule vehicule = trouverMeilleurVehicule(reservationPivot);

            if (vehicule == null) {
                continue;
            }

            int passagersReservationPivot = reservationPivot.getNombrePersonnes();
            int placesVehicule = vehicule.getCapacitePassagers();

            // Sprint 6: si la réservation dépasse la capacité du véhicule, on fractionne.
            if (passagersReservationPivot > placesVehicule) {
                Reservation fragmentReste = reservationService.fractionnerReservation(reservationPivot, placesVehicule);
                if (fragmentReste != null) {
                    restantes.add(fragmentReste);
                    trierReservationsPourAssignation(restantes);
                    reservationPivot = reservationService.getReservationById(reservationPivot.getId());
                    passagersReservationPivot = reservationPivot != null ? reservationPivot.getNombrePersonnes() : placesVehicule;
                }
            }

            String dateHeureCreneau = construireDateHeureReservation(reservationPivot);
            Long localisationCouranteVehicule = dateHeureCreneau != null
                    ? vehiculeDeplacementHistoriqueRepository.getDernierLieuIdAvant(vehicule.getId(), dateHeureCreneau)
                    : null;

            assignerVehicule(reservationPivot.getId(), (int) vehicule.getId());
            actualiserDisponibiliteVehiculeApresAssignation((int) vehicule.getId(), reservationPivot);

            if (reservationPivot.getLieuDepartId() != null && reservationPivot.getLieuDepartId() > 0) {
                localisationCouranteVehicule = reservationPivot.getLieuDepartId();
            }

            int placesRestantes = placesVehicule - passagersReservationPivot;
            if (placesRestantes <= 0 || restantes.isEmpty()) {
                continue;
            }

            List<Reservation> candidats = new ArrayList<>(restantes);
            while (placesRestantes > 0 && !candidats.isEmpty()) {
                final Long lieuCourant = localisationCouranteVehicule;
                final int placesDisponibles = placesRestantes;

                Reservation prochainCandidat = candidats.stream()
                        .filter(r -> r.getNombrePersonnes() <= placesDisponibles)
                        .min(Comparator
                                .comparingDouble((Reservation r) -> calculerProximiteDepuisLieu(lieuCourant, r))
                                .thenComparingInt(Reservation::getNombrePersonnes)
                                .thenComparingInt(Reservation::getId))
                        .orElse(null);

                // Sprint 6: aucun candidat exact -> fractionner celui le plus proche des places restantes.
                if (prochainCandidat == null) {
                    Reservation candidatAFractionner = candidats.stream()
                            .filter(r -> r.getNombrePersonnes() > placesDisponibles)
                            .min(Comparator
                                    .comparingInt((Reservation r) -> Math.abs(r.getNombrePersonnes() - placesDisponibles))
                                    .thenComparingInt(Reservation::getNombrePersonnes)
                                    .thenComparingInt(Reservation::getId))
                            .orElse(null);

                    if (candidatAFractionner == null || placesDisponibles <= 0) {
                        break;
                    }

                    Reservation fragmentReste = reservationService.fractionnerReservation(candidatAFractionner, placesDisponibles);
                    if (fragmentReste == null) {
                        break;
                    }

                    prochainCandidat = reservationService.getReservationById(candidatAFractionner.getId());
                    if (prochainCandidat == null) {
                        break;
                    }

                    restantes.add(fragmentReste);
                    candidats.add(fragmentReste);
                }

                assignerVehicule(prochainCandidat.getId(), (int) vehicule.getId());
                actualiserDisponibiliteVehiculeApresAssignation((int) vehicule.getId(), prochainCandidat);

                placesRestantes -= prochainCandidat.getNombrePersonnes();
                final int prochainCandidatId = prochainCandidat.getId();
                restantes.removeIf(r -> r.getId() == prochainCandidatId);
                candidats.removeIf(r -> r.getId() == prochainCandidatId);

                if (prochainCandidat.getLieuDepartId() != null && prochainCandidat.getLieuDepartId() > 0) {
                    localisationCouranteVehicule = prochainCandidat.getLieuDepartId();
                }
            }
        }
    }

    private void trierReservationsPourAssignation(List<Reservation> reservations) {
        reservations.sort(Comparator
                .comparingInt(Reservation::getNombrePersonnes).reversed()
                .thenComparing(Reservation::getHeure, Comparator.nullsLast(String::compareTo))
                .thenComparingInt(Reservation::getId));
    }

    private void actualiserDisponibiliteVehiculeApresAssignation(int vehiculeId, Reservation reservation) {
        if (reservation == null || reservation.getHeure() == null || reservation.getHeure().trim().isEmpty()) {
            return;
        }

        Vehicule vehicule = vehiculeService.getVehiculeById(vehiculeId);
        if (vehicule == null) {
            return;
        }

        LocalTime heureCourante = parseHeureSafe(vehicule.getHeureDisponibleCourante(), LocalTime.MIN);
        LocalTime heureDebutReservation = parseHeureSafe(reservation.getHeure(), LocalTime.MIN);

        PlanningTrajet planning = getPlanningByReservationId(reservation.getId());
        LocalTime heureArrivee = null;
        if (planning != null && planning.getDureeEstimee() != null) {
            String heureArriveeStr = calculerHeureArriveePrevue(normaliserHeure(reservation.getHeure()), planning.getDureeEstimee());
            heureArrivee = parseHeureSafe(heureArriveeStr, null);
        }

        if (heureArrivee == null) {
            heureArrivee = heureDebutReservation.plusHours(1);
        }

        LocalTime nouvelleDispo = heureArrivee.isAfter(heureCourante) ? heureArrivee : heureCourante;
        vehiculeService.updateHeureDisponibiliteCourante(vehiculeId, nouvelleDispo.toString());
    }

    private boolean estVehiculeDisponibleParHeure(Vehicule vehicule, String heureReference) {
        if (vehicule == null || heureReference == null || heureReference.trim().isEmpty()) {
            return true;
        }

        String heureSource = vehicule.getHeureDisponibleCourante();
        if (heureSource == null || heureSource.trim().isEmpty()) {
            heureSource = vehicule.getHeureDisponibleDebut();
        }
        if (heureSource == null || heureSource.trim().isEmpty()) {
            heureSource = "00:00:00";
        }

        LocalTime heureDisponible = parseHeureSafe(heureSource, LocalTime.MIN);
        LocalTime heureDemande = parseHeureSafe(heureReference, LocalTime.MIN);
        return !heureDemande.isBefore(heureDisponible);
    }

    private LocalTime parseHeureSafe(String heure, LocalTime defaultValue) {
        if (heure == null || heure.trim().isEmpty()) {
            return defaultValue;
        }

        String normalisee = heure.trim();
        if (normalisee.matches("^\\d{2}:\\d{2}$")) {
            normalisee = normalisee + ":00";
        }

        try {
            return LocalTime.parse(normalisee);
        } catch (DateTimeParseException e) {
            return defaultValue;
        }
    }

    private String buildCreneauKey(Reservation reservation) {
        LocalDate date = reservation.getDateArrivee().toLocalDateTime().toLocalDate();
        return date + "|" + normaliserHeure(reservation.getHeure());
    }

    private double calculerProximiteRamassage(Reservation pivot, Reservation candidate) {
        if (pivot.getLieuDepartId() == null || candidate.getLieuDepartId() == null) {
            return Double.MAX_VALUE;
        }

        if (pivot.getLieuDepartId().longValue() == candidate.getLieuDepartId().longValue()) {
            return 0.0;
        }

        double distance = distanceService.calculerDistance(
                pivot.getLieuDepartId(),
                candidate.getLieuDepartId()
        );

        return distance > 0 ? distance : Double.MAX_VALUE;
    }

    private double calculerProximiteDepuisLieu(Long lieuReferenceId, Reservation candidate) {
        if (lieuReferenceId == null || candidate.getLieuDepartId() == null) {
            return Double.MAX_VALUE;
        }

        if (lieuReferenceId.longValue() == candidate.getLieuDepartId().longValue()) {
            return 0.0;
        }

        double distance = distanceService.calculerDistance(lieuReferenceId, candidate.getLieuDepartId());
        return distance > 0 ? distance : Double.MAX_VALUE;
    }

    private String construireDateHeureReservation(Reservation reservation) {
        if (reservation == null || reservation.getDateArrivee() == null || reservation.getHeure() == null) {
            return null;
        }

        String date = reservation.getDateArrivee().toLocalDateTime().toLocalDate().toString();
        String heure = normaliserHeure(reservation.getHeure());
        return date + " " + heure;
    }

    private void enregistrerHistoriqueDeplacementVehicule(int vehiculeId,
                                                          Reservation reservation,
                                                          PlanningTrajet planning) {
        if (reservation == null || reservation.getDateArrivee() == null || reservation.getHeure() == null) {
            return;
        }

        String dateService = reservation.getDateArrivee().toLocalDateTime().toLocalDate().toString();
        String heureDepart = normaliserHeure(reservation.getHeure());
        String dateHeureDepart = dateService + " " + heureDepart;

        Long planningId = planning != null ? planning.getId() : null;
        Long reservationId = (long) reservation.getId();

        vehiculeDeplacementHistoriqueRepository.insertEvenement(
                vehiculeId,
                reservation.getLieuDepartId(),
                planningId,
                reservationId,
                "RAMASSAGE",
                dateHeureDepart,
                "Ramassage client reservation " + reservation.getId()
        );

        String dureeTrajet = planning != null ? planning.getDureeEstimee() : null;
        String heureArrivee = calculerHeureArriveePrevue(heureDepart, dureeTrajet);
        String dateHeureArrivee = dateService + " " + (heureArrivee != null ? heureArrivee : heureDepart);

        vehiculeDeplacementHistoriqueRepository.insertEvenement(
                vehiculeId,
                reservation.getLieuArriveeId(),
                planningId,
                reservationId,
                "ARRIVEE",
                dateHeureArrivee,
                "Arrivee client reservation " + reservation.getId()
        );
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
         * NOUVELLE MÉTHODE SPRINT 3 : Calculer un trajet optimisé pour un groupe de réservations
         * 
         * Problème : Avant, on calculait la distance individuellement par réservation
         * Solution : Calculer le trajet COMPLET du véhicule qui dessert PLUSIEURS réservations
         * 
         * Ordre du trajet : Position véhicule → Ramassage 1 → Ramassage 2 → ... → Dépôt 1 → Dépôt 2
         * 
         * @param vehiculeId ID du véhicule
         * @param reservationsGroupe Liste de toutes les réservations assignées au même véhicule
         * @param planningByReservationId Map des plannings par réservation pour accéder aux lieux
         * @return distance totale en km
         */
        private double calculerTrajetOptimiseGroupe(int vehiculeId, List<Reservation> reservationsGroupe,
                Map<Long, PlanningTrajet> planningByReservationId) {
            if (reservationsGroupe == null || reservationsGroupe.isEmpty()) {
                return 0.0;
            }

            try {
                // ÉTAPE 1 : Récupérer la position actuelle du véhicule
                //           (dernière localisation depuis l'historique de déplacement)
                Long positionActuelleVehiculeId = vehiculeDeplacementHistoriqueRepository
                    .getDerniereLieuDuVehicule(vehiculeId);
                
                if (positionActuelleVehiculeId == null || positionActuelleVehiculeId <= 0) {
                    // Si pas d'historique, utiliser le premier point de ramassage comme référence
                    positionActuelleVehiculeId = null;
                }

                // ÉTAPE 2 : Extraire tous les points de visite du groupe
                //          - Points de départ (ramassages)
                //          - Points d'arrivée (dépôts)
                List<Long> pointsDepart = new ArrayList<>();
                List<Long> pointsArrivee = new ArrayList<>();

                for (Reservation r : reservationsGroupe) {
                    PlanningTrajet p = planningByReservationId.get((long) r.getId());
                    if (p != null) {
                        if (p.getLieuDepartId() != null && p.getLieuDepartId() > 0) {
                            pointsDepart.add(p.getLieuDepartId());
                        }
                        if (p.getLieuArriveeId() != null && p.getLieuArriveeId() > 0) {
                            pointsArrivee.add(p.getLieuArriveeId());
                        }
                    }
                }

                // ÉTAPE 3 : Calculer les distances intermédiaires
                //          avec optimisation des trajets (points les plus proches en priorité)
                double distanceTotale = 0.0;
                Long lieuActuel = positionActuelleVehiculeId;

                // Traiter d'abord les ramassages (départs)
                List<Long> dePartNonVisites = new ArrayList<>(pointsDepart);
                while (!dePartNonVisites.isEmpty()) {
                    // Trouver le point de ramassage le plus proche du point actuel
                    Long pointLePlusPrche = dePartNonVisites.get(0);
                    double distanceMin = Double.MAX_VALUE;

                    if (lieuActuel != null && lieuActuel > 0) {
                        for (Long lieu : dePartNonVisites) {
                            double dist = distanceService.calculerDistance(lieuActuel, lieu);
                            if (dist < distanceMin) {
                                distanceMin = dist;
                                pointLePlusPrche = lieu;
                            }
                        }
                    }

                    // Ajouter cette distance au total
                    if (lieuActuel != null && lieuActuel > 0) {
                        double distanceAuPoint = distanceService.calculerDistance(lieuActuel, pointLePlusPrche);
                        if (distanceAuPoint > 0) {
                            distanceTotale += distanceAuPoint;
                        }
                    }

                    // Enregistrer cet événement de ramassage dans l'historique
                    if (lieuActuel != null && lieuActuel > 0) {
                        // Optionnel : enregistrer le déplacement vers ce point de ramassage
                    }

                    // Mettre à jour la position actuelle et continuer
                    lieuActuel = pointLePlusPrche;
                    dePartNonVisites.remove(pointLePlusPrche);
                }

                // Traiter ensuite les dépôts (arrivées)
                List<Long> depotsNonVisites = new ArrayList<>(pointsArrivee);
                while (!depotsNonVisites.isEmpty()) {
                    // Trouver le point de dépôt le plus proche du point actuel
                    Long pointLePlusPrche = depotsNonVisites.get(0);
                    double distanceMin = Double.MAX_VALUE;

                    if (lieuActuel != null && lieuActuel > 0) {
                        for (Long lieu : depotsNonVisites) {
                            double dist = distanceService.calculerDistance(lieuActuel, lieu);
                            if (dist < distanceMin) {
                                distanceMin = dist;
                                pointLePlusPrche = lieu;
                            }
                        }
                    }

                    // Ajouter cette distance au total
                    if (lieuActuel != null && lieuActuel > 0) {
                        double distanceAuPoint = distanceService.calculerDistance(lieuActuel, pointLePlusPrche);
                        if (distanceAuPoint > 0) {
                            distanceTotale += distanceAuPoint;
                        }
                    }

                    // Enregistrer cet événement de dépôt dans l'historique
                    if (lieuActuel != null && lieuActuel > 0) {
                        // Optionnel : enregistrer le dépôt
                    }

                    // Mettre à jour la position actuelle et continuer
                    lieuActuel = pointLePlusPrche;
                    depotsNonVisites.remove(pointLePlusPrche);
                }

                return distanceTotale;

            } catch (Exception e) {
                System.err.println("Erreur lors du calcul du trajet optimisé: " + e.getMessage());
                e.printStackTrace();
                return 0.0;
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
         * Exporte un detail d'assignation agrege par vehicule + date.
         * ⭐ SPRINT 4 : Crée une seule ligne par GROUPE de réservations groupables par temps d'attente
         * 
         * Logique :
         * 1. Récupérer toutes les réservations du véhicule pour la date
         * 2. Grouper par temps d'attente (écart ≤ TEMPS_ATTENTE_MAX_MINUTES)
         * 3. Pour chaque groupe : créer UNE SEULE ligne d'assignation
         * 4. Énumérer toutes les réservations du groupe dans reservation_client
         */
        private void externaliserDetailAssignationVehicule(int vehiculeId, Reservation reservationPivot) {
            if (reservationPivot == null || reservationPivot.getDateArrivee() == null) {
                return;
            }

            String dateArrivee = reservationPivot.getDateArrivee().toLocalDateTime().toLocalDate().toString();

            List<PlanningTrajet> planningsVehicule = getPlanningsByVehicule(vehiculeId);
            if (planningsVehicule == null || planningsVehicule.isEmpty()) {
                return;
            }

            // Récupérer toutes les réservations du véhicule pour cette DATE
            List<Reservation> reservationsVehiculeDate = new ArrayList<>();
            Map<Long, PlanningTrajet> planningByReservationId = new HashMap<>();

            for (PlanningTrajet p : planningsVehicule) {
                Reservation r = reservationService.getReservationById((int) p.getReservationId());
                if (r == null || r.getDateArrivee() == null) {
                    continue;
                }

                String rDate = r.getDateArrivee().toLocalDateTime().toLocalDate().toString();
                if (dateArrivee.equals(rDate)) {
                    reservationsVehiculeDate.add(r);
                    planningByReservationId.put((long) r.getId(), p);
                }
            }

            if (reservationsVehiculeDate.isEmpty()) {
                return;
            }

            // ⭐ GROUPER PAR TEMPS D'ATTENTE (Sprint 4)
            int tempsAttentMaxMinutes = obtenirTempsAttentMaxConfig();
            Map<Integer, List<Reservation>> groupesParTempsAttente = grouperParTempsAttente(
                reservationsVehiculeDate,
                tempsAttentMaxMinutes
            );

            Vehicule vehicule = vehiculeService.getVehiculeById(vehiculeId);
            int capaciteVehicule = vehicule != null ? vehicule.getCapacitePassagers() : 0;

            // Exporter chaque GROUPE en UNE SEULE LIGNE
            for (Map.Entry<Integer, List<Reservation>> entryGroupe : groupesParTempsAttente.entrySet()) {
                List<Reservation> reservationsGroupeTriees = entryGroupe.getValue();
                
                if (reservationsGroupeTriees.isEmpty()) {
                    continue;
                }

                // Trier par heure
                reservationsGroupeTriees.sort(Comparator
                    .comparing(Reservation::getHeure, Comparator.nullsLast(String::compareTo))
                    .thenComparingInt(Reservation::getId));

                Reservation premiereReservation = reservationsGroupeTriees.get(0);
                Reservation derniereReservation = reservationsGroupeTriees.get(reservationsGroupeTriees.size() - 1);

                // Calculer durée et distance du GROUPE
                double distanceOptimiseeGroupe = calculerTrajetOptimiseGroupe(
                    vehiculeId,
                    reservationsGroupeTriees,
                    planningByReservationId
                );

                int dureeEstimeeGroupeMinutes = 0;
                if (distanceOptimiseeGroupe > 0) {
                    int vitesseMoyenne = paramService.getParametreAsInt("VITESSE_MOYENNE_KMH");
                    if (vitesseMoyenne > 0) {
                        double heures = distanceOptimiseeGroupe / vitesseMoyenne;
                        dureeEstimeeGroupeMinutes = (int) Math.round(heures * 60);
                    }
                }
                String dureeOptimiseeGroup = formatDureeForInterval(dureeEstimeeGroupeMinutes);

                PlanningTrajet planningPremiereReservation = planningByReservationId.get((long) premiereReservation.getId());
                PlanningTrajet planningDerniereReservation = planningByReservationId.get((long) derniereReservation.getId());

                String premierPointDepart = planningPremiereReservation != null
                    ? planningPremiereReservation.getLieuDepart()
                    : null;
                String dernierPointArrivee = planningDerniereReservation != null
                    ? planningDerniereReservation.getLieuArrivee()
                    : null;

                // Énumérer toutes les réservations du groupe
                StringBuilder sbReservationsClients = new StringBuilder();
                StringBuilder sbIdsGroupees = new StringBuilder();
                int passagersTotal = 0;

                for (int i = 0; i < reservationsGroupeTriees.size(); i++) {
                    Reservation res = reservationsGroupeTriees.get(i);
                    passagersTotal += res.getNombrePersonnes();
                    
                    if (i > 0) {
                        sbReservationsClients.append(" + ");
                        sbIdsGroupees.append(",");
                    }
                    sbReservationsClients.append(res.getNom()).append("(").append(res.getNombrePersonnes()).append("p)");
                    sbIdsGroupees.append(res.getId());
                }

                String reservationClientStr = sbReservationsClients.toString();
                String reservationIdsGroupees = sbIdsGroupees.toString();
                int placesLibres = Math.max(capaciteVehicule - passagersTotal, 0);

                // Calculer temps d'attente du groupe
                int tempsAttenteGroupeMinutes = calculerTempsAttenteGroupe(reservationsGroupeTriees);
                String heureDeprtAjustee = calculerHeureDepart(reservationsGroupeTriees);
                String plageHeuresGroupe = premiereReservation.getHeure() + " → " + heureDeprtAjustee
                    + " (attente: " + tempsAttenteGroupeMinutes + " min)";

                // ⭐ CRÉER UNE SEULE LIGNE POUR LE GROUPE
                PlanningAssignationDetail detail = new PlanningAssignationDetail();
                detail.setVehiculeId(vehiculeId);
                detail.setDateArrivee(dateArrivee);
                detail.setHeureArrivee(premiereReservation.getHeure()); // Heure de la 1ère réservation
                detail.setReservationId(premiereReservation.getId()); // ID de la 1ère réservation
                detail.setPremiereReservationId(premiereReservation.getId());
                detail.setReservationClient(reservationClientStr); // Énumération de toutes les réservations
                detail.setNombrePassagersTotal(passagersTotal);
                detail.setCapaciteVehicule(capaciteVehicule);
                detail.setPlacesLibres(placesLibres);
                detail.setDistanceEstimee(distanceOptimiseeGroupe);
                detail.setDureeEstimee(dureeOptimiseeGroup);
                detail.setPremierPointDepart(premierPointDepart);
                detail.setDernierPointArrivee(dernierPointArrivee);
                
                // Stocker les infos supplémentaires du groupe (Sprint 4)
                detail.setReservationIdsGroupees(reservationIdsGroupees);
                detail.setNombreReservationsGroupe(reservationsGroupeTriees.size());
                detail.setTempsAttenteGroupeMinutes(tempsAttenteGroupeMinutes);
                detail.setHeureDeprtAjustee(heureDeprtAjustee);
                detail.setPlageHeuresGroupe(plageHeuresGroupe);

                planningAssignationDetailRepository.upsert(detail);

                // Enregistrer l'historique d'assignation pour la PREMIÈRE réservation du groupe
                PlanningTrajet planningPremiereRes = planningByReservationId.get((long) premiereReservation.getId());
                String heureArriveePrevue = calculerHeureArriveePrevue(heureDeprtAjustee, dureeOptimiseeGroup);
                planningAssignationDetailRepository.upsertHistoriqueAssignation(
                        vehiculeId,
                        premiereReservation.getId(),
                        planningPremiereRes != null ? planningPremiereRes.getId() : null,
                        dateArrivee,
                        premiereReservation.getHeure(),
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
    /**
     * ⭐ SPRINT 5 : Trouver le meilleur véhicule avec sélection par priorité
     * 
     * Priorité d'assignation :
     * 1. Proximité (type carburant: Diesel prioritaire)
     * 2. Nombre MINIMUM de trajets (favoriser les véhicules les moins utilisés)
     * 3. Nombre de places disponibles
     */
    private Vehicule trouverMeilleurVehicule(Reservation reservation) {
        if (reservation == null) {
            return null;
        }

        // ÉTAPE 1 : Filtrer par capacité passagers et disponibilité.
        List<Vehicule> vehiculesAptes = vehiculeService
                .getVehiculesByCapacite(reservation.getNombrePersonnes());

        if (reservation.getDateArrivee() != null && reservation.getHeure() != null && !reservation.getHeure().isEmpty()) {
            String dateService = reservation.getDateArrivee().toLocalDateTime().toLocalDate().toString();
            String heureReference = reservation.getHeure();

            vehiculesAptes = vehiculesAptes.stream()
                .filter(v -> estVehiculeDisponibleParHeure(v, heureReference))
                .filter(v -> planningAssignationDetailRepository.isVehiculeDisponibleAt(v.getId(), dateService, heureReference))
                .collect(Collectors.toList());
        }

        // Sprint 6 : si aucun véhicule ne couvre toute la réservation, on tente un véhicule partiel.
        if (vehiculesAptes.isEmpty()) {
            List<Vehicule> vehiculesPartiels = vehiculeService.getVehiculesDisponibles();
            if (reservation.getDateArrivee() != null && reservation.getHeure() != null && !reservation.getHeure().isEmpty()) {
                String dateService = reservation.getDateArrivee().toLocalDateTime().toLocalDate().toString();
                String heureReference = reservation.getHeure();
                vehiculesPartiels = vehiculesPartiels.stream()
                    .filter(v -> estVehiculeDisponibleParHeure(v, heureReference))
                    .filter(v -> planningAssignationDetailRepository.isVehiculeDisponibleAt(v.getId(), dateService, heureReference))
                    .collect(Collectors.toList());
            }

            if (vehiculesPartiels.isEmpty()) {
                return null;
            }

            return vehiculesPartiels.stream()
                .max(Comparator
                    .comparingInt(Vehicule::getCapacitePassagers)
                    .thenComparingInt(v -> -compterTrajetsVehicule(v))
                    .thenComparingInt(v -> (int) -v.getId()))
                .orElse(null);
        }

        // ÉTAPE 2 : Score des véhicules selon priorités Sprint 5 + Sprint 6.
        return vehiculesAptes.stream()
            .min(Comparator
                // Priorité 1: Proximité (Diesel prioritaire)
                .comparingInt((Vehicule v) -> {
                    boolean isDiesel = v.getTypeCarburant() != null && 
                                      v.getTypeCarburant().equalsIgnoreCase("Diesel");
                    return isDiesel ? 0 : 1;
                })
                // Priorité 2: Nombre MINIMUM de trajets
                .thenComparingInt(this::compterTrajetsVehicule)
                // Priorité 3 (Sprint 6): capacité minimale suffisante pour limiter le gaspillage de places
                .thenComparingInt(Vehicule::getCapacitePassagers)
                .thenComparingInt((Vehicule v) -> (int) v.getId()))
            .orElse(null);
    }

    /**
     * ⭐ SPRINT 5 : Compter le nombre de trajets (créneau date+heure différent) pour un véhicule
     * 
     * Utilité: Favoriser les véhicules les moins utilisés lors de la sélection
     * - V1 avec 2 trajets → score: 2
     * - V2 avec 1 trajet → score: 1
     * - V3 avec 0 trajet → score: 0 (favorisé ✅)
     * 
     * @param vehicule Véhicule à scorer
     * @return Nombre de créneau date+heure différents assignés
     */
    private int compterTrajetsVehicule(Vehicule vehicule) {
        if (vehicule == null || vehicule.getId() <= 0) {
            return 0;
        }

        // Récupérer tous les plannings du véhicule
        List<PlanningTrajet> planningsVehicule = getPlanningsByVehicule((int) vehicule.getId());
        
        if (planningsVehicule == null || planningsVehicule.isEmpty()) {
            return 0;
        }

        // Compter les CRÉNEAU UNIQUES (date + heure différents)
        // Deux réservations au même moment = 1 seul trajet
        return (int) planningsVehicule.stream()
            .map(p -> {
                Reservation r = reservationService.getReservationById((int) p.getReservationId());
                if (r == null || r.getDateArrivee() == null || r.getHeure() == null) {
                    return null;
                }
                // Clé unique par créneau
                String dateIso = r.getDateArrivee().toLocalDateTime().toLocalDate().toString();
                String heureNormalisee = normaliserHeure(r.getHeure());
                return dateIso + "|" + heureNormalisee;
            })
            .filter(key -> key != null)
            .distinct()
            .count();
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

    /**
     * ============ NOUVELLES MÉTHODES SPRINT 4 ============
     * Gestion du temps d'attente et regroupement de réservations
     */

    /**
     * Calculer le temps d'attente en minutes entre deux heures
     * @param heure1 Première heure (format HH:MM ou HH:MM:SS)
     * @param heure2 Deuxième heure (format HH:MM ou HH:MM:SS)
     * @return Différence en minutes (heure2 - heure1)
     */
    public int calculerTempsAttente(String heure1, String heure2) {
        if (heure1 == null || heure2 == null || heure1.isEmpty() || heure2.isEmpty()) {
            return Integer.MAX_VALUE;
        }

        try {
            LocalTime time1 = LocalTime.parse(normaliserHeure(heure1));
            LocalTime time2 = LocalTime.parse(normaliserHeure(heure2));

            // Calculer la différence en minutes (positif = heure2 après heure1)
            long minutesDiff = java.time.temporal.ChronoUnit.MINUTES.between(time1, time2);
            return (int) minutesDiff;
        } catch (DateTimeParseException e) {
            return Integer.MAX_VALUE;
        }
    }

    /**
     * Vérifier si deux réservations peuvent être groupées selon le temps d'attente max
     * @param res1 Première réservation
     * @param res2 Deuxième réservation
     * @param tempsAttentMaxMinutes Temps d'attente maximum en minutes
     * @return true si l'écart ≤ temps d'attente max
     */
    public boolean peutEtreGroupee(Reservation res1, Reservation res2, int tempsAttentMaxMinutes) {
        if (res1 == null || res2 == null) {
            return false;
        }

        // Même date d'arrivée requise
        if (!res1.getDateArrivee().equals(res2.getDateArrivee())) {
            return false;
        }

        String heure1 = res1.getHeure();
        String heure2 = res2.getHeure();

        if (heure1 == null || heure2 == null) {
            return false;
        }

        // Calculer l'écart en minutes
        int ecartMinutes = calculerTempsAttente(heure1, heure2);
        
        // Vérifier que heure2 >= heure1 (on considère l'ordre chronologique)
        if (ecartMinutes < 0) {
            ecartMinutes = -ecartMinutes; // Prendre la valeur absolue pour comparaison
        }

        // Groupable si écart ≤ temps d'attente max
        return ecartMinutes <= tempsAttentMaxMinutes;
    }

    /**
     * Grouper les réservations par temps d'attente
     * Retourne une map : key=numéro du groupe, value=liste des réservations du groupe
     * 
     * @param reservations Liste des réservations à grouper
     * @param tempsAttentMaxMinutes Temps d'attente maximum en minutes
     * @return Map des groupes
     */
    public Map<Integer, List<Reservation>> grouperParTempsAttente(List<Reservation> reservations, 
                                                                   int tempsAttentMaxMinutes) {
        Map<Integer, List<Reservation>> groupes = new LinkedHashMap<>();
        
        if (reservations == null || reservations.isEmpty()) {
            return groupes;
        }

        // Trier par date puis par heure
        List<Reservation> reservationTriees = new ArrayList<>(reservations);
        reservationTriees.sort(Comparator
            .comparing(Reservation::getDateArrivee)
            .thenComparing(Reservation::getHeure, Comparator.nullsLast(String::compareTo))
            .thenComparingInt(Reservation::getId));

        int numeroGroupe = 0;
        List<Reservation> groupeCourant = new ArrayList<>();

        for (Reservation reservation : reservationTriees) {
            if (groupeCourant.isEmpty()) {
                // Premier élément du groupe
                groupeCourant.add(reservation);
            } else {
                // Vérifier si peut être ajoutée au groupe courant
                Reservation derniereReservation = groupeCourant.get(groupeCourant.size() - 1);
                
                if (peutEtreGroupee(derniereReservation, reservation, tempsAttentMaxMinutes)) {
                    // Peut être groupée : ajouter au groupe courant
                    groupeCourant.add(reservation);
                } else {
                    // Ne peut pas être groupée : sauvegarder groupe courant et démarrer nouveau groupe
                    if (!groupeCourant.isEmpty()) {
                        groupes.put(numeroGroupe, new ArrayList<>(groupeCourant));
                        numeroGroupe++;
                    }
                    groupeCourant.clear();
                    groupeCourant.add(reservation);
                }
            }
        }

        // Sauvegarder le dernier groupe
        if (!groupeCourant.isEmpty()) {
            groupes.put(numeroGroupe, groupeCourant);
        }

        return groupes;
    }

    /**
     * Calculer l'heure de départ ajustée pour un groupe
     * = Heure de la DERNIÈRE réservation du groupe (celle qui arrive la plus tard)
     * 
     * @param groupe Liste de réservations du groupe
     * @return Heure de départ ajustée (format HH:MM)
     */
    public String calculerHeureDepart(List<Reservation> groupe) {
        if (groupe == null || groupe.isEmpty()) {
            return null;
        }

        // Trouver la réservation avec l'heure la plus tard
        Reservation derniere = groupe.stream()
            .max(Comparator.comparing(Reservation::getHeure, Comparator.nullsLast(String::compareTo)))
            .orElse(null);

        return derniere != null ? derniere.getHeure() : null;
    }

    /**
     * Calculer le temps d'attente total entre la première et la dernière réservation
     * 
     * @param groupe Liste de réservations du groupe
     * @return Temps d'attente en minutes
     */
    public int calculerTempsAttenteGroupe(List<Reservation> groupe) {
        if (groupe == null || groupe.isEmpty()) {
            return 0;
        }

        if (groupe.size() == 1) {
            return 0; // Pas d'attente s'il y a une seule réservation
        }

        // Trier pour avoir le min et max
        List<String> heures = groupe.stream()
            .map(Reservation::getHeure)
            .filter(h -> h != null && !h.isEmpty())
            .sorted()
            .collect(Collectors.toList());

        if (heures.isEmpty()) {
            return 0;
        }

        // Calculer écart entre première et dernière
        int tempsAttente = calculerTempsAttente(heures.get(0), heures.get(heures.size() - 1));
        return tempsAttente > 0 ? tempsAttente : 0;
    }

    /**
     * Adapter le planning pour un groupe regroupé avec temps d'attente
     * - Mettre à jour l'heure de départ pour toutes les réservations
     * - Recalculer la durée totale du trajet
     * 
     * @param groupe Groupe de réservations regroupées
     * @param heureDepart Heure de départ ajustée du groupe
     */
    public void adapterPlanningGroupe(List<Reservation> groupe, String heureDepart) {
        if (groupe == null || groupe.isEmpty() || heureDepart == null || heureDepart.isEmpty()) {
            return;
        }

        // Mettre à jour chaque réservation du groupe avec la nouvelle heure de départ
        for (Reservation reservation : groupe) {
            PlanningTrajet planning = getPlanningByReservationId((int) reservation.getId());
            
            if (planning != null) {
                // Mettre à jour l'heure de départ dans le planning
                // (Note: cette info peut être stockée dans une table de configuration ou historique)
                // Pour l'instant, juste tracer l'adaptation
                String heureArriveeOriginal = reservation.getHeure();
                int tempsAttente = calculerTempsAttente(heureArriveeOriginal, heureDepart);
                
                System.out.println("Adaptation planning - Réservation " + reservation.getId() + 
                                 ": arrivée " + heureArriveeOriginal + 
                                 " → départ " + heureDepart + 
                                 " (attente: " + tempsAttente + " min)");
            }
        }
    }

    /**
     * Récupérer le paramètre de temps d'attente maximum depuis la configuration
     * Par défaut: 30 minutes si non trouvé
     * 
     * @return Temps d'attente maximum en minutes
     */
    public int obtenirTempsAttentMaxConfig() {
        try {
            int configValue = paramService.getParametreAsInt("TEMPS_ATTENTE_MAX_MINUTES");
            return configValue > 0 ? configValue : 30; // Défaut 30 min
        } catch (Exception e) {
            System.err.println("Impossible de récupérer TEMPS_ATTENTE_MAX_MINUTES, utilisation défaut (30 min)");
            return 30;
        }
    }
}

