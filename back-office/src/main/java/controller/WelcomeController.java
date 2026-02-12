package controller;

import framework.annotation.*;
import framework.ModelAndView.ModelAndView;
import jakarta.servlet.http.HttpServletRequest;
import service.UserService;
import service.HotelService;
import service.ReservationService;

@Controller
public class WelcomeController {
    
    private UserService userService = new UserService();
    private HotelService hotelService = new HotelService();
    private ReservationService reservationService = new ReservationService();
    
    /**
     * Page d'accueil après connexion
     */
    @Url("/welcome")
    @Get
    @AuthenticatedOnly
    public ModelAndView welcome(HttpServletRequest request) {
        ModelAndView mav = new ModelAndView("/WEB-INF/templates/main-template.jsp");
        
        // Titre de la page
        mav.addObject("pageTitle", "Tableau de Bord");
        
        // Page de contenu à inclure
        mav.addObject("contentPage", "/views/welcome.jsp");
        
        // Récupérer les informations de l'utilisateur
        model.User dbUser = (model.User) request.getSession().getAttribute("dbUser");
        if (dbUser != null) {
            mav.addObject("currentUser", dbUser);
            mav.addObject("userName", dbUser.getFirstName() + " " + dbUser.getLastName());
        }
        
        // Statistiques pour le dashboard
        try {
            int totalHotels = hotelService.getAllHotels().size();
            int totalReservations = reservationService.getAllReservations().size();
            int totalUsers = userService.getAllUsers().size();
            
            mav.addObject("totalHotels", totalHotels);
            mav.addObject("totalReservations", totalReservations);
            mav.addObject("totalUsers", totalUsers);
        } catch (Exception e) {
            e.printStackTrace();
            mav.addObject("totalHotels", 0);
            mav.addObject("totalReservations", 0);
            mav.addObject("totalUsers", 0);
        }
        
        return mav;
    }
}