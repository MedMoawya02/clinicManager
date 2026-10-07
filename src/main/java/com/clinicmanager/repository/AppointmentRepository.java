package com.clinicmanager.repository;

import com.clinicmanager.model.Appointment;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface AppointmentRepository {

    Appointment save(Appointment a);

    Optional<Appointment> findById(Long id);

    List<Appointment> findByPatientId(Long patientId);

    List<Appointment> findByDoctorId(Long doctorId);

    boolean existsForDoctorAt(Long doctorId, LocalDate date, String slot);

    void delete(Long id);
}