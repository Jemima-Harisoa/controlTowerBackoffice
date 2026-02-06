package dto;

/**
 * DTO pour la requête de login
 */
public class LoginRequestDto {
    private String username;
    private String password;
    
    // Constructeur par défaut
    public LoginRequestDto() {}
    
    // Constructeur avec paramètres
    public LoginRequestDto(String username, String password) {
        this.username = username;
        this.password = password;
    }
    
    // Getters
    public String getUsername() { return username; }
    public String getPassword() { return password; }
    
    // Setters
    public void setUsername(String username) { this.username = username; }
    public void setPassword(String password) { this.password = password; }
    
    // Validation
    public boolean isValid() {
        return username != null && !username.trim().isEmpty() &&
               password != null && !password.trim().isEmpty();
    }
}