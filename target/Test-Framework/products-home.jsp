<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Tests de Formulaires - Produits</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        h1 {
            color: #333;
            border-bottom: 3px solid #4CAF50;
            padding-bottom: 10px;
        }
        .form-links {
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .form-link {
            display: block;
            padding: 15px;
            margin: 10px 0;
            background: #4CAF50;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            transition: background 0.3s;
        }
        .form-link:hover {
            background: #45a049;
        }
        .description {
            color: #666;
            font-size: 14px;
            margin-top: 5px;
        }
    </style>
</head>
<body>
    <h1>🧪 Tests de Formulaires HTML</h1>
    
    <div class="form-links">
        <h2>Choisissez un type de formulaire à tester :</h2>
        
        <a href="${pageContext.request.contextPath}/products/form-simple" class="form-link">
            📝 Formulaire Simple
            <div class="description">Input text, number, email</div>
        </a>
        
        <a href="${pageContext.request.contextPath}/products/form-select" class="form-link">
            📋 Formulaire avec Select
            <div class="description">Liste déroulante (dropdown)</div>
        </a>
        
        <a href="${pageContext.request.contextPath}/products/form-checkbox" class="form-link">
            ☑️ Formulaire avec Checkboxes
            <div class="description">Cases à cocher multiples</div>
        </a>
        
        <a href="${pageContext.request.contextPath}/products/form-radio" class="form-link">
            🔘 Formulaire avec Radio Buttons
            <div class="description">Boutons radio (choix unique)</div>
        </a>
        
        <a href="${pageContext.request.contextPath}/products/form-textarea" class="form-link">
            📄 Formulaire avec Textarea
            <div class="description">Zone de texte multi-lignes</div>
        </a>
        
        <a href="${pageContext.request.contextPath}/products/form-complete" class="form-link">
            🎯 Formulaire Complet
            <div class="description">Tous les types de champs combinés</div>
        </a>
        
        <hr style="margin: 30px 0;">
        
        <a href="${pageContext.request.contextPath}/products/list" class="form-link" style="background: #2196F3;">
            📦 Voir tous les produits créés
        </a>
    </div>
</body>
</html>