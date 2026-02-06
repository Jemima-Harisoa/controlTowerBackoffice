package test;

import java.util.List;
import annotations.Entity;
/**
 * Modèle représentant un produit
 * Contient toutes les informations d'un produit avec différents types de données
 */
@Entity(name = "Product")
public class Product {
    private int id; // Nouveau champ ID
    private String name;
    private double price;
    private int quantity;
    private String category;
    private boolean inStock;
    private String description;
    private List<String> tags;
    private String priority;
    
    // Constructeur vide (nécessaire pour certaines opérations)
    public Product() {
    }
    
    // Constructeur avec paramètres essentiels
    public Product(String name, double price, int quantity) {
        this.name = name;
        this.price = price;
        this.quantity = quantity;
        this.inStock = true;
    }
    
    // Getters et Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public double getPrice() {
        return price;
    }
    
    public void setPrice(double price) {
        this.price = price;
    }
    
    public int getQuantity() {
        return quantity;
    }
    
    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }
    
    public String getCategory() {
        return category;
    }
    
    public void setCategory(String category) {
        this.category = category;
    }
    
    public boolean isInStock() {
        return inStock;
    }
    
    public void setInStock(boolean inStock) {
        this.inStock = inStock;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public List<String> getTags() {
        return tags;
    }
    
    public void setTags(List<String> tags) {
        this.tags = tags;
    }
    
    public String getPriority() {
        return priority;
    }
    
    public void setPriority(String priority) {
        this.priority = priority;
    }
    
    @Override
    public String toString() {
        return "Product{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", price=" + price +
                ", quantity=" + quantity +
                ", category='" + category + '\'' +
                ", inStock=" + inStock +
                ", description='" + description + '\'' +
                ", tags=" + tags +
                ", priority='" + priority + '\'' +
                '}';
    }
}