package com.clinicmanager.web.admin;

import com.clinicmanager.dto.CreateUserRequest;
import com.clinicmanager.model.Genre;
import com.clinicmanager.model.GroupeSanguin;
import com.clinicmanager.model.Role;
import com.clinicmanager.service.UserService;
import com.clinicmanager.service.impl.UserServiceImplementation;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;

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

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        CreateUserRequest req = new CreateUserRequest();
        String error = null;

        try {
            // ─── Champs communs ───
            req.fullName = request.getParameter("fullName");
            req.email    = request.getParameter("email");
            req.password = request.getParameter("password");
            String confirm = request.getParameter("confirmPassword");
            req.active   = request.getParameter("active") != null;

            // ─── Rôle ───
            String roleParam = request.getParameter("role");
            try {
                req.role = Role.valueOf(roleParam);
            } catch (Exception e) {
                throw new IllegalArgumentException("Veuillez sélectionner un rôle valide.");
            }

            if (req.password != null && !req.password.equals(confirm)) {
                throw new IllegalArgumentException("Les mots de passe ne correspondent pas.");
            }

            // ─── Champs PATIENT ───
            if (req.role == Role.PATIENT) {
                req.cin       = request.getParameter("cin");
                req.nom       = request.getParameter("nom");
                req.prenom    = request.getParameter("prenom");
                req.adresse   = request.getParameter("adresse");
                req.telephone = request.getParameter("telephone");

                String dn = request.getParameter("dateNaissance");
                if (dn != null && !dn.isBlank()) req.dateNaissance = LocalDate.parse(dn);

                String g = request.getParameter("genre");
                if (g != null && !g.isBlank()) req.genre = Genre.valueOf(g);

                String gs = request.getParameter("groupeSanguin");
                if (gs != null && !gs.isBlank()) req.groupeSanguin = GroupeSanguin.valueOf(gs);
            }

            // ─── Champs DOCTOR ───
            if (req.role == Role.DOCTOR) {
                req.matricule   = request.getParameter("matricule");
                req.nom         = request.getParameter("nom");
                req.prenom      = request.getParameter("prenom");
                req.titre       = request.getParameter("titre");
                req.emailPro    = request.getParameter("emailPro");
                req.telephone   = request.getParameter("telephone");
                req.specialite  = request.getParameter("specialite");
                req.departement = request.getParameter("departement");
            }

            // ─── Création ───
            userService.createUser(req);

            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            return;

        } catch (IllegalArgumentException e) {
            error = e.getMessage();
        } catch (Exception e) {
            e.printStackTrace();
            error = "Erreur interne : " + e.getMessage();
        }

        // ─── Erreur → réafficher ───
        request.setAttribute("error",         error);
        request.setAttribute("roles",         Role.values());
        request.setAttribute("fullName",      req.fullName);
        request.setAttribute("email",         req.email);
        request.setAttribute("role",          req.role != null ? req.role.name() : "");
        request.setAttribute("active",        req.active);
        request.setAttribute("cin",           req.cin);
        request.setAttribute("nom",           req.nom);
        request.setAttribute("prenom",        req.prenom);
        request.setAttribute("dateNaissance", req.dateNaissance != null ? req.dateNaissance.toString() : "");
        request.setAttribute("adresse",       req.adresse);
        request.setAttribute("telephone",     req.telephone);
        //doctor
        request.setAttribute("matricule",     req.matricule);
        request.setAttribute("titre",         req.titre);
        request.setAttribute("emailPro",      req.emailPro);
        request.setAttribute("specialite",    req.specialite);
        request.setAttribute("departement",   req.departement);

        request.getRequestDispatcher(VIEW).forward(request, response);
    }}