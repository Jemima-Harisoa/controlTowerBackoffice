<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.*" %>
<%@ page import="dto.UserDto" %>
<%@ page import="java.util.List" %>
<%
    // Vérifier si l'utilisateur est connecté
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String username = (String) userSession.getAttribute("user");
    String role = (String) userSession.getAttribute("role");
    
    @SuppressWarnings("unchecked")
    List<UserDto> users = (List<UserDto>) request.getAttribute("users");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Control Tower - Gestion des utilisateurs</title>
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
        .user-info {
            display: flex;
            align-items: center;
            gap: 15px;
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
        .page-header {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
            margin-bottom: 30px;
        }
        .users-table {
            background: white;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }
        .table-header {
            background: #f8f9fa;
            padding: 20px;
            border-bottom: 1px solid #dee2e6;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            padding: 15px;
            text-align: left;
            border-bottom: 1px solid #dee2e6;
        }
        th {
            background: #f8f9fa;
            font-weight: bold;
            color: #333;
        }
        .status-active {
            color: #28a745;
            font-weight: bold;
        }
        .status-inactive {
            color: #dc3545;
            font-weight: bold;
        }
        .role-badge {
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: bold;
        }
        .role-admin {
            background: #dc3545;
            color: white;
        }
        .role-manager {
            background: #ffc107;
            color: #333;
        }
        .role-user {
            background: #28a745;
            color: white;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>Control Tower</h1>
        <div class="nav-links">
            <a href="dashboard">Dashboard</a>
            <a href="users">Utilisateurs</a>
        </div>
        <div class="user-info">
            <span>Connecté en tant que <%= username %> (<%= role %>)</span>
            <a href="logout" class="btn-logout">Déconnexion</a>
        </div>
    </div>
    
    <div class="container">
        <div class="page-header">
            <h2>Gestion des utilisateurs</h2>
            <p>Liste complète des utilisateurs du système</p>
        </div>
        
        <div class="users-table">
            <div class="table-header">
                <h3>Utilisateurs (Total: <%= users != null ? users.size() : 0 %>)</h3>
            </div>
            
            <% if (users != null && !users.isEmpty()) { %>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Nom d'utilisateur</th>
                            <th>Email</th>
                            <th>Rôle</th>
                            <th>Statut</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (UserDto user : users) { %>
                            <tr>
                                <td><%= user.getId() %></td>
                                <td><%= user.getUsername() %></td>
                                <td><%= user.getEmail() != null ? user.getEmail() : "N/A" %></td>
                                <td>
                                    <span class="role-badge role-<%= user.getRole().toLowerCase() %>">
                                        <%= user.getRole() %>
                                    </span>
                                </td>
                                <td>
                                    <span class="<%= user.isActive() ? "status-active" : "status-inactive" %>">
                                        <%= user.isActive() ? "Actif" : "Inactif" %>
                                    </span>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } else { %>
                <div style="padding: 30px; text-align: center; color: #666;">
                    Aucun utilisateur trouvé
                </div>
            <% } %>
        </div>
    </div>
</body>
</html>