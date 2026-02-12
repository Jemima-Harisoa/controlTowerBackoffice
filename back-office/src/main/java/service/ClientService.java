package service;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import util.DatabaseConnection;
import model.Client;
import model.Sexe;
import model.TypeClient;

public class ClientService {
    private DatabaseConnection dbConnection = DatabaseConnection.getInstance();
    
    /**
     * Récupère un client par son ID
     * @param id ID du client
     * @return Client ou null si non trouvé
     */
    public Client getClientById(int id) {
        try {
            Connection conn = dbConnection.getConnection();
            
            String query = "SELECT * FROM clients WHERE id = ?";
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setInt(1, id);
            
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                Client client = new Client();
                client.setId(rs.getInt("id"));
                client.setDenomination(rs.getString("denomination"));
                client.setSexeId(rs.getObject("sexe_id", Integer.class));  // Gestion des null
                client.setTypeId(rs.getObject("type_id", Integer.class));  // Gestion des null
                
                rs.close();
                stmt.close();
                conn.close();
                
                return client;
            }
            
            rs.close();
            stmt.close();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Récupère tous les clients
     * @return Liste des clients
     */
    public List<Client> getAllClients() {
        List<Client> clients = new ArrayList<>();
        try {
            Connection conn = dbConnection.getConnection();
            
            String query = "SELECT * FROM clients ORDER BY denomination";
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(query);
            
            while (rs.next()) {
                Client client = new Client();
                client.setId(rs.getInt("id"));
                client.setDenomination(rs.getString("denomination"));
                client.setSexeId(rs.getObject("sexe_id", Integer.class));  // Gestion des null
                client.setTypeId(rs.getObject("type_id", Integer.class));  // Gestion des null
                clients.add(client);
            }
            
            rs.close();
            stmt.close();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return clients;
    }
    
    /**
     * Crée un nouveau client
     * @param client Client à créer
     * @return true si la création a réussi, false sinon
     */
    public boolean createClient(Client client) {
        try {
            Connection conn = dbConnection.getConnection();
            
            String query = "INSERT INTO clients (denomination, sexe_id, type_id) VALUES (?, ?, ?)";
            PreparedStatement stmt = conn.prepareStatement(query, Statement.RETURN_GENERATED_KEYS);
            
            stmt.setString(1, client.getDenomination());
            if (client.getSexeId() != null) {
                stmt.setInt(2, client.getSexeId());
            } else {
                stmt.setNull(2, java.sql.Types.INTEGER);
            }
            if (client.getTypeId() != null) {
                stmt.setInt(3, client.getTypeId());
            } else {
                stmt.setNull(3, java.sql.Types.INTEGER);
            }
            
            int result = stmt.executeUpdate();
            
            // Récupérer l'ID généré
            if (result > 0) {
                ResultSet generatedKeys = stmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    client.setId(generatedKeys.getInt(1));
                }
                generatedKeys.close();
            }
            
            stmt.close();
            conn.close();
            
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Met à jour un client existant
     * @param client Client à mettre à jour
     * @return true si la mise à jour a réussi, false sinon
     */
    public boolean updateClient(Client client) {
        try {
            Connection conn = dbConnection.getConnection();
            
            String query = "UPDATE clients SET denomination = ?, sexe_id = ?, type_id = ? WHERE id = ?";
            PreparedStatement stmt = conn.prepareStatement(query);
            
            stmt.setString(1, client.getDenomination());
            if (client.getSexeId() != null) {
                stmt.setInt(2, client.getSexeId());
            } else {
                stmt.setNull(2, java.sql.Types.INTEGER);
            }
            if (client.getTypeId() != null) {
                stmt.setInt(3, client.getTypeId());
            } else {
                stmt.setNull(3, java.sql.Types.INTEGER);
            }
            stmt.setInt(4, client.getId());
            
            int result = stmt.executeUpdate();
            
            stmt.close();
            conn.close();
            
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Supprime un client
     * @param id ID du client à supprimer
     * @return true si la suppression a réussi, false sinon
     */
    public boolean deleteClient(int id) {
        try {
            Connection conn = dbConnection.getConnection();
            
            String query = "DELETE FROM clients WHERE id = ?";
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setInt(1, id);
            
            int result = stmt.executeUpdate();
            
            stmt.close();
            conn.close();
            
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Récupère tous les sexes
     * @return Liste des sexes
     */
    public List<Sexe> getAllSexes() {
        List<Sexe> sexes = new ArrayList<>();
        try {
            Connection conn = dbConnection.getConnection();
            
            String query = "SELECT * FROM sexes ORDER BY libelle";
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(query);
            
            while (rs.next()) {
                Sexe sexe = new Sexe();
                sexe.setId(rs.getInt("id"));
                sexe.setLibelle(rs.getString("libelle"));
                sexe.setDescription(rs.getString("description"));
                sexes.add(sexe);
            }
            
            rs.close();
            stmt.close();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return sexes;
    }
    
    /**
     * Récupère un sexe par son ID
     * @param id ID du sexe
     * @return Sexe ou null si non trouvé
     */
    public Sexe getSexeById(int id) {
        try {
            Connection conn = dbConnection.getConnection();
            
            String query = "SELECT * FROM sexes WHERE id = ?";
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setInt(1, id);
            
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                Sexe sexe = new Sexe();
                sexe.setId(rs.getInt("id"));
                sexe.setLibelle(rs.getString("libelle"));
                sexe.setDescription(rs.getString("description"));
                
                rs.close();
                stmt.close();
                conn.close();
                
                return sexe;
            }
            
            rs.close();
            stmt.close();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Récupère tous les types de clients
     * @return Liste des types de clients
     */
    public List<TypeClient> getAllTypeClients() {
        List<TypeClient> typeClients = new ArrayList<>();
        try {
            Connection conn = dbConnection.getConnection();
            
            String query = "SELECT * FROM type_clients ORDER BY libelle";
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(query);
            
            while (rs.next()) {
                TypeClient typeClient = new TypeClient();
                typeClient.setId(rs.getInt("id"));
                typeClient.setLibelle(rs.getString("libelle"));
                typeClient.setDescription(rs.getString("description"));
                typeClients.add(typeClient);
            }
            
            rs.close();
            stmt.close();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return typeClients;
    }
    
    /**
     * Récupère un type de client par son ID
     * @param id ID du type de client
     * @return TypeClient ou null si non trouvé
     */
    public TypeClient getTypeClientById(int id) {
        try {
            Connection conn = dbConnection.getConnection();
            
            String query = "SELECT * FROM type_clients WHERE id = ?";
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setInt(1, id);
            
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                TypeClient typeClient = new TypeClient();
                typeClient.setId(rs.getInt("id"));
                typeClient.setLibelle(rs.getString("libelle"));
                typeClient.setDescription(rs.getString("description"));
                
                rs.close();
                stmt.close();
                conn.close();
                
                return typeClient;
            }
            
            rs.close();
            stmt.close();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Récupère tous les sexes sous forme de Map (ID -> Sexe)
     * @return Map des sexes
     */
    public Map<Integer, Sexe> getAllSexesAsMap() {
        Map<Integer, Sexe> sexeMap = new HashMap<>();
        List<Sexe> sexes = getAllSexes();
        for (Sexe sexe : sexes) {
            sexeMap.put(sexe.getId(), sexe);
        }
        return sexeMap;
    }
    
    /**
     * Récupère tous les types de clients sous forme de Map (ID -> TypeClient)
     * @return Map des types de clients
     */
    public Map<Integer, TypeClient> getAllTypeClientsAsMap() {
        Map<Integer, TypeClient> typeClientMap = new HashMap<>();
        List<TypeClient> typeClients = getAllTypeClients();
        for (TypeClient typeClient : typeClients) {
            typeClientMap.put(typeClient.getId(), typeClient);
        }
        return typeClientMap;
    }
}
