<%@ include file="page-header.jsp" %>
<%
    request.setAttribute("pageTitle", "Formulaire Complexe avec Édition");
    
    // Récupérer le produit depuis la requête
    test.Product product = (test.Product) request.getAttribute("product");
    String action = (String) request.getAttribute("action");
    boolean isUpdate = "update".equals(action);
    
    if (product == null) {
        product = new test.Product();
        isUpdate = false;
    }
%>

<div class="card">
    <h3><%= isUpdate ? "✏️ Édition de Produit" : "🎯 Formulaire Complexe avec Objet" %></h3>
    <p><%= isUpdate ? "Modifiez le produit existant." : "Testez la création/édition d'un objet Product avec mix de paramètres." %></p>
    
    <form action="<%= request.getContextPath() %>/products/create-with-mixed/<%= isUpdate ? product.getId() : "0" %>" method="post">
        <input type="hidden" name="action" value="<%= isUpdate ? "update" : "create" %>">
        
        <% if (isUpdate) { %>
        <div class="form-group">
            <label>ID du produit</label>
            <input type="text" class="form-control" value="<%= product.getId() %>" disabled>
            <small>ID: <%= product.getId() %> (non modifiable)</small>
        </div>
        <% } %>
        
        <div class="form-group">
            <label for="Product.name">Nom du produit *</label>
            <input type="text" id="Product.name" name="Product.name" class="form-control" 
                   value="<%= product.getName() != null ? product.getName() : "" %>" required>
        </div>
        
        <div class="form-group">
            <label for="Product.price">Prix (€) *</label>
            <input type="number" id="Product.price" name="Product.price" class="form-control" 
                   step="0.01" min="0" value="<%= product.getPrice() %>" required>
        </div>
        
        <div class="form-group">
            <label for="Product.quantity">Quantité *</label>
            <input type="number" id="Product.quantity" name="Product.quantity" class="form-control" 
                   min="1" value="<%= product.getQuantity() %>" required>
        </div>
        
        <div class="form-group">
            <label for="Product.category">Catégorie</label>
            <select id="Product.category" name="Product.category" class="form-control">
                <option value="">-- Sélectionnez une catégorie --</option>
                <option value="electronique" <%= "electronique".equals(product.getCategory()) ? "selected" : "" %>>Électronique</option>
                <option value="informatique" <%= "informatique".equals(product.getCategory()) ? "selected" : "" %>>Informatique</option>
                <option value="mobilier" <%= "mobilier".equals(product.getCategory()) ? "selected" : "" %>>Mobilier</option>
                <option value="vetements" <%= "vetements".equals(product.getCategory()) ? "selected" : "" %>>Vêtements</option>
                <option value="alimentaire" <%= "alimentaire".equals(product.getCategory()) ? "selected" : "" %>>Alimentaire</option>
                <option value="sport" <%= "sport".equals(product.getCategory()) ? "selected" : "" %>>Sport</option>
                <option value="livres" <%= "livres".equals(product.getCategory()) ? "selected" : "" %>>Livres</option>
                <option value="autre" <%= "autre".equals(product.getCategory()) ? "selected" : "" %>>Autre</option>
            </select>
        </div>
        
        <div class="form-group">
            <label>Disponibilité</label>
            <div style="margin-top: 10px;">
                <label style="display: block; margin-bottom: 8px;">
                    <input type="checkbox" name="inStock" value="true" <%= product.isInStock() ? "checked" : "" %>>
                    Produit en stock
                </label>
            </div>
        </div>
        
        <div class="form-group">
            <label for="Product.description">Description</label>
            <textarea id="Product.description" name="Product.description" class="form-control" rows="4"><%= product.getDescription() != null ? product.getDescription() : "" %></textarea>
        </div>
        
        <button type="submit" class="btn">
            <%= isUpdate ? "Mettre à jour le produit" : "Créer le produit" %>
        </button>
        
        <% if (isUpdate) { %>
        <a href="<%= request.getContextPath() %>/products/delete/<%= product.getId() %>" 
           class="btn btn-danger" 
           onclick="return confirm('Êtes-vous sûr de vouloir supprimer ce produit?')">
            Supprimer
        </a>
        <% } %>
        
        <a href="<%= request.getContextPath() %>/products" class="btn btn-secondary">Retour</a>
    </form>
    
    <div style="margin-top: 20px; padding: 15px; background: #f5f5f5; border-radius: 5px;">
        <h4>Note :</h4>
        <p>Ce formulaire utilise un mix de paramètres :</p>
        <ul>
            <li><strong>Path Variable</strong>: ID du produit dans l'URL</li>
            <li><strong>Request Param</strong>: Action (create/update) et checkbox inStock</li>
            <li><strong>Objet Complexe</strong>: Product avec notation pointée (Product.nomChamp)</li>
        </ul>
    </div>
</div>

<%@ include file="page-footer.jsp" %>