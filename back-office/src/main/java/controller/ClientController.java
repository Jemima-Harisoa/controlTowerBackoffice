package controller;

import framework.annotation.*;
import framework.ModelAndView.ModelAndView;
import model.Client;
import service.ClientService;
import java.util.List;

@Controller
public class ClientController {
    private ClientService clientService = new ClientService();

    @Url("/clients/list")
    @Get
    public ModelAndView listerClients() {
        ModelAndView mav = new ModelAndView("/WEB-INF/templates/main-template.jsp");
        mav.addObject("pageTitle", "Liste des Clients");
        mav.addObject("contentPage", "/views/client/liste-clients.jsp");
        mav.addObject("currentPage", "clients-list");
        mav.addObject("clients", clientService.getAllClients());
        
        // Ajout des maps pour l'affichage
        mav.addObject("sexeMap", clientService.getAllSexesAsMap());
        mav.addObject("typeClientMap", clientService.getAllTypeClientsAsMap());
        
        return mav;
    }

    @Url("/clients/create")
    @Get
    public ModelAndView afficherFormulaireClient() {
        ModelAndView mav = new ModelAndView("/WEB-INF/templates/main-template.jsp");
        mav.addObject("pageTitle", "Ajouter un Client");
        mav.addObject("contentPage", "/views/client/formulaire-client.jsp");
        mav.addObject("currentPage", "clients-create");
        
        // Données pour les dropdowns
        mav.addObject("sexes", clientService.getAllSexes());
        mav.addObject("typeClients", clientService.getAllTypeClients());
        
        return mav;
    }

    @Url("/clients/view")
    @Get
    public ModelAndView voirClient(@RequestParam("id") int id) {
        Client client = clientService.getClientById(id);
        ModelAndView mav = new ModelAndView("/WEB-INF/templates/main-template.jsp");
        mav.addObject("pageTitle", "Détails du Client");
        mav.addObject("contentPage", "/views/client/details-client.jsp");
        mav.addObject("currentPage", "clients-view");
        mav.addObject("client", client);
        
        // Données pour l'affichage
        mav.addObject("sexeMap", clientService.getAllSexesAsMap());
        mav.addObject("typeClientMap", clientService.getAllTypeClientsAsMap());
        
        return mav;
    }

    @Url("/clients/edit")
    @Get
    public ModelAndView editerClient(@RequestParam("id") int id) {
        Client client = clientService.getClientById(id);
        ModelAndView mav = new ModelAndView("/WEB-INF/templates/main-template.jsp");
        mav.addObject("pageTitle", "Modifier le Client");
        mav.addObject("contentPage", "/views/client/modification-client.jsp");
        mav.addObject("currentPage", "clients-edit");
        mav.addObject("client", client);
        
        // Données pour les dropdowns
        mav.addObject("sexes", clientService.getAllSexes());
        mav.addObject("typeClients", clientService.getAllTypeClients());
        
        return mav;
    }

    @Url("/clients/create")
    @Post
    public ModelAndView traiterFormulaireClient(
            @RequestParam("denomination") String denomination,
            @RequestParam(value = "sexeId", required = false) String sexeId,
            @RequestParam(value = "typeId", required = false) String typeId) {
        
        // Validation des données
        if (denomination == null || denomination.trim().isEmpty()) {
            ModelAndView mav = new ModelAndView("/WEB-INF/templates/main-template.jsp");
            mav.addObject("pageTitle", "Ajouter un Client");
            mav.addObject("contentPage", "/views/client/formulaire-client.jsp");
            mav.addObject("currentPage", "clients-create");
            mav.addObject("erreur", "La dénomination est obligatoire");
            
            // Réinitialisation des données pour le formulaire
            mav.addObject("sexes", clientService.getAllSexes());
            mav.addObject("typeClients", clientService.getAllTypeClients());
            mav.addObject("param", denomination);
            
            return mav;
        }
        
        // Création du client
        Client newClient = new Client();
        newClient.setDenomination(denomination.trim());
        if (sexeId != null && !sexeId.isEmpty()) {
            newClient.setSexeId(Integer.parseInt(sexeId));
        }
        if (typeId != null && !typeId.isEmpty()) {
            newClient.setTypeId(Integer.parseInt(typeId));
        }
        
        // Enregistrement en base de données
        boolean success = clientService.createClient(newClient);
        if (success) {
            ModelAndView mav = new ModelAndView("/WEB-INF/templates/main-template.jsp");
            mav.addObject("pageTitle", "Confirmation");
            mav.addObject("contentPage", "/views/client/confirmation-client.jsp");
            mav.addObject("currentPage", "clients-list");
            mav.addObject("message", "Le client a été enregistré avec succès");
            return mav;
        } else {
            ModelAndView mav = new ModelAndView("/WEB-INF/templates/main-template.jsp");
            mav.addObject("pageTitle", "Ajouter un Client");
            mav.addObject("contentPage", "/views/client/formulaire-client.jsp");
            mav.addObject("currentPage", "clients-create");
            mav.addObject("erreur", "Erreur lors de la création du client");
            
            // Réinitialisation des données pour le formulaire
            mav.addObject("sexes", clientService.getAllSexes());
            mav.addObject("typeClients", clientService.getAllTypeClients());
            
            return mav;
        }
    }

    @Url("/clients/edit")
    @Post
    public ModelAndView mettreAJourClient(
            @RequestParam("id") int id,
            @RequestParam("denomination") String denomination,
            @RequestParam(value = "sexeId", required = false) String sexeId,
            @RequestParam(value = "typeId", required = false) String typeId) {
        
        // Validation des données
        if (denomination == null || denomination.trim().isEmpty()) {
            ModelAndView mav = new ModelAndView("/WEB-INF/templates/main-template.jsp");
            mav.addObject("pageTitle", "Modifier le Client");
            mav.addObject("contentPage", "/views/client/modification-client.jsp");
            mav.addObject("currentPage", "clients-edit");
            mav.addObject("erreur", "La dénomination est obligatoire");
            
            // Réinitialisation des données
            Client existingClient = clientService.getClientById(id);
            mav.addObject("client", existingClient);
            mav.addObject("sexes", clientService.getAllSexes());
            mav.addObject("typeClients", clientService.getAllTypeClients());
            
            return mav;
        }
        
        // Mise à jour du client
        Client updatedClient = clientService.getClientById(id);
        updatedClient.setDenomination(denomination.trim());
        if (sexeId != null && !sexeId.isEmpty()) {
            updatedClient.setSexeId(Integer.parseInt(sexeId));
        } else {
            updatedClient.setSexeId(null);
        }
        if (typeId != null && !typeId.isEmpty()) {
            updatedClient.setTypeId(Integer.parseInt(typeId));
        } else {
            updatedClient.setTypeId(null);
        }
        
        // Enregistrement en base de données
        boolean success = clientService.updateClient(updatedClient);
        if (success) {
            ModelAndView mav = new ModelAndView("/WEB-INF/templates/main-template.jsp");
            mav.addObject("pageTitle", "Confirmation");
            mav.addObject("contentPage", "/views/client/confirmation-client.jsp");
            mav.addObject("currentPage", "clients-list");
            mav.addObject("message", "Le client a été mis à jour avec succès");
            return mav;
        } else {
            ModelAndView mav = new ModelAndView("/WEB-INF/templates/main-template.jsp");
            mav.addObject("pageTitle", "Modifier le Client");
            mav.addObject("contentPage", "/views/client/modification-client.jsp");
            mav.addObject("currentPage", "clients-edit");
            mav.addObject("erreur", "Erreur lors de la mise à jour du client");
            
            mav.addObject("client", updatedClient);
            mav.addObject("sexes", clientService.getAllSexes());
            mav.addObject("typeClients", clientService.getAllTypeClients());
            
            return mav;
        }
    }

    @Url("/clients/delete")
    @Post
    public ModelAndView supprimerClient(@RequestParam("id") int id) {
        boolean success = clientService.deleteClient(id);
        if (success) {
            ModelAndView mav = new ModelAndView("/WEB-INF/templates/main-template.jsp");
            mav.addObject("pageTitle", "Confirmation");
            mav.addObject("contentPage", "/views/client/confirmation-client.jsp");
            mav.addObject("currentPage", "clients-list");
            mav.addObject("message", "Le client a été supprimé avec succès");
            return mav;
        } else {
            ModelAndView mav = new ModelAndView("/WEB-INF/templates/main-template.jsp");
            mav.addObject("pageTitle", "Liste des Clients");
            mav.addObject("contentPage", "/views/client/liste-clients.jsp");
            mav.addObject("currentPage", "clients-list");
            mav.addObject("erreur", "Erreur lors de la suppression du client");
            mav.addObject("clients", clientService.getAllClients());
            
            // Ajout des maps pour l'affichage
            mav.addObject("sexeMap", clientService.getAllSexesAsMap());
            mav.addObject("typeClientMap", clientService.getAllTypeClientsAsMap());
            
            return mav;
        }
    }
}
