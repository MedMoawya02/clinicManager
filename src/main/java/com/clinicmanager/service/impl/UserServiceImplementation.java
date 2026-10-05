package com.clinicmanager.service.impl;

import com.clinicmanager.model.Role;
import com.clinicmanager.model.User;
import com.clinicmanager.repository.UserRepository;
import com.clinicmanager.repository.UserRepositoryImpl;
import com.clinicmanager.service.UserService;


import java.util.List;
import java.util.Optional;

public class UserServiceImplementation implements UserService {

    // Program to the interface, instantiate the impl here (or inject via DI)
    private final UserRepository userRepository = new UserRepositoryImpl();

    @Override
    public User createUser(String fullName, String email, String plainPassword,
                           Role role, boolean active) {

        // --- Business validation (beyond simple field checks) ---
        if (fullName == null || fullName.isBlank()) {
            throw new IllegalArgumentException("Le nom complet est obligatoire.");
        }
        if (email == null || email.isBlank()) {
            throw new IllegalArgumentException("L'adresse e-mail est obligatoire.");
        }
        if (plainPassword == null || plainPassword.length() < 8) {
            throw new IllegalArgumentException("Le mot de passe doit contenir au moins 8 caractères.");
        }
        if (role == null) {
            throw new IllegalArgumentException("Le rôle est obligatoire.");
        }

        String cleanEmail = email.trim().toLowerCase();

        // --- Uniqueness rule ---
        if (userRepository.findByEmail(cleanEmail).isPresent()) {
            throw new IllegalArgumentException("Cet e-mail est déjà utilisé.");
        }
        User u=new User();
        u.setFullName(fullName);
        u.setEmail(email);
        u.setPassword(plainPassword);
        u.setRole(role);
        u.setActive(active);
        return userRepository.save(u);
    }

    @Override
    public Optional<User> findByEmail(String email) {
        if (email == null || email.isBlank()) return Optional.empty();
        return userRepository.findByEmail(email.trim().toLowerCase());
    }

    @Override
    public List<User> findAll() {
        return userRepository.findAll();
    }

    @Override
    public void delete(Long id) {
        if (id == null) throw new IllegalArgumentException("ID invalide.");
        userRepository.delete(id);
    }
}