<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%-- 
    login-success.jsp - Page de redirection après connexion réussie
    ================================================================
    Redirige automatiquement vers /reservations via meta-refresh + JS.
    
    Pourquoi cette page ? 
    Le framework ne supporte pas "redirect:/". Après un POST /login, 
    on ne peut pas faire de redirection HTTP. Cette page fait une 
    redirection côté client vers /reservations (GET).
--%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <%-- Redirection automatique vers la liste des réservations --%>
    <meta http-equiv="refresh" content="0;url=${pageContext.request.contextPath}/reservations">
    <title>Connexion réussie</title>
    <style>
        body {
            margin: 0; padding: 0;
            display: flex; justify-content: center; align-items: center;
            min-height: 100vh;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            font-family: 'Segoe UI', sans-serif;
            color: white;
        }
        .loader {
            width: 40px; height: 40px;
            border: 4px solid rgba(255,255,255,0.3);
            border-top-color: white;
            border-radius: 50%;
            animation: spin 0.8s linear infinite;
            margin: 0 auto 15px;
        }
        @keyframes spin { to { transform: rotate(360deg); } }
        .container { text-align: center; }
    </style>
</head>
<body>
    <div class="container">
        <div class="loader"></div>
        <p>Connexion réussie, redirection...</p>
    </div>
    <script>
        // Fallback JS si meta-refresh ne fonctionne pas
        window.location.replace('${pageContext.request.contextPath}/reservations');
    </script>
</body>
</html>
