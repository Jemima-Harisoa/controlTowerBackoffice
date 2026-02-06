<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Formulaire avec Textarea - Produits</title>
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
        textarea {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
            box-sizing: border-box;
            font-family: Arial, sans-serif;
        }
        textarea {
            resize: vertical;
            min-height: 120px;
        }
        input:focus,
        textarea:focus {
            outline: none;
            border-color: #4CAF50;
        }
        .char-counter {
            text-align: right;
            font-size: 12px;
            color: #666;
            margin-top: 5px;
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
        .hint {
            font-size: 12px;
            color: #666;
            margin-top: 5px;
            font-style: italic;
        }
    </style>
    <script>
        // Compteur de caractères pour la description
        function updateCharCount() {
            const textarea = document.getElementById('description');
            const counter = document.getElementById('charCount');
            const currentLength = textarea.value.length;
            const maxLength = textarea.getAttribute('maxlength');
            counter.textContent = currentLength + ' / ' + maxLength + ' caractères';
        }
    </script>
</head>
<body>
    <h1>📄 Formulaire avec Textarea</h1>
    
    <div class="form-container">
        <div class="info">
            <strong>Type testé :</strong> Textarea (zone de texte multi-lignes)<br>
            <strong>Ce formulaire teste :</strong> La saisie de texte long (description détaillée)
        </div>
        
        <form action="${pageContext.request.contextPath}/products/create-textarea" method="post">
            
            <div class="form-group">
                <label for="name">Nom du produit *</label>
                <input type="text" id="name" name="name" required 
                       placeholder="Ex: Casque Audio Premium">
            </div>
            
            <div class="form-group">
                <label for="price">Prix (€) *</label>
                <input type="number" id="price" name="price" 
                       step="0.01" min="0" required 
                       placeholder="Ex: 149.99">
            </div>
            
            <div class="form-group">
                <label for="quantity">Quantité *</label>
                <input type="number" id="quantity" name="quantity" 
                       min="0" required 
                       placeholder="Ex: 50">
            </div>
            
            <div class="form-group">
                <label for="description">Description détaillée *</label>
                <textarea 
                    id="description" 
                    name="description" 
                    required
                    maxlength="500"
                    oninput="updateCharCount()"
                    placeholder="Décrivez les caractéristiques du produit, ses avantages, ses spécifications techniques, etc.&#10;&#10;Exemple :&#10;- Réduction de bruit active&#10;- Autonomie 30h&#10;- Bluetooth 5.0&#10;- Pliable avec housse de transport"></textarea>
                <div class="hint">💡 Séparez les caractéristiques par des retours à la ligne</div>
                <div class="char-counter" id="charCount">0 / 500 caractères</div>
            </div>
            
            <button type="submit" class="btn">✅ Créer le produit</button>
        </form>
        
        <a href="${pageContext.request.contextPath}/products" class="back-link">
            ← Retour à l'accueil
        </a>
    </div>
    
    <script>
        // Initialise le compteur au chargement
        updateCharCount();
    </script>
</body>
</html>