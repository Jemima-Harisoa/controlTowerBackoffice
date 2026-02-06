<%@ include file="page-header.jsp" %>
<%
    request.setAttribute("pageTitle", "Accueil Produits");
%>

<div class="message-box info">
    <h3>Bienvenue dans le gestionnaire de produits !</h3>
    <p>Choisissez un type de formulaire pour tester différentes méthodes de saisie de données.</p>
</div>

<div class="grid">
    <div class="card">
        <h3>📝 Formulaire Simple</h3>
        <p>Inputs texte de base avec types différents (text, number).</p>
        <p><strong>Champs testés :</strong> nom, prix (nombre), quantité</p>
        <a href="<%= request.getContextPath() %>/products/form-simple" class="btn">Tester ce formulaire</a>
    </div>
    
    <div class="card">
        <h3>📋 Formulaire avec Select</h3>
        <p>Liste déroulante pour sélectionner une catégorie.</p>
        <p><strong>Champs testés :</strong> nom, prix, quantité, catégorie (select)</p>
        <a href="<%= request.getContextPath() %>/products/form-select" class="btn">Tester ce formulaire</a>
    </div>
    
    <div class="card">
        <h3>✅ Formulaire avec Checkboxes</h3>
        <p>Cases à cocher multiples pour sélectionner des tags.</p>
        <p><strong>Champs testés :</strong> nom, prix, quantité, tags (plusieurs valeurs)</p>
        <a href="<%= request.getContextPath() %>/products/form-checkbox" class="btn">Tester ce formulaire</a>
    </div>
    
    <div class="card">
        <h3>🔘 Formulaire avec Radio Buttons</h3>
        <p>Boutons radio pour un choix unique (priorité).</p>
        <p><strong>Champs testés :</strong> nom, prix, quantité, priorité (un seul choix)</p>
        <a href="<%= request.getContextPath() %>/products/form-radio" class="btn">Tester ce formulaire</a>
    </div>
    
    <div class="card">
        <h3>📄 Formulaire avec Textarea</h3>
        <p>Zone de texte multiligne pour une description.</p>
        <p><strong>Champs testés :</strong> nom, prix, quantité, description (texte long)</p>
        <a href="<%= request.getContextPath() %>/products/form-textarea" class="btn">Tester ce formulaire</a>
    </div>
    
    <div class="card">
        <h3>🎯 Formulaire Complet</h3>
        <p>Tous les types de champs réunis en un seul formulaire.</p>
        <p><strong>Champs testés :</strong> tous les types disponibles</p>
        <a href="<%= request.getContextPath() %>/products/form-complete" class="btn">Tester ce formulaire</a>
    </div>

    <div class="card">
        <h3>🎯 Formulaire avec Instanciation d'objet</h3>
        <p>Formulaire pour tester le binding d'objet</p>
        <p><strong>Champs testés :</strong> nom, prix, quantité, description (texte long)</p>
        <a href="<%= request.getContextPath() %>/products/form-object" class="btn">Tester ce formulaire</a>
    </div>
    
    <!-- NOUVEAU : Section Upload de Fichiers -->
    <div class="card" style="border: 2px solid #6a11cb;">
        <h3>📤 Upload de Fichiers</h3>
        <p>Testez l'upload de fichiers avec le formulaire multipart/form-data.</p>
        <p><strong>Sprint 10 :</strong> Gestion des fichiers uploadés</p>
        <a href="<%= request.getContextPath() %>/files/upload-form" class="btn">Uploader des fichiers</a>
    </div>
    
</div>

<div class="card">
    <h3>📊 Voir tous les produits</h3>
    <p>Consultez la liste complète des produits créés.</p>
    <a href="<%= request.getContextPath() %>/products/list" class="btn">Afficher la liste</a>
</div>

<!-- NOUVEAU : Section Gestion des Fichiers -->
<div class="card">
    <h3>📁 Gestion des Fichiers Uploadés</h3>
    <p>Consultez la bibliothèque de tous les fichiers uploadés sur le serveur.</p>
    <a href="<%= request.getContextPath() %>/files/list" class="btn">
        📋 Voir tous les fichiers uploadés
    </a>
</div>

<%@ include file="page-footer.jsp" %>