package test;

import annotations.Controller;
import annotations.GetMapping;
import java.util.Map;

import annotations.JsonMapping;
import annotations.PostMapping;
import annotations.PathVariable;
import annotations.RequestParam;
import java.util.ArrayList;
import java.util.List;

@Controller
public class ProductApiController {
    
    @JsonMapping
    @GetMapping("/api/products/{id}")
    public Product getProduct(@PathVariable int id) {
        Product product = new Product();
        product.setId(id);
        product.setName("Product " + id);
        product.setPrice(99.99);
        return product; // Sera sérialisé en JSON automatiquement
    }
    
    @JsonMapping
    @GetMapping("/api/products")
    public List<Product> getProducts() {
        List<Product> products = new ArrayList<>();
        for (int i = 1; i <= 10; i++) {
            Product p = new Product();
            p.setId(i);
            p.setName("Product " + i);
            p.setPrice(i * 10.0);
            products.add(p);
        }
        return products; // Sera sérialisé en JSON automatiquement
    }
    
    // @JsonMapping
    // @PostMapping("/api/products")
    // public Product createProduct(Map<String, Object> data) {
    //     // Traitement des données POST en JSON
    //     Product product = new Product();
    //     product.setName((String) data.get("name"));
    //     product.setPrice((Double) data.get("price"));
    //     product.setId(100); // ID généré
    //     return product; // Retourne le produit créé en JSON
    // }
}