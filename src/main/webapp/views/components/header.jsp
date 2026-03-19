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

        /* CSS Header avec badges ETU - Sticky et moderne */
        .main-header-new {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            position: sticky;
            top: 10px;
            z-index: 1000;
            background: #f5f7fb;
            padding: 12px;
            border-radius: 10px;
            box-shadow: 0 4px 14px rgba(0,0,0,0.12);
        }

        .etu-badge-section {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 8px;
        }

        .etu-label {
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            color: #667eea;
            letter-spacing: 1px;
        }

        .etu-numbers {
            display: flex;
            gap: 6px;
        }

        .etu-badge {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
        }

        .main-header-new h1 {
            margin: 0;
            color: #333;
            font-size: 28px;
            flex: 1;
            text-align: center;
        }

        .user-section {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .welcome-text {
            font-size: 14px;
            color: #666;
        }

        .welcome-text strong {
            color: #333;
            font-weight: 700;
        }

        .btn-logout {
            padding: 10px 16px;
            background: #dc3545;
            color: white;
            text-decoration: none;
            border: none;
            border-radius: 6px;
            transition: all 0.3s;
            font-weight: 500;
            box-shadow: 0 2px 4px rgba(220, 53, 69, 0.3);
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 13px;
        }

        .btn-logout:hover {
            background: #c82333;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(220, 53, 69, 0.4);
        }

        @media (max-width: 768px) {
            .main-header-new {
                flex-direction: column;
                gap: 15px;
            }

            .main-header-new h1 {
                font-size: 20px;
            }

            .user-section {
                flex-direction: column;
                width: 100%;
            }

            .welcome-text {
                font-size: 12px;
            }

            .etu-numbers {
                flex-wrap: wrap;
                justify-content: center;
            }
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
