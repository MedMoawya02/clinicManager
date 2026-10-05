package com.clinicmanager.exception;

public class UnavailableSlotException extends RuntimeException {

    public UnavailableSlotException(String message) {
        super(message);
    }
}