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
}
