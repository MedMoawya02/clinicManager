package com.clinicmanager.exception;

public class MedicalNoteLockedException extends RuntimeException {

    public MedicalNoteLockedException(String message) {
        super(message);
    }

    public MedicalNoteLockedException() {
        super("Cette note médicale est validée et ne peut plus être modifiée.");
    }
}