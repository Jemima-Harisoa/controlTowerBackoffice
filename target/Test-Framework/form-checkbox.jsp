<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Formulaire avec Checkboxes - Produits</title>
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
        input[type="number"] {
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
        .checkbox-group {
            border: 1px solid #ddd;
            padding: 15px;
            border-radius: 4px;
            background: #fafafa;
        }
        .checkbox-item {
            margin-bottom: 10px;
        }
        .checkbox-item label {
            font-weight: normal;
            display: inline;
            margin-left: 8px;
            cursor: pointer;
        }
        input[type="checkbox"] {
            cursor: pointer;
            width: 18px;
            height: 18px;
            vertical-align: middle;
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
    <h1>☑️ Formulaire avec Checkboxes</h1>
    
    <div class="form-container">
        <div class="info">
            <strong>Type testé :</strong> Checkboxes (cases à cocher)<br>
            <strong>Ce formulaire teste :</strong> La sélection multiple de valeurs (tags/étiquettes)
        </div>
        
        <form action="${pageContext.request.contextPath}/products/create-checkbox" method="post">
            
            <div class="form-group">
                <label for="name">Nom du produit *</label>
                <input type="text" id="name" name="name" required 
                       placeholder="Ex: Laptop Gaming">
            </div>
            
            <div class="form-group">
                <label for="price">Prix (€) *</label>
                <input type="number" id="price" name="price" 
                       step="0.01" min="0" required 
                       placeholder="Ex: 1299.99">
            </div>
            
            <div class="form-group">
                <label for="quantity">Quantité *</label>
                <input type="number" id="quantity" name="quantity" 
                       min="0" required 
                       placeholder="Ex: 15">
            </div>
            
            <div class="form-group">
                <label>Tags / Étiquettes</label>
                <div class="checkbox-group">
                    <div class="checkbox-item">
                        <input type="checkbox" id="tag1" name="tags" value="Nouveau">
                        <label for="tag1">🆕 Nouveau</label>
                    </div>
                    
                    <div class="checkbox-item">
                        <input type="checkbox" id="tag2" name="tags" value="Promotion">
                        <label for="tag2">🔥 Promotion</label>
                    </div>
                    
                    <div class="checkbox-item">
                        <input type="checkbox" id="tag3" name="tags" value="Populaire">
                        <label for="tag3">⭐ Populaire</label>
                    </div>
                    
                    <div class="checkbox-item">
                        <input type="checkbox" id="tag4" name="tags" value="Recommandé">
                        <label for="tag4">👍 Recommandé</label>
                    </div>
                    
                    <div class="checkbox-item">
                        <input type="checkbox" id="tag5" name="tags" value="BestSeller">
                        <label for="tag5">🏆 Best Seller</label>
                    </div>
                    
                    <div class="checkbox-item">
                        <input type="checkbox" id="tag6" name="tags" value="Écologique">
                        <label for="tag6">🌱 Écologique</label>
                    </div>
                </div>
            </div>
            
            <button type="submit" class="btn">✅ Créer le produit</button>
        </form>
        
        <a href="${pageContext.request.contextPath}/products" class="back-link">
            ← Retour à l'accueil
        </a>
    </div>
</body>
</html>