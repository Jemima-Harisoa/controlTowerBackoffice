package filter;

import framework.security.User;
import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;

/**
 * Filtre d'authentification pour protéger les pages du back-office
 */
public class AuthenticationFilter implements Filter {
    
    // URLs publiques (sans authentification)
    private static final List<String> PUBLIC_URLS = Arrays.asList(
        "/login",
        "/css/",
        "/js/",
        "/images/",
        "/favicon.ico",
        "/index.jsp",
         "/WEB-INF/login.jsp"
    );
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        System.out.println("✓ AuthenticationFilter initialized");
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) 
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        
        // Récupérer l'URI et le context path
        String requestURI = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        
        // CORRECTION: Utiliser une variable finale pour éviter l'erreur
        // "must be final or effectively final"
        final String requestPath;
        if (requestURI.startsWith(contextPath)) {
            requestPath = requestURI.substring(contextPath.length());
        } else {
            requestPath = requestURI;
        }
        
        // Vérifier si l'URL est publique
        boolean isPublicUrl = PUBLIC_URLS.stream()
            .anyMatch(publicUrl -> requestPath.startsWith(publicUrl));
        
        if (isPublicUrl) {
            // URL publique - continuer sans vérification
            chain.doFilter(request, response);
            return;
        }
        
        // Vérifier si l'utilisateur est authentifié
        User user = (User) httpRequest.getSession().getAttribute("user");
        
        if (user == null) {
            // Pas authentifié - rediriger vers login
            System.out.println("⚠ Non authentifié - redirection vers login: " + requestPath);
            httpResponse.sendRedirect(contextPath + "/login");
            return;
        }
        
        // Utilisateur authentifié - continuer
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        System.out.println("✓ AuthenticationFilter destroyed");
    }
}