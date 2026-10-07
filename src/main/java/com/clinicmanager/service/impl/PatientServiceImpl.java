package com.clinicmanager.service.impl;

import com.clinicmanager.model.Patient;
import com.clinicmanager.repository.PatientRepository;
import com.clinicmanager.repository.PatientRepositoryImpl;
import com.clinicmanager.service.PatientService;
import jakarta.persistence.EntityManager;

import java.util.List;
import java.util.Optional;

public class PatientServiceImpl implements PatientService {

    private final PatientRepository repo = new PatientRepositoryImpl();

    // ══════════════════════════════════════════════════════════
    //  Version AUTONOME — le repo gère sa propre transaction
    // ══════════════════════════════════════════════════════════
    @Override
    public Patient create(Patient p) {
        if (p.getCin() != null && repo.findByCin(p.getCin()).isPresent()) {
            throw new IllegalArgumentException("Ce CIN est déjà utilisé : " + p.getCin());
        }
        return repo.save(p);
    }

    @Override
    public Optional<Patient> findById(Long id) {
        return repo.findById(id);
    }

    @Override
    public Optional<Patient> findByCin(String cin) {
        return repo.findByCin(cin);
    }

    @Override
    public Optional<Patient> findByUserId(Long userId) {
        return repo.findByUserId(userId);
    }

    @Override
    public List<Patient> findAll() {
        return repo.findAll();
    }

    @Override
    public void delete(Long id) {
        repo.delete(id);
    }
    @Override
    public Patient update(Patient patient){
        return repo.update(patient);
    }
    @Override
    public Patient update(EntityManager em,Patient patient){
        return repo.update(em, patient);
    }

    // ══════════════════════════════════════════════════════════
    //  Version TRANSACTION EXTERNE (appelée par UserServiceImpl)
    //  ⚠️ Ne PAS ouvrir de transaction, ne PAS fermer l'EM
    // ══════════════════════════════════════════════════════════
    @Override
    public Patient create(EntityManager em, Patient p) {
        if (p.getCin() != null && repo.findByCin(em, p.getCin()).isPresent()) {
            throw new IllegalArgumentException("Ce CIN est déjà utilisé : " + p.getCin());
        }
        return repo.save(em, p);
    }
}