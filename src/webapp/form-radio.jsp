<%@ include file="page-header.jsp" %>
<%
    request.setAttribute("pageTitle", "Formulaire avec Boutons Radio");
%>

<div class="card">
    <h3>🔘 Formulaire avec Boutons Radio</h3>
    <p>Testez des radio buttons pour un choix unique (priorité).</p>
    
    <form action="<%= request.getContextPath() %>/products/create-radio" method="post" id="radioForm">
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
            <label>Priorité (choisissez une seule option) *</label>
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
                <label style="display: block; margin-bottom: 8px;">
                    <input type="radio" name="priority" value="urgent"> Urgent
                </label>
            </div>
        </div>
        
        <button type="submit" class="btn" onclick="return validateForm('radioForm')">
            Créer le produit
        </button>
        <a href="<%= request.getContextPath() %>/products" class="btn btn-secondary">Retour</a>
    </form>
</div>

<%@ include file="page-footer.jsp" %>