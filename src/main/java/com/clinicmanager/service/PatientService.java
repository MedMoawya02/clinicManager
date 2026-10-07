package com.clinicmanager.service;
import com.clinicmanager.model.Patient;
import jakarta.persistence.EntityManager;
import java.util.List;
import java.util.Optional;
public interface PatientService {
    // ─── Autonomes ───
    Patient create(Patient p);
    Optional<Patient> findById(Long id);
    Optional<Patient> findByCin(String cin);
    Optional<Patient> findByUserId(Long userId);
    List<Patient> findAll();
    void delete(Long id);
    Patient update(Patient p);
    Patient update(EntityManager em, Patient p);
    // ─── Transaction externe ───
    Patient create(EntityManager em, Patient p);
}