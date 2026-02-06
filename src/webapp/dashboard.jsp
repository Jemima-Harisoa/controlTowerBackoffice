<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.*" %>
<%
    // Vérifier si l'utilisateur est connecté
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String username = (String) userSession.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Control Tower - Dashboard</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: Arial, sans-serif;
            background: #f5f5f5;
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .header h1 {
            font-size: 24px;
        }
        .user-info {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        .nav-links {
            display: flex;
            gap: 20px;
        }
        .nav-links a {
            color: white;
            text-decoration: none;
            padding: 8px 16px;
            border-radius: 6px;
            transition: background 0.3s;
        }
        .nav-links a:hover {
            background: rgba(255, 255, 255, 0.2);
        }
        .btn-logout {
            background: rgba(255, 255, 255, 0.2);
            color: white;
            border: 1px solid rgba(255, 255, 255, 0.3);
            padding: 8px 16px;
            border-radius: 6px;
            text-decoration: none;
            transition: all 0.3s;
        }
        .btn-logout:hover {
            background: rgba(255, 255, 255, 0.3);
        }
        .container {
            max-width: 1200px;
            margin: 40px auto;
            padding: 0 20px;
        }
        .dashboard-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 30px;
            margin-top: 30px;
        }
        .dashboard-card {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
            text-align: center;
        }
        .dashboard-card h3 {
            color: #333;
            margin-bottom: 15px;
            font-size: 20px;
        }
        .dashboard-card p {
            color: #666;
            line-height: 1.6;
        }
        .welcome-message {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
            text-align: center;
        }
        .welcome-message h2 {
            color: #333;
            margin-bottom: 15px;
        }
        .welcome-message p {
            color: #666;
            font-size: 18px;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>Control Tower Dashboard</h1>
        <div class="nav-links">
            <a href="dashboard">Dashboard</a>
            <a href="users">Utilisateurs</a>
        </div>
        <div class="user-info">
            <span>Bienvenue, <%= username %></span>
            <a href="logout" class="btn-logout">Déconnexion</a>
        </div>
    </div>
    
    <div class="container">
        <div class="welcome-message">
            <h2>Tableau de bord administratif</h2>
            <p>Bienvenue dans l'interface d'administration Control Tower</p>
        </div>
        
        <div class="dashboard-grid">
            <div class="dashboard-card">
                <h3>Gestion des utilisateurs</h3>
                <p>Administrer les comptes utilisateurs et leurs permissions.</p>
                <a href="users" style="color: #667eea; text-decoration: none; font-weight: bold;">→ Accéder</a>
            </div>
            
            <div class="dashboard-card">
                <h3>Configuration système</h3>
                <p>Paramétrer les options et configurations de l'application.</p>
            </div>
            
            <div class="dashboard-card">
                <h3>Rapports et statistiques</h3>
                <p>Consulter les métriques et générer des rapports détaillés.</p>
            </div>
            
            <div class="dashboard-card">
                <h3>Maintenance</h3>
                <p>Outils de maintenance et de monitoring du système.</p>
            </div>
        </div>
    </div>
</body>
</html>