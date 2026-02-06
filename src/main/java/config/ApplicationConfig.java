package config;

import annotations.Controller;
import java.util.Arrays;
import java.util.List;

/**
 * Configuration principale de l'application Control Tower
 */
public class ApplicationConfig {
    
    /**
     * Packages à scanner pour les contrôleurs
     */
    public static List<String> getControllerPackages() {
        return Arrays.asList("controller");
    }
    
    /**
     * Configuration des sessions
     */
    public static class SessionConfig {
        public static final int SESSION_TIMEOUT = 30 * 60; // 30 minutes en secondes
        public static final String SESSION_USER_KEY = "user";
        public static final String SESSION_ROLE_KEY = "role";
    }
    
    /**
     * Configuration des vues
     */
    public static class ViewConfig {
        public static final String VIEW_PREFIX = "/";
        public static final String VIEW_SUFFIX = ".jsp";
        public static final String REDIRECT_PREFIX = "redirect:";
    }
    
    /**
     * Configuration de l'authentification
     */
    public static class AuthConfig {
        public static final String LOGIN_URL = "/login";
        public static final String LOGOUT_URL = "/logout";
        public static final String DASHBOARD_URL = "/dashboard";
        
        /**
         * Pages qui ne nécessitent pas d'authentification
         */
        public static List<String> getPublicUrls() {
            return Arrays.asList(
                LOGIN_URL,
                "/css/*",
                "/js/*", 
                "/images/*",
                "/favicon.ico",
                "/"
            );
        }
    }
}