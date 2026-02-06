<%@ include file="page-header.jsp" %>
<%
    request.setAttribute("pageTitle", "Formulaire avec Zone de Texte");
%>

<div class="card">
    <h3>📄 Formulaire avec Zone de Texte Multiligne</h3>
    <p>Testez un textarea pour saisir une description longue.</p>
    
    <form action="<%= request.getContextPath() %>/products/create-textarea" method="post" id="textareaForm">
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
            <label for="description">Description du produit</label>
            <textarea id="description" name="description" class="form-control" 
                     rows="5" placeholder="Décrivez le produit en détail..."></textarea>
            <small style="color: #666;">Vous pouvez utiliser jusqu'à 1000 caractères</small>
        </div>
        
        <button type="submit" class="btn" onclick="return validateForm('textareaForm')">
            Créer le produit
        </button>
        <a href="<%= request.getContextPath() %>/products" class="btn btn-secondary">Retour</a>
    </form>
</div>

<%@ include file="page-footer.jsp" %>