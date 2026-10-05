package com.clinicmanager.filter;

import com.clinicmanager.dto.UserDTO;
import com.clinicmanager.model.Role;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebFilter(urlPatterns = {"/admin/*", "/doctor/*", "/patient/*"})
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        HttpSession session = request.getSession(false);
        UserDTO user = (session != null) ? (UserDTO) session.getAttribute("user") : null;  // ← UserDTO, pas User

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String path = request.getRequestURI();
        String ctx = request.getContextPath();

        boolean forbidden =
                (path.startsWith(ctx + "/admin")   && user.role() != Role.ADMIN) ||
                        (path.startsWith(ctx + "/doctor")  && user.role() != Role.DOCTOR) ||
                        (path.startsWith(ctx + "/patient") && user.role() != Role.PATIENT);

        if (forbidden) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Accès refusé");
            return;
        }

        chain.doFilter(req, res);
    }
}