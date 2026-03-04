package controller;

import framework.ModelAndView.ModelAndView;
import framework.annotation.Controller;
import framework.annotation.Get;
import framework.annotation.Post;
import framework.annotation.RequestParam;
import framework.annotation.Url;
import framework.security.AuthenticationManager;
import framework.security.User;
import jakarta.servlet.http.HttpServletRequest;
import service.ReservationService;
import service.UserService;
import util.PasswordUtil;

@Controller
public class LoginController {
    private UserService userService = new UserService();
    private ReservationService reservationService = new ReservationService();
    
    /**
     * Affiche le formulaire de connexion
     */
    @Url("/login")
    @Get
    public ModelAndView showLoginForm() {
        return new ModelAndView("/WEB-INF/login.jsp");
    }
    
    /**
     * Traite la soumission du formulaire de connexion
     */
    @Url("/login")
    @Post
    public ModelAndView processLogin(
            @RequestParam("username") String username,
            @RequestParam("password") String password,
            HttpServletRequest request) {
        
        // Validation des données
        if (username == null || username.trim().isEmpty() || 
            password == null || password.isEmpty()) {
            
            ModelAndView mav = new ModelAndView("/WEB-INF/login.jsp");
            mav.addObject("erreur", "Veuillez remplir tous les champs");
            return mav;
        }
        
        // Récupérer l'utilisateur depuis la BDD (avec BCrypt)
        model.User dbUser = userService.getUserByUsername(username.trim());
        
        if (dbUser == null) {
            ModelAndView mav = new ModelAndView("/WEB-INF/login.jsp");
            mav.addObject("erreur", "Nom d'utilisateur ou mot de passe incorrect");
            return mav;
        }        
        
        // Vérifier le mot de passe avec BCrypt
        if (!PasswordUtil.verifyPassword(password, dbUser.getPassword())) {
            ModelAndView mav = new ModelAndView("/WEB-INF/login.jsp");
            mav.addObject("erreur", "Nom d'utilisateur ou mot de passe incorrect");
            return mav;
        }
        
        // Vérifier que l'utilisateur est actif
        if (!dbUser.isActive()) {
            ModelAndView mav = new ModelAndView("/WEB-INF/login.jsp");
            mav.addObject("erreur", "Compte désactivé. Contactez l'administrateur.");
            return mav;
        }
        
        // Créer un User du framework à partir de l'utilisateur BD
        User frameworkUser = new User();
        frameworkUser.setUsername(dbUser.getUsername());
        frameworkUser.setPassword(dbUser.getPassword());
        frameworkUser.setRole(dbUser.getRole());
        
        // Stocker l'utilisateur dans la session avec la clé du framework
        request.getSession().setAttribute(AuthenticationManager.SESSION_USER_KEY, frameworkUser);
        
        // Stocker aussi l'utilisateur BD pour les détails complets
        request.getSession().setAttribute("dbUser", dbUser);
        
        // Afficher la liste des réservations avec le template
        ModelAndView mav = new ModelAndView("/WEB-INF/templates/main-template.jsp");
        mav.addObject("pageTitle", "Tableau de Bord - Réservations");
        mav.addObject("contentPage", "/views/reservation/liste-reservations.jsp");
        mav.addObject("currentPage", "reservations-list");
        mav.addObject("userName", dbUser.getFirstName() + " " + dbUser.getLastName());
        mav.addObject("currentUser", dbUser);
        
        // Récupérer et afficher les réservations
        mav.addObject("reservations", reservationService.getAllReservationsForView());
        
        return mav;
    }
    
    /**
     * Déconnecte l'utilisateur
     */
    @Url("/logout")
    @Get
    public String logout(HttpServletRequest request) {
        // Invalidation de la session HTTP
        if (request.getSession(false) != null) {
            request.getSession().invalidate();
        }
        // Afficher le formulaire de connexion
        return "/WEB-INF/login.jsp";
    }
}
