package com.dermathologyai.filter;

import com.dermathologyai.model.User;
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
            // Role checks
            boolean isAdminRoute = uri.startsWith(req.getContextPath() + "/admin");
            boolean isDoctorRoute = uri.startsWith(req.getContextPath() + "/doctor");
            boolean isPatientRoute = uri.startsWith(req.getContextPath() + "/patient");

            if (isAdminRoute && !user.isAdmin()) {
                res.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied. Admin privileges required.");
                return;
            }

            if (isDoctorRoute && !user.isDoctor()) {
                res.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied. Doctor privileges required.");
                return;
            }

            if (isPatientRoute && !user.isPatient() && !user.isAdmin()) {
                res.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
                return;
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
