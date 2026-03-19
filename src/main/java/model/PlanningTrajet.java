package model;

public class PlanningTrajet {
    private long id;
    private long reservationId;
    private Long vehiculeId;
    private Long lieuDepartId;
    private Long lieuArriveeId;
    private String datePlanification;
    private String dureeEstimee;
    private double distanceEstimee;
    private long statutId;
    private String statut;
    private String createdAt;
    private String updatedAt;

    // Relations
    private String vehiculeImmatriculation;
    private String vehiculeMarque;
    private String vehiculeModele;
    private String lieuDepart;
    private String lieuArrivee;

    // Constructeurs
    public PlanningTrajet() {}

    public PlanningTrajet(long reservationId, long statutId) {
        this.reservationId = reservationId;
        this.statutId = statutId;
    }

    // Getters et Setters
    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public long getReservationId() {
        return reservationId;
    }

    public void setReservationId(long reservationId) {
        this.reservationId = reservationId;
    }

    public Long getVehiculeId() {
        return vehiculeId;
    }

    public void setVehiculeId(Long vehiculeId) {
        this.vehiculeId = vehiculeId;
    }

    public Long getLieuDepartId() {
        return lieuDepartId;
    }

    public void setLieuDepartId(Long lieuDepartId) {
        this.lieuDepartId = lieuDepartId;
    }

    public Long getLieuArriveeId() {
        return lieuArriveeId;
    }

    public void setLieuArriveeId(Long lieuArriveeId) {
        this.lieuArriveeId = lieuArriveeId;
    }

    public String getDatePlanification() {
        return datePlanification;
    }

    public void setDatePlanification(String datePlanification) {
        this.datePlanification = datePlanification;
    }

    public String getDureeEstimee() {
        return dureeEstimee;
    }

    public void setDureeEstimee(String dureeEstimee) {
        this.dureeEstimee = dureeEstimee;
    }

    public double getDistanceEstimee() {
        return distanceEstimee;
    }

    public void setDistanceEstimee(double distanceEstimee) {
        this.distanceEstimee = distanceEstimee;
    }

    public long getStatutId() {
        return statutId;
    }

    public void setStatutId(long statutId) {
        this.statutId = statutId;
    }

    public String getStatut() {
        return statut;
    }

    public void setStatut(String statut) {
        this.statut = statut;
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

    public String getVehiculeImmatriculation() {
        return vehiculeImmatriculation;
    }

    public void setVehiculeImmatriculation(String vehiculeImmatriculation) {
        this.vehiculeImmatriculation = vehiculeImmatriculation;
    }

    public String getVehiculeMarque() {
        return vehiculeMarque;
    }

    public void setVehiculeMarque(String vehiculeMarque) {
        this.vehiculeMarque = vehiculeMarque;
    }

    public String getVehiculeModele() {
        return vehiculeModele;
    }

    public void setVehiculeModele(String vehiculeModele) {
        this.vehiculeModele = vehiculeModele;
    }

    public String getLieuDepart() {
        return lieuDepart;
    }

    public void setLieuDepart(String lieuDepart) {
        this.lieuDepart = lieuDepart;
    }

    public String getLieuArrivee() {
        return lieuArrivee;
    }

    public void setLieuArrivee(String lieuArrivee) {
        this.lieuArrivee = lieuArrivee;
    }
}
