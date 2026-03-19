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
        } catch (Exception e) {
            throw new Exception("Erreur lors de la génération du planning: " + e.getMessage());
        }
    }

    private void assignerGroupeReservations(List<Reservation> reservationsMemeCreneau) throws Exception {
        if (reservationsMemeCreneau == null || reservationsMemeCreneau.isEmpty()) {
            return;
        }

        List<Reservation> restantes = new ArrayList<>(reservationsMemeCreneau);
        restantes.sort(Comparator
                .comparingInt(Reservation::getNombrePersonnes).reversed()
                .thenComparing(Reservation::getHeure, Comparator.nullsLast(String::compareTo))
                .thenComparingInt(Reservation::getId));

        while (!restantes.isEmpty()) {
            Reservation reservationPivot = restantes.remove(0);
            Vehicule vehicule = trouverMeilleurVehicule(reservationPivot);

            if (vehicule == null) {
                continue;
            }

            String dateHeureCreneau = construireDateHeureReservation(reservationPivot);
            Long localisationCouranteVehicule = dateHeureCreneau != null
                    ? vehiculeDeplacementHistoriqueRepository.getDernierLieuIdAvant(vehicule.getId(), dateHeureCreneau)
                    : null;

            assignerVehicule(reservationPivot.getId(), (int) vehicule.getId());

            if (reservationPivot.getLieuDepartId() != null && reservationPivot.getLieuDepartId() > 0) {
                localisationCouranteVehicule = reservationPivot.getLieuDepartId();
            }

            int placesRestantes = vehicule.getCapacitePassagers() - reservationPivot.getNombrePersonnes();
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
                                .thenComparing(Comparator.comparingInt(Reservation::getNombrePersonnes).reversed())
                                .thenComparingInt(Reservation::getId))
                        .orElse(null);

                if (prochainCandidat == null) {
                    break;
                }

                assignerVehicule(prochainCandidat.getId(), (int) vehicule.getId());
                placesRestantes -= prochainCandidat.getNombrePersonnes();
                restantes.removeIf(r -> r.getId() == prochainCandidat.getId());
                candidats.removeIf(r -> r.getId() == prochainCandidat.getId());

                if (prochainCandidat.getLieuDepartId() != null && prochainCandidat.getLieuDepartId() > 0) {
                    localisationCouranteVehicule = prochainCandidat.getLieuDepartId();
                }
            }
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

                // ⭐ CORRECTION SPRINT 3 : Calculer le TRAJET OPTIMISÉ DU GROUPE (au lieu du trajet individuel)
                double distanceOptimiseeGroupe = calculerTrajetOptimiseGroupe(
                    vehiculeId, 
                    reservationsGroupe, 
                    planningByReservationId
                );
                
                // Calculer la durée estimée totale pour le groupe
                int dureeEstimeeGroupeMinutes = 0;
                if (distanceOptimiseeGroupe > 0) {
                    int vitesseMoyenne = paramService.getParametreAsInt("VITESSE_MOYENNE_KMH");
                    if (vitesseMoyenne > 0) {
                        double heures = distanceOptimiseeGroupe / vitesseMoyenne;
                        dureeEstimeeGroupeMinutes = (int) Math.round(heures * 60);
                    }
                }
                String dureeOptimiseeGroup = formatDureeForInterval(dureeEstimeeGroupeMinutes);

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
                
                // ⭐ UTILISER LA DISTANCE DU GROUPE OPTIMISÉ AU LIEU DE LA DISTANCE INDIVIDUELLE
                double distanceEstimee = distanceOptimiseeGroupe;
                String dureeEstimee = dureeOptimiseeGroup;

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
