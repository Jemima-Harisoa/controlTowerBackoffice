package model;

public class Vehicule {
    private long id;
    private String immatriculation;
    private String marque;
    private String modele;
    private int annee;
    private long typeCarburantId;
    private String typeCarburant;
    private int capacitePassagers;
    private boolean isAvailable;
    private String heureDisponibleDebut;
    private String heureDisponibleCourante;
    private String createdAt;
    private String updatedAt;

    // Constructeurs
    public Vehicule() {}

    public Vehicule(String immatriculation, String marque, String modele, int annee,
                    long typeCarburantId, int capacitePassagers) {
        this.immatriculation = immatriculation;
        this.marque = marque;
        this.modele = modele;
        this.annee = annee;
        this.typeCarburantId = typeCarburantId;
        this.capacitePassagers = capacitePassagers;
        this.isAvailable = true;
        this.heureDisponibleDebut = "00:00:00";
        this.heureDisponibleCourante = "00:00:00";
    }

    // Getters et Setters
    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getImmatriculation() {
        return immatriculation;
    }

    public void setImmatriculation(String immatriculation) {
        this.immatriculation = immatriculation;
    }

    public String getMarque() {
        return marque;
    }

    public void setMarque(String marque) {
        this.marque = marque;
    }

    public String getModele() {
        return modele;
    }

    public void setModele(String modele) {
        this.modele = modele;
    }

    public int getAnnee() {
        return annee;
    }

    public void setAnnee(int annee) {
        this.annee = annee;
    }

    public long getTypeCarburantId() {
        return typeCarburantId;
    }

    public void setTypeCarburantId(long typeCarburantId) {
        this.typeCarburantId = typeCarburantId;
    }

    public String getTypeCarburant() {
        return typeCarburant;
    }

    public void setTypeCarburant(String typeCarburant) {
        this.typeCarburant = typeCarburant;
    }

    public int getCapacitePassagers() {
        return capacitePassagers;
    }

    public void setCapacitePassagers(int capacitePassagers) {
        this.capacitePassagers = capacitePassagers;
    }

    public boolean isAvailable() {
        return isAvailable;
    }

    public void setAvailable(boolean available) {
        isAvailable = available;
    }

    public String getHeureDisponibleDebut() {
        return heureDisponibleDebut;
    }

    public void setHeureDisponibleDebut(String heureDisponibleDebut) {
        this.heureDisponibleDebut = heureDisponibleDebut;
    }

    public String getHeureDisponibleCourante() {
        return heureDisponibleCourante;
    }

    public void setHeureDisponibleCourante(String heureDisponibleCourante) {
        this.heureDisponibleCourante = heureDisponibleCourante;
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
