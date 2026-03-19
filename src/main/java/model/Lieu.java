package model;

public class Lieu {
    private long id;
    private String nom;
    private long typeLieuId;
    private String typeLieu;
    private String adresse;
    private String ville;
    private String pays;
    private double latitude;
    private double longitude;
    private String description;
    private Long hotelId;
    private boolean isActive;
    private String createdAt;
    private String updatedAt;

    // Constructeurs
    public Lieu() {}

    public Lieu(String nom, long typeLieuId, String adresse, String ville, String pays) {
        this.nom = nom;
        this.typeLieuId = typeLieuId;
        this.adresse = adresse;
        this.ville = ville;
        this.pays = pays;
        this.isActive = true;
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

    public long getTypeLieuId() {
        return typeLieuId;
    }

    public void setTypeLieuId(long typeLieuId) {
        this.typeLieuId = typeLieuId;
    }

    public String getTypeLieu() {
        return typeLieu;
    }

    public void setTypeLieu(String typeLieu) {
        this.typeLieu = typeLieu;
    }

    public String getAdresse() {
        return adresse;
    }

    public void setAdresse(String adresse) {
        this.adresse = adresse;
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

    public Long getHotelId() {
        return hotelId;
    }

    public void setHotelId(Long hotelId) {
        this.hotelId = hotelId;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }

    public String getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(String updatedAt) {
        this.updatedAt = updatedAt;
    }
}
