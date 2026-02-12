package dto;

import java.sql.Timestamp;

public class ReservationView {
    private int id;
    private String nomFormate;
    private String email;
    private String dateAffichee;
    private String heureAffichee;
    private int nombrePersonnes;
    private String nomHotel;
    private boolean isConfirmed;

    // Constructeurs
    public ReservationView() {}

    public ReservationView(int id, String nomFormate, String email, 
                          String dateAffichee, String heureAffichee, 
                          int nombrePersonnes, String nomHotel, boolean isConfirmed) {
        this.id = id;
        this.nomFormate = nomFormate;
        this.email = email;
        this.dateAffichee = dateAffichee;
        this.heureAffichee = heureAffichee;
        this.nombrePersonnes = nombrePersonnes;
        this.nomHotel = nomHotel;
        this.isConfirmed = isConfirmed;
    }

    // Getters et Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getNomFormate() {
        return nomFormate;
    }

    public void setNomFormate(String nomFormate) {
        this.nomFormate = nomFormate;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getDateAffichee() {
        return dateAffichee;
    }

    public void setDateAffichee(String dateAffichee) {
        this.dateAffichee = dateAffichee;
    }

    public String getHeureAffichee() {
        return heureAffichee;
    }

    public void setHeureAffichee(String heureAffichee) {
        this.heureAffichee = heureAffichee;
    }

    public int getNombrePersonnes() {
        return nombrePersonnes;
    }

    public void setNombrePersonnes(int nombrePersonnes) {
        this.nombrePersonnes = nombrePersonnes;
    }

    public String getNomHotel() {
        return nomHotel;
    }

    public void setNomHotel(String nomHotel) {
        this.nomHotel = nomHotel;
    }

    public boolean isConfirmed() {
        return isConfirmed;
    }

    public void setConfirmed(boolean confirmed) {
        isConfirmed = confirmed;
    }
}
