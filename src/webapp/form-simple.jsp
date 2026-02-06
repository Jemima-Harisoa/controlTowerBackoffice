<%@ include file="page-header.jsp" %>
<%
    request.setAttribute("pageTitle", "Formulaire Simple");
%>

<div class="card">
    <h3>📝 Formulaire Simple</h3>
    <p>Testez des inputs texte simples avec différents types.</p>
    
    <form action="<%= request.getContextPath() %>/products/create-simple" method="post" id="simpleForm">
        <div class="form-group">
            <label for="name">Nom du produit *</label>
            <input type="text" id="name" name="name" class="form-control" required 
                   placeholder="Ex: Ordinateur Portable">
        </div>
        
        <div class="form-group">
            <label for="price">Prix (€) *</label>
            <input type="number" id="price" name="price" class="form-control" 
                   step="0.01" min="0" required placeholder="Ex: 899.99">
        </div>
        
        <div class="form-group">
            <label for="quantity">Quantité *</label>
            <input type="number" id="quantity" name="quantity" class="form-control" 
                   min="1" required placeholder="Ex: 5">
        </div>
        
        <button type="submit" class="btn" onclick="return validateForm('simpleForm')">
            Créer le produit
        </button>
        <a href="<%= request.getContextPath() %>/products" class="btn btn-secondary">Retour</a>
    </form>
</div>

<%@ include file="page-footer.jsp" %>