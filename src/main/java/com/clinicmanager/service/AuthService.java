package com.clinicmanager.service;

import com.clinicmanager.dto.UserDTO;
import com.clinicmanager.exception.DuplicateEmailException;
import com.clinicmanager.exception.UnauthorizedActionException;
import com.clinicmanager.exception.UserNotFoundException;
import com.clinicmanager.model.Role;
import com.clinicmanager.model.User;
import com.clinicmanager.repository.UserRepository;
import com.clinicmanager.repository.UserRepositoryImpl;

public class AuthService {

    private final UserRepository userRepo;

    // Constructeur par défaut (utilisé par les Servlets)
    public AuthService() {
        this(new UserRepositoryImpl());
    }

    // Constructeur pour les tests (injection)
    public AuthService(UserRepository userRepo) {
        this.userRepo = userRepo;
    }

    /**
     * Inscription d'un nouvel utilisateur.
     */
    public UserDTO register(String email, String password, Role role,String fullName) {
        if (email == null || email.isBlank()) {
            throw new IllegalArgumentException("L'email est obligatoire");
        }
        if (password == null || password.length() < 6) {
            throw new IllegalArgumentException("Le mot de passe doit faire au moins 6 caractères");
        }
        if (userRepo.findByEmail(email).isPresent()) {
            throw new DuplicateEmailException("Email déjà utilisé : " + email);
        }

        User user = new User(email, password, role);
        user.setFullName(fullName!=null&&!fullName.isBlank()?fullName:email);
        user.setActive(true);
        User saved = userRepo.save(user);
        return new UserDTO(saved.getId(), saved.getEmail(), saved.getRole(), saved.isActive());
    }

    /**
     * Connexion d'un utilisateur existant.
     */
    public UserDTO login(String email, String password) {
        User user = userRepo.findByEmail(email)
                .orElseThrow(() -> new UserNotFoundException("Email inconnu : " + email));

        if (!user.isActive()) {
            throw new UnauthorizedActionException("Ce compte est désactivé");
        }
        if (!user.getPassword().equals(password)) {
            throw new UnauthorizedActionException("Mot de passe incorrect");
        }

        return new UserDTO(user.getId(), user.getEmail(), user.getRole(), user.isActive());
    }
}