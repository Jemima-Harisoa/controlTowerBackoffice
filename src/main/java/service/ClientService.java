package service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import model.Client;
import model.Sexe;
import model.TypeClient;
import repository.ClientRepository;

public class ClientService {
    private ClientRepository clientRepository = new ClientRepository();
    
    /**
     * Récupère un client par son ID
     * @param id ID du client
     * @return Client ou null si non trouvé
     */
    public Client getClientById(int id) {
        return clientRepository.findById(id);
    }

    /**
     * Récupère un client par denomination
     * @param denomination Nom du client
     * @return Client ou null si non trouvé
     */
    public Client getClientByDenomination(String denomination) {
        return clientRepository.findByDenomination(denomination);
    }
    
    /**
     * Récupère tous les clients
     * @return Liste des clients
     */
    public List<Client> getAllClients() {
        return clientRepository.findAll();
    }
    
    /**
     * Crée un nouveau client
     * @param client Client à créer
     * @return true si la création a réussi, false sinon
     */
    public boolean createClient(Client client) {
        return clientRepository.create(client) != null;
    }
    
    /**
     * Met à jour un client existant
     * @param client Client à mettre à jour
     * @return true si la mise à jour a réussi, false sinon
     */
    public boolean updateClient(Client client) {
        return clientRepository.update(client);
    }
    
    /**
     * Supprime un client
     * @param id ID du client à supprimer
     * @return true si la suppression a réussi, false sinon
     */
    public boolean deleteClient(int id) {
        return clientRepository.delete(id);
    }
    
    /**
     * Récupère tous les sexes
     * @return Liste des sexes
     */
    public List<Sexe> getAllSexes() {
        return clientRepository.findAllSexes();
    }
    
    /**
     * Récupère un sexe par son ID
     * @param id ID du sexe
     * @return Sexe ou null si non trouvé
     */
    public Sexe getSexeById(int id) {
        return clientRepository.findSexeById(id);
    }
    
    /**
     * Récupère tous les types de clients
     * @return Liste des types de clients
     */
    public List<TypeClient> getAllTypeClients() {
        return clientRepository.findAllTypeClients();
    }
    
    /**
     * Récupère un type de client par son ID
     * @param id ID du type de client
     * @return TypeClient ou null si non trouvé
     */
    public TypeClient getTypeClientById(int id) {
        return clientRepository.findTypeClientById(id);
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
