package controller;

import java.util.Map;

import framework.ModelAndView.ModelAndView;
import framework.annotation.Controller;
import framework.annotation.Get;
import framework.annotation.Post;
import framework.annotation.RequestParam;
import framework.annotation.Session;
import framework.annotation.Url;
import framework.security.AuthenticationManager;
import framework.security.User;
import jakarta.servlet.http.HttpServletRequest;
import service.UserService;
import util.PasswordUtil;

/**
 * Gestion de l'authentification (login / logout)
 * ================================================
 * Tout passe par ModelAndView + @Session, pas de request.setAttribute().
 * 
 * @Session Map : le framework injecte les attributs de la HttpSession comme Map.
 *   - session.put(cle, valeur) → ajoute dans la Map
 *   - syncSessionBack() recopie la Map vers HttpSession apres le return
 * 
 * ModelAndView.addObject() → passe des donnees a la vue (forward)
 * HttpServletRequest → utilise UNIQUEMENT pour invalidate() dans logout
 *                      (comme SessionController.viderSession dans le projet Test)
 */
@Controller
public class LoginController {
    
    private UserService userService = new UserService();
    
    /**
     * GET /login → Affiche le formulaire de connexion
     */
    @Get
    @Url("/login")
    public ModelAndView showLogin() {
        return new ModelAndView("/views/login.jsp");
    }
    
    /**
     * POST /login → Traite la connexion
     * 
     * Erreurs : passees via ModelAndView.addObject("erreur", ...)
     * Session : stockee via @Session Map.put()
     */
    @Post
    @Url("/login")
    public ModelAndView processLogin(
            @RequestParam("username") String username,
            @RequestParam("password") String password,
            @Session Map<String, Object> session) {
        
        ModelAndView log = new ModelAndView("/views/login.jsp");
        
        // Validation basique
        if (username == null || username.trim().isEmpty() || 
            password == null || password.isEmpty()) {
            log.addObject("erreur", "Veuillez remplir tous les champs");
            return log;
        }
        
        // Recherche de l'utilisateur en BDD
        model.User dbUser = userService.getUserByUsername(username.trim());
        
        // Verification credentials (BCrypt)
        if (dbUser == null || !PasswordUtil.verifyPassword(password, dbUser.getPassword())) {
            log.addObject("erreur", "Nom d'utilisateur ou mot de passe incorrect");
            return log;
        }
        
        // Verification compte actif
        if (!dbUser.isActive()) {
            log.addObject("erreur", "Compte desactive. Contactez l'administrateur.");
            return log;
        }
        
        // === SUCCES : creer le User framework (necessaire pour @AuthenticatedOnly) ===
        User frameworkUser = new User();
        frameworkUser.setUsername(dbUser.getUsername());
        frameworkUser.setPassword(dbUser.getPassword());
        frameworkUser.setRole(dbUser.getRole());
        
        // Stocker dans la Map @Session (syncSessionBack recopie vers HttpSession)
        session.put(AuthenticationManager.SESSION_USER_KEY, frameworkUser);
        
        // Donnees supplementaires pour l'affichage dans header.jsp
        session.put("dbUser", dbUser);
        session.put("userName", dbUser.getFirstName() + " " + dbUser.getLastName());
        
        // Page intermediaire qui redirige vers /reservations (meta-refresh)
        return new ModelAndView("/views/login-success.jsp");
    }
    
    /**
     * GET /logout → Invalidation de session + retour au formulaire
     * Pattern identique a SessionController.viderSession() :
     *   @Session + HttpServletRequest pour invalidate()
     */
    @Get
    @Url("/logout")
    public ModelAndView logout(@Session Map<String, Object> session, HttpServletRequest request) {
        // Invalider completement la session HTTP
        request.getSession().invalidate();
        return new ModelAndView("/views/login.jsp");
    }
}
