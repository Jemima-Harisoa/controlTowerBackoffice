package dto;

import java.util.List;

/**
 * DTO pour afficher un groupe de reservations assignees
 * au meme vehicule pour un meme creneau (date + heure).
 * 
 * Sprint 4 : Ajout des champs de temps d'attente et regroupement
 */
public class PlanningTrajetGroupeView {
    private long vehiculeId;
    private String vehiculeImmatriculation;
    private String dateArrivee;
    private String dateArriveeIso;
    private String heureArrivee;
    private List<String> clients;
    private int nombrePassagersTotal;
    private int capaciteVehicule;
    private int placesLibres;
    private double distanceTotale;
    private String dureeEstimee;
    private List<String> pointsDepart;
    private List<String> pointsArrivee;
    private String typeCarburantVehicule;
    private String statut;
    
    // === Sprint 4 : Champs de regroupement par temps d'attente ===
    private String reservationIdsGroupees;        // CSV des IDs du groupe (ex: "7,8")
    private int nombreReservationsGroupe;         // Nombre de réservations dans le groupe
    private int tempsAttenteGroupeMinutes;        // Temps d'attente entre 1ère et dernière rés.
    private String heureDeprtAjustee;             // Heure de départ = heure dernière réservation
    private String plageHeuresGroupe;             // Affichage lisible (ex: "08:00 → 08:15")

    public long getVehiculeId() {
        return vehiculeId;
    }

    public void setVehiculeId(long vehiculeId) {
        this.vehiculeId = vehiculeId;
    }

    public String getVehiculeImmatriculation() {
        return vehiculeImmatriculation;
    }

    public void setVehiculeImmatriculation(String vehiculeImmatriculation) {
        this.vehiculeImmatriculation = vehiculeImmatriculation;
    }

    public String getDateArrivee() {
        return dateArrivee;
    }

    public void setDateArrivee(String dateArrivee) {
        this.dateArrivee = dateArrivee;
    }

    public String getDateArriveeIso() {
        return dateArriveeIso;
    }

    public void setDateArriveeIso(String dateArriveeIso) {
        this.dateArriveeIso = dateArriveeIso;
    }

    public String getHeureArrivee() {
        return heureArrivee;
    }

    public void setHeureArrivee(String heureArrivee) {
        this.heureArrivee = heureArrivee;
    }

    public List<String> getClients() {
        return clients;
    }

    public void setClients(List<String> clients) {
        this.clients = clients;
    }

    public int getNombrePassagersTotal() {
        return nombrePassagersTotal;
    }

    public void setNombrePassagersTotal(int nombrePassagersTotal) {
        this.nombrePassagersTotal = nombrePassagersTotal;
    }

    public int getCapaciteVehicule() {
        return capaciteVehicule;
    }

    public void setCapaciteVehicule(int capaciteVehicule) {
        this.capaciteVehicule = capaciteVehicule;
    }

    public int getPlacesLibres() {
        return placesLibres;
    }

    public void setPlacesLibres(int placesLibres) {
        this.placesLibres = placesLibres;
    }

    public double getDistanceTotale() {
        return distanceTotale;
    }

    public void setDistanceTotale(double distanceTotale) {
        this.distanceTotale = distanceTotale;
    }

    public String getDureeEstimee() {
        return dureeEstimee;
    }

    public void setDureeEstimee(String dureeEstimee) {
        this.dureeEstimee = dureeEstimee;
    }

    public List<String> getPointsDepart() {
        return pointsDepart;
    }

    public void setPointsDepart(List<String> pointsDepart) {
        this.pointsDepart = pointsDepart;
    }

    public List<String> getPointsArrivee() {
        return pointsArrivee;
    }

    public void setPointsArrivee(List<String> pointsArrivee) {
        this.pointsArrivee = pointsArrivee;
    }

    public String getTypeCarburantVehicule() {
        return typeCarburantVehicule;
    }

    public void setTypeCarburantVehicule(String typeCarburantVehicule) {
        this.typeCarburantVehicule = typeCarburantVehicule;
    }

    public String getStatut() {
        return statut;
    }

    public void setStatut(String statut) {
        this.statut = statut;
    }

    // === Getters/Setters Sprint 4 ===
    public String getReservationIdsGroupees() {
        return reservationIdsGroupees;
    }

    public void setReservationIdsGroupees(String reservationIdsGroupees) {
        this.reservationIdsGroupees = reservationIdsGroupees;
    }

    public int getNombreReservationsGroupe() {
        return nombreReservationsGroupe;
    }

    public void setNombreReservationsGroupe(int nombreReservationsGroupe) {
        this.nombreReservationsGroupe = nombreReservationsGroupe;
    }

    public int getTempsAttenteGroupeMinutes() {
        return tempsAttenteGroupeMinutes;
    }

    public void setTempsAttenteGroupeMinutes(int tempsAttenteGroupeMinutes) {
        this.tempsAttenteGroupeMinutes = tempsAttenteGroupeMinutes;
    }

    public String getHeureDeprtAjustee() {
        return heureDeprtAjustee;
    }

    public void setHeureDeprtAjustee(String heureDeprtAjustee) {
        this.heureDeprtAjustee = heureDeprtAjustee;
    }

    public String getPlageHeuresGroupe() {
        return plageHeuresGroupe;
    }

    public void setPlageHeuresGroupe(String plageHeuresGroupe) {
        this.plageHeuresGroupe = plageHeuresGroupe;
    }
}
