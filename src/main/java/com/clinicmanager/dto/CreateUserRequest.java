package com.clinicmanager.dto;

import com.clinicmanager.model.Genre;
import com.clinicmanager.model.GroupeSanguin;
import com.clinicmanager.model.Role;

import java.time.LocalDate;

public class CreateUserRequest {

    // ─── Communs ───
    public String fullName;
    public String email;
    public String password;
    public Role role;
    public boolean active;

    // ─── Patient ───
    public String cin;
    public String nom;
    public String prenom;
    public LocalDate dateNaissance;
    public Genre genre;
    public String adresse;
    public String telephone;
    public GroupeSanguin groupeSanguin;

    // ─── Doctor ───
    public String matricule;
    public String titre;
    public String emailPro;
    public String specialite;
    public String departement;
}