package com.clinicmanager.model;

public enum Genre {
    HOMME("Homme"),
    FEMME("Femme"),
    AUTRE("Autre");

    private final String label;
    Genre(String label) { this.label = label; }
    public String getLabel() { return label; }
}