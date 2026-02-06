package controller;

import annotations.Controller;
import annotations.GetMapping;
import annotations.PostMapping;
import annotations.RequestParam;
import model.View;

import dto.LoginRequestDto;
import dto.LoginResponseDto;
import service.AuthService;

@Controller
public class LoginController {
    
    private AuthService authService = new AuthService();
    
    @GetMapping("/login")
    public View showLoginPage() {
        return new View("login");
    }
    
    @PostMapping("/login")
    public View login(
            @RequestParam("username") String username,
            @RequestParam("password") String password) {
        
        // Créer le DTO de requête
        LoginRequestDto loginRequest = new LoginRequestDto(username, password);
        
        // Authentifier via le service
        LoginResponseDto loginResponse = authService.authenticate(loginRequest);
        
        if (loginResponse.isSuccess()) {
            View view = new View("redirect:dashboard");
            return view;
        } else {
            View view = new View("login");
            return view;
        }
    }
    
    @GetMapping("/logout") 
    @PostMapping("/logout")
    public View logout() {
        return new View("redirect:login");
    }
    
    @GetMapping("/dashboard")
    public View dashboard() {
        return new View("dashboard");
    }
}