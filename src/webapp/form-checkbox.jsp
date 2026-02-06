<%@ include file="page-header.jsp" %>
<%
    request.setAttribute("pageTitle", "Formulaire avec Cases à Cocher");
%>

<div class="card">
    <h3>✅ Formulaire avec Cases à Cocher</h3>
    <p>Testez des checkboxes pour sélectionner plusieurs tags.</p>
    
    <form action="<%= request.getContextPath() %>/products/create-checkbox" method="post" id="checkboxForm">
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
            <label>Tags (sélectionnez un ou plusieurs) *</label>
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
                <label style="display: block; margin-bottom: 8px;">
                    <input type="checkbox" name="tags" value="limite"> Édition limitée
                </label>
                <label style="display: block; margin-bottom: 8px;">
                    <input type="checkbox" name="tags" value="ecologique"> Écologique
                </label>
                <label style="display: block; margin-bottom: 8px;">
                    <input type="checkbox" name="tags" value="premium"> Premium
                </label>
            </div>
        </div>
        
        <button type="submit" class="btn" onclick="return validateForm('checkboxForm')">
            Créer le produit
        </button>
        <a href="<%= request.getContextPath() %>/products" class="btn btn-secondary">Retour</a>
    </form>
</div>

<%@ include file="page-footer.jsp" %>