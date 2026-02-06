package test;

import annotations.Controller;
import annotations.GetMapping;
import annotations.PostMapping;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.Part;
import model.View;

import java.io.File;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

/**
 * Contrôleur pour gérer l'upload de fichiers
 * Gère l'affichage du formulaire d'upload et le traitement des fichiers
 */
@Controller(name = "fileUploadController")
public class FileUploadController {
    
    // Répertoire où seront stockés les fichiers uploadés
    // Dans un environnement de production, ce chemin devrait être configurable
    private static final String UPLOAD_DIR = "uploads";
    
    // Liste en mémoire des fichiers uploadés (pour l'affichage)
    private static List<UploadedFileInfo> uploadedFiles = new ArrayList<>();
    
    /**
     * Affiche le formulaire d'upload de fichiers
     * URL: /files/upload-form
     */
    @GetMapping("/files/upload-form")
    public View showUploadForm() {
        View view = new View("file-upload-form");
        view.addData("uploadedFiles", uploadedFiles);
        view.addData("totalFiles", uploadedFiles.size());
        return view;
    }
    
    /**
     * Traite l'upload de fichiers
     * URL: /files/upload
     * 
     * @param request La requête HTTP contenant le(s) fichier(s)
     * @return Vue de succès avec les informations du fichier uploadé
     */
    @PostMapping("/files/upload")
    public View handleFileUpload(HttpServletRequest request) {
        try {
            // Crée le répertoire d'upload s'il n'existe pas
            String uploadPath = getUploadPath(request);
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            
            // Récupère tous les fichiers de la requête multipart
            Collection<Part> parts = request.getParts();
            List<UploadedFileInfo> currentUploadedFiles = new ArrayList<>();
            
            for (Part part : parts) {
                // Ignore les parties qui ne sont pas des fichiers
                String fileName = getFileName(part);
                if (fileName == null || fileName.isEmpty()) {
                    continue;
                }
                
                // Génère un nom unique pour éviter les conflits
                String uniqueFileName = System.currentTimeMillis() + "_" + fileName;
                Path filePath = Paths.get(uploadPath, uniqueFileName);
                
                // Sauvegarde le fichier
                try (InputStream inputStream = part.getInputStream()) {
                    Files.copy(inputStream, filePath, StandardCopyOption.REPLACE_EXISTING);
                }
                
                // Crée un objet d'information sur le fichier
                UploadedFileInfo fileInfo = new UploadedFileInfo(
                    uniqueFileName,
                    fileName,
                    part.getContentType(),
                    part.getSize(),
                    filePath.toString()
                );
                
                // Ajoute aux listes
                currentUploadedFiles.add(fileInfo);
                uploadedFiles.add(fileInfo);
            }
            
            // Prépare la vue de succès
            View view = new View("file-upload-success");
            view.addData("message", "Fichier(s) uploadé(s) avec succès !");
            view.addData("uploadedFiles", currentUploadedFiles);
            view.addData("fileCount", currentUploadedFiles.size());
            
            return view;
            
        } catch (Exception e) {
            // En cas d'erreur, prépare une vue d'erreur
            View errorView = new View("error");
            errorView.addData("message", "Erreur lors de l'upload : " + e.getMessage());
            e.printStackTrace();
            return errorView;
        }
    }
    
    /**
     * Affiche la liste de tous les fichiers uploadés
     * URL: /files/list
     */
    @GetMapping("/files/list")
    public View listUploadedFiles() {
        View view = new View("file-list");
        view.addData("uploadedFiles", uploadedFiles);
        view.addData("totalFiles", uploadedFiles.size());
        
        // Calcule la taille totale
        long totalSize = uploadedFiles.stream()
            .mapToLong(UploadedFileInfo::getSize)
            .sum();
        view.addData("totalSize", totalSize);
        
        return view;
    }
    
    /**
     * Extrait le nom du fichier à partir d'un Part
     * 
     * @param part La partie de la requête multipart
     * @return Le nom du fichier ou null si ce n'est pas un fichier
     */
    private String getFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        if (contentDisposition == null) {
            return null;
        }
        
        for (String content : contentDisposition.split(";")) {
            if (content.trim().startsWith("filename")) {
                return content.substring(content.indexOf('=') + 1).trim()
                    .replace("\"", "");
            }
        }
        return null;
    }
    
    /**
     * Récupère le chemin absolu du répertoire d'upload
     * 
     * @param request La requête HTTP
     * @return Le chemin absolu du répertoire d'upload
     */
    private String getUploadPath(HttpServletRequest request) {
        // Utilise le répertoire de l'application web
        String appPath = request.getServletContext().getRealPath("");
        return appPath + File.separator + UPLOAD_DIR;
    }
    
    /**
     * Classe interne pour stocker les informations sur un fichier uploadé
     */
    public static class UploadedFileInfo {
        private String uniqueName;     // Nom unique généré
        private String originalName;   // Nom original du fichier
        private String contentType;    // Type MIME
        private long size;            // Taille en octets
        private String path;          // Chemin complet du fichier
        
        public UploadedFileInfo(String uniqueName, String originalName, 
                               String contentType, long size, String path) {
            this.uniqueName = uniqueName;
            this.originalName = originalName;
            this.contentType = contentType;
            this.size = size;
            this.path = path;
        }
        
        // Getters
        public String getUniqueName() { return uniqueName; }
        public String getOriginalName() { return originalName; }
        public String getContentType() { return contentType; }
        public long getSize() { return size; }
        public String getPath() { return path; }
        
        /**
         * Retourne la taille formatée en KB ou MB
         */
        public String getFormattedSize() {
            if (size < 1024) {
                return size + " B";
            } else if (size < 1024 * 1024) {
                return String.format("%.2f KB", size / 1024.0);
            } else {
                return String.format("%.2f MB", size / (1024.0 * 1024.0));
            }
        }
    }
}