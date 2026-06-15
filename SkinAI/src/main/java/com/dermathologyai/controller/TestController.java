package com.dermathologyai.controller;

import com.dermathologyai.dao.ClinicDAO;
import com.dermathologyai.model.Clinic;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/test/clinics")
public class TestController extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("text/html;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        
        out.println("<html><head><title>Test Clinics</title></head><body>");
        out.println("<h1>Clinic Test Results</h1>");
        
        try {
            ClinicDAO clinicDAO = new ClinicDAO();
            
            // Test all clinics
            List<Clinic> allClinics = clinicDAO.findAll();
            out.println("<h2>All Clinics (" + allClinics.size() + "):</h2>");
            out.println("<table border='1'>");
            out.println("<tr><th>ID</th><th>Name</th><th>Address</th><th>Active</th></tr>");
            
            for (Clinic c : allClinics) {
                out.println("<tr>");
                out.println("<td>" + c.getId() + "</td>");
                out.println("<td>" + c.getClinicName() + "</td>");
                out.println("<td>" + c.getAddress() + "</td>");
                out.println("<td>" + c.isActive() + "</td>");
                out.println("</tr>");
            }
            out.println("</table>");
            
            // Test active clinics
            List<Clinic> activeClinics = clinicDAO.findActive();
            out.println("<h2>Active Clinics (" + activeClinics.size() + "):</h2>");
            
            if (activeClinics.isEmpty()) {
                out.println("<p style='color: red;'><strong>NO ACTIVE CLINICS FOUND!</strong></p>");
                out.println("<p>Run this SQL to fix: <code>UPDATE clinics SET is_active = 1</code></p>");
            } else {
                out.println("<ul>");
                for (Clinic c : activeClinics) {
                    out.println("<li>" + c.getClinicName() + " - " + c.getAddress() + "</li>");
                }
                out.println("</ul>");
            }
            
        } catch (Exception e) {
            out.println("<p style='color: red;'>ERROR: " + e.getMessage() + "</p>");
            e.printStackTrace(out);
        }
        
        out.println("</body></html>");
    }
}