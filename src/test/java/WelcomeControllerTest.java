import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import org.junit.Test;

import controller.WelcomeController;
import framework.ModelAndView.ModelAndView;

/**
 * Test du WelcomeController
 * =========================
 * Vérifie que la méthode welcome() retourne bien un ModelAndView
 * avec les attributs attendus (totalHotels, totalReservations, pageTitle).
 * 
 * IMPORTANT : Ce test nécessite une connexion à la base de données PostgreSQL
 * pour fonctionner (les services font des requêtes SQL réelles).
 */
public class WelcomeControllerTest {

    @Test
    public void testWelcomeReturnsModelAndView() {
        WelcomeController controller = new WelcomeController();
        ModelAndView mav = controller.welcome();
        
        assertNotNull("ModelAndView ne doit pas être null", mav);
    }

    @Test
    public void testWelcomeHasCorrectView() {
        WelcomeController controller = new WelcomeController();
        ModelAndView mav = controller.welcome();
        
        assertEquals("La vue doit être /views/welcome.jsp", 
                     "/views/welcome.jsp", mav.getView());
    }

    @Test
    public void testWelcomeHasPageTitle() {
        WelcomeController controller = new WelcomeController();
        ModelAndView mav = controller.welcome();
        
        Object pageTitle = mav.getObject("pageTitle");
        assertNotNull("pageTitle ne doit pas être null", pageTitle);
        assertEquals("Tableau de Bord", pageTitle);
    }

    @Test
    public void testWelcomeHasTotalHotels() {
        WelcomeController controller = new WelcomeController();
        ModelAndView mav = controller.welcome();
        
        Object totalHotels = mav.getObject("totalHotels");
        assertNotNull("totalHotels ne doit pas être null", totalHotels);
        assertTrue("totalHotels doit être un Integer", totalHotels instanceof Integer);
        
        int value = (Integer) totalHotels;
        System.out.println(">>> totalHotels = " + value);
        assertTrue("totalHotels doit être >= 0", value >= 0);
    }

    @Test
    public void testWelcomeHasTotalReservations() {
        WelcomeController controller = new WelcomeController();
        ModelAndView mav = controller.welcome();
        
        Object totalReservations = mav.getObject("totalReservations");
        assertNotNull("totalReservations ne doit pas être null", totalReservations);
        assertTrue("totalReservations doit être un Integer", totalReservations instanceof Integer);
        
        int value = (Integer) totalReservations;
        System.out.println(">>> totalReservations = " + value);
        assertTrue("totalReservations doit être >= 0", value >= 0);
    }

    @Test
    public void testWelcomeModelContainsAllKeys() {
        WelcomeController controller = new WelcomeController();
        ModelAndView mav = controller.welcome();
        
        java.util.Map<String, Object> model = mav.getModel();
        assertNotNull("Le modèle ne doit pas être null", model);
        
        System.out.println(">>> Contenu du modèle : " + model);
        System.out.println(">>> Clés du modèle : " + model.keySet());
        
        assertTrue("Le modèle doit contenir 'pageTitle'", model.containsKey("pageTitle"));
        assertTrue("Le modèle doit contenir 'totalHotels'", model.containsKey("totalHotels"));
        assertTrue("Le modèle doit contenir 'totalReservations'", model.containsKey("totalReservations"));
    }
}
