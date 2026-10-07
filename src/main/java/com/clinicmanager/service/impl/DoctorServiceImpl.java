package com.clinicmanager.service.impl;

import com.clinicmanager.model.Doctor;
import com.clinicmanager.repository.DoctorRepository;
import com.clinicmanager.repository.DoctorRepositoryImpl;
import com.clinicmanager.service.DoctorService;
import jakarta.persistence.EntityManager;

import java.util.List;
import java.util.Optional;

public class DoctorServiceImpl implements DoctorService {

    private final DoctorRepository repo = new DoctorRepositoryImpl();

    // ══════════════════════════════════════════════════════════
    //  Version AUTONOME
    // ══════════════════════════════════════════════════════════
    @Override
    public Doctor create(Doctor d) {
        if (d.getMatricule() != null && repo.findByMatricule(d.getMatricule()).isPresent()) {
            throw new IllegalArgumentException("Ce matricule est déjà utilisé : " + d.getMatricule());
        }
        return repo.save(d);
    }

    @Override
    public Optional<Doctor> findById(Long id) {
        return repo.findById(id);
    }

    @Override
    public Optional<Doctor> findByMatricule(String matricule) {
        return repo.findByMatricule(matricule);
    }

    @Override
    public Optional<Doctor> findByUserId(Long userId) {
        return repo.findByUserId(userId);
    }

    @Override
    public List<Doctor> findAll() {
        return repo.findAll();
    }

    @Override
    public void delete(Long id) {
        repo.delete(id);
    }

    // ══════════════════════════════════════════════════════════
    //  Version TRANSACTION EXTERNE (appelée par UserServiceImplementation)
    // ══════════════════════════════════════════════════════════
    @Override
    public Doctor create(EntityManager em, Doctor d) {
        if (d.getMatricule() != null && repo.findByMatricule(em, d.getMatricule()).isPresent()) {
            throw new IllegalArgumentException("Ce matricule est déjà utilisé : " + d.getMatricule());
        }
        return repo.save(em, d);
    }
}