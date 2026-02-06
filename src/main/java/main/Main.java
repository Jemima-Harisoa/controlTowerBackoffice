package main;

import config.ApplicationConfig;
import service.AuthService;
import service.UserService;

/**
 * Point d'entrée principal de l'application Control Tower
 * Initialise les services et configure le framework
 */
public class Main {
    
    /**
     * Initialisation de l'application
     * Cette méthode sera appelée au démarrage du serveur
     */
    public static void initializeApplication() {
        System.out.println("=== Control Tower Backoffice - Démarrage ===");
        
        // Initialiser les services
        initializeServices();
        
        // Configurer le framework
        configureFramework();
        
        System.out.println("=== Application initialisée avec succès ===");
    }
    
    /**
     * Initialise les services métier
     */
    private static void initializeServices() {
        System.out.println("Initialisation des services...");
        
        // Initialiser UserService avec les utilisateurs par défaut
        UserService userService = new UserService();
        System.out.println("- UserService: " + userService.getAllUsers().size() + " utilisateurs créés");
        
        // Initialiser AuthService  
        AuthService authService = new AuthService();
        System.out.println("- AuthService: Service d'authentification prêt");
    }
    
    /**
     * Configure le framework maison
     */
    private static void configureFramework() {
        System.out.println("Configuration du framework...");
        
        // Configuration des packages à scanner
        System.out.println("- Packages contrôleurs: " + ApplicationConfig.getControllerPackages());
        
        // Configuration des sessions
        System.out.println("- Timeout session: " + ApplicationConfig.SessionConfig.SESSION_TIMEOUT + "s");
        
        // Configuration des vues
        System.out.println("- Préfixe vues: " + ApplicationConfig.ViewConfig.VIEW_PREFIX);
        System.out.println("- Suffixe vues: " + ApplicationConfig.ViewConfig.VIEW_SUFFIX);
        
        // URLs publiques (sans authentification)
        System.out.println("- URLs publiques: " + ApplicationConfig.AuthConfig.getPublicUrls());
    }
    
    /**
     * Méthode appelée lors de l'arrêt de l'application
     */
    public static void shutdownApplication() {
        System.out.println("=== Arrêt de l'application Control Tower ===");
        // Nettoyage des ressources si nécessaire
    }
}