<%@ page import="test.FileUploadController.UploadedFileInfo" %>
<%@ page import="java.util.List" %>
<%@ include file="page-header.jsp" %>
<%
    request.setAttribute("pageTitle", "Upload de Fichiers");
    
    // Récupère la liste des fichiers déjà uploadés
    List<UploadedFileInfo> uploadedFiles = 
        (List<UploadedFileInfo>) request.getAttribute("uploadedFiles");
    Integer totalFiles = (Integer) request.getAttribute("totalFiles");
    
    if (uploadedFiles == null) uploadedFiles = new java.util.ArrayList<>();
    if (totalFiles == null) totalFiles = 0;
%>

<div class="card">
    <h3>📤 Upload de Fichiers</h3>
    <p>Sélectionnez un ou plusieurs fichiers à uploader sur le serveur.</p>
    
    <!-- 
        IMPORTANT : 
        - enctype="multipart/form-data" est OBLIGATOIRE pour l'upload de fichiers
        - method="post" est requis (GET ne supporte pas l'upload de fichiers)
    -->
    <form action="<%= request.getContextPath() %>/files/upload" 
          method="post" 
          enctype="multipart/form-data" 
          id="uploadForm">
        
        <div class="form-group">
            <label for="file">Choisir un fichier *</label>
            <input type="file" 
                   id="file" 
                   name="file" 
                   class="form-control" 
                   required
                   accept="image/*,.pdf,.doc,.docx,.txt">
            <small style="color: #666;">
                Types acceptés : images, PDF, documents Word, fichiers texte
            </small>
        </div>
        
        <div class="form-group">
            <label for="multipleFiles">Ou choisir plusieurs fichiers</label>
            <input type="file" 
                   id="multipleFiles" 
                   name="multipleFiles" 
                   class="form-control" 
                   multiple
                   accept="image/*,.pdf,.doc,.docx,.txt">
            <small style="color: #666;">
                Maintenez Ctrl (ou Cmd sur Mac) pour sélectionner plusieurs fichiers
            </small>
        </div>
        
        <div class="form-group">
            <label for="description">Description (optionnel)</label>
            <textarea id="description" 
                      name="description" 
                      class="form-control" 
                      rows="3"
                      placeholder="Ajoutez une description pour vos fichiers..."></textarea>
        </div>
        
        <div style="margin-top: 20px;">
            <button type="submit" class="btn" id="uploadBtn">
                📤 Uploader les fichiers
            </button>
            <a href="<%= request.getContextPath() %>/files/list" class="btn btn-secondary">
                📋 Voir tous les fichiers
            </a>
            <a href="<%= request.getContextPath() %>/products" class="btn btn-secondary">
                🏠 Retour à l'accueil
            </a>
        </div>
    </form>
    
    <!-- Indicateur de progression (optionnel mais recommandé) -->
    <div id="progressContainer" style="display: none; margin-top: 20px;">
        <p><strong>Upload en cours...</strong></p>
        <div style="width: 100%; background-color: #f0f0f0; border-radius: 5px; overflow: hidden;">
            <div id="progressBar" style="width: 0%; height: 30px; background-color: #4CAF50; 
                 text-align: center; line-height: 30px; color: white; transition: width 0.3s;">
                0%
            </div>
        </div>
    </div>
</div>

<!-- Section des fichiers récemment uploadés -->
<% if (totalFiles > 0) { %>
<div class="card">
    <h3>📁 Fichiers Récemment Uploadés</h3>
    <p>Total : <strong><%= totalFiles %></strong> fichier(s)</p>
    
    <table>
        <thead>
            <tr>
                <th>Nom Original</th>
                <th>Type</th>
                <th>Taille</th>
                <th>Date</th>
            </tr>
        </thead>
        <tbody>
            <% 
                // Affiche les 5 derniers fichiers uploadés
                int displayCount = Math.min(5, uploadedFiles.size());
                for (int i = uploadedFiles.size() - 1; i >= uploadedFiles.size() - displayCount; i--) {
                    UploadedFileInfo file = uploadedFiles.get(i);
            %>
            <tr>
                <td><strong><%= file.getOriginalName() %></strong></td>
                <td>
                    <span class="badge">
                        <%= file.getContentType() != null ? file.getContentType() : "Inconnu" %>
                    </span>
                </td>
                <td><%= file.getFormattedSize() %></td>
                <td>À l'instant</td>
            </tr>
            <% } %>
        </tbody>
    </table>
    
    <div style="margin-top: 15px;">
        <a href="<%= request.getContextPath() %>/files/list" class="btn">
            Voir tous les fichiers (<%=totalFiles%>)
        </a>
    </div>
</div>
<% } %>

<!-- Note explicative sur le fonctionnement -->
<div class="card">
    <h4>ℹ️ Comment ça marche ?</h4>
    <ul style="line-height: 1.8;">
        <li><strong>enctype="multipart/form-data"</strong> : Attribut obligatoire qui permet au formulaire d'envoyer des fichiers binaires</li>
        <li><strong>Part</strong> : Chaque fichier uploadé est traité comme une "partie" (Part) de la requête HTTP</li>
        <li><strong>Stockage</strong> : Les fichiers sont sauvegardés dans le répertoire <code>uploads/</code> du serveur</li>
        <li><strong>Nom unique</strong> : Un timestamp est ajouté au nom pour éviter les conflits</li>
        <li><strong>Multiple</strong> : L'attribut "multiple" permet de sélectionner plusieurs fichiers à la fois</li>
    </ul>
</div>

<script>
    // Gestion de l'affichage de la progression lors de l'upload
    document.getElementById('uploadForm').addEventListener('submit', function(e) {
        var fileInput = document.getElementById('file');
        var multipleInput = document.getElementById('multipleFiles');
        
        // Vérifie qu'au moins un fichier est sélectionné
        if (!fileInput.files.length && !multipleInput.files.length) {
            alert('Veuillez sélectionner au moins un fichier');
            e.preventDefault();
            return false;
        }
        
        // Affiche la barre de progression
        document.getElementById('progressContainer').style.display = 'block';
        document.getElementById('uploadBtn').disabled = true;
        document.getElementById('uploadBtn').textContent = '⏳ Upload en cours...';
        
        // Simule la progression (dans une vraie application, utilisez XMLHttpRequest)
        var progress = 0;
        var interval = setInterval(function() {
            progress += 10;
            document.getElementById('progressBar').style.width = progress + '%';
            document.getElementById('progressBar').textContent = progress + '%';
            
            if (progress >= 90) {
                clearInterval(interval);
            }
        }, 200);
    });
    
    // Affiche le nom des fichiers sélectionnés
    function displaySelectedFiles(inputId) {
        var input = document.getElementById(inputId);
        input.addEventListener('change', function() {
            if (this.files.length > 0) {
                var fileNames = Array.from(this.files).map(f => f.name).join(', ');
                console.log('Fichiers sélectionnés : ' + fileNames);
            }
        });
    }
    
    displaySelectedFiles('file');
    displaySelectedFiles('multipleFiles');
</script>

<%@ include file="page-footer.jsp" %>