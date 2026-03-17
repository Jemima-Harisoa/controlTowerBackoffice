package controller;

import java.util.List;
import java.util.stream.Collectors;

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
    public ModelAndView afficherAssignation() {
        ModelAndView mav = new ModelAndView("/views/planning/assignation.jsp");
        
        // Récupérer toutes les réservations non assignées ou en cours
        List<ReservationView> reservations = reservationService.getReservationNonAssigneesViews();
        
        // Récupérer tous les véhicules disponibles
        List<Vehicule> vehicules = vehiculeService.getVehiculesDisponibles();
        
        String pageTitle = "Plannification des R&#233;servations";
        mav.addObject("pageTitle", pageTitle);
        mav.addObject("reservations", reservations);
        mav.addObject("vehicules", vehicules);
        mav.addObject("plannings", planningTrajetService.getAllPlanningsForView());
        
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
     * Filtre les réservations par date et heure d'arrivée
     */
    @Url("/planning/assignation/filter")
    @Post
    public ModelAndView filterAssignation(
            @RequestParam(value = "date", required = false) String date,
            @RequestParam(value = "heure", required = false) String heure,
            @RequestParam(value = "vehiculeId", required = false) String vehiculeId) {
        
        ModelAndView mav = new ModelAndView("/views/planning/assignation.jsp");
        
        List<Reservation> reservations = reservationService.getReservationNonAssignees();
        
        // Filtre par date
        if (date != null && !date.isEmpty()) {
            reservations = reservations.stream()
                    .filter(r -> r.getDateArrivee() != null &&
                               r.getDateArrivee().toString().startsWith(date))
                    .collect(Collectors.toList());
        }
        
        // Filtre par heure
        if (heure != null && !heure.isEmpty()) {
            final String filterHeure = heure;
            reservations = reservations.stream()
                    .filter(r -> r.getHeure() != null &&
                               r.getHeure().startsWith(filterHeure))
                    .collect(Collectors.toList());
        }
        
        List<Vehicule> vehicules = vehiculeService.getVehiculesDisponibles();
        
        mav.addObject("reservations", reservations);
        mav.addObject("vehicules", vehicules);
        mav.addObject("filterDate", date);
        mav.addObject("filterHeure", heure);
        mav.addObject("filterVehiculeId", vehiculeId);
        mav.addObject("plannings", planningTrajetService.getAllPlanningsForView());
        
        return mav;
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
        mav.addObject("reservations", reservationService.getReservationNonAssignees());
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
