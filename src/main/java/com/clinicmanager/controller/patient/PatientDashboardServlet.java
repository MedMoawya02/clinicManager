package com.clinicmanager.controller.patient;   // ⚠️ À ADAPTER selon ton dossier

import com.clinicmanager.dto.UserDTO;
import com.clinicmanager.model.Patient;
import com.clinicmanager.service.PatientService;
import com.clinicmanager.service.impl.PatientServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Optional;

@WebServlet("/patient/dashboard")
public class PatientDashboardServlet extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/patient/dashboard.jsp";
    private final PatientService patientService = new PatientServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        UserDTO current = (UserDTO) request.getSession().getAttribute("user");
        if (current == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Optional<Patient> p = patientService.findByUserId(current.id());

        if (p.isEmpty()) {
            response.sendError(404, "Aucun profil patient associé à ce compte.");
            return;
        }

        request.setAttribute("patient", p.get());
        request.getRequestDispatcher(VIEW).forward(request, response);
    }
}