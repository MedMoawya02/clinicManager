package com.clinicmanager.exception;

public class DuplicateMatriculeException extends RuntimeException {

    public DuplicateMatriculeException(String message) {
        super(message);
    }

    public DuplicateMatriculeException(String matricule, boolean isDuplicate) {
        super("Le matricule est déjà utilisé : " + matricule);
    }
}