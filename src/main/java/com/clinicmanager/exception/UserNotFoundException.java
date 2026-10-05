package com.clinicmanager.exception;

public class UserNotFoundException extends RuntimeException {

    public UserNotFoundException(String message) {
        super(message);
    }

    public UserNotFoundException(Long id) {
        super("Utilisateur introuvable avec l'id : " + id);
    }
}