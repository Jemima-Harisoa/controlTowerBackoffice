package controller;

import java.util.List;
import java.util.stream.Collectors;

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
        mav.addObject("plannings", planningTrajetService.getAllPlanningsForView());
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

}
