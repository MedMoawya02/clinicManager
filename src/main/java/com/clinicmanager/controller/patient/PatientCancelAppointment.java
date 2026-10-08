package com.clinicmanager.controller.patient;


import com.clinicmanager.dto.UserDTO;
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
import java.util.Optional;

@WebServlet("/patient/cancel")
public class PatientCancelAppointment extends HttpServlet {
    private final AppointmentService appointmentService=new AppointmentServiceImpl();
    private final PatientService patientService     = new PatientServiceImpl();
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)throws ServletException, IOException{
        res.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)throws ServletException, IOException{
        HttpSession session=req.getSession(false);
        if(session==null){
            res.sendRedirect(req.getContextPath()+"/login");
            return;
        }
        Object userAtrr=session.getAttribute("user");
        if(!(userAtrr instanceof UserDTO user)){
            res.sendRedirect(req.getContextPath()+"/login");
            return;
        }

        Optional<Patient> patientOpt=patientService.findByUserId(user.id());
        if(patientOpt.isEmpty()){
            res.sendError(HttpServletResponse.SC_NOT_FOUND,"Patient introuvable");
            return;
        }
        try {
            Long idAppointement=Long.parseLong(req.getParameter("id"));
            appointmentService.cancel(idAppointement,patientOpt.get().getId());
        } catch (NumberFormatException e) {
            res.sendError(HttpServletResponse.SC_BAD_REQUEST, "Identifiant de rendez-vous invalide");
            return;
        } catch (SecurityException e) {
            res.sendError(HttpServletResponse.SC_FORBIDDEN, "Accès refusé");
            return;
        }
        res.sendRedirect(req.getContextPath() + "/patient/appointments");
    }
}
