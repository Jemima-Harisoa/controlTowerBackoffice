package model;

public class Distance {
    private long id;
    private long lieuDepartId;
    private long lieuArriveeId;
    private String lieuDepartNom;
    private String lieuArriveeNom;
    private double distanceKm;
    private String createdAt;
    private String updatedAt;

    // Constructeurs
    public Distance() {}

    public Distance(long lieuDepartId, long lieuArriveeId, double distanceKm) {
        this.lieuDepartId = lieuDepartId;
        this.lieuArriveeId = lieuArriveeId;
        this.distanceKm = distanceKm;
    }

    // Getters et Setters
    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public long getLieuDepartId() {
        return lieuDepartId;
    }

    public void setLieuDepartId(long lieuDepartId) {
        this.lieuDepartId = lieuDepartId;
    }

    public long getLieuArriveeId() {
        return lieuArriveeId;
    }

    public void setLieuArriveeId(long lieuArriveeId) {
        this.lieuArriveeId = lieuArriveeId;
    }

    public String getLieuDepartNom() {
        return lieuDepartNom;
    }

    public void setLieuDepartNom(String lieuDepartNom) {
        this.lieuDepartNom = lieuDepartNom;
    }

    public String getLieuArriveeNom() {
        return lieuArriveeNom;
    }

    public void setLieuArriveeNom(String lieuArriveeNom) {
        this.lieuArriveeNom = lieuArriveeNom;
    }

    public double getDistanceKm() {
        return distanceKm;
    }

    public void setDistanceKm(double distanceKm) {
        this.distanceKm = distanceKm;
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
