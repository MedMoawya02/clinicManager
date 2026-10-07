package com.clinicmanager.controller.patient;

import com.clinicmanager.dto.UserDTO;
import com.clinicmanager.model.Genre;
import com.clinicmanager.model.GroupeSanguin;
import com.clinicmanager.model.Patient;
import com.clinicmanager.service.PatientService;
import com.clinicmanager.service.impl.PatientServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Optional;

@WebServlet("/patient/profile")
public class PatientProfileServlet extends HttpServlet {

    private final PatientService patientService = new PatientServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Object userAttr = session.getAttribute("user");
        if (!(userAttr instanceof UserDTO user)) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Optional<Patient> patientOpt = patientService.findByUserId(user.id());
        if (patientOpt.isEmpty()) {
            res.sendError(HttpServletResponse.SC_NOT_FOUND, "Patient introuvable");
            return;
        }

        req.setAttribute("patient", patientOpt.get());
        req.setAttribute("genres",  Genre.values());
        req.setAttribute("groupes", GroupeSanguin.values());
        req.setAttribute("email",   user.email());   // si l'email est dans UserDTO

        req.getRequestDispatcher("/WEB-INF/views/patient/profile.jsp")
                .forward(req, res);   // <-- NE PAS OUBLIER
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        // consultation seule → pas de POST, ou redirection vers /patient/edit
        res.sendRedirect(req.getContextPath() + "/patient/edit");
    }
}