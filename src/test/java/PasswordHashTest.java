import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import org.junit.Test;

import model.User;
import service.UserService;
import util.PasswordUtil;

/**
 * Test individuel pour vérifier le hash du mot de passe
 * Username: admin
 * Password: password
 */
public class PasswordHashTest {
    
    private UserService userService = new UserService();
    
    /**
     * Test 1: Vérifier que le hash du mot de passe "password" est correct
     */
    @Test
    public void testPasswordHashWithStaticHash() {
        // Hash BCrypt connu pour le mot de passe "password"
        String knownHash = "$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi";
        String plainPassword = "password";
        
        // Vérifier que le mot de passe correspond au hash
        boolean isValid = PasswordUtil.verifyPassword(plainPassword, knownHash);
        
        assertTrue("Le mot de passe 'password' devrait correspondre au hash", isValid);
        System.out.println("✓ Test réussi: Le hash du mot de passe 'password' est correct");
    }
    
    /**
     * Test 2: Vérifier avec un utilisateur admin depuis la base de données
     * Ce test nécessite une connexion à la base de données
     */
    @Test
    public void testAdminPasswordFromDatabase() {
        String username = "admin";
        String plainPassword = "password";
        
        // Récupérer l'utilisateur depuis la base de données
        User dbUser = userService.getUserByUsername(username);
        
        // Vérifier que l'utilisateur existe
        assertNotNull("L'utilisateur 'admin' devrait exister dans la base de données", dbUser);
        
        // Vérifier que le mot de passe est correct
        boolean isValid = PasswordUtil.verifyPassword(plainPassword, dbUser.getPassword());
        
        assertTrue("Le mot de passe 'password' devrait être valide pour l'utilisateur 'admin'", isValid);
        System.out.println("✓ Test réussi: Le mot de passe de l'utilisateur 'admin' est correct");
        System.out.println("  Username: " + dbUser.getUsername());
        System.out.println("  Email: " + dbUser.getEmail());
        System.out.println("  Role: " + dbUser.getRole());
    }
    
    /**
     * Test 3: Vérifier qu'un mauvais mot de passe est rejeté
     */
    @Test
    public void testWrongPassword() {
        String knownHash = "$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi";
        String wrongPassword = "wrongpassword";
        
        // Vérifier qu'un mauvais mot de passe est rejeté
        boolean isValid = PasswordUtil.verifyPassword(wrongPassword, knownHash);
        
        assertFalse("Un mauvais mot de passe ne devrait pas correspondre au hash", isValid);
        System.out.println("✓ Test réussi: Le mauvais mot de passe est correctement rejeté");
    }
    
    /**
     * Test 4: Générer un nouveau hash et vérifier qu'il fonctionne
     */
    @Test
    public void testHashGeneration() {
        String plainPassword = "password";
        
        // Générer un nouveau hash
        String newHash = PasswordUtil.hashPassword(plainPassword);
        
        // Vérifier que le hash n'est pas vide
        assertNotNull("Le hash ne devrait pas être null", newHash);
        assertFalse("Le hash ne devrait pas être vide", newHash.isEmpty());
        
        // Vérifier que le mot de passe correspond au nouveau hash
        boolean isValid = PasswordUtil.verifyPassword(plainPassword, newHash);
        assertTrue("Le mot de passe devrait correspondre au hash généré", isValid);
        
        System.out.println("✓ Test réussi: Génération et vérification du hash");
        System.out.println("  Hash généré: " + newHash);
    }
}
