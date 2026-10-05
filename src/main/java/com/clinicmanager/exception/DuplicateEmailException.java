package com.clinicmanager.exception;

public class DuplicateEmailException extends RuntimeException {

    public DuplicateEmailException(String message) {
        super(message);
    }

    public DuplicateEmailException(String email, boolean isDuplicate) {
        super("L'email est déjà utilisé : " + email);
    }
}