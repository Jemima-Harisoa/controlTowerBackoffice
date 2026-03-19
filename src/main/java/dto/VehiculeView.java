package dto;

/**
 * DTO - Vue formatée d'un véhicule pour le frontend
 * Données prêtes à l'affichage, aucun champ technique inutile
 */
public class VehiculeView {
    private long id;
    private String immatriculation;
    private String marque;
    private String modele;
    private int annee;
    private String typeCarburant;
    private int capacitePassagers;
    private boolean available;

    public VehiculeView() {}

    public VehiculeView(long id, String immatriculation, String marque, String modele,
                        int annee, String typeCarburant, int capacitePassagers, boolean available) {
        this.id = id;
        this.immatriculation = immatriculation;
        this.marque = marque;
        this.modele = modele;
        this.annee = annee;
        this.typeCarburant = typeCarburant;
        this.capacitePassagers = capacitePassagers;
        this.available = available;
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
        return available;
    }

    public void setAvailable(boolean available) {
        this.available = available;
    }
}
