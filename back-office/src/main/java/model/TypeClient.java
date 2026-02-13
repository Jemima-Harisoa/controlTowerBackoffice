package model;

public class TypeClient {
    private int id;
    private String libelle;       // Changé de type à libelle pour correspondre à la base
    private String description;
    
    // Constructeurs
    public TypeClient() {}
    
    public TypeClient(int id, String libelle, String description) {
        this.id = id;
        this.libelle = libelle;
        this.description = description;
    }
    
    // Getters et Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getLibelle() { return libelle; }
    public void setLibelle(String libelle) { this.libelle = libelle; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}
