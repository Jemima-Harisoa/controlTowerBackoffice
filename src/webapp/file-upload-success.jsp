<%@ page import="test.FileUploadController.UploadedFileInfo" %>
<%@ page import="java.util.List" %>
<%@ include file="page-header.jsp" %>
<%
    request.setAttribute("pageTitle", "Upload Réussi");
    
    // Récupère les informations du contrôleur
    String message = (String) request.getAttribute("message");
    List<UploadedFileInfo> uploadedFiles = 
        (List<UploadedFileInfo>) request.getAttribute("uploadedFiles");
    Integer fileCount = (Integer) request.getAttribute("fileCount");
    
    if (message == null) message = "Fichiers uploadés avec succès !";
    if (uploadedFiles == null) uploadedFiles = new java.util.ArrayList<>();
    if (fileCount == null) fileCount = uploadedFiles.size();
%>

<!-- Message de succès -->
<div class="message-box success">
    <h3>✅ Succès !</h3>
    <p><%= message %></p>
    <p><strong><%= fileCount %></strong> fichier(s) uploadé(s)</p>
</div>

<!-- Détails des fichiers uploadés -->
<div class="card">
    <h3>📋 Détails des Fichiers Uploadés</h3>
    
    <% if (uploadedFiles.isEmpty()) { %>
        <p>Aucun fichier n'a été uploadé.</p>
    <% } else { %>
        <table>
            <thead>
                <tr>
                    <th>#</th>
                    <th>Nom Original</th>
                    <th>Nom sur le Serveur</th>
                    <th>Type MIME</th>
                    <th>Taille</th>
                    <th>Statut</th>
                </tr>
            </thead>
            <tbody>
                <% 
                    int index = 1;
                    for (UploadedFileInfo file : uploadedFiles) { 
                %>
                <tr>
                    <td><%= index++ %></td>
                    <td>
                        <strong><%= file.getOriginalName() %></strong>
                    </td>
                    <td>
                        <code style="background: #f5f5f5; padding: 3px 8px; border-radius: 3px;">
                            <%= file.getUniqueName() %>
                        </code>
                    </td>
                    <td>
                        <span class="badge">
                            <%= file.getContentType() != null ? file.getContentType() : "Inconnu" %>
                        </span>
                    </td>
                    <td><%= file.getFormattedSize() %></td>
                    <td>
                        <span class="badge badge-success">✓ Sauvegardé</span>
                    </td>
                </tr>
                <% } %>
            </tbody>
        </table>
        
        <!-- Informations supplémentaires -->
        <div style="margin-top: 25px; padding: 15px; background: #f8f9fa; border-radius: 8px;">
            <h4>📊 Résumé de l'Upload</h4>
            <%
                // Calcule la taille totale
                long totalSize = 0;
                for (UploadedFileInfo file : uploadedFiles) {
                    totalSize += file.getSize();
                }
                
                // Formate la taille totale
                String formattedTotalSize;
                if (totalSize < 1024) {
                    formattedTotalSize = totalSize + " B";
                } else if (totalSize < 1024 * 1024) {
                    formattedTotalSize = String.format("%.2f KB", totalSize / 1024.0);
                } else {
                    formattedTotalSize = String.format("%.2f MB", totalSize / (1024.0 * 1024.0));
                }
            %>
            <p><strong>Nombre total de fichiers :</strong> <%= fileCount %></p>
            <p><strong>Taille totale :</strong> <%= formattedTotalSize %></p>
            <p><strong>Répertoire de stockage :</strong> <code>/uploads/</code></p>
        </div>
        
        <!-- Affichage des aperçus pour les images -->
        <div style="margin-top: 25px;">
            <h4>🖼️ Aperçus des Images</h4>
            <div style="display: flex; flex-wrap: wrap; gap: 15px; margin-top: 15px;">
                <% 
                    for (UploadedFileInfo file : uploadedFiles) {
                        // Vérifie si c'est une image
                        String contentType = file.getContentType();
                        if (contentType != null && contentType.startsWith("image/")) {
                %>
                <div style="border: 1px solid #ddd; border-radius: 8px; padding: 10px; 
                            background: white; text-align: center; max-width: 200px;">
                    <div style="width: 180px; height: 180px; display: flex; align-items: center; 
                                justify-content: center; background: #f5f5f5; border-radius: 5px; 
                                overflow: hidden; margin-bottom: 10px;">
                        <!-- Note: En production, il faudrait une servlet pour servir les images -->
                        <div style="color: #999; font-size: 48px;">🖼️</div>
                    </div>
                    <p style="margin: 5px 0; font-size: 12px; word-break: break-all;">
                        <%= file.getOriginalName() %>
                    </p>
                    <p style="margin: 0; font-size: 11px; color: #666;">
                        <%= file.getFormattedSize() %>
                    </p>
                </div>
                <% 
                        }
                    } 
                %>
            </div>
            <% 
                // Compte les images
                long imageCount = uploadedFiles.stream()
                    .filter(f -> f.getContentType() != null && f.getContentType().startsWith("image/"))
                    .count();
                
                if (imageCount == 0) {
            %>
            <p style="color: #666; font-style: italic;">
                Aucune image uploadée dans ce lot.
            </p>
            <% } %>
        </div>
    <% } %>
</div>

<!-- Actions suivantes -->
<div class="card">
    <h3>🎯 Prochaines Actions</h3>
    <div style="display: flex; gap: 15px; margin-top: 20px; flex-wrap: wrap;">
        <a href="<%= request.getContextPath() %>/files/upload-form" class="btn">
            📤 Uploader d'autres fichiers
        </a>
        <a href="<%= request.getContextPath() %>/files/list" class="btn">
            📋 Voir tous les fichiers
        </a>
        <a href="<%= request.getContextPath() %>/products" class="btn btn-secondary">
            🏠 Retour à l'accueil
        </a>
    </div>
</div>

<!-- Explications techniques -->
<div class="card">
    <h4>🔧 Informations Techniques</h4>
    <ul style="line-height: 1.8;">
        <li>
            <strong>Nom unique :</strong> Un timestamp (horodatage) a été ajouté au nom de chaque fichier 
            pour éviter les conflits si plusieurs fichiers ont le même nom
        </li>
        <li>
            <strong>Type MIME :</strong> Le serveur détecte automatiquement le type de contenu 
            (ex: image/jpeg, application/pdf, text/plain)
        </li>
        <li>
            <strong>Stockage :</strong> Les fichiers sont stockés dans le répertoire 
            <code>uploads/</code> sur le serveur
        </li>
        <li>
            <strong>Sécurité :</strong> En production, il faudrait ajouter des validations 
            supplémentaires (taille max, types autorisés, scan antivirus, etc.)
        </li>
    </ul>
</div>

<!-- Note sur l'affichage des images -->
<div style="margin-top: 20px; padding: 15px; background: #fff3cd; border-left: 4px solid #ffc107; border-radius: 5px;">
    <p style="margin: 0;">
        <strong>📝 Note :</strong> Pour afficher réellement les images uploadées, 
        il faudrait créer une servlet dédiée qui sert les fichiers depuis le répertoire 
        <code>uploads/</code>. Pour l'instant, seules les icônes sont affichées.
    </p>
</div>

<%@ include file="page-footer.jsp" %>