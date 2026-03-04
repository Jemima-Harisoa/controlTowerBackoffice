package controller;

import java.util.List;

import dto.ReservationView;
import framework.annotation.Controller;
import framework.annotation.Get;
import framework.annotation.RequestParam;
import framework.annotation.RestAPI;
import framework.annotation.Url;
import framework.response.ApiResponse;
import model.Hotel;
import service.HotelService;
import service.ReservationService;

/**
 * API REST - Frontoffice Réservations
 * =====================================
 * Endpoints publics pour la consultation des réservations.
 * Pas de @AuthenticatedOnly : le frontoffice est accessible sans connexion.
 * 
 * @RestAPI : le framework sérialise automatiquement en JSON
 *            via FrameworkDispatcher.sendJsonResponse()
 * 
 * Endpoints :
 *   GET /api/reservations                              → toutes les réservations
 *   GET /api/reservations?date=YYYY-MM-DD              → filtre par date
 *   GET /api/reservations?hotelId=ID                   → filtre par hôtel
 *   GET /api/reservations?date=YYYY-MM-DD&hotelId=ID   → filtres combinés
 *   GET /api/hotels                                    → liste des hôtels (pour les filtres)
 */
@Controller
public class ReservationApiController {

    private ReservationService reservationService = new ReservationService();
    private HotelService hotelService = new HotelService();

    /**
     * GET /api/reservations → Retourne les réservations formatées (ReservationView)
     * Filtres optionnels : date, hotelId
     */
    @Url("/api/reservations")
    @Get
    @RestAPI
    public ApiResponse getReservations(
            @RequestParam(value = "date", required = false) String date,
            @RequestParam(value = "hotelId", required = false) String hotelId) {

        try {
            List<ReservationView> reservations;

            boolean hasDate = date != null && !date.trim().isEmpty();
            boolean hasHotel = hotelId != null && !hotelId.trim().isEmpty();

            if (hasDate && hasHotel) {
                // Filtres combinés : date + hôtel
                int hotelIdInt = Integer.parseInt(hotelId);
                reservations = reservationService.getReservationsForViewByDateAndHotel(date, hotelIdInt);
            } else if (hasDate) {
                // Filtre par date uniquement
                reservations = reservationService.getReservationsForViewByDate(date);
            } else if (hasHotel) {
                // Filtre par hôtel uniquement
                int hotelIdInt = Integer.parseInt(hotelId);
                reservations = reservationService.getReservationsForViewByHotel(hotelIdInt);
            } else {
                // Pas de filtre : toutes les réservations
                reservations = reservationService.getAllReservationsForView();
            }

            return ApiResponse.success(reservations);

        } catch (NumberFormatException e) {
            return ApiResponse.error(400, "hotelId doit être un entier valide");
        } catch (Exception e) {
            e.printStackTrace();
            return ApiResponse.error(500, "Erreur serveur : " + e.getMessage());
        }
    }

    /**
     * GET /api/hotels → Liste des hôtels disponibles (pour alimenter les filtres frontend)
     */
    @Url("/api/hotels")
    @Get
    @RestAPI
    public ApiResponse getHotels() {
        try {
            List<Hotel> hotels = hotelService.getAllHotels();
            return ApiResponse.success(hotels);
        } catch (Exception e) {
            e.printStackTrace();
            return ApiResponse.error(500, "Erreur serveur : " + e.getMessage());
        }
    }
}
