package controller;

import annotations.Controller;
import annotations.GetMapping;
import annotations.PostMapping;
import annotations.JsonMapping;
import annotations.RequestParam;

import dto.UserDto;
import service.UserService;
import java.util.List;

@Controller
public class ApiController {
    
    private UserService userService = new UserService();
    
    @GetMapping("/api/users")
    @JsonMapping
    public List<UserDto> getUsersJson() {
        return userService.getAllUsers();
    }
    
    @PostMapping("/api/users")
    @JsonMapping  
    public UserDto createUserJson(
            @RequestParam("username") String username,
            @RequestParam("password") String password,
            @RequestParam("email") String email,
            @RequestParam("role") String role) {
        
        if (userService.existsByUsername(username)) {
            return null; // Erreur 409 - Conflit
        }
        
        userService.createUser(username, password, email, role);
        return userService.getAllUsers()
                .stream()
                .filter(u -> u.getUsername().equals(username))
                .findFirst()
                .orElse(null);
    }
    
    @GetMapping("/api/status")
    @JsonMapping
    public Object getApplicationStatus() {
        return new Object() {
            public final String status = "running";
            public final String version = "1.0.0";
            public final long timestamp = System.currentTimeMillis();
            public final String application = "Control Tower Backoffice";
        };
    }
}