package test;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

import annotations.Controller;
import annotations.GetMapping;
import annotations.PathVariable;
import annotations.PostMapping;
import annotations.RequestParam;
import model.View;
import com.MultipartFile;

@Controller(name="productController")
public class ProductService {
    
    // Simulation d'une base de données en mémoire avec ID auto-incrément
    private static List<Product> productDatabase = new ArrayList<>();
    private static int nextId = 1;
    
    // ==========================================================
    // PAGES D'ACCUEIL ET FORMULAIRES
    // ==========================================================
    @PostMapping("/products/upload-multiple")
    public View uploadMultiple(@RequestParam MultipartFile[] files) {

        View view = new View("success");

        view.addData("message", "Upload multiple OK");
        view.addData("count", files != null ? files.length : 0);
        view.addData("formType", "upload-multiple");

        return view;
    }

    @PostMapping("/products/upload-with-text")
    public View uploadWithText(
            @RequestParam String name,
            @RequestParam String description,
            @RequestParam MultipartFile image) {

        View view = new View("success");

        view.addData("message", "Upload texte + fichier OK");
        view.addData("name", name);
        view.addData("description", description);
        view.addData("filename", image.getOriginalFilename());
        view.addData("size", image.getSize());
        view.addData("formType", "upload-text");

        return view;
    }

    @PostMapping("/products/upload-simple")
    public View uploadSimple(@RequestParam MultipartFile file) {

        View view = new View("success");

        if (file == null || file.isEmpty()) {
            view = new View("error");
            view.addData("message", "Aucun fichier reçu");
            return view;
        }

        view.addData("message", "Fichier reçu avec succès !");
        view.addData("filename", file.getOriginalFilename());
        view.addData("size", file.getSize());
        view.addData("contentType", file.getContentType());
        view.addData("formType", "upload-simple");

        return view;
    }

    @GetMapping("/products/{id}/form-object-complex")
    public View getFormObjectComplex(@PathVariable int id){
        // Récupère le produit par son ID pour l'édition
        Product product = getProductById(id);
        if (product == null) {
            // Si le produit n'existe pas, redirige vers la liste
            View errorView = new View("error");
            errorView.addData("message", "Produit non trouvé avec l'ID: " + id);
            return errorView;
        }
        
        View view = new View("form-object-complex");
        view.addData("product", product);
        view.addData("action", "update");
        return view;
    }

    @GetMapping("/products/form-upload-simple")
    public View getFormUpload(){
        return new View("form-upload-simple");
    }

    @GetMapping("/products/form-object")
    public View getFormObject(){
        return new View("form-object");
    }
    
    /**
     * Page d'accueil - Liste tous les formulaires de test disponibles
     */
    @GetMapping("/products")
    public View homePage() {
        return new View("products-home");
    }
    
    /**
     * Formulaire 1 : Inputs texte simples
     */
    @GetMapping("/products/form-simple")
    public View showSimpleForm() {
        return new View("form-simple");
    }
    
    /**
     * Formulaire 2 : Select (liste déroulante)
     */
    @GetMapping("/products/form-select")
    public View showSelectForm() {
        return new View("form-select");
    }
    
    /**
     * Formulaire 3 : Checkboxes
     */
    @GetMapping("/products/form-checkbox")
    public View showCheckboxForm() {
        return new View("form-checkbox");
    }
    
    /**
     * Formulaire 4 : Radio buttons
     */
    @GetMapping("/products/form-radio")
    public View showRadioForm() {
        return new View("form-radio");
    }
    
    /**
     * Formulaire 5 : Textarea
     */
    @GetMapping("/products/form-textarea")
    public View showTextareaForm() {
        return new View("form-textarea");
    }
    
    /**
     * Formulaire 6 : Formulaire complet
     */
    @GetMapping("/products/form-complete")
    public View showCompleteForm() {
        return new View("form-complete");
    }
    
    // ==========================================================
    // MÉTHODES DE GESTION DES PRODUITS
    // ==========================================================
    
    /**
     * Méthode utilitaire : Récupère un produit par son ID
     */
    private Product getProductById(int id) {
        for (Product product : productDatabase) {
            if (product.getId() == id) {
                return product;
            }
        }
        return null;
    }
    
    /**
     * Méthode utilitaire : Met à jour un produit existant
     */
    private void updateProduct(Product updatedProduct) {
        for (int i = 0; i < productDatabase.size(); i++) {
            if (productDatabase.get(i).getId() == updatedProduct.getId()) {
                productDatabase.set(i, updatedProduct);
                return;
            }
        }
    }
    
    /**
     * Crée un produit à partir d'un objet Product
     */
    @PostMapping("/products/create-from-object")
    public View createFromObject(Product product) {
        // Attribue un ID au produit
        product.setId(nextId++);
        productDatabase.add(product);
        
        View view = new View("success");
        view.addData("message", "Produit créé directement à partir de l'objet !");
        view.addData("product", product);
        view.addData("formType", "object");
        return view;
    }
    
    /**
     * Méthode mixte pour création/mise à jour avec paramètres variés
     * URL: /products/create-with-mixed/{id}
     * 
     * @param id ID du produit (0 pour création, >0 pour mise à jour)
     * @param action Action à effectuer ("create" ou "update")
     * @param product Objet Product rempli automatiquement
     * @param request Boolean pour checkbox (renommé pour éviter confusion)
     */
    @PostMapping("/products/create-with-mixed/{id}")
    public View createWithMixed(@PathVariable int id, 
                              @RequestParam String action,
                              Product product,
                              @RequestParam Boolean inStock) {
        
        // Utilise la valeur de la checkbox si fournie
        if (inStock != null) {
            product.setInStock(inStock);
        }
        
        if (id > 0 && "update".equalsIgnoreCase(action)) {
            // Mise à jour d'un produit existant
            Product existingProduct = getProductById(id);
            if (existingProduct != null) {
                // Échange les données du produit existant avec les nouvelles
                product.setId(id); // Garde le même ID
                updateProduct(product);
                
                View view = new View("success");
                view.addData("message", "Produit mis à jour avec succès ! ID: " + id);
                view.addData("product", product);
                view.addData("action", "update");
                return view;
            }
        }
        
        // Création d'un nouveau produit
        product.setId(nextId++);
        productDatabase.add(product);
        
        View view = new View("success");
        view.addData("message", "Nouveau produit créé avec succès ! Action: " + action);
        view.addData("product", product);
        view.addData("action", "create");
        return view;
    }
    
    /**
     * Crée plusieurs produits à partir de deux objets
     */
    @PostMapping("/products/create-multiple")
    public View createMultiple(Product product1, Product product2) {
        // Attribue des IDs aux produits
        product1.setId(nextId++);
        product2.setId(nextId++);
        
        productDatabase.add(product1);
        productDatabase.add(product2);
        
        View view = new View("success");
        view.addData("message", "Deux produits créés simultanément !");
        view.addData("product1", product1);
        view.addData("product2", product2);
        view.addData("formType", "multiple");
        return view;
    }
    
    // ==========================================================
    // TRAITEMENT DES FORMULAIRES EXISTANTS (conservés pour compatibilité)
    // ==========================================================
    
    @PostMapping("/products/create-simple")
    public View createSimpleProduct(Map<String, Object> params) {
        String name = (String) params.get("name");
        Double price = (Double) params.get("price");
        Integer quantity = (Integer) params.get("quantity");
        
        Product product = new Product(name, price, quantity);
        product.setId(nextId++);
        productDatabase.add(product);
        
        View view = new View("success");
        view.addData("message", "Produit simple créé avec succès !");
        view.addData("product", product);
        view.addData("formType", "simple");
        return view;
    }
    
    @PostMapping("/products/create-select")
    public View createProductWithSelect(Map<String, Object> params) {
        String name = (String) params.get("name");
        Double price = (Double) params.get("price");
        Integer quantity = (Integer) params.get("quantity");
        String category = (String) params.get("category");
        
        Product product = new Product(name, price, quantity);
        product.setCategory(category);
        product.setId(nextId++);
        productDatabase.add(product);
        
        View view = new View("success");
        view.addData("message", "Produit avec catégorie créé avec succès !");
        view.addData("product", product);
        view.addData("formType", "select");
        return view;
    }
    
    @PostMapping("/products/create-checkbox")
    public View createProductWithCheckbox(Map<String, Object> params) {
        String name = (String) params.get("name");
        Double price = (Double) params.get("price");
        Integer quantity = (Integer) params.get("quantity");
        
        Object tagsObj = params.get("tags");
        List<String> tags = new ArrayList<>();
        
        if (tagsObj != null) {
            if (tagsObj instanceof String[]) {
                tags = Arrays.asList((String[]) tagsObj);
            } else if (tagsObj instanceof Object[]) {
                Object[] objArray = (Object[]) tagsObj;
                for (Object obj : objArray) {
                    tags.add(obj.toString());
                }
            } else if (tagsObj instanceof String) {
                tags.add((String) tagsObj);
            }
        }
        
        Product product = new Product(name, price, quantity);
        product.setTags(tags);
        product.setId(nextId++);
        productDatabase.add(product);
        
        View view = new View("success");
        view.addData("message", "Produit avec tags créé avec succès !");
        view.addData("product", product);
        view.addData("formType", "checkbox");
        return view;
    }
    
    @PostMapping("/products/create-radio")
    public View createProductWithRadio(Map<String, Object> params) {
        String name = (String) params.get("name");
        Double price = (Double) params.get("price");
        Integer quantity = (Integer) params.get("quantity");
        String priority = (String) params.get("priority");
        
        Product product = new Product(name, price, quantity);
        product.setPriority(priority);
        product.setId(nextId++);
        productDatabase.add(product);
        
        View view = new View("success");
        view.addData("message", "Produit avec priorité créé avec succès !");
        view.addData("product", product);
        view.addData("formType", "radio");
        return view;
    }
    
    @PostMapping("/products/create-textarea")
    public View createProductWithTextarea(Map<String, Object> params) {
        String name = (String) params.get("name");
        Double price = (Double) params.get("price");
        Integer quantity = (Integer) params.get("quantity");
        String description = (String) params.get("description");
        
        Product product = new Product(name, price, quantity);
        product.setDescription(description);
        product.setId(nextId++);
        productDatabase.add(product);
        
        View view = new View("success");
        view.addData("message", "Produit avec description créé avec succès !");
        view.addData("product", product);
        view.addData("formType", "textarea");
        return view;
    }
    
    @PostMapping("/products/create-complete")
    public View createCompleteProduct(Map<String, Object> params) {
        String name = (String) params.get("name");
        Double price = (Double) params.get("price");
        Integer quantity = (Integer) params.get("quantity");
        String category = (String) params.get("category");
        String priority = (String) params.get("priority");
        String description = (String) params.get("description");
        
        Object inStockObj = params.get("inStock");
        boolean inStock = false;
        if (inStockObj != null) {
            if (inStockObj instanceof Boolean) {
                inStock = (Boolean) inStockObj;
            } else if (inStockObj instanceof String) {
                String strValue = (String) inStockObj;
                inStock = "on".equalsIgnoreCase(strValue) || 
                         "true".equalsIgnoreCase(strValue) ||
                         "yes".equalsIgnoreCase(strValue);
            }
        }
        
        Object tagsObj = params.get("tags");
        List<String> tags = new ArrayList<>();
        if (tagsObj != null) {
            if (tagsObj instanceof String[]) {
                tags = Arrays.asList((String[]) tagsObj);
            } else if (tagsObj instanceof Object[]) {
                Object[] objArray = (Object[]) tagsObj;
                for (Object obj : objArray) {
                    tags.add(obj.toString());
                }
            } else if (tagsObj instanceof String) {
                tags.add((String) tagsObj);
            }
        }
        
        Product product = new Product(name, price, quantity);
        product.setCategory(category);
        product.setPriority(priority);
        product.setDescription(description);
        product.setInStock(inStock);
        product.setTags(tags);
        product.setId(nextId++);
        productDatabase.add(product);
        
        View view = new View("success");
        view.addData("message", "Produit complet créé avec succès !");
        view.addData("product", product);
        view.addData("formType", "complete");
        return view;
    }
    
    /**
     * Affiche tous les produits créés
     */
    @GetMapping("/products/list")
    public View listProducts() {
        View view = new View("product-list");
        view.addData("products", productDatabase);
        view.addData("totalProducts", productDatabase.size());
        return view;
    }
    
    /**
     * Supprime un produit par son ID
     */
    @GetMapping("/products/delete/{id}")
    public View deleteProduct(@PathVariable int id) {
        Product productToRemove = null;
        for (Product product : productDatabase) {
            if (product.getId() == id) {
                productToRemove = product;
                break;
            }
        }
        
        if (productToRemove != null) {
            productDatabase.remove(productToRemove);
            View view = new View("success");
            view.addData("message", "Produit supprimé avec succès ! ID: " + id);
            view.addData("formType", "delete");
            return view;
        } else {
            View errorView = new View("error");
            errorView.addData("message", "Produit non trouvé avec l'ID: " + id);
            return errorView;
        }
    }
}