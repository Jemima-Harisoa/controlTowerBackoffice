package dto;

/**
 * DTO - Vue formatée d'un lieu pour le frontend
 */
public class LieuView {
    private long id;
    private String nom;
    private String typeLieu;
    private String ville;
    private String pays;
    private double latitude;
    private double longitude;
    private String description;

    public LieuView() {}

    public LieuView(long id, String nom, String typeLieu, String ville, String pays) {
        this.id = id;
        this.nom = nom;
        this.typeLieu = typeLieu;
        this.ville = ville;
        this.pays = pays;
    }

    // Getters et Setters
    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getNom() {
        return nom;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }

    public String getTypeLieu() {
        return typeLieu;
    }

    public void setTypeLieu(String typeLieu) {
        this.typeLieu = typeLieu;
    }

    public String getVille() {
        return ville;
    }

    public void setVille(String ville) {
        this.ville = ville;
    }

    public String getPays() {
        return pays;
    }

    public void setPays(String pays) {
        this.pays = pays;
    }

    public double getLatitude() {
        return latitude;
    }

    public void setLatitude(double latitude) {
        this.latitude = latitude;
    }

    public double getLongitude() {
        return longitude;
    }

    public void setLongitude(double longitude) {
        this.longitude = longitude;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}
