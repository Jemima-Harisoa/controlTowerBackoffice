package service;

import model.User;
import dto.UserDto;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Service de gestion des utilisateurs
 */
public class UserService {
    
    // Simulation d'une base de données en mémoire
    // En production, utiliser JPA/Hibernate avec une vraie base de données
    private final Map<String, User> users = new HashMap<>();
    private Long nextId = 1L;
    
    public UserService() {
        initializeDefaultUsers();
    }
    
    /**
     * Initialise les utilisateurs par défaut
     */
    private void initializeDefaultUsers() {
        createUser("admin", "admin", "admin@controltower.com", "ADMIN");
        createUser("user", "password", "user@controltower.com", "USER");
        createUser("manager", "manager123", "manager@controltower.com", "MANAGER");
    }
    
    /**
     * Crée un nouvel utilisateur
     */
    public User createUser(String username, String password, String email, String role) {
        User user = new User(username, password, role);
        user.setId(nextId++);
        user.setEmail(email);
        users.put(username, user);
        return user;
    }
    
    /**
     * Recherche un utilisateur par nom d'utilisateur
     */
    public User findByUsername(String username) {
        return users.get(username);
    }
    
    /**
     * Recherche un utilisateur par ID
     */
    public User findById(Long id) {
        return users.values()
                .stream()
                .filter(user -> user.getId().equals(id))
                .findFirst()
                .orElse(null);
    }
    
    /**
     * Met à jour un utilisateur
     */
    public User updateUser(User user) {
        if (user.getUsername() != null && users.containsKey(user.getUsername())) {
            users.put(user.getUsername(), user);
            return user;
        }
        return null;
    }
    
    /**
     * Désactive un utilisateur
     */
    public boolean deactivateUser(String username) {
        User user = users.get(username);
        if (user != null) {
            user.setActive(false);
            return true;
        }
        return false;
    }
    
    /**
     * Active un utilisateur
     */
    public boolean activateUser(String username) {
        User user = users.get(username);
        if (user != null) {
            user.setActive(true);
            return true;
        }
        return false;
    }
    
    /**
     * Récupère tous les utilisateurs sous forme de DTO
     */
    public List<UserDto> getAllUsers() {
        return users.values()
                .stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }
    
    /**
     * Récupère les utilisateurs actifs
     */
    public List<UserDto> getActiveUsers() {
        return users.values()
                .stream()
                .filter(User::isActive)
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }
    
    /**
     * Convertit un User en UserDto (sans données sensibles)
     */
    private UserDto convertToDto(User user) {
        return new UserDto(
                user.getId(),
                user.getUsername(),
                user.getEmail(),
                user.getRole(),
                user.isActive()
        );
    }
    
    /**
     * Vérifie si un nom d'utilisateur existe déjà
     */
    public boolean existsByUsername(String username) {
        return users.containsKey(username);
    }
    
    /**
     * Change le mot de passe d'un utilisateur
     */
    public boolean changePassword(String username, String oldPassword, String newPassword) {
        User user = users.get(username);
        if (user != null && user.getPassword().equals(oldPassword)) {
            user.setPassword(newPassword);
            return true;
        }
        return false;
    }
}