package com.clinicmanager.exception;

public class AppointmentNotFoundException extends RuntimeException {

    public AppointmentNotFoundException(String message) {
        super(message);
    }

    public AppointmentNotFoundException(Long id) {
        super("Rendez-vous introuvable avec l'id : " + id);
    }
}