package controller;

import java.util.List;

import dto.ReservationView;
import framework.ModelAndView.ModelAndView;
import framework.annotation.Controller;
import framework.annotation.Get;
import framework.annotation.Url;
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
        
        return mav;
    }
}
