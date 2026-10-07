package com.clinicmanager.service;

import com.clinicmanager.model.Doctor;
import jakarta.persistence.EntityManager;

import java.util.List;
import java.util.Optional;

public interface DoctorService {

    // ─── Autonomes ───
    Doctor create(Doctor d);
    Optional<Doctor> findById(Long id);
    Optional<Doctor> findByMatricule(String matricule);
    Optional<Doctor> findByUserId(Long userId);
    List<Doctor> findAll();
    void delete(Long id);

    // ─── Transaction externe ───
    Doctor create(EntityManager em, Doctor d);
}