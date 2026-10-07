package com.clinicmanager.repository;

import com.clinicmanager.model.Doctor;
import com.clinicmanager.util.JpaUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.NoResultException;

import java.util.List;
import java.util.Optional;

public class DoctorRepositoryImpl implements DoctorRepository {

    // ══════════════════════════════════════════════════════════
    //  Version AUTONOME — ouvre sa propre transaction
    // ══════════════════════════════════════════════════════════

    @Override
    public Doctor save(Doctor d) {
        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Doctor merged;
            if (d.getId() == null) {
                em.persist(d);
                merged = d;
            } else {
                merged = em.merge(d);
            }
            tx.commit();
            return merged;
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    @Override
    public Optional<Doctor> findById(Long id) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return Optional.ofNullable(em.find(Doctor.class, id));
        } finally {
            em.close();
        }
    }

    @Override
    public Optional<Doctor> findByMatricule(String matricule) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return findByMatricule(em, matricule);   // délègue à la version "em"
        } finally {
            em.close();
        }
    }


    @Override
    public List<Doctor> findBySpecialty(Long specialtyId){
        return null;
    }
    @Override
    public Optional<Doctor> findByUserId(Long uid) {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            Doctor d = em.createQuery(
                            "SELECT d FROM Doctor d WHERE d.user.id = :uid", Doctor.class)
                    .setParameter("uid", uid)
                    .getSingleResult();
            return Optional.of(d);
        } catch (NoResultException e) {
            return Optional.empty();
        } finally {
            em.close();
        }
    }

    @Override
    public List<Doctor> findAll() {
        EntityManager em = JpaUtil.getEntityManager();
        try {
            return em.createQuery(
                            "SELECT d FROM Doctor d ORDER BY d.nom, d.prenom", Doctor.class)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public void delete(Long id) {
        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Doctor d = em.find(Doctor.class, id);
            if (d != null) em.remove(d);
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    // ══════════════════════════════════════════════════════════
    //  Version TRANSACTION EXTERNE
    //  ⚠️ Ne PAS ouvrir de transaction, ne PAS fermer l'EM
    // ══════════════════════════════════════════════════════════

    @Override
    public Doctor save(EntityManager em, Doctor d) {
        if (d.getId() == null) {
            em.persist(d);
            return d;
        } else {
            return em.merge(d);
        }
    }

    @Override
    public Optional<Doctor> findByMatricule(EntityManager em, String matricule) {
        try {
            Doctor d = em.createQuery(
                            "SELECT d FROM Doctor d WHERE d.matricule = :m", Doctor.class)
                    .setParameter("m", matricule)
                    .getSingleResult();
            return Optional.of(d);
        } catch (NoResultException e) {
            return Optional.empty();
        }
    }
}