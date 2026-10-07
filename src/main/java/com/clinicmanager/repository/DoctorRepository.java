package com.clinicmanager.repository;

import com.clinicmanager.model.Doctor;
import jakarta.persistence.EntityManager;

import java.util.List;
import java.util.Optional;

public interface DoctorRepository {
    Doctor save(Doctor d);
    Optional<Doctor> findById(Long id);
    Optional<Doctor> findByMatricule(String matricule);
    Optional<Doctor> findByUserId(Long userId);
    List<Doctor> findBySpecialty(Long specialtyId);
    List<Doctor> findAll();
    void delete(Long id);
    Doctor save(EntityManager em, Doctor d);
    Optional<Doctor> findByMatricule(EntityManager em, String matricule);
}