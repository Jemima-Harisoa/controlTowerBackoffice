package dto;

import java.util.List;

/**
 * DTO pour afficher un groupe de reservations assignees
 * au meme vehicule pour un meme creneau (date + heure).
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
}
