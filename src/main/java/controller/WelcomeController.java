package controller;

import framework.ModelAndView.ModelAndView;
import framework.annotation.AuthenticatedOnly;
import framework.annotation.Controller;
import framework.annotation.Get;
import framework.annotation.Url;
import service.HotelService;
import service.ReservationService;

/**
 * Dashboard principal
 * ====================
 * Utilise ModelAndView car on doit passer des données (statistiques) à la vue.
 * 
 * ModelAndView("/views/...") → FrontServlet.handleModelView() :
 *   1. Vérifie que la vue existe (getResource)
 *   2. Copie les attributs du modèle en request.setAttribute()
 *   3. Forward vers la JSP
 * 
 * Le userName vient de la session (défini au login), pas besoin de le re-charger.
 */
@Controller
public class WelcomeController {
    
    private HotelService hotelService = new HotelService();
    private ReservationService reservationService = new ReservationService();
    
    /**
     * GET /welcome → Tableau de bord avec statistiques
     * @AuthenticatedOnly → si pas connecté, le framework retourne erreur 401
     */
    @Url("/welcome")
    @Get
    @AuthenticatedOnly
    public ModelAndView welcome() {
        // Vue directe : plus de template intermédiaire, chaque page est autonome
        ModelAndView mav = new ModelAndView("/views/welcome.jsp");
        mav.addObject("pageTitle", "Tableau de Bord");
        
        // Statistiques pour le dashboard
        try {
            mav.addObject("totalHotels", hotelService.getAllHotels().size());
            mav.addObject("totalReservations", reservationService.getAllReservations().size());
        } catch (Exception e) {
            mav.addObject("totalHotels", 0);
            mav.addObject("totalReservations", 0);
        }
        
        return mav;
    }
}