package controller;

import framework.annotation.*;
import framework.ModelAndView.ModelAndView;
import model.Hotel;
import service.HotelService;
@Controller
public class HotelController {
    private HotelService hotelService = new HotelService();

    @Url("/hotels/list")
    @Get
    public ModelAndView listerHotels() {
        ModelAndView mav = new ModelAndView("/WEB-INF/templates/main-template.jsp");
        mav.addObject("pageTitle", "Liste des Hôtels");
        mav.addObject("contentPage", "/views/hotel/liste-hotels.jsp");
        mav.addObject("currentPage", "hotels-list");
        mav.addObject("hotels", hotelService.getAvailableHotels());
        return mav;
    }

    @Url("/hotels/create")
    @Get
    public ModelAndView afficherFormulaireHotel() {
        ModelAndView mav = new ModelAndView("/WEB-INF/templates/main-template.jsp");
        mav.addObject("pageTitle", "Ajouter un Hôtel");
        mav.addObject("contentPage", "/views/hotel/formulaire-hotel.jsp");
        mav.addObject("currentPage", "hotels-create");
        return mav;
    }

    @Url("/hotels/view")
    @Get
    public ModelAndView voirHotel(@RequestParam("id") int id) {
        Hotel hotel = hotelService.getHotelById(id);
        ModelAndView mav = new ModelAndView("/WEB-INF/templates/main-template.jsp");
        mav.addObject("pageTitle", "Détails de l'Hôtel");
        mav.addObject("contentPage", "/views/hotel/details-hotel.jsp");
        mav.addObject("currentPage", "hotels-view");
        mav.addObject("hotel", hotel);
        return mav;
    }

    @Url("/hotels/edit")
    @Get
    public ModelAndView editerHotel(@RequestParam("id") int id) {
        Hotel hotel = hotelService.getHotelById(id);
        ModelAndView mav = new ModelAndView("/WEB-INF/templates/main-template.jsp");
        mav.addObject("pageTitle", "Modifier l'Hôtel");
        mav.addObject("contentPage", "/views/hotel/edition-hotel.jsp");
        mav.addObject("currentPage", "hotels-edit");
        mav.addObject("hotel", hotel);
        return mav;
    }

    @Url("/hotels/create")
    @Post
    public ModelAndView traiterFormulaireHotel(
            @RequestParam("nom") String nom,
            @RequestParam("adresse") String adresse,
            @RequestParam("ville") String ville,
            @RequestParam("pays") String pays,
            @RequestParam("etoiles") int etoiles,
            @RequestParam("description") String description) {
        
        // Validation des données
        if (nom == null || nom.isEmpty() || 
            adresse == null || adresse.isEmpty() || 
            ville == null || ville.isEmpty() || 
            pays == null || pays.isEmpty() || 
            etoiles < 1 || etoiles > 5) {
            
            ModelAndView mav = new ModelAndView("/WEB-INF/templates/main-template.jsp");
            mav.addObject("pageTitle", "Ajouter un Hôtel");
            mav.addObject("contentPage", "/views/hotel/formulaire-hotel.jsp");
            mav.addObject("currentPage", "hotels-create");
            mav.addObject("erreur", "Veuillez remplir correctement tous les champs obligatoires");
            return mav;
        }
        
        // Création de l'hôtel
        Hotel newHotel = new Hotel();
        newHotel.setNom(nom);
        newHotel.setAdresse(adresse);
        newHotel.setVille(ville);
        newHotel.setPays(pays);
        newHotel.setNombreEtoiles(etoiles);
        newHotel.setDescription(description);
        
        // Enregistrement en base de données
        boolean success = hotelService.createHotel(newHotel);
        if (success) {
            ModelAndView mav = new ModelAndView("/WEB-INF/templates/main-template.jsp");
            mav.addObject("pageTitle", "Confirmation");
            mav.addObject("contentPage", "/views/hotel/confirmation-hotel.jsp");
            mav.addObject("currentPage", "hotels-list");
            mav.addObject("message", "L'hôtel a été enregistré avec succès dans la base de données");
            return mav;
        } else {
            ModelAndView mav = new ModelAndView("/WEB-INF/templates/main-template.jsp");
            mav.addObject("pageTitle", "Ajouter un Hôtel");
            mav.addObject("contentPage", "/views/hotel/formulaire-hotel.jsp");
            mav.addObject("currentPage", "hotels-create");
            mav.addObject("erreur", "Erreur lors de la création de l'hôtel");
            return mav;
        }
    }

    @Url("/hotels/edit")
    @Post
    public ModelAndView mettreAJourHotel(
            @RequestParam("id") int id,
            @RequestParam("nom") String nom,
            @RequestParam("adresse") String adresse,
            @RequestParam("ville") String ville,
            @RequestParam("pays") String pays,
            @RequestParam("etoiles") int etoiles,
            @RequestParam("description") String description) {
        
        // Validation des données
        if (nom == null || nom.isEmpty() || 
            adresse == null || adresse.isEmpty() || 
            ville == null || ville.isEmpty() || 
            pays == null || pays.isEmpty() || 
            etoiles < 1 || etoiles > 5) {
            
            Hotel existingHotel = hotelService.getHotelById(id);
            ModelAndView mav = new ModelAndView("/WEB-INF/templates/main-template.jsp");
            mav.addObject("pageTitle", "Modifier l'Hôtel");
            mav.addObject("contentPage", "/views/hotel/edition-hotel.jsp");
            mav.addObject("currentPage", "hotels-edit");
            mav.addObject("hotel", existingHotel);
            mav.addObject("erreur", "Veuillez remplir correctement tous les champs obligatoires");
            return mav;
        }
        
        // Mise à jour de l'hôtel
        Hotel updatedHotel = new Hotel();
        updatedHotel.setId(id);
        updatedHotel.setNom(nom);
        updatedHotel.setAdresse(adresse);
        updatedHotel.setVille(ville);
        updatedHotel.setPays(pays);
        updatedHotel.setNombreEtoiles(etoiles);
        updatedHotel.setDescription(description);
        
        // Enregistrement en base de données
        boolean success = hotelService.updateHotel(updatedHotel);
        if (success) {
            ModelAndView mav = new ModelAndView("/WEB-INF/templates/main-template.jsp");
            mav.addObject("pageTitle", "Confirmation");
            mav.addObject("contentPage", "/views/hotel/confirmation-hotel.jsp");
            mav.addObject("currentPage", "hotels-list");
            mav.addObject("message", "L'hôtel a été mis à jour avec succès");
            return mav;
        } else {
            ModelAndView mav = new ModelAndView("/WEB-INF/templates/main-template.jsp");
            mav.addObject("pageTitle", "Modifier l'Hôtel");
            mav.addObject("contentPage", "/views/hotel/edition-hotel.jsp");
            mav.addObject("currentPage", "hotels-edit");
            mav.addObject("erreur", "Erreur lors de la mise à jour de l'hôtel");
            return mav;
        }
    }

    @Url("/hotels/delete")
    @Post
    public ModelAndView supprimerHotel(@RequestParam("id") int id) {
        boolean success = hotelService.deleteHotel(id);
        if (success) {
            ModelAndView mav = new ModelAndView("/WEB-INF/templates/main-template.jsp");
            mav.addObject("pageTitle", "Confirmation");
            mav.addObject("contentPage", "/views/hotel/confirmation-hotel.jsp");
            mav.addObject("currentPage", "hotels-list");
            mav.addObject("message", "L'hôtel a été supprimé avec succès");
            return mav;
        } else {
            ModelAndView mav = new ModelAndView("/WEB-INF/templates/main-template.jsp");
            mav.addObject("pageTitle", "Liste des Hôtels");
            mav.addObject("contentPage", "/views/hotel/liste-hotels.jsp");
            mav.addObject("currentPage", "hotels-list");
            mav.addObject("erreur", "Erreur lors de la suppression de l'hôtel");
            mav.addObject("hotels", hotelService.getAvailableHotels());
            return mav;
        }
    }
}
