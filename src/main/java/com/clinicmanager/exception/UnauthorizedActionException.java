package com.clinicmanager.exception;

public class UnauthorizedActionException extends RuntimeException {

    public UnauthorizedActionException(String message) {
        super(message);
    }

    public UnauthorizedActionException() {
        super("Action non autorisée.");
    }
}