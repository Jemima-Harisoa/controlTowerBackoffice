package service;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import util.DatabaseConnection;
import util.PasswordUtil;
import framework.security.User;

public class UserService {
    private DatabaseConnection dbConnection = DatabaseConnection.getInstance();
    
    /**
     * Authentifie un utilisateur avec son nom d'utilisateur et son mot de passe
     * @param username Nom d'utilisateur
     * @param password Mot de passe en clair
     * @return Utilisateur authentifié ou null
     */
    public User authenticate(String username, String password) {
        try {
            Connection conn = dbConnection.getConnection();
            
            String query = "SELECT * FROM users WHERE username = ? AND is_active = true";
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setString(1, username);
            
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                String hashedPassword = rs.getString("password_hash");
                
                // BCRYPT: Vérifier le mot de passe
                if (PasswordUtil.verifyPassword(password, hashedPassword)) {
                    User authenticatedUser = new User();
                    authenticatedUser.setUsername(rs.getString("username"));
                    authenticatedUser.setPassword(hashedPassword);
                    authenticatedUser.setRole(rs.getString("role"));
                    
                    rs.close();
                    stmt.close();
                    conn.close();
                    
                    return authenticatedUser;
                }
            }
            
            rs.close();
            stmt.close();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Récupère un utilisateur par son nom d'utilisateur
     */
    public model.User getUserByUsername(String username) {
        try {
            Connection conn = dbConnection.getConnection();
            
            String query = "SELECT * FROM users WHERE username = ?";
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setString(1, username);
            
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                model.User user = new model.User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setPassword(rs.getString("password_hash"));
                user.setEmail(rs.getString("email"));
                user.setFirstName(rs.getString("first_name"));
                user.setLastName(rs.getString("last_name"));
                user.setRole(rs.getString("role"));
                user.setActive(rs.getBoolean("is_active"));
                user.setCreatedAt(rs.getTimestamp("created_at"));
                user.setUpdatedAt(rs.getTimestamp("updated_at"));
                
                rs.close();
                stmt.close();
                conn.close();
                
                return user;
            }
            
            rs.close();
            stmt.close();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Récupère un utilisateur par son ID
     */
    public model.User getUserById(int id) {
        try {
            Connection conn = dbConnection.getConnection();
            
            String query = "SELECT * FROM users WHERE id = ?";
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setInt(1, id);
            
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                model.User user = new model.User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setPassword(rs.getString("password_hash"));
                user.setEmail(rs.getString("email"));
                user.setFirstName(rs.getString("first_name"));
                user.setLastName(rs.getString("last_name"));
                user.setRole(rs.getString("role"));
                user.setActive(rs.getBoolean("is_active"));
                user.setCreatedAt(rs.getTimestamp("created_at"));
                user.setUpdatedAt(rs.getTimestamp("updated_at"));
                
                rs.close();
                stmt.close();
                conn.close();
                
                return user;
            }
            
            rs.close();
            stmt.close();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Récupère tous les utilisateurs
     */
    public List<model.User> getAllUsers() {
        List<model.User> users = new ArrayList<>();
        try {
            Connection conn = dbConnection.getConnection();
            
            String query = "SELECT * FROM users ORDER BY created_at DESC";
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(query);
            
            while (rs.next()) {
                model.User user = new model.User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setPassword(rs.getString("password_hash"));
                user.setEmail(rs.getString("email"));
                user.setFirstName(rs.getString("first_name"));
                user.setLastName(rs.getString("last_name"));
                user.setRole(rs.getString("role"));
                user.setActive(rs.getBoolean("is_active"));
                user.setCreatedAt(rs.getTimestamp("created_at"));
                user.setUpdatedAt(rs.getTimestamp("updated_at"));
                users.add(user);
            }
            
            rs.close();
            stmt.close();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return users;
    }
    
    /**
     * Crée un nouvel utilisateur avec hash BCrypt
     */
    public boolean createUser(model.User user, String plainPassword) {
        try {
            Connection conn = dbConnection.getConnection();
            
            String query = "INSERT INTO users (username, password_hash, email, first_name, last_name, role, is_active) VALUES (?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement stmt = conn.prepareStatement(query);
            
            stmt.setString(1, user.getUsername());
            stmt.setString(2, PasswordUtil.hashPassword(plainPassword)); // BCRYPT
            stmt.setString(3, user.getEmail());
            stmt.setString(4, user.getFirstName());
            stmt.setString(5, user.getLastName());
            stmt.setString(6, user.getRole());
            stmt.setBoolean(7, user.isActive());
            
            int result = stmt.executeUpdate();
            
            stmt.close();
            conn.close();
            
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Met à jour un utilisateur
     */
    public boolean updateUser(model.User user) {
        try {
            Connection conn = dbConnection.getConnection();
            
            String query = "UPDATE users SET username = ?, email = ?, first_name = ?, last_name = ?, role = ?, is_active = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";
            PreparedStatement stmt = conn.prepareStatement(query);
            
            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, user.getFirstName());
            stmt.setString(4, user.getLastName());
            stmt.setString(5, user.getRole());
            stmt.setBoolean(6, user.isActive());
            stmt.setInt(7, user.getId());
            
            int result = stmt.executeUpdate();
            
            stmt.close();
            conn.close();
            
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Change le mot de passe d'un utilisateur
     */
    public boolean changePassword(int userId, String newPassword) {
        try {
            Connection conn = dbConnection.getConnection();
            
            String query = "UPDATE users SET password_hash = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";
            PreparedStatement stmt = conn.prepareStatement(query);
            
            stmt.setString(1, PasswordUtil.hashPassword(newPassword)); // BCRYPT
            stmt.setInt(2, userId);
            
            int result = stmt.executeUpdate();
            
            stmt.close();
            conn.close();
            
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Supprime un utilisateur
     */
    public boolean deleteUser(int id) {
        try {
            Connection conn = dbConnection.getConnection();
            
            String query = "DELETE FROM users WHERE id = ?";
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setInt(1, id);
            
            int result = stmt.executeUpdate();
            
            stmt.close();
            conn.close();
            
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}