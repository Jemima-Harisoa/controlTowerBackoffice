package model;

import java.sql.Timestamp;

public class Reservation {
    private int id;
    private String nom;
    private String email;
    private Timestamp dateArrivee;
    private String heure;
    private int nombrePersonnes;
    private int hotelId;
    private boolean isConfirmed;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Constructeurs
    public Reservation() {}

    public Reservation(String nom, String email, Timestamp dateArrivee, 
                      String heure, int nombrePersonnes, int hotelId) {
        this.nom = nom;
        this.email = email;
        this.dateArrivee = dateArrivee;
        this.heure = heure;
        this.nombrePersonnes = nombrePersonnes;
        this.hotelId = hotelId;
    }

    // Getters et Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getNom() {
        return nom;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public Timestamp getDateArrivee() {
        return dateArrivee;
    }

    public void setDateArrivee(Timestamp dateArrivee) {
        this.dateArrivee = dateArrivee;
    }

    public String getHeure() {
        return heure;
    }

    public void setHeure(String heure) {
        this.heure = heure;
    }

    public int getNombrePersonnes() {
        return nombrePersonnes;
    }

    public void setNombrePersonnes(int nombrePersonnes) {
        this.nombrePersonnes = nombrePersonnes;
    }

    public int getHotelId() {
        return hotelId;
    }

    public void setHotelId(int hotelId) {
        this.hotelId = hotelId;
    }

    public boolean isConfirmed() {
        return isConfirmed;
    }

    public void setConfirmed(boolean confirmed) {
        isConfirmed = confirmed;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
}
