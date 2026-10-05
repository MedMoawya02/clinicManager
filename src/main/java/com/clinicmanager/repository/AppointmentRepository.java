package com.clinicmanager.repository;

import com.clinicmanager.model.Appointment;
import com.clinicmanager.model.Doctor;
import com.clinicmanager.model.Patient;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

public interface AppointmentRepository {
    Appointment save(Appointment a);

    Optional<Appointment> findById(Long id);

    List<Appointment> findByPatient(Patient patient);

    List<Appointment> findByDoctor(Doctor doctor);

    boolean existsConflict(Doctor doctor, LocalDate date, LocalTime slot);

    void delete(Long id);
}