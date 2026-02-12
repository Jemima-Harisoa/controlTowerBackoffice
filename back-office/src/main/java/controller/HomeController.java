package controller;

import framework.annotation.*;
import framework.ModelAndView.ModelAndView;
import jakarta.servlet.http.HttpServletRequest;

@Controller
public class HomeController {
    
    @Url("/")
    @Get
    public ModelAndView index(HttpServletRequest request) {
        Object user = request.getSession().getAttribute("user");
        if (user != null) {
            return new ModelAndView("redirect:/welcome");
        }
        return new ModelAndView("redirect:/login");
    }
}