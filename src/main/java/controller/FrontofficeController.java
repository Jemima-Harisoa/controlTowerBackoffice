package controller;

import framework.ModelAndView.ModelAndView;
import framework.annotation.Controller;
import framework.annotation.Get;
import framework.annotation.Url;
import service.HotelService;

/**
 * Frontoffice - Pages de consultation publiques
 * ================================================
 * Pas de @AuthenticatedOnly : ces pages sont accessibles sans connexion.
 * 
 * Le frontoffice consomme l'API REST (/api/reservations) via JavaScript (fetch).
 * Ici on sert uniquement la page HTML avec les filtres.
 */
@Controller
public class FrontofficeController {

    private HotelService hotelService = new HotelService();

    /**
     * GET /frontoffice/reservations → Page de consultation des réservations
     * Affiche un tableau avec filtres (date, hôtel) qui appelle l'API REST.
     */
    @Url("/frontoffice/reservations")
    @Get
    public ModelAndView showReservationsPage() {
        ModelAndView mav = new ModelAndView("/views/frontoffice/liste-reservations.jsp");
        mav.addObject("pageTitle", "Consultation des R\u00e9servations");
        
        // Passer les hôtels pour le filtre dropdown
        try {
            mav.addObject("hotels", hotelService.getAllHotels());
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return mav;
    }
}
