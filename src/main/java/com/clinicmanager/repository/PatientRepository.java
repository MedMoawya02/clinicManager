package com.clinicmanager.repository;

import com.clinicmanager.model.Patient;
import jakarta.persistence.EntityManager;

import java.util.List;
import java.util.Optional;

public interface PatientRepository {
    Patient save(Patient p);
    Optional<Patient> findById(Long id);
    Optional<Patient> findByCin(String cin);
    Optional<Patient> findByUserId(Long userId);
    List<Patient> findAll();
    void delete(Long id);
    Patient update(Patient p);
    Patient update(EntityManager em, Patient p);
    Patient save(EntityManager em, Patient p);
    Optional<Patient> findByCin(EntityManager em, String cin);
}