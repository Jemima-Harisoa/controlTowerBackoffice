package controller;

import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.regex.Pattern;

import framework.ModelAndView.ModelAndView;
import framework.annotation.AuthenticatedOnly;
import framework.annotation.Controller;
import framework.annotation.Get;
import framework.annotation.Post;
import framework.annotation.RequestParam;
import framework.annotation.Url;
import jakarta.servlet.http.HttpServletRequest;
import model.Client;
import model.Hotel;
import model.Reservation;
import service.ClientService;
import service.HotelService;
import service.ReservationService;

/**
 * CRUD Réservations
 * ===================
 * Toutes les méthodes utilisent ModelAndView("/views/...") :
 *   - Le chemin commence par "/" → résolution absolue depuis la racine webapp
 *   - FrontServlet.handleModelView() forward vers la JSP
 *   - Chaque JSP inclut header.jsp/footer.jsp au compile-time (pas de template)
 * 
 * @AuthenticatedOnly → le framework vérifie la session avant d'exécuter la méthode
 */
@Controller
public class ReservationController {
    private HotelService hotelService = new HotelService();
    private ReservationService reservationService = new ReservationService();
    private ClientService clientService = new ClientService();

    /**
     * Affiche le formulaire de création de réservation
     * @return ModelAndView avec le formulaire de réservation
     */
    @Url("/reservations/create")
    @Get
    @AuthenticatedOnly
    public ModelAndView showCreateReservationForm() {
        // Vue directe : la JSP inclut header/footer via <%@ include %>
        ModelAndView mav = new ModelAndView("/views/reservation/formulaire-reservation.jsp");
        mav.addObject("pageTitle", "Créer une Réservation");
        
        // Récupération de la liste des hôtels disponibles
        List<Hotel> hotels = hotelService.getAvailableHotels();
        mav.addObject("hotels", hotels);
        
        // Récupération des sexes et types de clients
        List<model.Sexe> sexes = clientService.getAllSexes();
        List<model.TypeClient> typeClients = clientService.getAllTypeClients();
        mav.addObject("sexes", sexes);
        mav.addObject("typeClients", typeClients);
        
        return mav;
    }

    /**
     * Traite la soumission du formulaire de création de réservation
     * @param nom Nom du client
     * @param email Email du client
     * @param dateArrivee Date d'arrivée
     * @param heure Heure d'arrivée
     * @param nombrePersonnes Nombre de personnes
     * @param hotelId ID de l'hôtel
     * @param sexeId ID du sexe (optionnel)
     * @param typeId ID du type de client (optionnel)
     * @param request Requête HTTP
     * @return ModelAndView avec redirection ou erreur
     */
    @Url("/reservations/create")
    @Post
    @AuthenticatedOnly
    public ModelAndView processCreateReservation(
            @RequestParam("nom") String nom,
            @RequestParam("email") String email,
            @RequestParam("dateArrivee") String dateArrivee,
            @RequestParam("heure") String heure,
            @RequestParam("nombrePersonnes") String nombrePersonnes,
            @RequestParam("hotelId") String hotelId,
            @RequestParam(value = "sexeId", required = false) String sexeId,
            @RequestParam(value = "typeId", required = false) String typeId,
            HttpServletRequest request) {
        
        // Validation des données
        List<String> erreurs = validateReservationData(nom, email, dateArrivee, heure, nombrePersonnes, hotelId);
        
        if (!erreurs.isEmpty()) {
            ModelAndView mav = new ModelAndView("/views/reservation/formulaire-reservation.jsp");
            mav.addObject("pageTitle", "Créer une Réservation");
            mav.addObject("erreurs", erreurs);
            
            // Réinitialisation des données pour le formulaire
            List<Hotel> hotels = hotelService.getAvailableHotels();
            List<model.Sexe> sexes = clientService.getAllSexes();
            List<model.TypeClient> typeClients = clientService.getAllTypeClients();
            mav.addObject("hotels", hotels);
            mav.addObject("sexes", sexes);
            mav.addObject("typeClients", typeClients);
            
            return mav;
        }
        
        try {
            // Conversion des données
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
            Date date = dateFormat.parse(dateArrivee);
            Timestamp dateArriveeTimestamp = new Timestamp(date.getTime());
            
            int nbPersonnes = Integer.parseInt(nombrePersonnes);
            int hotelIdInt = Integer.parseInt(hotelId);
            
            // Création du client
            Client client = new Client();
            client.setDenomination(nom);
            if (sexeId != null && !sexeId.isEmpty()) {
                client.setSexeId(Integer.parseInt(sexeId));
            }
            if (typeId != null && !typeId.isEmpty()) {
                client.setTypeId(Integer.parseInt(typeId));
            }
            
            // Création de la réservation
            Reservation reservation = new Reservation();
            reservation.setNom(nom);
            reservation.setEmail(email);
            reservation.setDateArrivee(dateArriveeTimestamp);
            reservation.setHeure(heure);
            reservation.setNombrePersonnes(nbPersonnes);
            reservation.setHotelId(hotelIdInt);
            
            // Insertion en base de données
            boolean success = reservationService.createReservationWithClient(reservation, client);
            
            if (success) {
                // Afficher la page de confirmation
                ModelAndView successMav = new ModelAndView("/views/reservation/confirmation-reservation.jsp");
                successMav.addObject("pageTitle", "Réservation Créée");
                successMav.addObject("message", "La réservation a été créée avec succès");
                return successMav;
            } else {
                ModelAndView mav = new ModelAndView("/views/reservation/formulaire-reservation.jsp");
                mav.addObject("pageTitle", "Créer une Réservation");
                mav.addObject("erreur", "Erreur lors de la création de la réservation");
                
                List<Hotel> hotels = hotelService.getAvailableHotels();
                List<model.Sexe> sexes = clientService.getAllSexes();
                List<model.TypeClient> typeClients = clientService.getAllTypeClients();
                mav.addObject("hotels", hotels);
                mav.addObject("sexes", sexes);
                mav.addObject("typeClients", typeClients);
                
                return mav;
            }
        } catch (ParseException e) {
            ModelAndView mav = new ModelAndView("/views/reservation/formulaire-reservation.jsp");
            mav.addObject("pageTitle", "Créer une Réservation");
            mav.addObject("erreur", "Format de date invalide");
            
            List<Hotel> hotels = hotelService.getAvailableHotels();
            List<model.Sexe> sexes = clientService.getAllSexes();
            List<model.TypeClient> typeClients = clientService.getAllTypeClients();
            mav.addObject("hotels", hotels);
            mav.addObject("sexes", sexes);
            mav.addObject("typeClients", typeClients);
            
            return mav;
        }
    }

    /**
     * Affiche la liste des réservations
     * @return ModelAndView avec la liste des réservations
     */
    @Url("/reservations")
    @Get
    @AuthenticatedOnly
    public ModelAndView listReservations() {
        // Vue directe, userName vient de la session (défini au login)
        ModelAndView mav = new ModelAndView("/views/reservation/liste-reservations.jsp");
        mav.addObject("pageTitle", "Liste des Réservations");
        mav.addObject("reservations", reservationService.getAllReservationsForView());
        return mav;
    }

    /**
     * Affiche les détails d'une réservation
     * @param id ID de la réservation
     * @return ModelAndView avec les détails de la réservation
     */
    @Url("/reservations/{id}")
    @Get
    @AuthenticatedOnly
    public ModelAndView showReservationDetails(@RequestParam("id") int id) {
        ModelAndView mav = new ModelAndView("/views/reservation/details-reservation.jsp");
        mav.addObject("pageTitle", "Détails de la Réservation");
        
        // Récupération de la réservation
        Reservation reservation = reservationService.getReservationById(id);
        
        if (reservation != null) {
            // Récupération de l'hôtel associé
            Hotel hotel = hotelService.getHotelById(reservation.getHotelId());
            mav.addObject("reservation", reservation);
            mav.addObject("hotel", hotel);
            
            // Récupération du client associé
            Client client = reservationService.getClientByReservationId(id);
            if (client != null) {
                mav.addObject("client", client);
                
                // Récupération du sexe et du type de client
                if (client.getSexeId() != null) {
                    model.Sexe sexe = clientService.getSexeById(client.getSexeId());
                    mav.addObject("sexe", sexe);
                }
                if (client.getTypeId() != null) {
                    model.TypeClient typeClient = clientService.getTypeClientById(client.getTypeId());
                    mav.addObject("typeClient", typeClient);
                }
            }
        } else {
            mav.addObject("erreur", "Réservation non trouvée");
        }
        
        return mav;
    }

    /**
     * Affiche le formulaire de modification de réservation
     * @param id ID de la réservation
     * @return ModelAndView avec le formulaire de modification
     */
    @Url("/reservations/{id}/edit")
    @Get
    @AuthenticatedOnly
    public ModelAndView showEditReservationForm(@RequestParam("id") int id) {
        ModelAndView mav = new ModelAndView("/views/reservation/modification-reservation.jsp");
        mav.addObject("pageTitle", "Modifier la Réservation");
        
        // Récupération de la réservation
        Reservation reservation = reservationService.getReservationById(id);
        
        if (reservation != null) {
            // Récupération de la liste des hôtels disponibles
            List<Hotel> hotels = hotelService.getAvailableHotels();
            mav.addObject("reservation", reservation);
            mav.addObject("hotels", hotels);
            
            // Récupération des sexes et types de clients
            List<model.Sexe> sexes = clientService.getAllSexes();
            List<model.TypeClient> typeClients = clientService.getAllTypeClients();
            mav.addObject("sexes", sexes);
            mav.addObject("typeClients", typeClients);
            
            // Récupération du client associé
            Client client = reservationService.getClientByReservationId(id);
            if (client != null) {
                mav.addObject("client", client);
            }
        } else {
            mav.addObject("erreur", "Réservation non trouvée");
        }
        
        return mav;
    }

    /**
     * Traite la soumission du formulaire de modification de réservation
     * @param id ID de la réservation
     * @param nom Nom du client
     * @param email Email du client
     * @param dateArrivee Date d'arrivée
     * @param heure Heure d'arrivée
     * @param nombrePersonnes Nombre de personnes
     * @param hotelId ID de l'hôtel
     * @param sexeId ID du sexe (optionnel)
     * @param typeId ID du type de client (optionnel)
     * @param request Requête HTTP
     * @return ModelAndView avec redirection ou erreur
     */
    @Url("/reservations/{id}/edit")
    @Post
    @AuthenticatedOnly
    public ModelAndView processEditReservation(
            @RequestParam("id") int id,
            @RequestParam("nom") String nom,
            @RequestParam("email") String email,
            @RequestParam("dateArrivee") String dateArrivee,
            @RequestParam("heure") String heure,
            @RequestParam("nombrePersonnes") String nombrePersonnes,
            @RequestParam("hotelId") String hotelId,
            @RequestParam(value = "sexeId", required = false) String sexeId,
            @RequestParam(value = "typeId", required = false) String typeId,
            HttpServletRequest request) {
        
        // Validation des données
        List<String> erreurs = validateReservationData(nom, email, dateArrivee, heure, nombrePersonnes, hotelId);
        
        if (!erreurs.isEmpty()) {
            ModelAndView mav = new ModelAndView("/views/reservation/modification-reservation.jsp");
            mav.addObject("pageTitle", "Modifier la Réservation");
            mav.addObject("erreurs", erreurs);
            
            // Récupération de la réservation existante
            Reservation existingReservation = reservationService.getReservationById(id);
            List<Hotel> hotels = hotelService.getAvailableHotels();
            List<model.Sexe> sexes = clientService.getAllSexes();
            List<model.TypeClient> typeClients = clientService.getAllTypeClients();
            mav.addObject("reservation", existingReservation);
            mav.addObject("hotels", hotels);
            mav.addObject("sexes", sexes);
            mav.addObject("typeClients", typeClients);
            
            return mav;
        }
        
        try {
            // Conversion des données
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
            Date date = dateFormat.parse(dateArrivee);
            Timestamp dateArriveeTimestamp = new Timestamp(date.getTime());
            
            int nbPersonnes = Integer.parseInt(nombrePersonnes);
            int hotelIdInt = Integer.parseInt(hotelId);
            
            // Mise à jour de la réservation
            Reservation reservation = reservationService.getReservationById(id);
            reservation.setNom(nom);
            reservation.setEmail(email);
            reservation.setDateArrivee(dateArriveeTimestamp);
            reservation.setHeure(heure);
            reservation.setNombrePersonnes(nbPersonnes);
            reservation.setHotelId(hotelIdInt);
            
            // Mise à jour du client
            Client client = reservationService.getClientByReservationId(id);
            if (client == null) {
                client = new Client();
                client.setDenomination(nom);
            }
            client.setDenomination(nom);
            if (sexeId != null && !sexeId.isEmpty()) {
                client.setSexeId(Integer.parseInt(sexeId));
            } else {
                client.setSexeId(null);
            }
            if (typeId != null && !typeId.isEmpty()) {
                client.setTypeId(Integer.parseInt(typeId));
            } else {
                client.setTypeId(null);
            }
            
            // Mise à jour en base de données
            boolean success = reservationService.updateReservationWithClient(reservation, client);
            
            if (success) {
                // Afficher la page de confirmation avec les détails de la réservation
                ModelAndView successMav = new ModelAndView("/views/reservation/confirmation-reservation.jsp");
                successMav.addObject("pageTitle", "Réservation Modifiée");
                successMav.addObject("message", "La réservation a été modifiée avec succès");
                successMav.addObject("reservation", reservation);
                
                // Récupération de l'hôtel pour affichage
                Hotel hotel = hotelService.getHotelById(reservation.getHotelId());
                successMav.addObject("hotel", hotel);
                
                return successMav;
            } else {
                ModelAndView mav = new ModelAndView("/views/reservation/modification-reservation.jsp");
                mav.addObject("pageTitle", "Modifier la Réservation");
                mav.addObject("erreur", "Erreur lors de la mise à jour de la réservation");
                
                List<Hotel> hotels = hotelService.getAvailableHotels();
                List<model.Sexe> sexes = clientService.getAllSexes();
                List<model.TypeClient> typeClients = clientService.getAllTypeClients();
                mav.addObject("reservation", reservation);
                mav.addObject("hotels", hotels);
                mav.addObject("sexes", sexes);
                mav.addObject("typeClients", typeClients);
                
                return mav;
            }
        } catch (ParseException e) {
            ModelAndView mav = new ModelAndView("/views/reservation/modification-reservation.jsp");
            mav.addObject("pageTitle", "Modifier la Réservation");
            mav.addObject("erreur", "Format de date invalide");
            
            Reservation reservation = reservationService.getReservationById(id);
            List<Hotel> hotels = hotelService.getAvailableHotels();
            List<model.Sexe> sexes = clientService.getAllSexes();
            List<model.TypeClient> typeClients = clientService.getAllTypeClients();
            mav.addObject("reservation", reservation);
            mav.addObject("hotels", hotels);
            mav.addObject("sexes", sexes);
            mav.addObject("typeClients", typeClients);
            
            return mav;
        }
    }

    /**
     * Supprime une réservation
     * @param id ID de la réservation
     * @param request Requête HTTP
     * @return ModelAndView avec redirection
     */
    @Url("/reservations/{id}/delete")
    @Post
    @AuthenticatedOnly
    public ModelAndView deleteReservation(
            @RequestParam("id") int id,
            HttpServletRequest request) {
        
        // Suppression de la réservation
        boolean success = reservationService.deleteReservation(id);
        
        // Afficher la page de confirmation
        ModelAndView mav = new ModelAndView("/views/reservation/confirmation-reservation.jsp");
        mav.addObject("pageTitle", "Réservation Supprimée");
        if (success) {
            mav.addObject("message", "La réservation a été supprimée avec succès");
        } else {
            mav.addObject("erreur", "Erreur lors de la suppression de la réservation");
        }
        return mav;
    }

    /**
     * Valide les données de réservation
     * @param nom Nom du client
     * @param email Email du client
     * @param dateArrivee Date d'arrivée
     * @param heure Heure d'arrivée
     * @param nombrePersonnes Nombre de personnes
     * @param hotelId ID de l'hôtel
     * @return Liste des erreurs de validation
     */
    private List<String> validateReservationData(String nom, String email, String dateArrivee, 
                                                String heure, String nombrePersonnes, String hotelId) {
        List<String> erreurs = new ArrayList<>();
        
        // Validation du nom
        if (nom == null || nom.trim().isEmpty()) {
            erreurs.add("Le nom est obligatoire");
        }
        
        // Validation de l'email
        if (email == null || email.trim().isEmpty()) {
            erreurs.add("L'email est obligatoire");
        } else {
            String emailRegex = "^[a-zA-Z0-9_+&*-]+(?:\\.[a-zA-Z0-9_+&*-]+)*@(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,7}$";
            Pattern pattern = Pattern.compile(emailRegex);
            if (!pattern.matcher(email).matches()) {
                erreurs.add("L'email n'est pas valide");
            }
        }
        
        // Validation de la date d'arrivée
        if (dateArrivee == null || dateArrivee.trim().isEmpty()) {
            erreurs.add("La date d'arrivée est obligatoire");
        } else {
            try {
                SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
                Date date = dateFormat.parse(dateArrivee);
                Date today = new Date();
                
                if (date.before(today)) {
                    erreurs.add("La date d'arrivée doit être future");
                }
            } catch (ParseException e) {
                erreurs.add("Le format de la date d'arrivée est invalide");
            }
        }
        
        // Validation de l'heure
        if (heure == null || heure.trim().isEmpty()) {
            erreurs.add("L'heure est obligatoire");
        } else {
            String heureRegex = "^([01]?[0-9]|2[0-3]):[0-5][0-9]$";
            Pattern pattern = Pattern.compile(heureRegex);
            if (!pattern.matcher(heure).matches()) {
                erreurs.add("L'heure n'est pas valide (format HH:MM)");
            }
        }
        
        // Validation du nombre de personnes
        if (nombrePersonnes == null || nombrePersonnes.trim().isEmpty()) {
            erreurs.add("Le nombre de personnes est obligatoire");
        } else {
            try {
                int nb = Integer.parseInt(nombrePersonnes);
                if (nb <= 0) {
                    erreurs.add("Le nombre de personnes doit être supérieur à 0");
                }
            } catch (NumberFormatException e) {
                erreurs.add("Le nombre de personnes doit être un entier");
            }
        }
        
        // Validation de l'hôtel
        if (hotelId == null || hotelId.trim().isEmpty()) {
            erreurs.add("L'hôtel est obligatoire");
        } else {
            try {
                int id = Integer.parseInt(hotelId);
                Hotel hotel = hotelService.getHotelById(id);
                if (hotel == null) {
                    erreurs.add("L'hôtel sélectionné n'est pas valide");
                }
            } catch (NumberFormatException e) {
                erreurs.add("L'identifiant de l'hôtel doit être un entier");
            }
        }
        
        return erreurs;
    }
}
