<%@ page import="test.FileUploadController.UploadedFileInfo" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ include file="page-header.jsp" %>
<%
    request.setAttribute("pageTitle", "Liste des Fichiers Uploadés");
    
    // Récupère les données du contrôleur
    List<UploadedFileInfo> uploadedFiles = 
        (List<UploadedFileInfo>) request.getAttribute("uploadedFiles");
    Integer totalFiles = (Integer) request.getAttribute("totalFiles");
    Long totalSize = (Long) request.getAttribute("totalSize");
    
    if (uploadedFiles == null) uploadedFiles = new java.util.ArrayList<>();
    if (totalFiles == null) totalFiles = 0;
    if (totalSize == null) totalSize = 0L;
    
    // Calcule des statistiques par type de fichier
    Map<String, Integer> fileTypeCount = new HashMap<>();
    Map<String, Long> fileTypeSize = new HashMap<>();
    
    for (UploadedFileInfo file : uploadedFiles) {
        String type = file.getContentType();
        if (type == null) type = "Inconnu";
        
        // Compte les fichiers par type
        fileTypeCount.put(type, fileTypeCount.getOrDefault(type, 0) + 1);
        
        // Somme les tailles par type
        fileTypeSize.put(type, fileTypeSize.getOrDefault(type, 0L) + file.getSize());
    }
%>

<!-- En-tête avec statistiques -->
<div class="message-box info">
    <h3>📁 Bibliothèque de Fichiers</h3>
    <p>Consultez et gérez tous les fichiers uploadés sur le serveur.</p>
    <div style="display: flex; gap: 30px; margin-top: 15px; flex-wrap: wrap;">
        <div>
            <strong style="font-size: 24px; color: #2575fc;"><%= totalFiles %></strong>
            <br>
            <span style="font-size: 14px;">Fichiers</span>
        </div>
        <div>
            <strong style="font-size: 24px; color: #2575fc;">
                <% 
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
                <%= formattedTotalSize %>
            </strong>
            <br>
            <span style="font-size: 14px;">Taille Totale</span>
        </div>
        <div>
            <strong style="font-size: 24px; color: #2575fc;"><%= fileTypeCount.size() %></strong>
            <br>
            <span style="font-size: 14px;">Types Différents</span>
        </div>
    </div>
</div>

<!-- Statistiques par type de fichier -->
<% if (!fileTypeCount.isEmpty()) { %>
<div class="card">
    <h3>📊 Statistiques par Type de Fichier</h3>
    <table>
        <thead>
            <tr>
                <th>Type MIME</th>
                <th>Nombre de Fichiers</th>
                <th>Taille Totale</th>
                <th>Pourcentage</th>
            </tr>
        </thead>
        <tbody>
            <% 
                for (Map.Entry<String, Integer> entry : fileTypeCount.entrySet()) {
                    String type = entry.getKey();
                    int count = entry.getValue();
                    long size = fileTypeSize.get(type);
                    double percentage = (totalFiles > 0) ? (count * 100.0 / totalFiles) : 0;
                    
                    // Formate la taille
                    String formattedSize;
                    if (size < 1024) {
                        formattedSize = size + " B";
                    } else if (size < 1024 * 1024) {
                        formattedSize = String.format("%.2f KB", size / 1024.0);
                    } else {
                        formattedSize = String.format("%.2f MB", size / (1024.0 * 1024.0));
                    }
            %>
            <tr>
                <td>
                    <span class="badge">
                        <%= type %>
                    </span>
                </td>
                <td><strong><%= count %></strong> fichier(s)</td>
                <td><%= formattedSize %></td>
                <td>
                    <div style="display: flex; align-items: center; gap: 10px;">
                        <div style="flex: 1; height: 20px; background: #f0f0f0; border-radius: 10px; overflow: hidden;">
                            <div style="width: <%= percentage %>%; height: 100%; background: linear-gradient(135deg, #6a11cb 0%, #2575fc 100%);"></div>
                        </div>
                        <span style="min-width: 50px;"><%= String.format("%.1f%%", percentage) %></span>
                    </div>
                </td>
            </tr>
            <% } %>
        </tbody>
    </table>
</div>
<% } %>

<!-- Liste complète des fichiers -->
<div class="card">
    <h3>📋 Liste Complète des Fichiers</h3>
    
    <% if (uploadedFiles.isEmpty()) { %>
        <div style="text-align: center; padding: 40px 20px;">
            <div style="font-size: 64px; margin-bottom: 20px;">📂</div>
            <p style="font-size: 18px; color: #666;">Aucun fichier n'a encore été uploadé</p>
            <a href="<%= request.getContextPath() %>/files/upload-form" class="btn" style="margin-top: 20px;">
                📤 Uploader votre premier fichier
            </a>
        </div>
    <% } else { %>
        <!-- Filtres (optionnel pour une future amélioration) -->
        <div style="margin-bottom: 20px; padding: 15px; background: #f8f9fa; border-radius: 8px;">
            <div style="display: flex; gap: 15px; align-items: center; flex-wrap: wrap;">
                <strong>Filtres :</strong>
                <select id="filterType" class="form-control" style="width: auto; padding: 8px 15px;">
                    <option value="">Tous les types</option>
                    <% for (String type : fileTypeCount.keySet()) { %>
                        <option value="<%= type %>"><%= type %></option>
                    <% } %>
                </select>
                <input type="text" id="searchInput" class="form-control" 
                       placeholder="Rechercher un fichier..." 
                       style="width: auto; min-width: 250px; padding: 8px 15px;">
            </div>
        </div>
        
        <table id="filesTable">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Nom Original</th>
                    <th>Nom sur Serveur</th>
                    <th>Type</th>
                    <th>Taille</th>
                    <th>Chemin</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <% 
                    int index = 1;
                    // Affiche les fichiers du plus récent au plus ancien
                    for (int i = uploadedFiles.size() - 1; i >= 0; i--) {
                        UploadedFileInfo file = uploadedFiles.get(i);
                        String contentType = file.getContentType();
                        if (contentType == null) contentType = "Inconnu";
                %>
                <tr data-type="<%= contentType %>">
                    <td><%= index++ %></td>
                    <td>
                        <strong><%= file.getOriginalName() %></strong>
                        <% if (contentType.startsWith("image/")) { %>
                            <br><span style="color: #28a745; font-size: 12px;">🖼️ Image</span>
                        <% } else if (contentType.contains("pdf")) { %>
                            <br><span style="color: #dc3545; font-size: 12px;">📄 PDF</span>
                        <% } else if (contentType.contains("text")) { %>
                            <br><span style="color: #17a2b8; font-size: 12px;">📝 Texte</span>
                        <% } %>
                    </td>
                    <td>
                        <code style="background: #f5f5f5; padding: 3px 8px; border-radius: 3px; font-size: 11px;">
                            <%= file.getUniqueName() %>
                        </code>
                    </td>
                    <td>
                        <span class="badge">
                            <%= contentType %>
                        </span>
                    </td>
                    <td><%= file.getFormattedSize() %></td>
                    <td>
                        <code style="font-size: 11px; color: #666;">
                            <%= file.getPath().length() > 50 ? 
                                "..." + file.getPath().substring(file.getPath().length() - 47) : 
                                file.getPath() %>
                        </code>
                    </td>
                    <td>
                        <button onclick="showFileDetails('<%= file.getOriginalName() %>', '<%= file.getFormattedSize() %>', '<%= contentType %>')" 
                                style="background: #6c757d; color: white; border: none; padding: 5px 10px; border-radius: 4px; cursor: pointer; font-size: 12px;">
                            ℹ️ Détails
                        </button>
                    </td>
                </tr>
                <% } %>
            </tbody>
        </table>
    <% } %>
</div>

<!-- Actions -->
<div class="card">
    <h3>🎯 Actions</h3>
    <div style="display: flex; gap: 15px; margin-top: 20px; flex-wrap: wrap;">
        <a href="<%= request.getContextPath() %>/files/upload-form" class="btn">
            📤 Uploader de nouveaux fichiers
        </a>
        <a href="<%= request.getContextPath() %>/products" class="btn btn-secondary">
            🏠 Retour à l'accueil
        </a>
    </div>
</div>

<!-- Informations système -->
<div class="card">
    <h4>⚙️ Informations Système</h4>
    <ul style="line-height: 1.8;">
        <li><strong>Répertoire de stockage :</strong> <code>/uploads/</code></li>
        <li><strong>Nombre total de fichiers :</strong> <%= totalFiles %></li>
        <li><strong>Espace utilisé :</strong> <%= formattedTotalSize %></li>
        <li><strong>Types de fichiers différents :</strong> <%= fileTypeCount.size() %></li>
    </ul>
</div>

<script>
    // Fonction pour afficher les détails d'un fichier
    function showFileDetails(name, size, type) {
        alert("Détails du fichier :\n\n" +
              "Nom : " + name + "\n" +
              "Taille : " + size + "\n" +
              "Type : " + type);
    }
    
    // Filtrage par type
    document.getElementById('filterType').addEventListener('change', function() {
        var selectedType = this.value;
        var rows = document.querySelectorAll('#filesTable tbody tr');
        
        rows.forEach(function(row) {
            if (selectedType === '' || row.getAttribute('data-type') === selectedType) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    });
    
    // Recherche de fichiers
    document.getElementById('searchInput').addEventListener('input', function() {
        var searchTerm = this.value.toLowerCase();
        var rows = document.querySelectorAll('#filesTable tbody tr');
        
        rows.forEach(function(row) {
            var fileName = row.cells[1].textContent.toLowerCase();
            if (fileName.includes(searchTerm)) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    });
</script>

<%@ include file="page-footer.jsp" %>