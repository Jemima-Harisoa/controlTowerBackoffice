package controller;

import java.util.List;

import dto.ReservationView;
import framework.ModelAndView.ModelAndView;
import framework.annotation.Controller;
import framework.annotation.Get;
import framework.annotation.RequestParam;
import framework.annotation.Url;
import service.HotelService;
import service.ReservationService;
/**
 * Frontoffice - Pages de consultation publiques
 * ================================================
 * Pas de @AuthenticatedOnly : ces pages sont accessibles sans connexion.
 * 
 * Le frontoffice affiche les données côté serveur avec filtres GET.
 */
@Controller
public class FrontofficeController {

    private HotelService hotelService = new HotelService();
    private ReservationService reservationService = new ReservationService();
    /**
     * GET /frontoffice/reservations → Page de consultation des réservations
    * Affiche un tableau avec filtres (date, hôtel).
     */
    @Url("/frontoffice/reservations")
    @Get
    public ModelAndView showReservationsPage(@RequestParam(value = "date", required = false) String dateFilter,
                                           @RequestParam(value = "hotelId", required = false ) Integer hotelIdFilter) {

        ModelAndView mav = new ModelAndView("/views/frontoffice/liste-reservations.jsp");

        String normalizedDate = (dateFilter != null && !dateFilter.trim().isEmpty()) ? dateFilter.trim() : null;
        boolean hasDate = normalizedDate != null;
        boolean hasHotel = hotelIdFilter != null;

        List<ReservationView> reservationView;
        if (!hasDate && !hasHotel) {
            reservationView = reservationService.getAllReservationsForView();
        }
        else if (hasDate && hasHotel) {
            reservationView = reservationService.getReservationsForViewByDateAndHotel(normalizedDate, hotelIdFilter);
        }
        else if (hasDate) {
            reservationView = reservationService.getReservationsForViewByDate(normalizedDate);
        }
        else {
            reservationView = reservationService.getReservationsForViewByHotel(hotelIdFilter);
        }

        mav.addObject("pageTitle", "Consultation des R\u00e9servations");
        mav.addObject("reservations", reservationView);
        
        // Passer les hôtels pour le filtre dropdown
        try {
            mav.addObject("hotels", hotelService.getAllHotels());
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return mav;
    }
}
