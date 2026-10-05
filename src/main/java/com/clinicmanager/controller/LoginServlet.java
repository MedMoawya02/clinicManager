package com.clinicmanager.controller;

import com.clinicmanager.dto.UserDTO;
import com.clinicmanager.exception.UnauthorizedActionException;
import com.clinicmanager.exception.UserNotFoundException;
import com.clinicmanager.model.Role;
import com.clinicmanager.service.AuthService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Si déjà connecté, rediriger vers le dashboard
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            redirectByRole((UserDTO) session.getAttribute("user"), req, resp);
            return;
        }
        req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String email = req.getParameter("email");
        String password = req.getParameter("password");

        try {
            UserDTO user = authService.login(email, password);

            HttpSession session = req.getSession(true);
            session.setAttribute("user", user);
            session.setAttribute("role", user.role().name());
            session.setMaxInactiveInterval(30 * 60); // 30 minutes

            redirectByRole(user, req, resp);

        } catch (UserNotFoundException | UnauthorizedActionException e) {
            req.setAttribute("error", e.getMessage());
            req.setAttribute("email", email);
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
        }
    }

    private void redirectByRole(UserDTO user, HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String ctx = req.getContextPath();
        if (user.role() == Role.ADMIN) {
            resp.sendRedirect(ctx + "/admin/dashboard");
        } else if (user.role() == Role.DOCTOR) {
            resp.sendRedirect(ctx + "/doctor/dashboard");
        } else {
            resp.sendRedirect(ctx + "/patient/dashboard");
        }
    }
}