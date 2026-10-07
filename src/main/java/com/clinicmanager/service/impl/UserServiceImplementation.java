package com.clinicmanager.service.impl;

import com.clinicmanager.dto.CreateUserRequest;
import com.clinicmanager.model.*;
import com.clinicmanager.repository.UserRepository;
import com.clinicmanager.repository.UserRepositoryImpl;
import com.clinicmanager.service.DoctorService;
import com.clinicmanager.service.PatientService;
import com.clinicmanager.service.UserService;
import com.clinicmanager.util.JpaUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;

import java.util.List;
import java.util.Optional;

public class UserServiceImplementation implements UserService {

    private final UserRepository userRepository = new UserRepositoryImpl();

    // ⚠️ NOUVEAU : pour créer les profils Patient/Doctor
    private final PatientService patientService = new PatientServiceImpl();
    private final DoctorService  doctorService  = new DoctorServiceImpl();

    @Override
    public User createUser(CreateUserRequest req) {

        // ─── 1) Validations communes ───
        if (req.fullName == null || req.fullName.isBlank())
            throw new IllegalArgumentException("Le nom complet est obligatoire.");
        if (req.email == null || req.email.isBlank())
            throw new IllegalArgumentException("L'adresse e-mail est obligatoire.");
        if (req.password == null || req.password.length() < 8)
            throw new IllegalArgumentException("Le mot de passe doit contenir au moins 8 caractères.");
        if (req.role == null)
            throw new IllegalArgumentException("Le rôle est obligatoire.");

        // ─── 2) UNE SEULE transaction ───
        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();

        try {
            tx.begin();

            // ─── 3) Unicité email ───
            Long count = em.createQuery(
                            "SELECT COUNT(u) FROM User u WHERE u.email = :email", Long.class)
                    .setParameter("email", req.email.trim().toLowerCase())
                    .getSingleResult();
            if (count > 0)
                throw new IllegalArgumentException("Cet e-mail est déjà utilisé.");

            // ─── 4) Créer le User ───
            User u = new User();
            u.setFullName(req.fullName.trim());
            u.setEmail(req.email.trim().toLowerCase());
            u.setPassword(req.password);   // ⚠️ pas de hash pour l'instant
            u.setRole(req.role);
            u.setActive(req.active);
            em.persist(u);

            // ─── 5) Créer le profil selon le rôle ───
            if (req.role == Role.PATIENT) {
                createPatientProfile(em, u, req);
            } else if (req.role == Role.DOCTOR) {
                createDoctorProfile(em, u, req);
            }
            // ADMIN, STAFF → rien de plus

            // ─── 6) Commit ───
            tx.commit();
            return u;

        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    // ══════════════════════════════════════════════════════════
    //                     PATIENT
    // ══════════════════════════════════════════════════════════
    private void createPatientProfile(EntityManager em, User user, CreateUserRequest req) {
        if (req.cin == null || req.cin.isBlank())
            throw new IllegalArgumentException("Le CIN est obligatoire.");
        if (req.nom == null || req.nom.isBlank())
            throw new IllegalArgumentException("Le nom est obligatoire.");
        if (req.prenom == null || req.prenom.isBlank())
            throw new IllegalArgumentException("Le prénom est obligatoire.");
        if (req.dateNaissance == null)
            throw new IllegalArgumentException("La date de naissance est obligatoire.");
        if (req.genre == null)
            throw new IllegalArgumentException("Le genre est obligatoire.");

        Patient p = new Patient();
        p.setUser(user);
        p.setCin(req.cin.trim());
        p.setNom(req.nom.trim());
        p.setPrenom(req.prenom.trim());
        p.setDateNaissance(req.dateNaissance);
        p.setGenre(req.genre);
        p.setAdresse(req.adresse);
        p.setTelephone(req.telephone);
        p.setGroupeSanguin(req.groupeSanguin);

        // ⚠️ Même EntityManager → même transaction
        patientService.create(em, p);
    }

    // ══════════════════════════════════════════════════════════
    //                     DOCTOR
    // ══════════════════════════════════════════════════════════
    private void createDoctorProfile(EntityManager em, User user, CreateUserRequest req) {
        if (req.matricule == null || req.matricule.isBlank())
            throw new IllegalArgumentException("Le matricule est obligatoire.");
        if (req.nom == null || req.nom.isBlank())
            throw new IllegalArgumentException("Le nom est obligatoire.");
        if (req.prenom == null || req.prenom.isBlank())
            throw new IllegalArgumentException("Le prénom est obligatoire.");

        Doctor d = new Doctor();
        d.setUser(user);
        d.setMatricule(req.matricule.trim());
        d.setNom(req.nom.trim());
        d.setPrenom(req.prenom.trim());
        d.setTitre(req.titre);
        d.setEmail(req.emailPro);
        d.setTelephone(req.telephone);
        d.setSpecialite(req.specialite);
        d.setDepartement(req.departement);

        doctorService.create(em, d);
    }

    // ══════════════════════════════════════════════════════════
    //                     CRUD classique
    // ══════════════════════════════════════════════════════════
    @Override
    public Optional<User> findByEmail(String email) {
        if (email == null || email.isBlank()) return Optional.empty();
        return userRepository.findByEmail(email.trim().toLowerCase());
    }

    @Override
    public List<User> findAll() {
        return userRepository.findAll();
    }

    @Override
    public void delete(Long id) {
        if (id == null) throw new IllegalArgumentException("ID invalide.");
        userRepository.delete(id);
    }
}