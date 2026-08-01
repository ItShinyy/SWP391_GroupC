package com.dermathologyai.controller.doctor;

import com.dermathologyai.dao.AppointmentDAO;
import com.dermathologyai.dao.DiagnosisReportDAO;
import com.dermathologyai.dao.DiseaseDAO;
import com.dermathologyai.dao.DoctorDAO;
import com.dermathologyai.dao.PatientDAO;
import com.dermathologyai.dao.DoctorScheduleDAO;
import com.dermathologyai.model.Appointment;
import com.dermathologyai.model.Doctor;
import com.dermathologyai.model.DiagnosisReport;
import com.dermathologyai.model.Invoice;
import com.dermathologyai.model.MedicalReport;
import com.dermathologyai.model.Patient;
import com.dermathologyai.model.Prescription;
import com.dermathologyai.model.DoctorSchedule;
import com.dermathologyai.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.dermathologyai.security.Permission;
import com.dermathologyai.service.AuditService;
import com.dermathologyai.service.BillingService;
import com.dermathologyai.service.MedicalRecordService;
import com.dermathologyai.service.NotificationService;
import com.dermathologyai.service.ScreeningAuthorizationService;
import com.dermathologyai.util.RequestUtil;
import com.dermathologyai.util.FormatUtil;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Controller xử lý xem chi tiết hồ sơ bệnh nhân, ghi nhận xét, chuyển ca khám,
 * kê đơn thuốc và xuất báo cáo kết quả PDF dành cho Bác sĩ.
 */
public class DoctorAppointmentDetailController extends HttpServlet {
    private DoctorDAO doctorDAO;
    private AppointmentDAO appointmentDAO;
    private DiagnosisReportDAO diagnosisReportDAO;
    private DiseaseDAO diseaseDAO;
    private DoctorScheduleDAO scheduleDAO;
    private PatientDAO patientDAO;
    private AuditService auditService;
    private BillingService billingService;
    private MedicalRecordService medicalRecordService;
    private NotificationService notificationService;
    private ScreeningAuthorizationService screeningAuthorizationService;

    @Override
    public void init() throws ServletException {
        doctorDAO = new DoctorDAO();
        appointmentDAO = new AppointmentDAO();
        diagnosisReportDAO = new DiagnosisReportDAO();
        diseaseDAO = new DiseaseDAO();
        scheduleDAO = new DoctorScheduleDAO();
        patientDAO = new PatientDAO();
        auditService = new AuditService();
        billingService = new BillingService();
        medicalRecordService = new MedicalRecordService();
        notificationService = new NotificationService();
        screeningAuthorizationService = new ScreeningAuthorizationService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        Doctor doctor = user == null ? null : doctorDAO.findByUserId(user.getId());
        
        if (doctor == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Doctor profile not found.");
            return;
        }
        
        String appointmentId = req.getParameter("id");
        if (appointmentId == null || appointmentId.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/doctor/dashboard");
            return;
        }
        
        Appointment fullAppointment = appointmentDAO.findByIdFull(appointmentId);
        if (fullAppointment == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Appointment not found.");
            return;
        }
        if (!doctor.getId().equals(fullAppointment.getDoctorId())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        // Handle PDF Export only after confirming the appointment belongs to this doctor.
        String action = req.getParameter("action");
        if ("exportPdf".equalsIgnoreCase(action)) {
            if ("COMPLETED".equals(fullAppointment.getStatus())) {
                List<Prescription> prescriptions = medicalRecordService.findPrescriptionsByAppointmentId(appointmentId);
                resp.setContentType("application/pdf");
                resp.setHeader("Content-Disposition", "inline; filename=\"phieu-kham-benh-" + appointmentId.substring(0, 8) + ".pdf\"");
                try {
                    com.dermathologyai.util.PdfReportGenerator.generateAppointmentReportPdf(resp.getOutputStream(), fullAppointment, prescriptions);
                    return;
                } catch (Exception e) {
                    e.printStackTrace();
                    resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error exporting PDF: " + e.getMessage());
                    return;
                }
            }
        }
        
        List<Doctor> sameClinicDoctors = doctorDAO.findByClinicId(doctor.getClinicId());
        sameClinicDoctors.removeIf(d -> d.getId().equals(doctor.getId()));
        
        List<Prescription> prescriptions = medicalRecordService.findPrescriptionsByAppointmentId(appointmentId);
        DiagnosisReport screeningReport = null;
        if (fullAppointment.getDiagnosisReportId() != null) {
            DiagnosisReport candidate = diagnosisReportDAO.findById(fullAppointment.getDiagnosisReportId());
            if (candidate != null && fullAppointment.getPatientId().equals(candidate.getPatientId()) &&
                candidate.getAiScreeningAttemptId() != null) {
                screeningReport = candidate;
            }
        }
        // Prefer report disease/confidence when appointment join left them blank
        if (screeningReport != null) {
            if (fullAppointment.getDiseaseName() == null || fullAppointment.getDiseaseName().isBlank()) {
                fullAppointment.setDiseaseName(screeningReport.getDiseaseName());
            }
            if (fullAppointment.getConfidenceScore() <= 0) {
                fullAppointment.setConfidenceScore(screeningReport.getConfidenceScore());
            }
        }
        
        MedicalReport medicalReport = medicalRecordService.findByAppointmentId(appointmentId);
        Invoice invoice = billingService.findByAppointmentId(appointmentId);
        boolean canReviewScreening = screeningReport != null
            && "PENDING_DOCTOR_REVIEW".equals(screeningReport.getDoctorReviewStatus())
            && "ACCEPTED".equals(fullAppointment.getDoctorStatus());

        // Backend workflow flags — single source of truth for the JSP.
        boolean locked = medicalRecordService.isLocked(fullAppointment);
        boolean activeVisit = medicalRecordService.isActiveVisit(fullAppointment);
        boolean canEditPrescriptions = medicalRecordService.canEditPrescriptions(fullAppointment);
        boolean canEditTreatmentNotes = medicalRecordService.canEditTreatmentNotes(fullAppointment);
        boolean canFinalizeMedicalReport = medicalRecordService.canFinalizeMedicalReport(fullAppointment);
        boolean canCompleteAppointment = medicalRecordService.canCompleteAppointment(fullAppointment);

        req.setAttribute("doctor", doctor);
        req.setAttribute("appointment", fullAppointment);
        req.setAttribute("sameClinicDoctors", sameClinicDoctors);
        req.setAttribute("prescriptions", prescriptions);
        req.setAttribute("screeningReport", screeningReport);
        req.setAttribute("canReviewScreening", canReviewScreening);
        if (canReviewScreening) {
            req.setAttribute("diseases", diseaseDAO.findAll());
        }
        req.setAttribute("medicalReport", medicalReport);
        req.setAttribute("invoice", invoice);
        req.setAttribute("locked", locked);
        req.setAttribute("activeVisit", activeVisit);
        req.setAttribute("canEditPrescriptions", canEditPrescriptions);
        req.setAttribute("canEditTreatmentNotes", canEditTreatmentNotes);
        req.setAttribute("canFinalizeMedicalReport", canFinalizeMedicalReport);
        req.setAttribute("canCompleteAppointment", canCompleteAppointment);
        
        req.getRequestDispatcher("/WEB-INF/views/doctor/appointment-detail.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        Doctor doctor = user == null ? null : doctorDAO.findByUserId(user.getId());
        
        if (doctor == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        
        String appointmentId = req.getParameter("appointmentId");
        String action = req.getParameter("action");
        
        if (appointmentId == null || action == null) {
            resp.sendRedirect(req.getContextPath() + "/doctor/dashboard");
            return;
        }

        Appointment ownedAppointment = appointmentDAO.findByIdFull(appointmentId);
        if (ownedAppointment == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Appointment not found.");
            return;
        }
        if (!doctor.getId().equals(ownedAppointment.getDoctorId())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        
        boolean success = false;
        
        switch (action) {
            case "acceptAppointment":
                success = appointmentDAO.updateDoctorStatus(appointmentId, "ACCEPTED",
                    ownedAppointment.getDoctorNotes());
                if (success) {
                    auditService.log(user.getId(), "DOCTOR_ACCEPT_APPT", "appointments", appointmentId,
                        null, "{\"doctorStatus\":\"ACCEPTED\"}", null,
                        RequestUtil.getClientIp(req), req.getHeader("User-Agent"));
                }
                resp.sendRedirect(req.getContextPath() + "/doctor/appointments/detail?id=" + appointmentId
                    + "&success=" + success + "#ai-screening-card");
                break;

            case "saveNotes":
                // Backend rule: only CHECKED_IN / IN_PROGRESS appointments allow editing treatment notes.
                // COMPLETED, CANCELLED, NO_SHOW, CONFIRMED are rejected even on direct HTTP POST.
                if (!medicalRecordService.canEditTreatmentNotes(ownedAppointment)) {
                    resp.sendRedirect(req.getContextPath() + "/doctor/appointments/detail?id=" + appointmentId + "&error=not_checked_in#notes-card");
                    break;
                }
                String doctorNotes = req.getParameter("doctorNotes");
                success = appointmentDAO.updateDoctorStatus(appointmentId, "ACCEPTED", doctorNotes);
                if (success) {
                    auditService.log(user.getId(), "DOCTOR_SAVE_NOTES", "appointments", appointmentId, null, "{\"doctorNotes\":\"" + doctorNotes + "\"}", null, RequestUtil.getClientIp(req), req.getHeader("User-Agent"));
                }
                resp.sendRedirect(req.getContextPath() + "/doctor/appointments/detail?id=" + appointmentId + "&success=" + success + "#notes-card");
                break;

            case "reviewConfirm":
            case "reviewOverride":
            case "reviewDismiss":
            case "reviewInPerson":
                handleScreeningReview(req, resp, user, doctor, ownedAppointment, action);
                break;
                
            case "completeAppointment":
                // Backend rule: only CHECKED_IN / IN_PROGRESS appointments may be completed.
                // COMPLETED, CANCELLED, NO_SHOW, CONFIRMED are rejected here even on direct HTTP POST.
                if (!medicalRecordService.canCompleteAppointment(ownedAppointment)) {
                    resp.sendRedirect(req.getContextPath() + "/doctor/appointments/detail?id=" + appointmentId + "&error=not_checked_in#notes-card");
                    break;
                }
                success = appointmentDAO.updateStatus(appointmentId, "COMPLETED");
                if (success) {
                    Appointment completed = appointmentDAO.findByIdFull(appointmentId);
                    medicalRecordService.ensureDraftFromAppointment(completed);
                    Invoice invoice = billingService.ensureUnpaidInvoiceForAppointment(appointmentId);
                    Patient patient = patientDAO.findById(ownedAppointment.getPatientId());
                    if (patient != null && invoice != null && "UNPAID".equals(invoice.getStatus())) {
                        notificationService.enqueuePaymentPending(patient.getUserId(), invoice.getId(),
                            "Buổi khám đã hoàn tất. Bạn còn hóa đơn chưa thanh toán.");
                    }
                    auditService.log(user.getId(), "DOCTOR_COMPLETE_APPT", "appointments", appointmentId, null, "{\"status\":\"COMPLETED\"}", null, RequestUtil.getClientIp(req), req.getHeader("User-Agent"));
                }
                resp.sendRedirect(req.getContextPath() + "/doctor/appointments/detail?id=" + appointmentId + "&success=" + success + "#notes-card");
                break;

            case "finalizeMedicalReport":
                if (!medicalRecordService.canFinalizeMedicalReport(ownedAppointment)) {
                    resp.sendRedirect(req.getContextPath() + "/doctor/appointments/detail?id=" + appointmentId + "&error=locked#medical-report-card");
                    break;
                }
                String chief = req.getParameter("chiefComplaint");
                String diagnosis = req.getParameter("doctorDiagnosis");
                String treatmentPlan = req.getParameter("treatmentPlan");
                String prescriptionNote = req.getParameter("prescriptionNote");
                String followUpRaw = req.getParameter("followUpDate");
                LocalDate followUp = FormatUtil.parseDate(followUpRaw);
                if (followUpRaw != null && !followUpRaw.isBlank() && followUp == null) {
                    resp.sendRedirect(req.getContextPath() + "/doctor/appointments/detail?id=" + appointmentId
                        + "&error=true#medical-report-card");
                    break;
                }
                MedicalReport draft = medicalRecordService.ensureDraftFromAppointment(ownedAppointment);
                success = draft != null && medicalRecordService.finalizeReport(
                    ownedAppointment, appointmentId, chief, diagnosis, treatmentPlan, prescriptionNote, followUp);
                if (success) {
                    auditService.log(user.getId(), "DOCTOR_FINALIZE_MEDICAL_REPORT", "medical_reports",
                        draft.getId(), null, "{\"status\":\"SAVED\"}", null, RequestUtil.getClientIp(req), req.getHeader("User-Agent"));
                }
                resp.sendRedirect(req.getContextPath() + "/doctor/appointments/detail?id=" + appointmentId + "&success=" + success + "#medical-report-card");
                break;

            case "checkIn":
                success = appointmentDAO.checkIn(appointmentId);
                if (success) {
                    auditService.log(user.getId(), "DOCTOR_CHECK_IN", "appointments", appointmentId, null, "{\"status\":\"CHECKED_IN\",\"attendance\":\"VISITED\"}", null, RequestUtil.getClientIp(req), req.getHeader("User-Agent"));
                }
                resp.sendRedirect(req.getContextPath() + "/doctor/appointments/detail?id=" + appointmentId + "&success=" + success + "#notes-card");
                break;
                
            case "transfer":
                String newDoctorId = req.getParameter("newDoctorId");
                String transferNotes = req.getParameter("transferNotes");
                if (newDoctorId != null && !newDoctorId.trim().isEmpty()) {
                    // Overload Check
                    Appointment appt = appointmentDAO.findByIdFull(appointmentId);
                    if (appt != null) {
                        LocalDateTime apptTime = appt.getAppointmentTime();
                        java.time.LocalDate date = apptTime.toLocalDate();
                        int hour = apptTime.getHour();
                        String slot = "MORNING";
                        if (hour >= 12 && hour < 17) {
                            slot = "AFTERNOON";
                        } else if (hour >= 17) {
                            slot = "EVENING";
                        }
                        
                        DoctorSchedule sched = scheduleDAO.findByDoctorDateAndSlot(newDoctorId, date, slot);
                        if (sched != null && sched.getBookedCount() >= sched.getMaxPatients()) {
                            resp.sendRedirect(req.getContextPath() + "/doctor/appointments/detail?id=" + appointmentId + "&error=overload");
                            return;
                        }
                    }
                    success = appointmentDAO.transferDoctor(appointmentId, newDoctorId, transferNotes);
                    if (success) {
                        auditService.log(user.getId(), "DOCTOR_TRANSFER_APPT", "appointments", appointmentId, null, "{\"newDoctorId\":\"" + newDoctorId + "\"}", null, RequestUtil.getClientIp(req), req.getHeader("User-Agent"));
                    }
                }
                if (success) {
                    resp.sendRedirect(req.getContextPath() + "/doctor/dashboard?transferSuccess=true");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/doctor/appointments/detail?id=" + appointmentId + "&error=true");
                }
                break;
                
            case "addPrescription":
                // Backend rule: only CHECKED_IN / IN_PROGRESS appointments allow adding prescriptions.
                // Service layer re-checks status before touching the DAO.
                if (!medicalRecordService.canEditPrescriptions(ownedAppointment)) {
                    resp.sendRedirect(req.getContextPath() + "/doctor/appointments/detail?id=" + appointmentId + "&error=not_checked_in#prescription-card");
                    break;
                }
                String drugName = req.getParameter("drugName");
                if ("custom".equals(drugName)) {
                    drugName = req.getParameter("customDrugName");
                }
                String qtyStr = req.getParameter("quantity");
                String dosage = req.getParameter("dosage");
                int quantity = 1;
                try {
                    quantity = Integer.parseInt(qtyStr);
                } catch (NumberFormatException ignored) {}
                
                if (drugName != null && !drugName.trim().isEmpty() && dosage != null && !dosage.trim().isEmpty()) {
                    Prescription p = new Prescription();
                    p.setAppointmentId(appointmentId);
                    p.setDrugName(drugName.trim());
                    p.setQuantity(quantity);
                    p.setDosage(dosage.trim());
                    success = medicalRecordService.addPrescription(ownedAppointment, p);
                    if (success) {
                        auditService.log(user.getId(), "DOCTOR_ADD_PRESCRIPTION", "appointments", appointmentId, null, "{\"drugName\":\"" + drugName + "\"}", null, RequestUtil.getClientIp(req), req.getHeader("User-Agent"));
                    }
                }
                resp.sendRedirect(req.getContextPath() + "/doctor/appointments/detail?id=" + appointmentId + "&success=" + success + "#prescription-card");
                break;
                
            case "deletePrescription":
                // Backend rule: only CHECKED_IN / IN_PROGRESS appointments allow deleting prescriptions.
                // MedicalRecordService.deletePrescription also verifies row ownership.
                if (!medicalRecordService.canEditPrescriptions(ownedAppointment)) {
                    resp.sendRedirect(req.getContextPath() + "/doctor/appointments/detail?id=" + appointmentId + "&error=not_checked_in#prescription-card");
                    break;
                }
                String prescriptionId = req.getParameter("prescriptionId");
                if (prescriptionId != null) {
                    success = medicalRecordService.deletePrescription(ownedAppointment, prescriptionId);
                    if (success) {
                        auditService.log(user.getId(), "DOCTOR_DELETE_PRESCRIPTION", "appointment_prescriptions", prescriptionId, null, null, null, RequestUtil.getClientIp(req), req.getHeader("User-Agent"));
                    }
                }
                resp.sendRedirect(req.getContextPath() + "/doctor/appointments/detail?id=" + appointmentId + "&success=" + success + "#prescription-card");
                break;
                
            default:
                resp.sendRedirect(req.getContextPath() + "/doctor/dashboard");
                break;
        }
    }

    private void handleScreeningReview(HttpServletRequest req, HttpServletResponse resp,
                                       User user, Doctor doctor, Appointment appointment, String action)
            throws IOException {
        String reportId = appointment.getDiagnosisReportId();
        DiagnosisReport report = reportId == null ? null : diagnosisReportDAO.findById(reportId);
        if (report == null
            || !appointment.getPatientId().equals(report.getPatientId())
            || !"PENDING_DOCTOR_REVIEW".equals(report.getDoctorReviewStatus())
            || !"ACCEPTED".equals(appointment.getDoctorStatus())
            || screeningAuthorizationService.requireAuthorizedDoctor(user, report.getPatientId(), Permission.AI_SCREENING_REVIEW) == null) {
            resp.sendRedirect(req.getContextPath() + "/doctor/appointments/detail?id=" + appointment.getId()
                + "&error=review_denied#ai-screening-card");
            return;
        }

        String status;
        String selectedDiseaseId = null;
        String overrideReason = null;
        if ("reviewConfirm".equals(action)) {
            status = "CONFIRMED";
            selectedDiseaseId = report.getAiSuggestedDiseaseId();
        } else if ("reviewOverride".equals(action)) {
            if (screeningAuthorizationService.requireAuthorizedDoctor(user, report.getPatientId(), Permission.AI_SCREENING_OVERRIDE) == null) {
                resp.sendRedirect(req.getContextPath() + "/doctor/appointments/detail?id=" + appointment.getId()
                    + "&error=review_denied#ai-screening-card");
                return;
            }
            status = "OVERRIDDEN";
            selectedDiseaseId = trim(req.getParameter("selectedDiseaseId"));
            overrideReason = trim(req.getParameter("overrideReason"));
            if (selectedDiseaseId == null || overrideReason == null || diseaseDAO.findById(selectedDiseaseId) == null) {
                resp.sendRedirect(req.getContextPath() + "/doctor/appointments/detail?id=" + appointment.getId()
                    + "&error=override_required#ai-screening-card");
                return;
            }
        } else if ("reviewDismiss".equals(action)) {
            status = "DISMISSED";
        } else if ("reviewInPerson".equals(action)) {
            status = "REQUIRES_IN_PERSON_REVIEW";
        } else {
            resp.sendRedirect(req.getContextPath() + "/doctor/appointments/detail?id=" + appointment.getId());
            return;
        }

        boolean visible = !"reviewDismiss".equals(action) && "on".equals(req.getParameter("visibleToPatient"));
        boolean updated = diagnosisReportDAO.applyDoctorReview(
            report.getId(), doctor.getId(), status, selectedDiseaseId, overrideReason,
            trim(req.getParameter("doctorNote")), trim(req.getParameter("patientGuidance")), visible);
        if (!updated) {
            resp.sendRedirect(req.getContextPath() + "/doctor/appointments/detail?id=" + appointment.getId()
                + "&error=review_stale#ai-screening-card");
            return;
        }
        auditService.log(user.getId(), "AI_SCREENING_DOCTOR_" + status, "diagnosis_reports", report.getId(),
            null, null, null, RequestUtil.getClientIp(req), req.getHeader("User-Agent"));
        resp.sendRedirect(req.getContextPath() + "/doctor/appointments/detail?id=" + appointment.getId()
            + "&screeningReviewed=1#ai-screening-card");
    }

    private static String trim(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}
