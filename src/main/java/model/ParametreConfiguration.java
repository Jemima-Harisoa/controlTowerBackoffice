package model;

public class ParametreConfiguration {
    private long id;
    private String cle;
    private String valeur;
    private String typeValeur;
    private String description;
    private String effectiveDate;
    private String createdAt;
    private String updatedAt;

    // Constructeurs
    public ParametreConfiguration() {}

    public ParametreConfiguration(String cle, String valeur, String typeValeur) {
        this.cle = cle;
        this.valeur = valeur;
        this.typeValeur = typeValeur;
    }

    // Getters et Setters
    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getCle() {
        return cle;
    }

    public void setCle(String cle) {
        this.cle = cle;
    }

    public String getValeur() {
        return valeur;
    }

    public void setValeur(String valeur) {
        this.valeur = valeur;
    }

    public String getTypeValeur() {
        return typeValeur;
    }

    public void setTypeValeur(String typeValeur) {
        this.typeValeur = typeValeur;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getEffectiveDate() {
        return effectiveDate;
    }

    public void setEffectiveDate(String effectiveDate) {
        this.effectiveDate = effectiveDate;
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

    // Méthodes pour conversion de type
    public int getValeurAsInt() {
        return Integer.parseInt(valeur);
    }

    public double getValeurAsDouble() {
        return Double.parseDouble(valeur);
    }

    public boolean getValeurAsBoolean() {
        return Boolean.parseBoolean(valeur);
    }
}
