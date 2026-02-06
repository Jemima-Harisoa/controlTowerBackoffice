<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profil Utilisateur - Control Tower</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/welcome.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>👤 Profil Utilisateur</h1>
            <p class="subtitle">Page d'exemple pour ModelAndView</p>
        </header>

        <div class="main-content">
            <h2>Informations Utilisateur</h2>
            <p class="description">${message}</p>
            
            <div class="info-section">
                <h3>Détails du Profil</h3>
                <ul class="info-list">
                    <li><strong>ID :</strong> ${userId}</li>
                    <li><strong>Nom :</strong> ${user.name}</li>
                    <li><strong>Prénom :</strong> ${user.firstName}</li>
                </ul>
            </div>

            <div style="text-align: center; margin-top: 30px;">
                <a href="${pageContext.request.contextPath}/welcome" class="cta-button">← Retour à l'accueil</a>
            </div>
        </div>

        <footer>
            <p>Page d'exemple générée par ModelAndView</p>
        </footer>
    </div>
</body>
</html>