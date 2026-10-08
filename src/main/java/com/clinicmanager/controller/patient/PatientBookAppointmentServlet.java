package com.clinicmanager.controller.patient;

import com.clinicmanager.dto.UserDTO;
import com.clinicmanager.model.AppointmentType;
import com.clinicmanager.model.Doctor;
import com.clinicmanager.model.Patient;
import com.clinicmanager.service.AppointmentService;
import com.clinicmanager.service.DoctorService;
import com.clinicmanager.service.PatientService;
import com.clinicmanager.service.impl.AppointmentServiceImpl;
import com.clinicmanager.service.impl.DoctorServiceImpl;
import com.clinicmanager.service.impl.PatientServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.Optional;

@WebServlet("/patient/book-appointment")
public class PatientBookAppointmentServlet extends HttpServlet {
    private final AppointmentService appointmentService = new AppointmentServiceImpl();
    private final PatientService patientService     = new PatientServiceImpl();
    private final DoctorService doctorService      = new DoctorServiceImpl();
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)throws ServletException, IOException{
        HttpSession session=req.getSession(false);
        if(session==null){
            res.sendRedirect(req.getContextPath()+"/login");
            return;
        }
        Object userAttr=session.getAttribute("user");
        if(!(userAttr instanceof UserDTO user)){
            res.sendRedirect(req.getContextPath()+"/login");
            return;
        }
        Optional<Patient> patientOpt=patientService.findByUserId(user.id());
        if(patientOpt.isEmpty()){
            res.sendError(HttpServletResponse.SC_NOT_FOUND, "Patient introuvable");
            return;
        }
        List<Doctor> doctors=doctorService.findAll();
        req.setAttribute("doctors", doctors);
        req.setAttribute("types", AppointmentType.values());

        req.getRequestDispatcher("/WEB-INF/views/patient/book-appointment.jsp")
                .forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req,HttpServletResponse res)throws ServletException, IOException{
        HttpSession session=req.getSession(false);
        if(session==null){
            res.sendRedirect(req.getContextPath()+"/login");
            return;
        }

        Object userAttr=session.getAttribute("user");
        if(!(userAttr instanceof UserDTO user)){
            res.sendRedirect(req.getContextPath()+"/login");
            return;
        }

        Optional<Patient> patientOpt=patientService.findByUserId(user.id());
        if(patientOpt.isEmpty()){
            res.sendError(HttpServletResponse.SC_NOT_FOUND,"Patient introuvable");
            return;
        }
        Patient patient=patientOpt.get();
        String doctorIdStr = req.getParameter("doctorId");
        String dateStr     = req.getParameter("date");
        String slot        = req.getParameter("slot");
        String typeStr     = req.getParameter("type");
        String motif       = req.getParameter("motif");

        Long doctorId;
        if (doctorIdStr == null || doctorIdStr.isBlank()) {
            throw new IllegalArgumentException("Veuillez choisir un médecin");
        }
        try {
            doctorId = Long.parseLong(doctorIdStr);
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Identifiant de médecin invalide");
        }
        LocalDate date;
        if (dateStr == null || dateStr.isBlank()) {
            throw new IllegalArgumentException("Veuillez choisir une date");
        }
        try {
            date = LocalDate.parse(dateStr);   // format attendu : yyyy-MM-dd
        } catch (DateTimeParseException e) {
            throw new IllegalArgumentException("Format de date invalide");
        }
        if (date.isBefore(LocalDate.now())) {
            throw new IllegalArgumentException("La date doit être dans le futur");
        }

        if (slot == null || slot.isBlank()) {
            throw new IllegalArgumentException("Veuillez choisir un créneau");
        }
        slot = slot.trim();
        AppointmentType type = null;
        if (typeStr != null && !typeStr.isBlank()) {
            try {
                type = AppointmentType.valueOf(typeStr);
            } catch (IllegalArgumentException e) {
                throw new IllegalArgumentException("Type de rendez-vous invalide");
            }
        }
        if (motif != null) motif = motif.trim();
        if (motif != null && motif.length() > 255) {
            throw new IllegalArgumentException("Le motif est trop long (255 caractères max)");
        }

        appointmentService.create(patientOpt.get().getId(),doctorId,date,slot,motif,type);
        res.sendRedirect(req.getContextPath()+"/patient/appointments");
    }
}
