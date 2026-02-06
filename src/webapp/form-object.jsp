<%@ include file="page-header.jsp" %>
<%
    request.setAttribute("pageTitle", "Formulaire avec Objet Complexe");
%>

<div class="card">
    <h3>🎯 Formulaire avec Objet Complexe</h3>
    <p>Testez la création d'un objet Product directement.</p>
    
    <form action="<%= request.getContextPath() %>/products/create-from-object" method="post">
        <div class="form-group">
            <label for="name">Nom du produit *</label>
            <input type="text" id="name" name="name" class="form-control" required>
        </div>
        
        <div class="form-group">
            <label for="price">Prix (€) *</label>
            <input type="number" id="price" name="price" class="form-control" 
                   step="0.01" min="0" required>
        </div>
        
        <div class="form-group">
            <label for="quantity">Quantité *</label>
            <input type="number" id="quantity" name="quantity" class="form-control" 
                   min="1" required>
        </div>
        
        <div class="form-group">
            <label for="category">Catégorie</label>
            <select id="category" name="category" class="form-control" required>
                <option value="">-- Sélectionnez une catégorie --</option>
                <option value="electronique">Électronique</option>
                <option value="informatique">Informatique</option>
                <option value="mobilier">Mobilier</option>
                <option value="vetements">Vêtements</option>
                <option value="alimentaire">Alimentaire</option>
                <option value="sport">Sport</option>
                <option value="livres">Livres</option>
                <option value="autre">Autre</option>
            </select>
          </div>
        
        <div class="form-group">
            <label for="description">Description</label>
            <textarea id="description" name="description" class="form-control" rows="4"></textarea>
        </div>
        
        <div class="form-group">
            <label>
                <input type="checkbox" name="inStock" value="true" checked> En stock
            </label>
        </div>
        
        <button type="submit" class="btn">
            Créer le produit (via objet)
        </button>
        <a href="<%= request.getContextPath() %>/products" class="btn btn-secondary">Retour</a>
    </form>
    
    <div style="margin-top: 20px; padding: 15px; background: #f5f5f5; border-radius: 5px;">
        <h4>Note :</h4>
        <p>Le formulaire utilise les noms de champs correspondant aux attributs de la classe Product.</p>
        <p>Le binding d'objet complexe va automatiquement créer une instance de Product et remplir ses champs.</p>
    </div>
</div>

<%@ include file="page-footer.jsp" %>