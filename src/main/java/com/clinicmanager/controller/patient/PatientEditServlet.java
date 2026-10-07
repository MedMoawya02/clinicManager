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

import javax.sql.rowset.serial.SerialException;
import java.io.IOException;
import java.util.Optional;

@WebServlet("/patient/edit")
public class PatientEditServlet extends HttpServlet {
    private final PatientService patientService=new PatientServiceImpl() ;
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)throws ServletException, IOException {
        HttpSession session=request.getSession(false);
        if(session==null){
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Récupérer l'utilisateur connecté depuis la session
        // (adapte selon ce que vous stockez : "user", "patient", "userId", ...)
        Object userAttr = session.getAttribute("user");
        if (!(userAttr instanceof UserDTO user)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        Long id=user.id();
        Optional<Patient> patient= patientService.findByUserId(id);
        if (patient.isEmpty()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Patient introuvable");
            return;
        }
        // Forward to the JSP form
        request.setAttribute("patient",patient.get());
        request.setAttribute("genres", Genre.values());
        request.setAttribute("groupes", GroupeSanguin.values());
        request.getRequestDispatcher("/WEB-INF/views/patient/edit.jsp")
                .forward(request, response);
    }
    @Override
    public void doPost(HttpServletRequest request, HttpServletResponse response)throws ServletException,IOException{
        HttpSession session=request.getSession(false);
        if(session==null){
            response.sendRedirect(request.getContextPath()+"/login");
            return;
        }
        Object userAttr=session.getAttribute("user");
        if(!(userAttr instanceof UserDTO user)){
            response.sendRedirect(request.getContextPath()+"/login");
            return;
        }
        Optional<Patient> patientOpt=patientService.findByUserId(user.id());
        if(patientOpt.isEmpty()){
            response.sendError(HttpServletResponse.SC_NOT_FOUND,"Patient introuvable");
            return;
        }
        Patient patient=patientOpt.get();

        // Champs texte modifiables
        String nom    = request.getParameter("nom");
        String prenom = request.getParameter("prenom");
        String tel    = request.getParameter("tel");
        String adresse  = request.getParameter("adresse");

        if (nom    != null && !nom.isBlank())    patient.setNom(nom.trim());
        if (prenom != null && !prenom.isBlank()) patient.setPrenom(prenom.trim());
        if (tel    != null && !tel.isBlank())    patient.setTelephone(tel.trim());
        if (adresse  != null && !adresse.isBlank())  patient.setAdresse(adresse.trim());

        // Enum : genre
        String genreStr = request.getParameter("genre");
        if (genreStr != null && !genreStr.isBlank()) {
            try {
                patient.setGenre(Genre.valueOf(genreStr));
            } catch (IllegalArgumentException e) {
                patient.setGenre(null);
            }
        } else {
            patient.setGenre(null);
        }

        // Enum : groupe sanguin
        String groupeStr = request.getParameter("groupeSanguin");
        if (groupeStr != null && !groupeStr.isBlank()) {
            try {
                patient.setGroupeSanguin(GroupeSanguin.valueOf(groupeStr));
            } catch (IllegalArgumentException e) {
                patient.setGroupeSanguin(null);
            }
        } else {
            patient.setGroupeSanguin(null);
        }

        // (Ajoutez ici les autres champs du formulaire : adresse, ville, etc.)

        Patient updated = patientService.update(patient);
        session.setAttribute("patient", updated);

        response.sendRedirect(request.getContextPath() + "/patient/edit");
    }
}
