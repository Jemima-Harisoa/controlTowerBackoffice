<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Formulaire Complet - Produits</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 700px;
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
        .form-section {
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 2px solid #f0f0f0;
        }
        .form-section:last-of-type {
            border-bottom: none;
        }
        .section-title {
            font-size: 18px;
            color: #4CAF50;
            margin-bottom: 15px;
            font-weight: bold;
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
        select,
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
            min-height: 100px;
        }
        input:focus,
        select:focus,
        textarea:focus {
            outline: none;
            border-color: #4CAF50;
        }
        .checkbox-group,
        .radio-group {
            border: 1px solid #ddd;
            padding: 15px;
            border-radius: 4px;
            background: #fafafa;
        }
        .checkbox-item,
        .radio-item {
            margin-bottom: 10px;
        }
        .checkbox-item label,
        .radio-item label {
            font-weight: normal;
            display: inline;
            margin-left: 8px;
            cursor: pointer;
        }
        input[type="checkbox"],
        input[type="radio"] {
            cursor: pointer;
            width: 18px;
            height: 18px;
            vertical-align: middle;
        }
        .single-checkbox {
            padding: 12px;
            background: #fff3cd;
            border: 1px solid #ffc107;
            border-radius: 4px;
            margin-top: 10px;
        }
        .single-checkbox label {
            font-weight: normal;
            display: inline;
            margin-left: 8px;
            cursor: pointer;
        }
        .btn {
            background: #4CAF50;
            color: white;
            padding: 15px 40px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 18px;
            transition: background 0.3s;
            width: 100%;
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
        .char-counter {
            text-align: right;
            font-size: 12px;
            color: #666;
            margin-top: 5px;
        }
    </style>
    <script>
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
    <h1>🎯 Formulaire Complet</h1>
    
    <div class="form-container">
        <div class="info">
            <strong>Types testés :</strong> Tous les types combinés<br>
            <strong>Ce formulaire teste :</strong> Input text/number, Select, Checkboxes, Radio buttons, Textarea, Checkbox unique
        </div>
        
        <form action="${pageContext.request.contextPath}/products/create-complete" method="post">
            
            <!-- Section 1 : Informations de base -->
            <div class="form-section">
                <div class="section-title">📝 Informations de base</div>
                
                <div class="form-group">
                    <label for="name">Nom du produit *</label>
                    <input type="text" id="name" name="name" required 
                           placeholder="Ex: MacBook Pro 16 pouces">
                </div>
                
                <div class="form-group">
                    <label for="price">Prix (€) *</label>
                    <input type="number" id="price" name="price" 
                           step="0.01" min="0" required 
                           placeholder="Ex: 2499.99">
                </div>
                
                <div class="form-group">
                    <label for="quantity">Quantité en stock *</label>
                    <input type="number" id="quantity" name="quantity" 
                           min="0" required 
                           placeholder="Ex: 5">
                </div>
            </div>
            
            <!-- Section 2 : Catégorie (Select) -->
            <div class="form-section">
                <div class="section-title">📋 Catégorie</div>
                
                <div class="form-group">
                    <label for="category">Catégorie du produit *</label>
                    <select id="category" name="category" required>
                        <option value="">-- Sélectionnez une catégorie --</option>
                        <option value="Électronique">Électronique</option>
                        <option value="Informatique">Informatique</option>
                        <option value="Mobilier">Mobilier</option>
                        <option value="Vêtements">Vêtements</option>
                        <option value="Alimentation">Alimentation</option>
                        <option value="Sport">Sport</option>
                        <option value="Jouets">Jouets</option>
                        <option value="Livres">Livres</option>
                    </select>
                </div>
            </div>
            
            <!-- Section 3 : Priorité (Radio buttons) -->
            <div class="form-section">
                <div class="section-title">🔘 Niveau de priorité</div>
                
                <div class="form-group">
                    <label>Priorité commerciale *</label>
                    <div class="radio-group">
                        <div class="radio-item">
                            <input type="radio" id="priority-high" name="priority" value="Haute" required>
                            <label for="priority-high">🔴 Haute - Produit phare</label>
                        </div>
                        
                        <div class="radio-item">
                            <input type="radio" id="priority-medium" name="priority" value="Moyenne" required>
                            <label for="priority-medium">🟠 Moyenne - Produit standard</label>
                        </div>
                        
                        <div class="radio-item">
                            <input type="radio" id="priority-low" name="priority" value="Basse" required>
                            <label for="priority-low">🟢 Basse - Produit secondaire</label>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Section 4 : Tags (Checkboxes multiples) -->
            <div class="form-section">
                <div class="section-title">☑️ Étiquettes marketing</div>
                
                <div class="form-group">
                    <label>Sélectionnez les tags applicables</label>
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
                    </div>
                </div>
            </div>
            
            <!-- Section 5 : Description (Textarea) -->
            <div class="form-section">
                <div class="section-title">📄 Description</div>
                
                <div class="form-group">
                    <label for="description">Description détaillée *</label>
                    <textarea 
                        id="description" 
                        name="description" 
                        required
                        maxlength="500"
                        oninput="updateCharCount()"
                        placeholder="Décrivez les caractéristiques, avantages et spécifications du produit..."></textarea>
                    <div class="char-counter" id="charCount">0 / 500 caractères</div>
                </div>
            </div>
            
            <!-- Section 6 : Disponibilité (Checkbox unique) -->
            <div class="form-section">
                <div class="section-title">✅ Disponibilité</div>
                
                <div class="single-checkbox">
                    <input type="checkbox" id="inStock" name="inStock" value="true" checked>
                    <label for="inStock">📦 Produit disponible en stock immédiatement</label>
                </div>
            </div>
            
            <button type="submit" class="btn">✅ Créer le produit complet</button>
        </form>
        
        <a href="${pageContext.request.contextPath}/products" class="back-link">
            ← Retour à l'accueil
        </a>
    </div>
    
    <script>
        updateCharCount();
    </script>
</body>
</html>