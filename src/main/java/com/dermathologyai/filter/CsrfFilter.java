package com.dermathologyai.filter;

import com.dermathologyai.util.CsrfUtil;
import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Set;

public class CsrfFilter implements Filter {

    // Endpoints that are excluded from CSRF validation (e.g., stateless API endpoints)
    private static final String API_PATH_PREFIX = "/api/";

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
            
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        // Only validate POST, PUT, DELETE
        String method = req.getMethod();
        if ("POST".equalsIgnoreCase(method) || "PUT".equalsIgnoreCase(method) || "DELETE".equalsIgnoreCase(method)) {
            String path = req.getServletPath();
            
            // Validate all mutating requests except whitelisted paths
            if (!path.startsWith(API_PATH_PREFIX)) {
                if (!CsrfUtil.validateToken(req)) {
                    res.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid or missing CSRF token");
                    return;
                }
            }
        }

        chain.doFilter(request, response);
    }
}
