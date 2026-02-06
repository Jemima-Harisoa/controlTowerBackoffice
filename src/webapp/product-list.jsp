<%@ include file="page-header.jsp" %>
<%
    request.setAttribute("pageTitle", "Liste des Produits");
    
    // Récupérer les données du modèle
    java.util.List<test.Product> products = (java.util.List<test.Product>) request.getAttribute("products");
    Integer totalProducts = (Integer) request.getAttribute("totalProducts");
    
    if (products == null) products = new java.util.ArrayList<>();
    if (totalProducts == null) totalProducts = products.size();
%>

<div class="card">
    <h3>📋 Liste des Produits</h3>
    <p>Total produits dans la base : <strong><%= totalProducts %></strong></p>
    
    <% if (products.isEmpty()) { %>
        <div class="message-box info" style="margin-top: 20px;">
            <p>Aucun produit n'a été créé pour le moment.</p>
            <a href="<%= request.getContextPath() %>/products" class="btn" style="margin-top: 10px;">
                Créer votre premier produit
            </a>
        </div>
    <% } else { %>
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Nom</th>
                    <th>Prix</th>
                    <th>Quantité</th>
                    <th>Catégorie</th>
                    <th>En stock</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <% 
                    int counter = 1;
                    for (test.Product product : products) { 
                %>
                <tr>
                    <td><%= counter %></td>
                    <td><strong><%= product.getName() %></strong></td>
                    <td><%= String.format("%.2f", product.getPrice()) %> €</td>
                    <td><%= product.getQuantity() %></td>
                    <td>
                        <% if (product.getCategory() != null) { %>
                            <span class="badge"><%= product.getCategory() %></span>
                        <% } else { %>
                            <span style="color: #999;">Non défini</span>
                        <% } %>
                    </td>
                    <td>
                        <% if (product.isInStock()) { %>
                            <span class="badge badge-success">✓ En stock</span>
                        <% } else { %>
                            <span class="badge badge-warning">✗ Rupture</span>
                        <% } %>
                    </td>
                    <td>
                        <button onclick="showDetails('<%= product.getName() %>', '<%= product.getPrice() %>', '<%= product.getQuantity() %>')" 
                                style="background: #6c757d; color: white; border: none; padding: 5px 10px; border-radius: 4px; cursor: pointer;">
                            Détails
                        </button>
                    </td>
                    <td>
                        <a href="<%= request.getContextPath() %>/products/<%= product.getId() %>/form-object-complex" 
                        class="btn-small" style="margin-right: 5px;">
                            ✏️ Éditer
                        </a>
                        <a href="<%= request.getContextPath() %>/products/delete/<%= product.getId() %>" 
                        class="btn-small btn-danger" 
                        onclick="return confirm('Supprimer ce produit?')">
                            🗑️ Supprimer
                        </a>
                    </td>
                </tr>
                <% 
                        counter++;
                    } 
                %>
            </tbody>
        </table>
        
        <div style="margin-top: 30px; padding: 20px; background: #f8f9fa; border-radius: 8px;">
            <h4>📊 Statistiques</h4>
            <%
                double totalValue = 0;
                int totalQuantity = 0;
                for (test.Product product : products) {
                    totalValue += product.getPrice() * product.getQuantity();
                    totalQuantity += product.getQuantity();
                }
            %>
            <p><strong>Valeur totale du stock :</strong> <%= String.format("%.2f", totalValue) %> €</p>
            <p><strong>Quantité totale :</strong> <%= totalQuantity %> unités</p>
            <p><strong>Prix moyen :</strong> 
                <% if (products.size() > 0) { 
                    double avgPrice = totalValue / totalQuantity;
                %>
                    <%= String.format("%.2f", avgPrice) %> €
                <% } else { %>
                    0 €
                <% } %>
            </p>
        </div>
    <% } %>
    
    <div style="margin-top: 30px;">
        <a href="<%= request.getContextPath() %>/products" class="btn">
            ← Retour à l'accueil
        </a>
        <a href="<%= request.getContextPath() %>/products/form-complete" class="btn">
            ＋ Ajouter un produit
        </a>
    </div>
</div>

<script>
    function showDetails(name, price, quantity) {
        alert("Détails du produit :\n\n" +
              "Nom : " + name + "\n" +
              "Prix : " + price + " €\n" +
              "Quantité : " + quantity);
    }
</script>

<%@ include file="page-footer.jsp" %>