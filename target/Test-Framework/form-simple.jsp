<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Formulaire Simple - Produits</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 600px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        h1 {
            color: #333;
            border-bottom: 3px solid #4CAF50;
            padding-bottom: 10px;
        }
        .form-container {
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .form-group {
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
            color: #555;
        }
        input[type="text"],
        input[type="number"],
        input[type="email"] {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
            box-sizing: border-box;
        }
        input:focus {
            outline: none;
            border-color: #4CAF50;
        }
        .btn {
            background: #4CAF50;
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            transition: background 0.3s;
        }
        .btn:hover {
            background: #45a049;
        }
        .back-link {
            display: inline-block;
            margin-top: 20px;
            color: #4CAF50;
            text-decoration: none;
        }
        .back-link:hover {
            text-decoration: underline;
        }
        .info {
            background: #e3f2fd;
            padding: 15px;
            border-left: 4px solid #2196F3;
            margin-bottom: 20px;
            border-radius: 4px;
        }
    </style>
</head>
<body>
    <h1>📝 Formulaire Simple</h1>
    
    <div class="form-container">
        <div class="info">
            <strong>Types testés :</strong> Input text, Input number<br>
            <strong>Ce formulaire teste :</strong> Les champs de saisie basiques
        </div>
        
        <form action="${pageContext.request.contextPath}/products/create-simple" method="post">
            
            <div class="form-group">
                <label for="name">Nom du produit *</label>
                <input type="text" id="name" name="name" required 
                       placeholder="Ex: Ordinateur portable">
            </div>
            
            <div class="form-group">
                <label for="price">Prix (€) *</label>
                <input type="number" id="price" name="price" 
                       step="0.01" min="0" required 
                       placeholder="Ex: 599.99">
            </div>
            
            <div class="form-group">
                <label for="quantity">Quantité *</label>
                <input type="number" id="quantity" name="quantity" 
                       min="0" required 
                       placeholder="Ex: 10">
            </div>
            
            <button type="submit" class="btn">✅ Créer le produit</button>
        </form>
        
        <a href="${pageContext.request.contextPath}/products" class="back-link">
            ← Retour à l'accueil
        </a>
    </div>
</body>
</html>