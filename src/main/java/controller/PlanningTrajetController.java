package controller;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

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

        // Filtre par date (sur table planning)
        if (date != null && !date.isEmpty()) {
            plannings = plannings.stream()
                    .filter(p -> p.getDateArriveeIso() != null && p.getDateArriveeIso().startsWith(date))
                    .collect(Collectors.toList());
        }

        // Filtre par heure (sur table planning)
        if (heure != null && !heure.isEmpty()) {
            final String filterHeure = heure;
            plannings = plannings.stream()
                    .filter(p -> p.getHeureArrivee() != null && p.getHeureArrivee().startsWith(filterHeure))
                    .collect(Collectors.toList());
        }

        // Filtre par véhicule assigné (sur table planning)
        if (vehiculeId != null && !vehiculeId.isEmpty()) {
            final long filterVehiculeId = Long.parseLong(vehiculeId);
            plannings = plannings.stream()
                    .filter(p -> p.getVehiculeId() == filterVehiculeId)
                    .collect(Collectors.toList());
        }
        
        // Récupérer tous les véhicules disponibles
        List<Vehicule> vehicules = vehiculeService.getVehiculesDisponibles();
        
        String pageTitle = "Plannification des R&#233;servations";
        mav.addObject("pageTitle", pageTitle);
        mav.addObject("reservations", reservations);
        mav.addObject("vehicules", vehicules);
        mav.addObject("plannings", plannings);
        mav.addObject("planningGroupes", buildPlanningGroupes(plannings));
        mav.addObject("filterDate", date);
        mav.addObject("filterHeure", heure);
        mav.addObject("filterVehiculeId", vehiculeId);
        
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
        mav.addObject("vehicules", vehiculeService.getVehiculesDisponibles());
        List<PlanningTrajetView> plannings = planningTrajetService.getAllPlanningsForView();
        mav.addObject("plannings", plannings);
        mav.addObject("planningGroupes", buildPlanningGroupes(plannings));
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
        }

        return new ArrayList<>(groupes.values());
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

}
