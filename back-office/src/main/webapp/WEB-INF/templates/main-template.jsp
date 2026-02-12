<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle} - Control Tower</title>
    
    <!-- CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/welcome.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/reservation.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/hotel.css">
    
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <style>
        /* Layout principal */
        body {
            margin: 0;
            padding: 0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f5f5f5;
        }
        
        .main-content {
            margin-left: 250px;
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
        
        .user-info span {
            color: #666;
        }
        
        .btn-logout {
            padding: 8px 16px;
            background: #dc3545;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            transition: background 0.3s;
        }
        
        .btn-logout:hover {
            background: #c82333;
        }
        
        .content-wrapper {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>
    <!-- Sidebar -->
    <jsp:include page="/WEB-INF/components/sidebar.jsp" />
    
    <!-- Contenu principal -->
    <div class="main-content">
        <div class="main-header">
            <h1>${pageTitle}</h1>
            <div class="user-info">
                <span>Bienvenue, <strong>
                    <c:choose>
                        <c:when test="${not empty userName}">${userName}</c:when>
                        <c:when test="${not empty currentUser}">${currentUser.firstName} ${currentUser.lastName}</c:when>
                        <c:otherwise>Utilisateur</c:otherwise>
                    </c:choose>
                </strong></span>
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">Déconnexion</a>
            </div>
        </div>
        
        <div class="content-wrapper">
            <!-- Contenu spécifique à la page -->
            <jsp:include page="${contentPage}" />
        </div>
    </div>
    
    <!-- Scripts JavaScript -->
    <script src="${pageContext.request.contextPath}/js/sidebar.js"></script>
    <script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>