package util;

import org.mindrot.jbcrypt.BCrypt;

/**
 * Utilitaire pour le hachage et la vérification des mots de passe avec BCrypt
 */
public class PasswordUtil {
    
    // Nombre de rounds pour BCrypt (12 est un bon compromis sécurité/performance)
    private static final int BCRYPT_ROUNDS = 12;
    
    /**
     * Hash un mot de passe avec BCrypt
     * @param plainPassword Mot de passe en clair
     * @return Hash BCrypt du mot de passe
     */
    public static String hashPassword(String plainPassword) {
        if (plainPassword == null || plainPassword.isEmpty()) {
            throw new IllegalArgumentException("Le mot de passe ne peut pas être vide");
        }
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt(BCRYPT_ROUNDS));
    }
    
    /**
     * Vérifie si un mot de passe correspond à son hash
     * @param plainPassword Mot de passe en clair
     * @param hashedPassword Hash BCrypt du mot de passe
     * @return true si le mot de passe correspond, false sinon
     */
    public static boolean verifyPassword(String plainPassword, String hashedPassword) {
        if (plainPassword == null || hashedPassword == null) {
            return false;
        }
        
        try {
            return BCrypt.checkpw(plainPassword, hashedPassword);
        } catch (IllegalArgumentException e) {
            // Hash invalide
            System.err.println("Hash BCrypt invalide: " + e.getMessage());
            return false;
        }
    }
    
    /**
     * Vérifie si un hash nécessite un rehash (si le nombre de rounds a changé)
     * @param hashedPassword Hash à vérifier
     * @return true si un rehash est nécessaire
     */
    public static boolean needsRehash(String hashedPassword) {
        try {
            // Extraire le nombre de rounds du hash
            String[] parts = hashedPassword.split("\\$");
            if (parts.length < 4) {
                return true;
            }
            int rounds = Integer.parseInt(parts[2]);
            return rounds < BCRYPT_ROUNDS;
        } catch (Exception e) {
            return true;
        }
    }
}