<%@ include file="page-header.jsp" %>
<%
    request.setAttribute("pageTitle", "Formulaire avec Liste Déroulante");
%>

<div class="card">
    <h3>📋 Formulaire avec Liste Déroulante</h3>
    <p>Testez un select (liste déroulante) pour choisir une catégorie.</p>
    
    <form action="<%= request.getContextPath() %>/products/create-select" method="post" id="selectForm">
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
        
        <button type="submit" class="btn" onclick="return validateForm('selectForm')">
            Créer le produit
        </button>
        <a href="<%= request.getContextPath() %>/products" class="btn btn-secondary">Retour</a>
    </form>
</div>

<%@ include file="page-footer.jsp" %>