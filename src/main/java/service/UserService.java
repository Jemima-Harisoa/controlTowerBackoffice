package service;

import java.util.List;

import framework.security.User;
import repository.UserRepository;
import util.PasswordUtil;

public class UserService {
    private UserRepository userRepository = new UserRepository();
    
    /**
     * Authentifie un utilisateur avec son nom d'utilisateur et son mot de passe
     * @param username Nom d'utilisateur
     * @param password Mot de passe en clair
     * @return Utilisateur authentifié ou null
     */
    public User authenticate(String username, String password) {
        try {
            model.User dbUser = userRepository.findActiveByUsername(username);
            if (dbUser == null) {
                return null;
            }

            if (PasswordUtil.verifyPassword(password, dbUser.getPassword())) {
                User authenticatedUser = new User();
                authenticatedUser.setUsername(dbUser.getUsername());
                authenticatedUser.setPassword(dbUser.getPassword());
                authenticatedUser.setRole(dbUser.getRole());
                return authenticatedUser;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Récupère un utilisateur par son nom d'utilisateur
     */
    public model.User getUserByUsername(String username) {
        return userRepository.findByUsername(username);
    }
    
    /**
     * Récupère un utilisateur par son ID
     */
    public model.User getUserById(int id) {
        return userRepository.findById(id);
    }
    
    /**
     * Récupère tous les utilisateurs
     */
    public List<model.User> getAllUsers() {
        return userRepository.findAll();
    }
    
    /**
     * Crée un nouvel utilisateur avec hash BCrypt
     */
    public boolean createUser(model.User user, String plainPassword) {
        String hashedPassword = PasswordUtil.hashPassword(plainPassword);
        return userRepository.create(user, hashedPassword);
    }
    
    /**
     * Met à jour un utilisateur
     */
    public boolean updateUser(model.User user) {
        return userRepository.update(user);
    }
    
    /**
     * Change le mot de passe d'un utilisateur
     */
    public boolean changePassword(int userId, String newPassword) {
        String hashedPassword = PasswordUtil.hashPassword(newPassword);
        return userRepository.updatePassword(userId, hashedPassword);
    }
    
    /**
     * Supprime un utilisateur
     */
    public boolean deleteUser(int id) {
        return userRepository.delete(id);
    }
}