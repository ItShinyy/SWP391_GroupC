package com.dermathologyai.controller.patient;

import com.dermathologyai.dao.ClinicDAO;
import com.dermathologyai.dao.DiagnosisReportDAO;
import com.dermathologyai.dao.DoctorDAO;
import com.dermathologyai.dao.DoctorScheduleDAO;
import com.dermathologyai.dao.FamilyMemberDAO;
import com.dermathologyai.dao.PatientDAO;
import com.dermathologyai.model.Appointment;
import com.dermathologyai.model.Clinic;
import com.dermathologyai.model.DiagnosisReport;
import com.dermathologyai.model.Doctor;
import com.dermathologyai.model.DoctorSchedule;
import com.dermathologyai.model.Patient;
import com.dermathologyai.model.User;
import com.dermathologyai.service.BookingService;
import com.dermathologyai.service.BillingService;
import com.dermathologyai.util.RequestUtil;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

public class BookingController extends HttpServlet {
    private static final Logger logger = LoggerFactory.getLogger(BookingController.class);
    private static final Gson GSON = new Gson();

    private ClinicDAO clinicDAO;
    private DiagnosisReportDAO diagnosisReportDAO;
    private PatientDAO patientDAO;
    private DoctorDAO doctorDAO;
    private DoctorScheduleDAO scheduleDAO;
    private FamilyMemberDAO familyMemberDAO;
    private BookingService bookingService;
    private BillingService billingService;

    @Override
    public void init() throws ServletException {
        clinicDAO = new ClinicDAO();
        diagnosisReportDAO = new DiagnosisReportDAO();
        patientDAO = new PatientDAO();
        doctorDAO = new DoctorDAO();
        scheduleDAO = new DoctorScheduleDAO();
        familyMemberDAO = new FamilyMemberDAO();
        bookingService = new BookingService();
        billingService = new BillingService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String ajax = req.getParameter("ajax");
        if ("doctors".equals(ajax)) {
            writeDoctorsJson(req, resp);
            return;
        }
        if ("slots".equals(ajax)) {
            writeSlotsJson(req, resp);
            return;
        }

        DiagnosisReport screeningReport = resolvePatientScreeningReport(req, resp);
        if (resp.isCommitted()) {
            return;
        }
        if (screeningReport != null) {
            req.setAttribute("screeningReportId", screeningReport.getId());
            req.setAttribute("screeningDiseaseName", screeningReport.getDiseaseName());
            double confidence = screeningReport.getConfidenceScore();
            if (confidence > 0 && confidence <= 1.0) confidence *= 100.0;
            req.setAttribute("screeningConfidencePercent", Math.round(confidence * 10.0) / 10.0);
        }

        HttpSession session = req.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user != null) {
            req.setAttribute("familyMembers", familyMemberDAO.findByOwnerUserId(user.getId()));
            req.setAttribute("patient", patientDAO.findByUserId(user.getId()));
            req.setAttribute("selectedExaminedPerson", req.getParameter("examinedPerson"));
        }

        String clinicId = req.getParameter("clinicId");
        if (clinicId != null && !clinicId.trim().isEmpty()) {
            req.setAttribute("selectedClinic", clinicDAO.findById(clinicId));
        }

        List<Clinic> clinics = clinicDAO.findActive();
        req.setAttribute("clinics", clinics);
        req.setAttribute("mapClinics", clinicDAO.findActiveWithLocation());
        req.setAttribute("specializations", doctorDAO.findAllSpecializations());

        String doctorName = req.getParameter("doctorName");
        String fromDate = req.getParameter("fromDate");
        String toDate = req.getParameter("toDate");
        String specialization = req.getParameter("specialization");
        String timeSlot = req.getParameter("timeSlot");
        if (hasSearchParams(doctorName, fromDate, toDate, specialization, timeSlot)) {
            try {
                req.setAttribute("searchResults",
                    doctorDAO.searchDoctors(doctorName, fromDate, toDate, specialization, timeSlot));
            } catch (Exception e) {
                logger.warn("Doctor search failed: {}", e.getMessage());
                req.setAttribute("errorMessage", "Không thể tìm kiếm bác sĩ. Vui lòng thử lại.");
            }
        }

        req.setAttribute("requestId", UUID.randomUUID().toString());
        req.getRequestDispatcher("/WEB-INF/views/patient/booking.jsp").forward(req, resp);
    }

    private boolean hasSearchParams(String doctorName, String fromDate, String toDate,
                                    String specialization, String timeSlot) {
        return (doctorName != null && !doctorName.trim().isEmpty())
            || (fromDate != null && !fromDate.trim().isEmpty())
            || (toDate != null && !toDate.trim().isEmpty())
            || (specialization != null && !specialization.trim().isEmpty())
            || (timeSlot != null && !timeSlot.trim().isEmpty());
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        User user = (User) session.getAttribute("user");

        String clinicId = req.getParameter("clinicId");
        String doctorId = req.getParameter("doctorId");
        String scheduleDate = req.getParameter("scheduleDate");
        String slot = req.getParameter("slot");
        String notes = req.getParameter("notes");
        String requestId = req.getParameter("requestId");
        String reportId = req.getParameter("reportId");
        String examinedPerson = req.getParameter("examinedPerson");

        if (clinicId == null || doctorId == null || scheduleDate == null || slot == null || requestId == null) {
            req.setAttribute("errorMessage", "Missing required booking fields.");
            doGet(req, resp);
            return;
        }

        try {
            LocalDate date = LocalDate.parse(scheduleDate.trim());
            Appointment appointment = new Appointment();
            appointment.setClinicId(clinicId.trim());
            appointment.setAppointmentTime(LocalDateTime.of(date, BookingService.slotStartTime(slot.trim().toUpperCase())));
            if (notes != null && notes.length() > 1000) {
                notes = notes.substring(0, 1000);
            }
            appointment.setNotes(notes);
            appointment.setRequestId(requestId);
            appointment.setDiagnosisReportId(reportId == null || reportId.isBlank() ? null : reportId.trim());

            if (examinedPerson != null && examinedPerson.startsWith("FAMILY:")) {
                String familyMemberId = examinedPerson.substring("FAMILY:".length()).trim();
                var member = familyMemberDAO.findByIdAndOwnerUserId(familyMemberId, user.getId());
                if (member == null) {
                    req.setAttribute("errorMessage", "Người thân không hợp lệ.");
                    doGet(req, resp);
                    return;
                }
                appointment.setFamilyMemberId(member.getId());
            }

            String appointmentId = bookingService.bookAppointment(
                user.getId(), appointment, doctorId.trim(), slot.trim(),
                RequestUtil.getClientIp(req), req.getHeader("User-Agent")
            );
            if (appointmentId != null) {
                billingService.ensureUnpaidInvoiceForAppointment(appointmentId);
                resp.sendRedirect(req.getContextPath()
                    + "/patient/payment?action=create&appointmentId=" + appointmentId);
            } else {
                req.setAttribute("errorMessage", "Could not book appointment. Please try another slot.");
                doGet(req, resp);
            }
        } catch (DateTimeParseException e) {
            logger.warn("Booking rejected: invalid scheduleDate={}", scheduleDate);
            req.setAttribute("errorMessage", "Invalid appointment date. Please choose a date again.");
            doGet(req, resp);
        } catch (IllegalStateException e) {
            logger.warn("Booking rejected (state): {}", e.getMessage());
            if (e.getMessage() != null && e.getMessage().toLowerCase().contains("profile")) {
                req.getSession().setAttribute("errorMessage", "Vui lòng cập nhật hồ sơ cá nhân trước khi đặt lịch.");
                resp.sendRedirect(req.getContextPath() + "/account/profile");
            } else {
                req.setAttribute("errorMessage",
                    e.getMessage() != null && !e.getMessage().isBlank()
                        ? e.getMessage()
                        : "This slot is no longer available. Please choose another time.");
                doGet(req, resp);
            }
        } catch (IllegalArgumentException e) {
            logger.warn("Booking rejected (argument): {}", e.getMessage());
            req.setAttribute("errorMessage",
                e.getMessage() != null && !e.getMessage().isBlank()
                    ? e.getMessage()
                    : "Invalid booking details. Please check clinic, doctor, date, and slot.");
            doGet(req, resp);
        } catch (RuntimeException e) {
            logger.error("Booking failed unexpectedly", e);
            Throwable root = e;
            while (root.getCause() != null && root.getCause() != root) {
                root = root.getCause();
            }
            String friendly = e.getMessage();
            if (friendly != null && (friendly.contains("UQ_appointments_patient_time")
                || (root.getMessage() != null && root.getMessage().contains("UQ_appointments_patient_time")))) {
                req.setAttribute("errorMessage",
                    "You already have an appointment at this date and time. Choose another day or time slot.");
            } else if (friendly != null && !friendly.isBlank() && friendly.length() < 180
                && !friendly.contains("Exception") && !friendly.contains("SQL")
                && !friendly.toLowerCase().contains("violation")) {
                req.setAttribute("errorMessage", friendly);
            } else {
                req.setAttribute("errorMessage", "Booking failed due to a server error. Please try again in a moment.");
            }
            doGet(req, resp);
        }
    }

    private void writeDoctorsJson(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String clinicId = req.getParameter("clinicId");
        List<Map<String, String>> payload = new ArrayList<>();
        if (clinicId != null && !clinicId.isBlank()) {
            for (Doctor doctor : doctorDAO.findByClinicId(clinicId.trim())) {
                Map<String, String> row = new LinkedHashMap<>();
                row.put("id", doctor.getId());
                row.put("fullName", doctor.getFullName());
                row.put("specialization", doctor.getSpecialization() == null ? "" : doctor.getSpecialization());
                payload.add(row);
            }
        }
        writeJson(resp, payload);
    }

    private void writeSlotsJson(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String doctorId = req.getParameter("doctorId");
        String dateRaw = req.getParameter("date");
        List<Map<String, Object>> payload = new ArrayList<>();
        if (doctorId != null && !doctorId.isBlank() && dateRaw != null && !dateRaw.isBlank()) {
            final LocalDate date;
            try {
                date = LocalDate.parse(dateRaw.trim());
            } catch (DateTimeParseException e) {
                writeJson(resp, payload);
                return;
            }
            for (String slot : List.of("MORNING", "AFTERNOON", "EVENING")) {
                DoctorSchedule schedule = scheduleDAO.findByDoctorDateAndSlot(doctorId.trim(), date, slot);
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("slot", slot);
                row.put("label", slotLabel(slot));
                if (schedule == null || !schedule.isAvailable()) {
                    row.put("state", "disabled");
                    row.put("remaining", 0);
                    row.put("bookedCount", schedule == null ? 0 : schedule.getBookedCount());
                    row.put("maxPatients", schedule == null ? 0 : schedule.getMaxPatients());
                } else {
                    int remaining = schedule.getMaxPatients() - schedule.getBookedCount();
                    row.put("remaining", Math.max(0, remaining));
                    row.put("bookedCount", schedule.getBookedCount());
                    row.put("maxPatients", schedule.getMaxPatients());
                    row.put("state", remaining > 0 ? "available" : "booked");
                }
                payload.add(row);
            }
        }
        writeJson(resp, payload);
    }

    private static String slotLabel(String slot) {
        return switch (slot) {
            case "MORNING" -> "Morning (" + BookingService.slotStartTime("MORNING") + ")";
            case "AFTERNOON" -> "Afternoon (" + BookingService.slotStartTime("AFTERNOON") + ")";
            case "EVENING" -> "Evening (" + BookingService.slotStartTime("EVENING") + ")";
            default -> slot;
        };
    }

    private void writeJson(HttpServletResponse resp, Object payload) throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        resp.getWriter().write(GSON.toJson(payload));
    }

    private DiagnosisReport resolvePatientScreeningReport(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String reportId = req.getParameter("reportId");
        if (reportId == null || reportId.isBlank()) {
            return null;
        }
        HttpSession session = req.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        Patient patient = user == null ? null : patientDAO.findByUserId(user.getId());
        DiagnosisReport report = diagnosisReportDAO.findById(reportId.trim());
        if (patient == null || report == null || !patient.getId().equals(report.getPatientId()) ||
            report.getAiScreeningAttemptId() == null ||
            !"PENDING_DOCTOR_REVIEW".equals(report.getDoctorReviewStatus())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "This screening is not available for appointment booking.");
            return null;
        }
        return report;
    }
}
