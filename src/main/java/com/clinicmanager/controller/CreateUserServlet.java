package com.clinicmanager.web.admin;

import com.clinicmanager.model.Role;
import com.clinicmanager.service.UserService;
import com.clinicmanager.service.impl.UserServiceImplementation;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/create-user")
public class CreateUserServlet extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/admin/create-user.jsp";

    private final UserService userService = new UserServiceImplementation();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Auth check (if not already handled by a filter)
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        request.setAttribute("roles", Role.values());

//        request.getRequestDispatcher("/WEB-INF/views/admin/create-user.jsp")
//                .forward(request, response);

        // Forward to the JSP form
        request.getRequestDispatcher("/WEB-INF/views/admin/create-user.jsp")
                .forward(request, response);
    }

    protected void doPost(HttpServletRequest request,HttpServletResponse response)throws ServletException,IOException{
        // Auth check (comme doGet)
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        // 1️⃣ Encodage (accents français)
        request.setCharacterEncoding("UTF-8");
        String fullName  = request.getParameter("fullName");
        String email     = request.getParameter("email");
        String password  = request.getParameter("password");
        String confirm   = request.getParameter("confirmPassword");
        String roleParam = request.getParameter("role");
        boolean active   = request.getParameter("active") != null;
        String error = null;
        Role role = null;

        if (fullName == null || fullName.isBlank())         error = "Le nom complet est obligatoire.";
        else if (email == null || email.isBlank())          error = "L'adresse e-mail est obligatoire.";
        else if (password == null || password.length() < 8) error = "Mot de passe : 8 caractères minimum.";
        else if (!password.equals(confirm))                 error = "Les mots de passe ne correspondent pas.";

        if (error == null) {
            try { role = Role.valueOf(roleParam); }
            catch (IllegalArgumentException | NullPointerException e) {
                error = "Veuillez sélectionner un rôle valide.";
            }
        }
        if(error==null){
            try {
                userService.createUser(fullName,email,password,role,active);
                response.sendRedirect(request.getContextPath()+"/admin/dashboard");
                return;
            }catch (IllegalArgumentException e){
                error=e.getMessage();
            }catch (Exception e){
                e.printStackTrace();
                error = "Erreur interne. Veuillez réessayer.";
            }
        }
        // 5️⃣ Erreur → on réaffiche le formulaire avec les valeurs saisies
        request.setAttribute("error",    error);
        request.setAttribute("fullName", fullName);
        request.setAttribute("email",    email);
        request.setAttribute("role",     roleParam);
        request.setAttribute("active",   active);
        request.setAttribute("roles",    Role.values());
        request.getRequestDispatcher(VIEW).forward(request, response);

    }
}