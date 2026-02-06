package service;

import dto.LoginRequestDto;
import dto.LoginResponseDto;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import model.User;

/**
 * Service d'authentification
 */
public class AuthService {
    
    private final UserService userService;
    
    // Simulation d'un cache de sessions (en production, utiliser Redis ou base de données)
    private final Map<String, String> activeSessions = new HashMap<>();
    
    public AuthService() {
        this.userService = new UserService();
    }
    
    /**
     * Authentifie un utilisateur
     */
    public LoginResponseDto authenticate(LoginRequestDto loginRequest) {
        // Validation des données d'entrée
        if (!loginRequest.isValid()) {
            return new LoginResponseDto(false, "Nom d'utilisateur et mot de passe requis");
        }
        
        try {
            // Rechercher l'utilisateur
            User user = userService.findByUsername(loginRequest.getUsername());
            
            if (user == null) {
                return new LoginResponseDto(false, "Utilisateur non trouvé");
            }
            
            if (!user.isActive()) {
                return new LoginResponseDto(false, "Compte désactivé");
            }
            
            // Vérifier le mot de passe
            if (!verifyPassword(loginRequest.getPassword(), user.getPassword())) {
                return new LoginResponseDto(false, "Mot de passe incorrect");
            }
            
            // Mettre à jour la dernière connexion
            user.setLastLogin(LocalDateTime.now());
            userService.updateUser(user);
            
            return new LoginResponseDto(true, user.getUsername(), user.getRole());
            
        } catch (Exception e) {
            return new LoginResponseDto(false, "Erreur lors de l'authentification");
        }
    }
    
    /**
     * Vérifie un mot de passe
     * TODO: Implémenter le hachage (BCrypt, etc.)
     */
    private boolean verifyPassword(String plainPassword, String hashedPassword) {
        // Pour l'instant, comparaison simple
        // En production, utiliser BCrypt.checkpw(plainPassword, hashedPassword)
        return plainPassword.equals(hashedPassword);
    }
    
    /**
     * Crée une session pour l'utilisateur
     */
    public void createSession(String sessionId, String username) {
        activeSessions.put(sessionId, username);
    }
    
    /**
     * Invalide une session
     */
    public void invalidateSession(String sessionId) {
        activeSessions.remove(sessionId);
    }
    
    /**
     * Vérifie si une session est valide
     */
    public boolean isValidSession(String sessionId) {
        return activeSessions.containsKey(sessionId);
    }
    
    /**
     * Récupère le nom d'utilisateur depuis la session
     */
    public String getUsernameFromSession(String sessionId) {
        return activeSessions.get(sessionId);
    }
}