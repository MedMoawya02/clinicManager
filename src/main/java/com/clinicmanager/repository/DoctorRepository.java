package com.clinicmanager.repository;

import com.clinicmanager.model.Doctor;
import java.util.List;
import java.util.Optional;

public interface DoctorRepository {
    Doctor save(Doctor d);
    Optional<Doctor> findById(Long id);
    Optional<Doctor> findByMatricule(String matricule);
    List<Doctor> findBySpecialty(Long specialtyId);
    List<Doctor> findAll();
    void delete(Long id);
}