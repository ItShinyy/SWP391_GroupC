package com.dermathologyai.filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;

import java.io.IOException;

public class AuditFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
            
        HttpServletRequest req = (HttpServletRequest) request;
        
        // Extract IP address
        String ipAddress = req.getHeader("X-Forwarded-For");
        if (ipAddress == null || ipAddress.isEmpty() || "unknown".equalsIgnoreCase(ipAddress)) {
            ipAddress = req.getRemoteAddr();
        } else {
            // X-Forwarded-For can contain multiple IPs, the first one is the original client
            ipAddress = ipAddress.split(",")[0].trim();
        }
        
        // Extract User-Agent
        String userAgent = req.getHeader("User-Agent");
        if (userAgent == null) {
            userAgent = "Unknown";
        }
        
        // Store in request attributes for controllers to use
        request.setAttribute("clientIp", ipAddress);
        request.setAttribute("userAgent", userAgent);

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
