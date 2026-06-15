package com.dermathologyai.controller.patient;

import com.dermathologyai.dao.AppointmentDAO;
import com.dermathologyai.dao.PatientDAO;
import com.dermathologyai.model.Appointment;
import com.dermathologyai.model.Patient;
import com.dermathologyai.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.List;

public class AppointmentsController extends HttpServlet {
    private static final Logger logger = LoggerFactory.getLogger(AppointmentsController.class);
    private AppointmentDAO appointmentDAO;
    private PatientDAO patientDAO;

    @Override
    public void init() throws ServletException {
        appointmentDAO = new AppointmentDAO();
        patientDAO = new PatientDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        
        // Get patient ID from user ID
        Patient patient = patientDAO.findByUserId(user.getId());
        if (patient == null) {
            logger.error("No patient profile found for user: {}", user.getId());
            req.setAttribute("error", "Patient profile not found. Please contact support.");
            req.setAttribute("appointments", List.of()); // Empty list to prevent JSP errors
            req.getRequestDispatcher("/WEB-INF/views/patient/appointments.jsp").forward(req, resp);
            return;
        }
        
        logger.info("AppointmentsController - User: {}, Patient: {}", user.getId(), patient.getId());
        
        // Get all appointments for this patient
        List<Appointment> appointments = appointmentDAO.findByPatientId(patient.getId());
        
        logger.info("AppointmentsController - Found {} appointments", appointments.size());
        
        req.setAttribute("appointments", appointments);
        req.setAttribute("totalAppointments", appointments.size());
        
        req.getRequestDispatcher("/WEB-INF/views/patient/appointments.jsp").forward(req, resp);
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Handle appointment cancellation
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        String action = req.getParameter("action");
        String appointmentId = req.getParameter("appointmentId");
        
        if ("cancel".equals(action) && appointmentId != null) {
            boolean success = appointmentDAO.updateStatus(appointmentId, "CANCELLED");
            if (success) {
                req.getSession().setAttribute("successMessage", "Appointment cancelled successfully.");
            } else {
                req.getSession().setAttribute("errorMessage", "Failed to cancel appointment.");
            }
        }
        
        resp.sendRedirect(req.getContextPath() + "/patient/appointments");
    }
}