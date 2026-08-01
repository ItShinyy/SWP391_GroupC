package com.dermathologyai.filter;

import com.dermathologyai.model.User;
import com.dermathologyai.dao.UserDAO;
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

public class AuthenticationFilter implements Filter {

    private UserDAO userDAO;

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        userDAO = new UserDAO();
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        boolean isLoggedIn = false;
        
        if (session != null && session.getAttribute("user") != null) {
            User sessionUser = (User) session.getAttribute("user");
            
            // Re-fetch user from DB to validate status and password_changed_at (Ponytail strict stateless security)
            User dbUser = userDAO.findById(sessionUser.getId());
            
            if (dbUser != null && "ACTIVE".equals(dbUser.getStatus())) {
                // If password_changed_at mismatches, it means the password was changed after this session was created
                if (java.util.Objects.equals(sessionUser.getPasswordChangedAt(), dbUser.getPasswordChangedAt())) {
                    isLoggedIn = true;
                    // Refresh session user with latest data
                    session.setAttribute("user", dbUser);
                } else {
                    session.invalidate();
                }
            } else {
                session.invalidate();
            }
        }

        if (isLoggedIn) {
            chain.doFilter(request, response);
        } else {
            // Save requested URL to redirect back after login (optional, but good UX)
            String requestURI = req.getRequestURI();
            if (req.getQueryString() != null) {
                requestURI += "?" + req.getQueryString();
            }
            req.getSession(true).setAttribute("redirectAfterLogin", requestURI);
            
            res.sendRedirect(req.getContextPath() + "/auth/login");
        }
    }

    @Override
    public void destroy() {}
}
