<%@ page pageEncoding="UTF-8" %>
<%-- 
    header.jsp - En-tete commun pour toutes les pages authentifiees
    ================================================================
    INCLUSION AU COMPILE-TIME (pas de passage par FrontServlet) :
        <%@ include file="/views/components/header.jsp" %>
    
    Variables utilisées :
    - ${pageTitle}          : titre de la page (request attribute, défini par le contrôleur)
    - ${sessionScope.userName} : nom de l'utilisateur (session attribute, défini au login)
--%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle} - Control Tower</title>
    
    <!-- Font Awesome (icones) -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    
    <!-- CSS externes -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/welcome.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/reservation.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/hotel.css">
    
    <style>
        /* Layout principal : sidebar fixe à gauche + contenu à droite */
        body {
            margin: 0;
            padding: 0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f5f5f5;
        }
        
        .main-content {
            margin-left: 250px;   /* largeur de la sidebar */
            min-height: 100vh;
            padding: 20px;
            transition: margin-left 0.3s;
        }
        
        .main-header {
            background: white;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .main-header h1 {
            margin: 0;
            color: #333;
            font-size: 24px;
        }
        
        .user-info {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .user-info span { color: #666; }
        
        .btn-logout {
            padding: 8px 16px;
            background: #dc3545;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            transition: background 0.3s;
        }
        
        .btn-logout:hover { background: #c82333; }
        
        .content-wrapper {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>
    <!-- Sidebar : incluse au compile-time (ne passe PAS par FrontServlet) -->
    <%@ include file="/views/components/sidebar.jsp" %>
    
    <!-- Contenu principal -->
    <div class="main-content">
        <!-- Barre du haut : titre + info utilisateur -->
        <div class="main-header">
            <h1>${pageTitle}</h1>
            <div class="user-info">
                <span>Bienvenue, <strong>${sessionScope.userName}</strong></span>
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                    <i class="fas fa-sign-out-alt"></i> D&#233;connexion
                </a>
            </div>
        </div>
        
        <!-- Début du contenu spécifique à la page -->
        <div class="content-wrapper">
