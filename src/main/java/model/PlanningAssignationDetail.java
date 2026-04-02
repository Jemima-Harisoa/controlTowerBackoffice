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
}
