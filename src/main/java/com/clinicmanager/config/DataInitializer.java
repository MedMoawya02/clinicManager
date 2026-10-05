package com.clinicmanager.config;

import com.clinicmanager.model.Role;
import com.clinicmanager.service.AuthService;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

@WebListener
public class DataInitializer implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println(">>> [DataInitializer] Démarrage...");
        AuthService authService = new AuthService();

        try {
            authService.register("admin@clinic.com", "admin123", Role.ADMIN, "Administrateur");
            System.out.println(">>> ✅ Admin initial créé : admin@clinic.com / admin123");
        } catch (Exception e) {
            System.out.println(">>> ℹ️ " + e.getMessage());
        }
    }
}