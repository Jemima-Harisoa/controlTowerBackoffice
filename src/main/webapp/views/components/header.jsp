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
    
    <!-- CSS seuls le layout global -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
    
    <style>
        /* Footer et petits ajustements supplémentaires si nécessaire */
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
        <!-- Header redesigné -->
        <div class="main-header-new">
            <div class="etu-badge-section">
                <div class="etu-label">ETU</div>
                <div class="etu-numbers">
                    <span class="etu-badge">3078</span>
                    <span class="etu-badge">3370</span>
                    <span class="etu-badge">3525</span>
                </div>
            </div>
            
            <div class="header-content">
                <h1>${pageTitle}</h1>
            </div>
            
            <div class="user-section">
                <span class="welcome-text">Bienvenue, <strong>${sessionScope.userName}</strong></span>
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                    <i class="fas fa-sign-out-alt"></i> D&#233;connexion
                </a>
            </div>
        </div>
        
        <!-- Début du contenu spécifique à la page -->
        <div class="content-wrapper">
