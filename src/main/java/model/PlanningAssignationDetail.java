package model;

public class PlanningAssignationDetail {
    private long id;
    private long vehiculeId;
    private String dateArrivee;
    private String heureArrivee;
    private long reservationId;
    private long premiereReservationId;
    private String reservationClient;
    private int nombrePassagersTotal;
    private int capaciteVehicule;
    private int placesLibres;
    private double distanceEstimee;
    private String dureeEstimee;
    private String premierPointDepart;
    private String dernierPointArrivee;
    private String pointsDepart;
    private String pointsArrivee;
    private String createdAt;
    private String updatedAt;
    
    //  SPRINT 4 : Champs pour groupement par temps d'attente
    private String reservationIdsGroupees;        // CSV des IDs du groupe (ex: "7,8")
    private int nombreReservationsGroupe;         // Nombre de réservations dans le groupe
    private int tempsAttenteGroupeMinutes;        // Temps d'attente total entre 1ère et dernière
    private String heureDeprtAjustee;             // Heure de départ = heure dernière réservation
    private String plageHeuresGroupe;             // Affichage lisible (ex: "08:00 → 08:15 (attente: 15 min)")

    public PlanningAssignationDetail() {}

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public long getVehiculeId() {
        return vehiculeId;
    }

    public void setVehiculeId(long vehiculeId) {
        this.vehiculeId = vehiculeId;
    }

    public String getDateArrivee() {
        return dateArrivee;
    }

    public void setDateArrivee(String dateArrivee) {
        this.dateArrivee = dateArrivee;
    }

    public String getHeureArrivee() {
        return heureArrivee;
    }

    public void setHeureArrivee(String heureArrivee) {
        this.heureArrivee = heureArrivee;
    }

    public long getReservationId() {
        return reservationId;
    }

    public void setReservationId(long reservationId) {
        this.reservationId = reservationId;
    }

    public long getPremiereReservationId() {
        return premiereReservationId;
    }

    public void setPremiereReservationId(long premiereReservationId) {
        this.premiereReservationId = premiereReservationId;
    }

    public String getReservationClient() {
        return reservationClient;
    }

    public void setReservationClient(String reservationClient) {
        this.reservationClient = reservationClient;
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

    public double getDistanceEstimee() {
        return distanceEstimee;
    }

    public void setDistanceEstimee(double distanceEstimee) {
        this.distanceEstimee = distanceEstimee;
    }

    public String getDureeEstimee() {
        return dureeEstimee;
    }

    public void setDureeEstimee(String dureeEstimee) {
        this.dureeEstimee = dureeEstimee;
    }

    public String getPremierPointDepart() {
        return premierPointDepart;
    }

    public void setPremierPointDepart(String premierPointDepart) {
        this.premierPointDepart = premierPointDepart;
    }

    public String getDernierPointArrivee() {
        return dernierPointArrivee;
    }

    public void setDernierPointArrivee(String dernierPointArrivee) {
        this.dernierPointArrivee = dernierPointArrivee;
    }

    public String getPointsDepart() {
        return pointsDepart;
    }

    public void setPointsDepart(String pointsDepart) {
        this.pointsDepart = pointsDepart;
    }

    public String getPointsArrivee() {
        return pointsArrivee;
    }

    public void setPointsArrivee(String pointsArrivee) {
        this.pointsArrivee = pointsArrivee;
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

    //  SPRINT 4 : Getters et Setters pour groupement par temps d'attente
    
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
