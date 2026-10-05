package com.clinicmanager.dto;

import com.clinicmanager.model.Role;

public record UserDTO(Long id, String email, Role role, boolean active) {}