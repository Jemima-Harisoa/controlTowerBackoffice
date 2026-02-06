<%@ include file="page-header.jsp" %>
<%
    request.setAttribute("pageTitle", "Erreur");
    String message = (String) request.getAttribute("message");
    if (message == null) message = "Une erreur est survenue.";
%>

<div class="message-box error">
    <h3>❌ Erreur</h3>
    <p><%= message %></p>
</div>

<div class="card">
    <div style="display: flex; gap: 15px; margin-top: 20px;">
        <a href="<%= request.getContextPath() %>/products" class="btn">
            🏠 Retour à l'accueil
        </a>
        <a href="<%= request.getContextPath() %>/products/list" class="btn">
            📋 Voir tous les produits
        </a>
    </div>
</div>

<%@ include file="page-footer.jsp" %>