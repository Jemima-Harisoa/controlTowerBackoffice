package service;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

import dto.LoginRequestDto;
import dto.LoginResponseDto;
import model.User;

public class AuthServiceTest {
    
    private AuthService authService;
    private UserService userService;
    
    @BeforeEach
    public void setUp() {
        authService = new AuthService();
        userService = new UserService();
    }
    
    @Test
    public void testValidAuthentication() {
        LoginRequestDto request = new LoginRequestDto("admin", "admin");
        LoginResponseDto response = authService.authenticate(request);
        
        assertTrue(response.isSuccess(), "L'authentification devrait réussir avec les bons credentials");
        assertEquals("admin", response.getUsername());
        assertEquals("ADMIN", response.getRole());
    }
    
    @Test
    public void testInvalidAuthentication() {
        LoginRequestDto request = new LoginRequestDto("admin", "wrongpassword");
        LoginResponseDto response = authService.authenticate(request);
        
        assertFalse(response.isSuccess(), "L'authentification devrait échouer avec un mauvais mot de passe");
        assertNotNull(response.getMessage());
    }
    
    @Test
    public void testEmptyCredentials() {
        LoginRequestDto request = new LoginRequestDto("", "");
        LoginResponseDto response = authService.authenticate(request);
        
        assertFalse(response.isSuccess(), "L'authentification devrait échouer avec des credentials vides");
    }
    
    @Test
    public void testUserServiceFindByUsername() {
        User user = userService.findByUsername("admin");
        
        assertNotNull(user, "L'utilisateur admin devrait exister");
        assertEquals("admin", user.getUsername());
        assertEquals("ADMIN", user.getRole());
        assertTrue(user.isActive());
    }
    
    @Test
    public void testUserServiceGetAllUsers() {
        var users = userService.getAllUsers();
        
        assertFalse(users.isEmpty(), "Il devrait y avoir des utilisateurs par défaut");
        assertTrue(users.stream().anyMatch(u -> "admin".equals(u.getUsername())));
    }
    
    @Test
    public void testSessionManagement() {
        String sessionId = "test-session-123";
        String username = "admin";
        
        // Créer une session
        authService.createSession(sessionId, username);
        
        // Vérifier que la session est valide
        assertTrue(authService.isValidSession(sessionId));
        assertEquals(username, authService.getUsernameFromSession(sessionId));
        
        // Invalider la session
        authService.invalidateSession(sessionId);
        assertFalse(authService.isValidSession(sessionId));
    }
}