package com.clinicmanager.repository;

import com.clinicmanager.model.Appointment;
import com.clinicmanager.model.AppointmentStatus;

import com.clinicmanager.util.JpaUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public class AppointmentRepositoryImpl implements AppointmentRepository {

    // ══════════════════════════════════════════════════════════
    //  Helpers
    // ══════════════════════════════════════════════════════════
    private EntityManager em() {
        return JpaUtil.getEntityManager();   // ← adaptez au nom réel
    }

    // ══════════════════════════════════════════════════════════
    //  save (insert ou update)
    // ══════════════════════════════════════════════════════════
    @Override
    public Appointment save(Appointment a) {
        EntityManager em = em();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Appointment result;
            if (a.getId() == null) {
                em.persist(a);
                result = a;
            } else {
                result = em.merge(a);
            }
            tx.commit();
            return result;
        } catch (RuntimeException e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    // ══════════════════════════════════════════════════════════
    //  findById
    // ══════════════════════════════════════════════════════════
    @Override
    public Optional<Appointment> findById(Long id) {
        EntityManager em = em();
        try {
            return Optional.ofNullable(em.find(Appointment.class, id));
        } finally {
            em.close();
        }
    }

    // ══════════════════════════════════════════════════════════
    //  findByPatientId
    // ══════════════════════════════════════════════════════════
    @Override
    public List<Appointment> findByPatientId(Long patientId) {
        EntityManager em = em();
        try {
            return em.createQuery(
                            "SELECT a FROM Appointment a " +
                                    "WHERE a.patient.id = :pid " +
                                    "ORDER BY a.date DESC, a.slot DESC",
                            Appointment.class)
                    .setParameter("pid", patientId)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    // ══════════════════════════════════════════════════════════
    //  findByDoctorId
    // ══════════════════════════════════════════════════════════
    @Override
    public List<Appointment> findByDoctorId(Long doctorId) {
        EntityManager em = em();
        try {
            return em.createQuery(
                            "SELECT a FROM Appointment a " +
                                    "WHERE a.doctor.id = :did " +
                                    "ORDER BY a.date DESC, a.slot DESC",
                            Appointment.class)
                    .setParameter("did", doctorId)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    // ══════════════════════════════════════════════════════════
    //  existsForDoctorAt — vérifie si un créneau est déjà pris
    // ══════════════════════════════════════════════════════════
    @Override
    public boolean existsForDoctorAt(Long doctorId, LocalDate date, String slot) {
        EntityManager em = em();
        try {
            Long count = em.createQuery(
                            "SELECT COUNT(a) FROM Appointment a " +
                                    "WHERE a.doctor.id = :did " +
                                    "  AND a.date = :date " +
                                    "  AND a.slot = :slot " +
                                    "  AND a.status <> :cancelled",
                            Long.class)
                    .setParameter("did", doctorId)
                    .setParameter("date", date)
                    .setParameter("slot", slot)
                    .setParameter("cancelled", AppointmentStatus.CANCELED)
                    .getSingleResult();
            return count > 0;
        } finally {
            em.close();
        }
    }

    // ══════════════════════════════════════════════════════════
    //  delete
    // ══════════════════════════════════════════════════════════
    @Override
    public void delete(Long id) {
        EntityManager em = em();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Appointment a = em.find(Appointment.class, id);
            if (a != null) em.remove(a);
            tx.commit();
        } catch (RuntimeException e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }
}