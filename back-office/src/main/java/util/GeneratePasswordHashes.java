package util;
import org.mindrot.jbcrypt.BCrypt;

public class GeneratePasswordHashes {
    public static void main(String[] args) {
        String password = "password";
        
        System.out.println("Hash pour admin:");
        System.out.println(BCrypt.hashpw(password, BCrypt.gensalt(12)));
        
        System.out.println("\nHash pour testuser:");
    }
}