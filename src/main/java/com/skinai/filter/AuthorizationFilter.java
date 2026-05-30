package com.skinai.filter;

import com.skinai.model.User;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

public class AuthorizationFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
            
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);
        
        String uri = req.getRequestURI();
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user != null) {
            // Check status
            if ("LOCKED".equals(user.getStatus())) {
                session.invalidate();
                res.sendRedirect(req.getContextPath() + "/auth/login?error=account_locked");
                return;
            }

            // Role checks
            boolean isAdminRoute = uri.startsWith(req.getContextPath() + "/admin");
            boolean isPatientRoute = uri.startsWith(req.getContextPath() + "/patient");

            if (isAdminRoute && !"ADMIN".equals(user.getRole())) {
                // Send 403 Forbidden
                res.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied. Admin privileges required.");
                return;
            }

            if (isPatientRoute && !"PATIENT".equals(user.getRole()) && !"ADMIN".equals(user.getRole())) {
                // Assuming admin can also access patient routes, or restrict to just PATIENT
                res.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
                return;
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
