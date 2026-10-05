package com.clinicmanager.exception;

public class DoctorNotFoundException extends RuntimeException {

    public DoctorNotFoundException(String message) {
        super(message);
    }

    public DoctorNotFoundException(Long id) {
        super("Médecin introuvable avec l'id : " + id);
    }

    public DoctorNotFoundException(String matricule, boolean byMatricule) {
        super("Médecin introuvable avec le matricule : " + matricule);
    }
}