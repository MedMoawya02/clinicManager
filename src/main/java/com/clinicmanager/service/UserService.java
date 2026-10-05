package com.clinicmanager.service;

import com.clinicmanager.model.Role;
import com.clinicmanager.model.User;

import java.util.List;
import java.util.Optional;

public interface UserService {

    /**
     * Creates a new user.
     * @throws IllegalArgumentException if email already exists or inputs are invalid
     */
    User createUser(String fullName, String email, String plainPassword,
                    Role role, boolean active);

    Optional<User> findByEmail(String email);

    List<User> findAll();

    void delete(Long id);
}