package controller;

import java.sql.Timestamp;
import java.util.UUID;
import jakarta.servlet.http.HttpServletRequest;
import framework.annotation.*;
import framework.ModelAndView.ModelAndView;
import framework.security.User; // User du framework
import service.UserService;
import service.UserSessionService;
import model.UserSession;
import util.PasswordUtil; // Pour BCrypt

@Controller
public class LoginController {
    private UserService userService = new UserService(); // Service qui utilise la BD
    private UserSessionService sessionService = new UserSessionService();
    
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
        
        // ✅ CRÉER UN USER DU FRAMEWORK à partir de l'utilisateur BD
        User frameworkUser = new User();
        frameworkUser.setUsername(dbUser.getUsername());
        frameworkUser.setPassword(dbUser.getPassword()); // Hash BCrypt
        frameworkUser.setRole(dbUser.getRole());
        
        // Stockage dans la session HTTP avec la clé du framework
        request.getSession().setAttribute("user", frameworkUser); // ✅ Clé "user"
        
        System.out.println("✓ Connexion réussie pour: " + username);
        
        // Redirection vers welcome
        return new ModelAndView("redirect:/welcome");
    }
    
    /**
     * Déconnecte l'utilisateur
     */
    @Url("/logout")
    @Get
    public ModelAndView logout(HttpServletRequest request) {
        // Invalidation de la session HTTP
        request.getSession().invalidate();
        
        System.out.println("✓ Déconnexion réussie");
        
        return new ModelAndView("redirect:/login");
    }
}
