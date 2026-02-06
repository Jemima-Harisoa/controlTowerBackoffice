package controller;

import framework.ModelAndView.ModelAndView;
import framework.annotation.Controller;
import framework.annotation.Get;
import framework.annotation.Post;
import framework.annotation.RequestParam;
import framework.annotation.RestAPI;
import framework.annotation.Url;
import model.User;

/**
 * Controller for the welcome page for test
 * 
 * ROUTES DE TEST DISPONIBLES :
 * 
 * 1. GET /welcome -> Page JSP classique
 * 2. GET /api/welcome -> API JSON (retourne objet User)
 * 3. POST /api/user -> Création utilisateur avec paramètres de formulaire
 * 4. GET /api/user/{id} -> Récupération utilisateur par ID (path variable)
 * 5. GET /profile/{userId} -> Page JSP avec ModelAndView et données
 * 6. GET /search?name=X&age=Y -> API avec query parameters
 * 
 * TESTS CURL :
 * curl http://localhost:8080/ControlTowerBackoffice/api/welcome
 * curl -X POST -d "nom=Dupont&prenom=Marie" http://localhost:8080/ControlTowerBackoffice/api/user
 * curl http://localhost:8080/ControlTowerBackoffice/api/user/123
 * curl "http://localhost:8080/ControlTowerBackoffice/search?name=Jean&age=25"
 */
@Controller
public class WelcomeController {
    
    /**
     * Route classique avec retours jsp 
     * (par defaut url / renvoi un texte brute de la liste de page presente a modifier dans config du frmework) 
     */
    @Get 
    @Url("/welcome")
    public String welcomePage() {
        return "views/welcome.jsp";
    }

    /**
     * Route ApiRest  avec retour json 
     * Peut retourner des objet reformater en json
     */
    @Get
    @Url("/api/welcome")
    @RestAPI
    public User welcomeApi() {
        User person = new  User("Rakoto", "Jean");
        return  person;
    }

    /**
     * Route POST avec paramètres de formulaire
     * Exemple : curl -X POST -d "nom=Dupont&prenom=Marie" http://localhost/api/user
     */
    @Post
    @Url("/api/user")
    @RestAPI
    public User createUser(
        @RequestParam("nom") String nom,
        @RequestParam("prenom") String prenom
    ) {
        User newUser = new User(nom, prenom);
        // Ici vous pourriez sauvegarder en base de données
        return newUser;
    }

    /**
     * Route avec variable dans l'URL (Path Variable)
     * Exemple : GET /api/user/123 -> récupère l'utilisateur avec l'ID 123
     */
    @Get
    @Url("/api/user/{id}")
    @RestAPI
    public User getUserById(int id) {
        // Simulation de récupération depuis une base de données
        if (id == 1) {
            return new User("Rakoto", "Jean");
        } else if (id == 2) {
            return new User("Dupont", "Marie");
        }
        return new User("Inconnu", "ID: " + id);
    }

    /**
     * Route avec ModelAndView pour passer des données à la vue JSP
     * Les données seront disponibles dans la JSP via ${message} et ${user}
     */
    @Get
    @Url("/profile/{userId}")
    public ModelAndView showUserProfile(int userId) {
        ModelAndView mv = new ModelAndView("views/user-profile.jsp");
        
        // Simulation de récupération utilisateur
        User user = new User("Utilisateur " + userId, "Profile");
        
        mv.addObject("message", "Profil de l'utilisateur " + userId);
        mv.addObject("user", user);
        mv.addObject("userId", userId);
        
        return mv;
    }

    /**
     * Route avec paramètres de requête (Query Parameters)
     * Exemple : GET /search?name=Jean&age=25
     * Les paramètres peuvent être optionnels (valeurs par défaut possibles)
     */
    @Get
    @Url("/search")
    @RestAPI
    public String searchUsers(
        @RequestParam("name") String name,
        @RequestParam("age") int age
    ) {
        // Simulation de recherche
        return "Recherche d'utilisateurs : nom='" + name + "', age=" + age;
    }
    
}
