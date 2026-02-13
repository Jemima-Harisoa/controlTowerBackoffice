package service;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import util.DatabaseConnection;
import model.UserSession;

public class UserSessionService {
    private DatabaseConnection dbConnection = DatabaseConnection.getInstance();
    
    /**
     * Crée une nouvelle session utilisateur
     * @param session Session à créer
     * @return true si la création a réussi, false sinon
     */
    public boolean createSession(UserSession session) {
        try {
            Connection conn = dbConnection.getConnection();
            
            // Utiliser directement la chaîne IP avec cast PostgreSQL
            String query = "INSERT INTO user_sessions (session_id, user_id, expires_at, ip_address, user_agent) VALUES (?, ?, ?, ?::inet, ?)";
            PreparedStatement stmt = conn.prepareStatement(query);
            
            stmt.setString(1, session.getSessionId());
            stmt.setInt(2, session.getUserId());
            stmt.setTimestamp(3, session.getExpiresAt());
            stmt.setString(4, session.getIpAddress()); // Passer directement la chaîne
            stmt.setString(5, session.getUserAgent());
            
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
     * Récupère une session par son ID
     * @param sessionId ID de la session
     * @return UserSession ou null si non trouvée
     */
    public UserSession getSessionById(String sessionId) {
        try {
            Connection conn = dbConnection.getConnection();
            
            String query = "SELECT * FROM user_sessions WHERE session_id = ? AND expires_at > CURRENT_TIMESTAMP";
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setString(1, sessionId);
            
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                UserSession session = new UserSession();
                session.setSessionId(rs.getString("session_id"));
                session.setUserId(rs.getInt("user_id"));
                session.setCreatedAt(rs.getTimestamp("created_at"));
                session.setExpiresAt(rs.getTimestamp("expires_at"));
                session.setIpAddress(rs.getString("ip_address"));
                session.setUserAgent(rs.getString("user_agent"));
                
                rs.close();
                stmt.close();
                conn.close();
                
                return session;
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
     * Supprime une session
     * @param sessionId ID de la session à supprimer
     * @return true si la suppression a réussi, false sinon
     */
    public boolean deleteSession(String sessionId) {
        try {
            Connection conn = dbConnection.getConnection();
            
            String query = "DELETE FROM user_sessions WHERE session_id = ?";
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setString(1, sessionId);
            
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
     * Supprime toutes les sessions expirées
     * @return true si la suppression a réussi, false sinon
     */
    public boolean deleteExpiredSessions() {
        try {
            Connection conn = dbConnection.getConnection();
            
            String query = "DELETE FROM user_sessions WHERE expires_at <= CURRENT_TIMESTAMP";
            Statement stmt = conn.createStatement();
            
            int result = stmt.executeUpdate(query);
            
            stmt.close();
            conn.close();
            
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
