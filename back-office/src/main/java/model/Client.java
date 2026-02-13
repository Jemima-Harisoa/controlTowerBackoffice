package model;

public class Client {
    private int id;
    private String denomination;
    private Integer sexeId;      // Utiliser Integer pour gérer les null
    private Integer typeId;      // Utiliser Integer pour gérer les null
    
    // Constructeurs
    public Client() {}
    
    public Client(int id, String denomination, Integer sexeId, Integer typeId) {
        this.id = id;
        this.denomination = denomination;
        this.sexeId = sexeId;
        this.typeId = typeId;
    }
    
    // Getters et Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getDenomination() { return denomination; }
    public void setDenomination(String denomination) { this.denomination = denomination; }
    
    public Integer getSexeId() { return sexeId; }
    public void setSexeId(Integer sexeId) { this.sexeId = sexeId; }
    
    public Integer getTypeId() { return typeId; }
    public void setTypeId(Integer typeId) { this.typeId = typeId; }
}
