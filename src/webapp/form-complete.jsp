<%@ include file="page-header.jsp" %>
<%
    request.setAttribute("pageTitle", "Formulaire Complet");
%>

<div class="card">
    <h3>🎯 Formulaire Complet</h3>
    <p>Testez tous les types de champs en un seul formulaire.</p>
    
    <form action="<%= request.getContextPath() %>/products/create-complete" method="post" id="completeForm">
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
            <label for="category">Catégorie *</label>
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
            <label>Tags</label>
            <div style="margin-top: 10px;">
                <label style="display: block; margin-bottom: 8px;">
                    <input type="checkbox" name="tags" value="nouveau"> Nouveau
                </label>
                <label style="display: block; margin-bottom: 8px;">
                    <input type="checkbox" name="tags" value="promotion"> Promotion
                </label>
                <label style="display: block; margin-bottom: 8px;">
                    <input type="checkbox" name="tags" value="populaire"> Populaire
                </label>
            </div>
        </div>
        
        <div class="form-group">
            <label>Priorité *</label>
            <div style="margin-top: 10px;">
                <label style="display: block; margin-bottom: 8px;">
                    <input type="radio" name="priority" value="basse" required> Basse
                </label>
                <label style="display: block; margin-bottom: 8px;">
                    <input type="radio" name="priority" value="moyenne"> Moyenne
                </label>
                <label style="display: block; margin-bottom: 8px;">
                    <input type="radio" name="priority" value="haute"> Haute
                </label>
            </div>
        </div>
        
        <div class="form-group">
            <label for="description">Description</label>
            <textarea id="description" name="description" class="form-control" 
                     rows="4" placeholder="Description du produit..."></textarea>
        </div>
        
        <div class="form-group">
            <label style="display: flex; align-items: center;">
                <input type="checkbox" name="inStock" value="true" style="margin-right: 10px;">
                Produit en stock
            </label>
        </div>
        
        <button type="submit" class="btn" onclick="return validateForm('completeForm')">
            Créer le produit complet
        </button>
        <a href="<%= request.getContextPath() %>/products" class="btn btn-secondary">Retour</a>
    </form>
</div>

<%@ include file="page-footer.jsp" %>