package controller;

import annotations.Controller;
import annotations.GetMapping;
import annotations.PostMapping;
import annotations.RequestParam;
import annotations.PathVariable;
import model.View;

import dto.UserDto;
import service.UserService;
import java.util.List;

@Controller
public class UserController {
    
    private UserService userService = new UserService();
    
    @GetMapping("/users")
    public View listUsers() {
        List<UserDto> users = userService.getAllUsers();
        View view = new View("users");
        return view;
    }
    
    @GetMapping("/users/{id}")
    public View viewUser(@PathVariable("id") String id) {
        try {
            Long userId = Long.parseLong(id);
            UserDto userDto = userService.getAllUsers()
                    .stream()
                    .filter(u -> u.getId().equals(userId))
                    .findFirst()
                    .orElse(null);
            
            View view = new View("user-detail");
            return view;
        } catch (NumberFormatException e) {
            View view = new View("users");
            return view;
        }
    }
    
    @PostMapping("/users/create")
    public View createUser(
            @RequestParam("username") String username,
            @RequestParam("password") String password,
            @RequestParam("email") String email,
            @RequestParam("role") String role) {
        
        // Validation des données
        if (username == null || username.trim().isEmpty() ||
            password == null || password.trim().isEmpty() ||
            role == null || role.trim().isEmpty()) {
            
            View view = new View("users");
            return view;
        }
        
        // Vérifier si l'utilisateur existe déjà
        if (userService.existsByUsername(username)) {
            View view = new View("users");
            return view;
        }
        
        userService.createUser(username, password, email, role);
        return new View("redirect:users");
    }
    
    @PostMapping("/users/deactivate")
    public View deactivateUser(@RequestParam("username") String username) {
        userService.deactivateUser(username);
        return new View("redirect:users");
    }
    
    @PostMapping("/users/activate")
    public View activateUser(@RequestParam("username") String username) {
        userService.activateUser(username);
        return new View("redirect:users");
    }
}