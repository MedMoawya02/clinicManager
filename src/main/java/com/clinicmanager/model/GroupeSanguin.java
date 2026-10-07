package com.clinicmanager.model;

public enum GroupeSanguin {
    A_POS("A+"), A_NEG("A-"),
    B_POS("B+"), B_NEG("B-"),
    AB_POS("AB+"), AB_NEG("AB-"),
    O_POS("O+"), O_NEG("O-");

    private final String label;
    GroupeSanguin(String label) { this.label = label; }
    public String getLabel() { return label; }
}