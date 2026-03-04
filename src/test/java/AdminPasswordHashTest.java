import static org.junit.Assert.assertTrue;
import org.junit.Test;

import util.PasswordUtil;

/**
 * Test individuel pour vérifier le hash du mot de passe
 * Username: admin
 * Password: password
 */
public class AdminPasswordHashTest {
    
    /**
     * Test: Vérifier que le hash du mot de passe "password" 
     * correspond au hash stocké pour l'utilisateur "admin"
     */
    @Test
    public void testAdminPasswordHash() {
        // Hash BCrypt stocké dans la base de données pour l'utilisateur "admin"
        // Ce hash correspond au mot de passe "password"
        String adminPasswordHash = "$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi";
        String plainPassword = "password";
        
        // Vérifier que le mot de passe "password" correspond au hash de l'admin
        boolean isValid = PasswordUtil.verifyPassword(plainPassword, adminPasswordHash);
        
        assertTrue("Le mot de passe 'password' devrait correspondre au hash de l'utilisateur admin", isValid);
        
        System.out.println("[OK] Test reussi: Le hash du mot de passe est correct");
        System.out.println("  Username: admin");
        System.out.println("  Password: password");
        System.out.println("  Hash: " + adminPasswordHash);
    }
}
