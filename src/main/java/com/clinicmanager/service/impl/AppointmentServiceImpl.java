package com.clinicmanager.service.impl;

import com.clinicmanager.model.Appointment;
import com.clinicmanager.model.AppointmentStatus;
import com.clinicmanager.model.AppointmentType;
import com.clinicmanager.model.Doctor;
import com.clinicmanager.model.Patient;
import com.clinicmanager.repository.AppointmentRepository;
import com.clinicmanager.repository.AppointmentRepositoryImpl;
import com.clinicmanager.repository.DoctorRepository;
import com.clinicmanager.repository.DoctorRepositoryImpl;
import com.clinicmanager.repository.PatientRepository;
import com.clinicmanager.repository.PatientRepositoryImpl;
import com.clinicmanager.service.AppointmentService;

import java.time.LocalDate;
import java.util.List;

public class AppointmentServiceImpl implements AppointmentService {

    private final AppointmentRepository appointmentRepo = new AppointmentRepositoryImpl();
    private final PatientRepository     patientRepo     = new PatientRepositoryImpl();
    private final DoctorRepository      doctorRepo      = new DoctorRepositoryImpl();

    // ══════════════════════════════════════════════════════════
    //  create
    // ══════════════════════════════════════════════════════════
    @Override
    public Appointment create(Long patientId,
                              Long doctorId,
                              LocalDate date,
                              String slot,
                              String motif,
                              AppointmentType type) {

        // 1. Validation date
        if (date == null) {
            throw new IllegalArgumentException("La date est obligatoire");
        }
        if (date.isBefore(LocalDate.now())) {
            throw new IllegalArgumentException("La date doit être dans le futur");
        }

        // 2. Validation créneau
        if (slot == null || slot.isBlank()) {
            throw new IllegalArgumentException("Le créneau est obligatoire");
        }

        // 3. Vérifier que le créneau est libre
        if (appointmentRepo.existsForDoctorAt(doctorId, date, slot)) {
            throw new IllegalStateException("Ce créneau est déjà réservé");
        }

        // 4. Charger les entités liées
        Patient patient = patientRepo.findById(patientId)
                .orElseThrow(() -> new IllegalArgumentException("Patient introuvable"));
        Doctor doctor = doctorRepo.findById(doctorId)
                .orElseThrow(() -> new IllegalArgumentException("Médecin introuvable"));

        // 5. Construire l'entité
        Appointment a = new Appointment();
        a.setPatient(patient);
        a.setDoctor(doctor);
        a.setDate(date);
        a.setSlot(slot);
        a.setMotif(motif);
        a.setType(type);
        a.setStatus(AppointmentStatus.PLANNED);

        // 6. Persister
        return appointmentRepo.save(a);
    }

    // ══════════════════════════════════════════════════════════
    //  findByPatient
    // ══════════════════════════════════════════════════════════
    @Override
    public List<Appointment> findByPatient(Long patientId) {
        return appointmentRepo.findByPatientId(patientId);
    }

    // ══════════════════════════════════════════════════════════
    //  cancel
    // ══════════════════════════════════════════════════════════
    @Override
    public void cancel(Long appointmentId, Long patientId) {
        Appointment a = appointmentRepo.findById(appointmentId)
                .orElseThrow(() -> new IllegalArgumentException("Rendez-vous introuvable"));

        // Sécurité : un patient ne peut annuler que ses propres RDV
        if (!a.getPatient().getId().equals(patientId)) {
            throw new SecurityException("Accès refusé");
        }

        // On ne peut annuler qu'un RDV encore actif
        if (a.getStatus() == AppointmentStatus.CANCELED
                || a.getStatus() == AppointmentStatus.DONE) {
            throw new IllegalStateException("Ce rendez-vous ne peut plus être annulé");
        }

        a.setStatus(AppointmentStatus.CANCELED);
        appointmentRepo.save(a);
    }
}