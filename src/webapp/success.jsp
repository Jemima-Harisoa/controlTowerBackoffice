<%@ include file="page-header.jsp" %>
<%
    request.setAttribute("pageTitle", "Succès !");
    
    // Récupérer les données du modèle
    String message = (String) request.getAttribute("message");
    Object productObj = request.getAttribute("product");
    String formType = (String) request.getAttribute("formType");
    
    if (message == null) message = "Action effectuée avec succès !";
    if (formType == null) formType = "inconnu";
%>

<div class="message-box success">
    <h3>✅ Succès !</h3>
    <p><%= message %></p>
    <span class="form-type-indicator">Type de formulaire : <%= formType %></span>
</div>

<% if (productObj != null) { 
    // Dans un vrai projet, vous auriez une classe Product
    // Ici, on affiche les propriétés de base
%>
<div class="card">
    <h3>📋 Détails du produit créé</h3>
    <div style="padding: 15px; background: #f8f9fa; border-radius: 6px;">
        <%
            // Utiliser la réflexion pour afficher les propriétés
            try {
                Class<?> productClass = productObj.getClass();
                java.lang.reflect.Field[] fields = productClass.getDeclaredFields();
                
                for (java.lang.reflect.Field field : fields) {
                    field.setAccessible(true);
                    Object value = field.get(productObj);
                    if (value != null) {
                        out.println("<p><strong>" + field.getName() + ":</strong> " + value.toString() + "</p>");
                    }
                }
            } catch (Exception e) {
                out.println("<p>Produit: " + productObj.toString() + "</p>");
            }
        %>
    </div>
</div>
<% } %>

<div class="card">
    <h3>📊 Prochaines actions</h3>
    <div style="display: flex; gap: 15px; margin-top: 20px;">
        <a href="<%= request.getContextPath() %>/products/list" class="btn">
            📋 Voir tous les produits
        </a>
        <a href="<%= request.getContextPath() %>/products" class="btn">
            🏠 Retour à l'accueil
        </a>
        <a href="<%= request.getContextPath() %>/products/form-<%= formType %>" class="btn">
            🔄 Nouveau formulaire
        </a>
    </div>
</div>

<%@ include file="page-footer.jsp" %>