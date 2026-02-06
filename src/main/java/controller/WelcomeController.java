package controller;

import framework.annotation.Controller;
import framework.annotation.Get;
import framework.annotation.Url;

/**
 *  Controller for the welcome page for test
 */
@Controller
public class WelcomeController {
    
    /**
     * 
     */
    @Get 
    @Url("/welcome")
    public String welcomePage() {
        return "views/welcome.jsp";
    }
    
}
