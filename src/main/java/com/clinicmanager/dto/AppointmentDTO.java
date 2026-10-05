package com.clinicmanager.dto;

import java.time.LocalDate;
import java.time.LocalTime;

public record AppointmentDTO(
        Long id,
        Long patientId,
        String patientName,
        Long doctorId,
        String doctorName,
        LocalDate date,
        LocalTime slot,
        String type,
        String status,
        String motif
) {}