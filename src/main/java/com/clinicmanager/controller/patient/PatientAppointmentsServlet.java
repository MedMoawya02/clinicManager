package com.clinicmanager.controller.patient;

import com.clinicmanager.dto.UserDTO;
import com.clinicmanager.model.Appointment;
import com.clinicmanager.model.Patient;
import com.clinicmanager.service.AppointmentService;
import com.clinicmanager.service.PatientService;
import com.clinicmanager.service.impl.AppointmentServiceImpl;
import com.clinicmanager.service.impl.PatientServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.Optional;

@WebServlet("/patient/appointments")
public class PatientAppointmentsServlet extends HttpServlet {

    private final AppointmentService appointmentService = new AppointmentServiceImpl();
    private final PatientService     patientService     = new PatientServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // 1. Vérifier la session
        HttpSession session = req.getSession(false);
        if (session == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // 2. Récupérer l'utilisateur connecté
        Object userAttr = session.getAttribute("user");
        if (!(userAttr instanceof UserDTO user)) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // 3. Retrouver le Patient lié à ce user
        Optional<Patient> patientOpt = patientService.findByUserId(user.id());
        if (patientOpt.isEmpty()) {
            res.sendError(HttpServletResponse.SC_NOT_FOUND, "Patient introuvable");
            return;
        }

        // 4. Charger la liste des rendez-vous du patient
        List<Appointment> appointments =
                appointmentService.findByPatient(patientOpt.get().getId());

        // 5. Passer au JSP
        req.setAttribute("appointments", appointments);

        req.getRequestDispatcher("/WEB-INF/views/patient/appointments.jsp")
                .forward(req, res);
    }
}