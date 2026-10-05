package com.clinicmanager.repository;

import com.clinicmanager.model.Patient;
import java.util.List;
import java.util.Optional;

public interface PatientRepository {
    Patient save(Patient p);
    Optional<Patient> findById(Long id);
    Optional<Patient> findByUserId(Long userId);
    List<Patient> findAll();
    void delete(Long id);
}