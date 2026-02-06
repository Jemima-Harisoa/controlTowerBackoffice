package dto;

/**
 * DTO pour la réponse de login
 */
public class LoginResponseDto {
    private boolean success;
    private String message;
    private String username;
    private String role;
    
    // Constructeur par défaut
    public LoginResponseDto() {}
    
    // Constructeur pour succès
    public LoginResponseDto(boolean success, String username, String role) {
        this.success = success;
        this.username = username;
        this.role = role;
        this.message = success ? "Connexion réussie" : "Échec de la connexion";
    }
    
    // Constructeur pour erreur
    public LoginResponseDto(boolean success, String message) {
        this.success = success;
        this.message = message;
    }
    
    // Getters
    public boolean isSuccess() { return success; }
    public String getMessage() { return message; }
    public String getUsername() { return username; }
    public String getRole() { return role; }
    
    // Setters
    public void setSuccess(boolean success) { this.success = success; }
    public void setMessage(String message) { this.message = message; }
    public void setUsername(String username) { this.username = username; }
    public void setRole(String role) { this.role = role; }
}