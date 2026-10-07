package com.clinicmanager.service;

import com.clinicmanager.model.Appointment;
import com.clinicmanager.model.AppointmentType;

import java.time.LocalDate;
import java.util.List;

public interface AppointmentService {

    Appointment create(Long patientId,
                       Long doctorId,
                       LocalDate date,
                       String slot,
                       String motif,
                       AppointmentType type);

    List<Appointment> findByPatient(Long patientId);

    void cancel(Long appointmentId, Long patientId);
}