package repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import model.Client;
import model.Sexe;
import model.TypeClient;
import util.DatabaseConnection;

/**
 * Repository pour l'acces donnees des clients.
 */
public class ClientRepository {
    private DatabaseConnection dbConnection = DatabaseConnection.getInstance();

    public Client findById(int id) {
        String query = "SELECT * FROM clients WHERE id = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapRowToClient(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public Client findByDenomination(String denomination) {
        String query = "SELECT * FROM clients WHERE denomination = ? ORDER BY id DESC LIMIT 1";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setString(1, denomination);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapRowToClient(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public List<Client> findAll() {
        List<Client> clients = new ArrayList<>();
        String query = "SELECT * FROM clients ORDER BY denomination";

        try (Connection conn = dbConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {

            while (rs.next()) {
                clients.add(mapRowToClient(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return clients;
    }

    public Client create(Client client) {
        String query = "INSERT INTO clients (denomination, sexe_id, type_id) VALUES (?, ?, ?)";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query, Statement.RETURN_GENERATED_KEYS)) {

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

            int affectedRows = stmt.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        client.setId(generatedKeys.getInt(1));
                    }
                }
                return client;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public boolean update(Client client) {
        String query = "UPDATE clients SET denomination = ?, sexe_id = ?, type_id = ? WHERE id = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

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

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean delete(int id) {
        String query = "DELETE FROM clients WHERE id = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public List<Sexe> findAllSexes() {
        List<Sexe> sexes = new ArrayList<>();
        String query = "SELECT * FROM sexes ORDER BY libelle";

        try (Connection conn = dbConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {

            while (rs.next()) {
                Sexe sexe = new Sexe();
                sexe.setId(rs.getInt("id"));
                sexe.setLibelle(rs.getString("libelle"));
                sexe.setDescription(rs.getString("description"));
                sexes.add(sexe);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return sexes;
    }

    public Sexe findSexeById(int id) {
        String query = "SELECT * FROM sexes WHERE id = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Sexe sexe = new Sexe();
                    sexe.setId(rs.getInt("id"));
                    sexe.setLibelle(rs.getString("libelle"));
                    sexe.setDescription(rs.getString("description"));
                    return sexe;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public List<TypeClient> findAllTypeClients() {
        List<TypeClient> typeClients = new ArrayList<>();
        String query = "SELECT * FROM type_clients ORDER BY libelle";

        try (Connection conn = dbConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {

            while (rs.next()) {
                TypeClient typeClient = new TypeClient();
                typeClient.setId(rs.getInt("id"));
                typeClient.setLibelle(rs.getString("libelle"));
                typeClient.setDescription(rs.getString("description"));
                typeClients.add(typeClient);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return typeClients;
    }

    public TypeClient findTypeClientById(int id) {
        String query = "SELECT * FROM type_clients WHERE id = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    TypeClient typeClient = new TypeClient();
                    typeClient.setId(rs.getInt("id"));
                    typeClient.setLibelle(rs.getString("libelle"));
                    typeClient.setDescription(rs.getString("description"));
                    return typeClient;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    private Client mapRowToClient(ResultSet rs) throws SQLException {
        Client client = new Client();
        client.setId(rs.getInt("id"));
        client.setDenomination(rs.getString("denomination"));
        client.setSexeId(rs.getObject("sexe_id", Integer.class));
        client.setTypeId(rs.getObject("type_id", Integer.class));
        return client;
    }
}
