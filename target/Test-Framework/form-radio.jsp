<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Formulaire avec Radio Buttons - Produits</title>
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
        .radio-group {
            border: 1px solid #ddd;
            padding: 15px;
            border-radius: 4px;
            background: #fafafa;
        }
        .radio-item {
            margin-bottom: 12px;
            padding: 10px;
            border-radius: 4px;
            transition: background 0.2s;
        }
        .radio-item:hover {
            background: #f0f0f0;
        }
        .radio-item label {
            font-weight: normal;
            display: inline;
            margin-left: 8px;
            cursor: pointer;
        }
        input[type="radio"] {
            cursor: pointer;
            width: 18px;
            height: 18px;
            vertical-align: middle;
        }
        .priority-high {
            border-left: 4px solid #f44336;
        }
        .priority-medium {
            border-left: 4px solid #ff9800;
        }
        .priority-low {
            border-left: 4px solid #4CAF50;
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
    <h1>🔘 Formulaire avec Radio Buttons</h1>
    
    <div class="form-container">
        <div class="info">
            <strong>Type testé :</strong> Radio buttons (boutons radio)<br>
            <strong>Ce formulaire teste :</strong> La sélection unique parmi plusieurs options (priorité)
        </div>
        
        <form action="${pageContext.request.contextPath}/products/create-radio" method="post">
            
            <div class="form-group">
                <label for="name">Nom du produit *</label>
                <input type="text" id="name" name="name" required 
                       placeholder="Ex: Écran 4K">
            </div>
            
            <div class="form-group">
                <label for="price">Prix (€) *</label>
                <input type="number" id="price" name="price" 
                       step="0.01" min="0" required 
                       placeholder="Ex: 349.99">
            </div>
            
            <div class="form-group">
                <label for="quantity">Quantité *</label>
                <input type="number" id="quantity" name="quantity" 
                       min="0" required 
                       placeholder="Ex: 8">
            </div>
            
            <div class="form-group">
                <label>Niveau de priorité *</label>
                <div class="radio-group">
                    <div class="radio-item priority-high">
                        <input type="radio" id="priority-high" name="priority" value="Haute" required>
                        <label for="priority-high">🔴 Haute priorité - Produit stratégique</label>
                    </div>
                    
                    <div class="radio-item priority-medium">
                        <input type="radio" id="priority-medium" name="priority" value="Moyenne" required>
                        <label for="priority-medium">🟠 Priorité moyenne - Produit standard</label>
                    </div>
                    
                    <div class="radio-item priority-low">
                        <input type="radio" id="priority-low" name="priority" value="Basse" required>
                        <label for="priority-low">🟢 Basse priorité - Produit secondaire</label>
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