package com.clinicmanager.repository;

import com.clinicmanager.model.Patient;
import com.clinicmanager.util.JpaUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.NoResultException;

import java.util.List;
import java.util.Optional;

public class PatientRepositoryImpl implements PatientRepository {
    @Override
    public Patient save(Patient p){
        EntityManager em= JpaUtil.getEntityManager();
        EntityTransaction tx=em.getTransaction();
        try {
            tx.begin();
            Patient merged;
            if(p.getId()==null){
                em.persist(p);
                merged=p;
            }else {
                merged=em.merge(p);
            }
            tx.commit();
            return merged;
        } catch (Exception e) {
            if(tx.isActive()) tx.rollback();
            throw e;
        }finally {
            em.close();
        }
    }

    @Override
    public Optional<Patient> findById(Long id){
        EntityManager em=JpaUtil.getEntityManager();
        try {
            return Optional.ofNullable(em.find(Patient.class,id));
        }finally {
            em.close();
        }
    }

    @Override
    public Optional<Patient> findByCin(String cin){
        EntityManager em=JpaUtil.getEntityManager();
        try {
            Patient p=em.createQuery("SELECT p FROM Patient p WHERE p.cin=:cin",Patient.class).setParameter("cin",cin).getSingleResult();
            return Optional.of(p);
        }catch (NoResultException e) {
            return Optional.empty();
        } finally {
            em.close();
        }
    }

    @Override
    public Optional<Patient> findByUserId(Long uid){
        EntityManager em=JpaUtil.getEntityManager();
        try {
            Patient p=em.createQuery("SELECT p FROM Patient p WHERE p.user.id=:uid",Patient.class).setParameter("uid",uid).getSingleResult();
            return Optional.of(p);
        }catch (NoResultException e) {
            return Optional.empty();
        } finally {
            em.close();
        }
    }

    @Override
    public List<Patient> findAll(){
        EntityManager em=JpaUtil.getEntityManager();
        try {
            return em.createQuery("SELECT p FROM Patient p ORDER BY p.nom",Patient.class).getResultList();
        }finally {
            em.close();
        }
    }

    @Override
    public void delete(Long id) {
        EntityManager em = JpaUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Patient p = em.find(Patient.class, id);
            if (p != null) em.remove(p);
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }
    @Override
    public Patient update(Patient patient){
        EntityManager em=JpaUtil.getEntityManager();
        EntityTransaction tx=em.getTransaction();
        try{
            tx.begin();
            Patient merged=em.merge(patient);
            tx.commit();
            return merged;
        }catch (RuntimeException e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }
    @Override
    public Patient update(EntityManager em, Patient p) {
        return em.merge(p);
    }

    @Override
    public Patient save(EntityManager em, Patient p) {
        if (p.getId() == null) {
            em.persist(p);
            return p;
        } else {
            return em.merge(p);
        }
    }

    @Override
    public Optional<Patient> findByCin(EntityManager em, String cin) {
        try {
            Patient p = em.createQuery(
                            "SELECT p FROM Patient p WHERE p.cin = :cin", Patient.class)
                    .setParameter("cin", cin)
                    .getSingleResult();
            return Optional.of(p);
        } catch (NoResultException e) {
            return Optional.empty();
        }
    }
}
