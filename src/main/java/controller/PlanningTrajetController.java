package controller;

import java.time.LocalTime;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import dto.PlanningAssignationAffichageView;
import dto.PlanningTrajetGroupeView;
import dto.PlanningTrajetView;
import dto.ReservationView;
import framework.ModelAndView.ModelAndView;
import framework.annotation.Controller;
import framework.annotation.Get;
import framework.annotation.Post;
import framework.annotation.RequestParam;
import framework.annotation.RestAPI;
import framework.annotation.Url;
import framework.response.ApiResponse;
import model.PlanningTrajet;
import model.Reservation;
import model.Vehicule;
import service.PlanningTrajetService;
import service.ReservationService;
import service.VehiculeService;

@Controller
public class PlanningTrajetController {
    private ReservationService reservationService = new ReservationService();
    private VehiculeService vehiculeService = new VehiculeService();
    private PlanningTrajetService planningTrajetService = new PlanningTrajetService();

    /**
     * Affiche la page d'assignation des véhicules aux réservations
     */
    @Url("/planning/assignation")
    @Get
    public ModelAndView afficherAssignation(
            @RequestParam(value = "date", required = false) String date,
            @RequestParam(value = "heure", required = false) String heure,
            @RequestParam(value = "vehiculeId", required = false) String vehiculeId) {
        ModelAndView mav = new ModelAndView("/views/planning/assignation.jsp");
        
        // Récupérer toutes les réservations non assignées ou en cours
        List<ReservationView> reservations = reservationService.getReservationNonAssigneesViews();
        List<PlanningTrajetView> plannings = planningTrajetService.getAllPlanningsForView();

        plannings = filtrerPlannings(plannings, date, heure, vehiculeId);
        
        // Récupérer tous les véhicules disponibles
        List<Vehicule> vehicules = vehiculeService.getVehiculesDisponibles();
        List<PlanningAssignationAffichageView> assignations =
            planningTrajetService.getAssignationsAffichage(date, heure, null);
        
        String pageTitle = "Plannification des R&#233;servations";
        mav.addObject("pageTitle", pageTitle);
        mav.addObject("reservations", reservations);
        mav.addObject("totalReservationsNonAssignees", reservationService.getTotalReservationsNonAssignees());
        mav.addObject("totalPersonnesRestantes", reservationService.getTotalPersonnesNonAssignees());
        mav.addObject("vehicules", vehicules);
        mav.addObject("plannings", plannings);
        mav.addObject("planningGroupes", buildPlanningGroupes(plannings));
        mav.addObject("assignations", assignations);
        mav.addObject("filterDate", date);
        mav.addObject("filterHeure", heure);
        mav.addObject("filterVehiculeId", vehiculeId);
        
        return mav;
    }

    /**
     * Affiche la page de visualisation des trajets groupes
     * Affiche une ligne par réservation (Sprint 3: une ligne par réservation dans le groupe)
     */
    @Url("/planning/visualisation")
    @Get
    public ModelAndView afficherVisualisation(
            @RequestParam(value = "date", required = false) String date,
            @RequestParam(value = "heure", required = false) String heure,
            @RequestParam(value = "vehiculeId", required = false) String vehiculeId) {
        ModelAndView mav = new ModelAndView("/views/planning/visualisation.jsp");

        // Récupérer les details d'assignation (une ligne par réservation)
        Long vehiculeIdFilter = null;
        if (vehiculeId != null && !vehiculeId.isEmpty()) {
            try {
                vehiculeIdFilter = Long.parseLong(vehiculeId);
            } catch (NumberFormatException ignored) {
                // Ignorer vehiculeId invalide
            }
        }
        
        List<PlanningAssignationAffichageView> assignations =
                planningTrajetService.getAssignationsAffichage(date, heure, vehiculeIdFilter);
        
        List<Vehicule> vehicules = vehiculeService.getAllVehicules();

        mav.addObject("pageTitle", "Visualisation des Trajets");
        mav.addObject("assignations", assignations);
        mav.addObject("vehicules", vehicules);
        mav.addObject("filterDate", date);
        mav.addObject("filterHeure", heure);
        mav.addObject("filterVehiculeId", vehiculeId);

        return mav;
    }

    /**
     * Affiche le detail d'un groupe de trajet (vehicule + date + heure)
     */
    @Url("/planning/visualisation/details")
    @Get
    public ModelAndView afficherDetailsVisualisation(
            @RequestParam("vehiculeId") long vehiculeId,
            @RequestParam("date") String date,
            @RequestParam("heure") String heure) {
        ModelAndView mav = new ModelAndView("/views/planning/visualisation-details.jsp");

        List<PlanningTrajetView> plannings = planningTrajetService.getAllPlanningsForView();
        List<PlanningTrajetView> planningsFiltres = plannings.stream()
                .filter(p -> p.getVehiculeId() == vehiculeId)
                .filter(p -> p.getDateArriveeIso() != null && p.getDateArriveeIso().equals(date))
                .filter(p -> p.getHeureArrivee() != null && p.getHeureArrivee().startsWith(heure))
                .collect(Collectors.toList());

        List<PlanningTrajetGroupeView> groupes = buildPlanningGroupes(planningsFiltres);
        PlanningTrajetGroupeView groupe = groupes.isEmpty() ? null : groupes.get(0);

        mav.addObject("pageTitle", "Detail Visualisation Trajet");
        mav.addObject("groupe", groupe);
        mav.addObject("plannings", planningsFiltres);

        return mav;
    }
    /**
     * Générer le planning automatiquement
     */
    @Url("/planning/assignation/generer")
    @Post
    @RestAPI
    public ApiResponse genererPlanning() {
        try {
            planningTrajetService.genererPlanning();
            return ApiResponse.success("Planning généré avec succès");
        } catch (Exception e) {
            String errorMessage = e.getMessage() != null
                    ? e.getMessage()
                    : "Une erreur inattendue est survenue lors de la génération du planning";
            return ApiResponse.error(500, errorMessage);
        }
    }
    /**
     * Assigner manuellement un véhicule à une réservation
     */
    @Url("/planning/assignation/{reservationId}/assign")
    @Post
    public ModelAndView assignerVehicule(
            int reservationId,
            @RequestParam("vehiculeId") int vehiculeId) {
        
        ModelAndView mav = new ModelAndView("/views/planning/assignation.jsp");
        try {
            planningTrajetService.assignerVehicule(reservationId, vehiculeId);
            mav.addObject("message", "Véhicule assigné avec succès");
        } catch (Exception e) {
            mav.addObject("erreur", e.getMessage());
        }
        mav.addObject("reservations", reservationService.getReservationNonAssigneesViews());
        mav.addObject("totalReservationsNonAssignees", reservationService.getTotalReservationsNonAssignees());
        mav.addObject("totalPersonnesRestantes", reservationService.getTotalPersonnesNonAssignees());
        mav.addObject("vehicules", vehiculeService.getVehiculesDisponibles());
        List<PlanningTrajetView> plannings = planningTrajetService.getAllPlanningsForView();
        mav.addObject("plannings", plannings);
        mav.addObject("planningGroupes", buildPlanningGroupes(plannings));
        mav.addObject("assignations", planningTrajetService.getAssignationsAffichage(null, null, null));
        return mav;
    }


    /**
     * Valider le planning
     */
    @Url("/planning/assignation/valider")
    @Post
    @RestAPI
    public ApiResponse validerPlanning() {
        try {
            planningTrajetService.validerPlanning();
            return ApiResponse.success("Planning validé avec succès");
        } catch (Exception e) {
            return ApiResponse.error(500, e.getMessage());
        }
    }

    /**
     * Sprint 6: modifier l'heure de disponibilité d'un véhicule.
     */
    @Url("/planning/vehicules/disponibilite")
    @Post
    @RestAPI
    public ApiResponse modifierDisponibiliteVehicule(
            @RequestParam("vehiculeId") long vehiculeId,
            @RequestParam("heureDisponible") String heureDisponible) {
        try {
            vehiculeService.updateHeureDisponibilite(vehiculeId, heureDisponible);
            return ApiResponse.success("Disponibilité du véhicule mise à jour");
        } catch (Exception e) {
            return ApiResponse.error(500, e.getMessage());
        }
    }

    /**
     * Voir les détails d'un trajet planifié
     */
    @Url("/planning/assignation/{reservationId}/details")
    @Get
    public ModelAndView afficherDetails(int reservationId) {
        ModelAndView mav = new ModelAndView("/views/planning/details.jsp");
        
        Reservation reservation = reservationService.getReservationById(reservationId);
        PlanningTrajet planning = planningTrajetService.getPlanningByReservationId(reservationId);
        
        mav.addObject("reservation", reservation);
        mav.addObject("planning", planning);
        
        return mav;
    }

    private List<PlanningTrajetGroupeView> buildPlanningGroupes(List<PlanningTrajetView> plannings) {
        Map<String, PlanningTrajetGroupeView> groupes = new LinkedHashMap<>();

        for (PlanningTrajetView planning : plannings) {
            String dateIso = planning.getDateArriveeIso() != null ? planning.getDateArriveeIso() : "";
            String heure = planning.getHeureArrivee() != null ? planning.getHeureArrivee() : "";
            String key = planning.getVehiculeId() + "|" + dateIso + "|" + heure;

            PlanningTrajetGroupeView groupe = groupes.get(key);
            if (groupe == null) {
                groupe = new PlanningTrajetGroupeView();
                groupe.setVehiculeId(planning.getVehiculeId());
                groupe.setVehiculeImmatriculation(planning.getVehiculeImmatriculation());
                groupe.setDateArrivee(planning.getDateArrivee());
                groupe.setDateArriveeIso(dateIso);
                groupe.setHeureArrivee(heure);
                groupe.setCapaciteVehicule(planning.getCapaciteVehicule());
                groupe.setTypeCarburantVehicule(planning.getTypeCarburantVehicule());
                groupe.setDureeEstimee(planning.getDureeEstimee());
                groupe.setStatut(planning.getStatut());
                groupe.setClients(new ArrayList<>());
                groupe.setPointsDepart(new ArrayList<>());
                groupe.setPointsArrivee(new ArrayList<>());
                groupes.put(key, groupe);
            }

            groupe.setNombrePassagersTotal(groupe.getNombrePassagersTotal() + planning.getNombrePersonnes());
            groupe.setDistanceTotale(groupe.getDistanceTotale() + planning.getDistance());
            groupe.setStatut(prioriserStatut(groupe.getStatut(), planning.getStatut()));

            String client = planning.getNomClient() + " (" + planning.getNombrePersonnes() + "p)";
            if (!groupe.getClients().contains(client)) {
                groupe.getClients().add(client);
            }

            if (planning.getLieuDepart() != null && !planning.getLieuDepart().isEmpty() &&
                    !groupe.getPointsDepart().contains(planning.getLieuDepart())) {
                groupe.getPointsDepart().add(planning.getLieuDepart());
            }

            if (planning.getLieuArrivee() != null && !planning.getLieuArrivee().isEmpty() &&
                    !groupe.getPointsArrivee().contains(planning.getLieuArrivee())) {
                groupe.getPointsArrivee().add(planning.getLieuArrivee());
            }
        }

        for (PlanningTrajetGroupeView groupe : groupes.values()) {
            int placesLibres = Math.max(groupe.getCapaciteVehicule() - groupe.getNombrePassagersTotal(), 0);
            groupe.setPlacesLibres(placesLibres);
            
            // ⭐ CORRECTION: Recalculer la durée estimée en fonction de la distance totale du groupe
            // (La durée n'était définie que pour la première réservation du groupe)
            groupe.setDureeEstimee(calculerDureeEstimee(groupe.getDistanceTotale()));
            groupe.setHeureRetour(calculerHeureRetour(groupe.getHeureArrivee(), groupe.getDureeEstimee()));
        }

        return new ArrayList<>(groupes.values());
    }

    private List<PlanningTrajetView> filtrerPlannings(List<PlanningTrajetView> plannings,
                                                      String date,
                                                      String heure,
                                                      String vehiculeId) {
        List<PlanningTrajetView> filtres = plannings;

        if (date != null && !date.isEmpty()) {
            filtres = filtres.stream()
                    .filter(p -> p.getDateArriveeIso() != null && p.getDateArriveeIso().startsWith(date))
                    .collect(Collectors.toList());
        }

        if (heure != null && !heure.isEmpty()) {
            final String filterHeure = heure;
            filtres = filtres.stream()
                    .filter(p -> p.getHeureArrivee() != null && p.getHeureArrivee().startsWith(filterHeure))
                    .collect(Collectors.toList());
        }

        if (vehiculeId != null && !vehiculeId.isEmpty()) {
            try {
                final long filterVehiculeId = Long.parseLong(vehiculeId);
                filtres = filtres.stream()
                        .filter(p -> p.getVehiculeId() == filterVehiculeId)
                        .collect(Collectors.toList());
            } catch (NumberFormatException ignored) {
                // Ignorer un vehiculeId invalide et ne pas casser la page
            }
        }

        return filtres;
    }

    private String prioriserStatut(String current, String incoming) {
        if (incoming == null || incoming.isEmpty()) {
            return current;
        }
        if (current == null || current.isEmpty()) {
            return incoming;
        }
        if ("PLANIFIE".equalsIgnoreCase(current) || "PLANIFIE".equalsIgnoreCase(incoming)) {
            return "PLANIFIE";
        }
        if ("EN_COURS".equalsIgnoreCase(current) || "EN_COURS".equalsIgnoreCase(incoming)) {
            return "EN_COURS";
        }
        return incoming;
    }

    /**
     * Calcule la durée estimée en fonction de la distance (en km)
     * Vitesse moyenne par défaut: 90 km/h
     */
    private String calculerDureeEstimee(double distanceKm) {
        if (distanceKm <= 0) {
            return "00:00:00";
        }
        
        // Vitesse moyenne par défaut 90 km/h
        int vitesseMoyenne = 90;
        
        try {
            // Essayer de récupérer la vitesse configurée
            service.ParametreConfigurationService paramService = new service.ParametreConfigurationService();
            int configuredSpeed = paramService.getParametreAsInt("VITESSE_MOYENNE_KMH");
            if (configuredSpeed > 0) {
                vitesseMoyenne = configuredSpeed;
            }
        } catch (Exception e) {
            // Si erreur, utiliser la vitesse par défaut
        }
        
        // Calculer les heures et convertir en minutes
        double heures = distanceKm / vitesseMoyenne;
        int minutes = (int) Math.round(heures * 60);
        
        // Formater au format HH:MM:SS
        int h = minutes / 60;
        int m = minutes % 60;
        int s = 0;
        return String.format("%02d:%02d:%02d", h, m, s);
    }

    private String calculerHeureRetour(String heureDepart, String dureeEstimee) {
        if (heureDepart == null || heureDepart.trim().isEmpty() || dureeEstimee == null || dureeEstimee.trim().isEmpty()) {
            return "N/A";
        }

        try {
            String heureNormalisee = heureDepart.trim();
            if (heureNormalisee.matches("^\\d{2}:\\d{2}$")) {
                heureNormalisee = heureNormalisee + ":00";
            }

            String[] parts = dureeEstimee.trim().split(":");
            if (parts.length < 2) {
                return "N/A";
            }

            int heures = Integer.parseInt(parts[0]);
            int minutes = Integer.parseInt(parts[1]);
            int secondes = parts.length > 2 ? Integer.parseInt(parts[2]) : 0;

            LocalTime retour = LocalTime.parse(heureNormalisee)
                    .plusHours(heures)
                    .plusMinutes(minutes)
                    .plusSeconds(secondes);

            return retour.toString();
        } catch (DateTimeParseException | NumberFormatException e) {
            return "N/A";
        }
    }

}
