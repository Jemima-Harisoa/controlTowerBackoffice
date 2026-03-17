package dto;

/**
 * DTO - Vue formatée d'un planning de trajet pour le frontend
 */
public class PlanningTrajetView {
    private long id;
    private long reservationId;
    private long vehiculeId;
    private String vehiculeImmatriculation;
    private String lieuDepart;
    private String lieuArrivee;
    private String dateArrivee;
    private String dateArriveeIso;
    private String heureArrivee;
    private String nomClient;
    private int nombrePersonnes;
    private double distance;
    private String dureeEstimee;
    private String statut;
    private String typeCarburantVehicule;
    private int capaciteVehicule;

    public PlanningTrajetView() {}

    public PlanningTrajetView(long id, long reservationId, long vehiculeId, String vehiculeImmatriculation,
                             String lieuDepart, String lieuArrivee, String dateArrivee, String dateArriveeIso,
                             String heureArrivee, String nomClient, int nombrePersonnes,
                             double distance, String dureeEstimee, String statut,
                             String typeCarburantVehicule, int capaciteVehicule) {
        this.id = id;
        this.reservationId = reservationId;
        this.vehiculeId = vehiculeId;
        this.vehiculeImmatriculation = vehiculeImmatriculation;
        this.lieuDepart = lieuDepart;
        this.lieuArrivee = lieuArrivee;
        this.dateArrivee = dateArrivee;
        this.dateArriveeIso = dateArriveeIso;
        this.heureArrivee = heureArrivee;
        this.nomClient = nomClient;
        this.nombrePersonnes = nombrePersonnes;
        this.distance = distance;
        this.dureeEstimee = dureeEstimee;
        this.statut = statut;
        this.typeCarburantVehicule = typeCarburantVehicule;
        this.capaciteVehicule = capaciteVehicule;
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

    public String getNomClient() {
        return nomClient;
    }

    public void setNomClient(String nomClient) {
        this.nomClient = nomClient;
    }

    public int getNombrePersonnes() {
        return nombrePersonnes;
    }

    public void setNombrePersonnes(int nombrePersonnes) {
        this.nombrePersonnes = nombrePersonnes;
    }

    public double getDistance() {
        return distance;
    }

    public void setDistance(double distance) {
        this.distance = distance;
    }

    public String getDureeEstimee() {
        return dureeEstimee;
    }

    public void setDureeEstimee(String dureeEstimee) {
        this.dureeEstimee = dureeEstimee;
    }

    public String getStatut() {
        return statut;
    }

    public void setStatut(String statut) {
        this.statut = statut;
    }

    public String getTypeCarburantVehicule() {
        return typeCarburantVehicule;
    }

    public void setTypeCarburantVehicule(String typeCarburantVehicule) {
        this.typeCarburantVehicule = typeCarburantVehicule;
    }

    public int getCapaciteVehicule() {
        return capaciteVehicule;
    }

    public void setCapaciteVehicule(int capaciteVehicule) {
        this.capaciteVehicule = capaciteVehicule;
    }
}
