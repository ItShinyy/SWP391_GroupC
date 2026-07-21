package com.dermathologyai.controller.patient;

import com.dermathologyai.dao.FamilyMemberDAO;
import com.dermathologyai.dao.MedicalReportDAO;
import com.dermathologyai.dao.PatientDAO;
import com.dermathologyai.model.FamilyMember;
import com.dermathologyai.model.MedicalReport;
import com.dermathologyai.model.Patient;
import com.dermathologyai.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;

public class MedicalRecordsController extends HttpServlet {
    private MedicalReportDAO medicalReportDAO;
    private PatientDAO patientDAO;
    private FamilyMemberDAO familyMemberDAO;

    @Override
    public void init() {
        medicalReportDAO = new MedicalReportDAO();
        patientDAO = new PatientDAO();
        familyMemberDAO = new FamilyMemberDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        Patient patient = patientDAO.findByUserId(user.getId());
        if (patient == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy hồ sơ bệnh nhân.");
            return;
        }

        if ("view".equals(request.getParameter("action"))) {
            showDetail(request, response, user, patient);
            return;
        }
        showList(request, response, user, patient);
    }

    private void showList(HttpServletRequest request, HttpServletResponse response,
                          User user, Patient patient) throws ServletException, IOException {
        List<FamilyMember> familyMembers = familyMemberDAO.findByOwnerUserId(user.getId());
        String person = normalize(request.getParameter("person"));
        String familyMemberId = null;
        String selectedPersonLabel = "Tôi - " + user.getFullName();

        if (person != null && person.startsWith("FAMILY:")) {
            String requestedId = person.substring("FAMILY:".length());
            FamilyMember familyMember = familyMemberDAO.findByIdAndOwnerUserId(requestedId, user.getId());
            if (familyMember == null) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền xem hồ sơ của người này.");
                return;
            }
            familyMemberId = familyMember.getId();
            selectedPersonLabel = relationshipLabel(familyMember.getRelationship()) + " - " + familyMember.getFullName();
            person = "FAMILY:" + familyMember.getId();
        } else {
            person = "SELF";
        }

        String search = normalize(request.getParameter("search"));
        String sort = "oldest".equalsIgnoreCase(request.getParameter("sort")) ? "oldest" : "newest";
        LocalDate fromDate = parseDate(request.getParameter("fromDate"));
        LocalDate toDate = parseDate(request.getParameter("toDate"));

        List<MedicalReport> reports = medicalReportDAO.findForExaminedPerson(
                patient.getId(), familyMemberId, search, fromDate, toDate, sort);
        for (MedicalReport report : reports) {
            if (report.getPrescriptionCount() > 0) {
                report.setPrescriptions(medicalReportDAO.findPrescriptionsByAppointmentId(report.getAppointmentId()));
            }
        }

        request.setAttribute("familyMembers", familyMembers);
        request.setAttribute("selectedPerson", person);
        request.setAttribute("selectedPersonLabel", selectedPersonLabel);
        request.setAttribute("reports", reports);
        request.setAttribute("search", search == null ? "" : search);
        request.setAttribute("fromDate", fromDate == null ? "" : fromDate.toString());
        request.setAttribute("toDate", toDate == null ? "" : toDate.toString());
        request.setAttribute("sort", sort);
        request.getRequestDispatcher("/WEB-INF/views/patient/medical-records.jsp").forward(request, response);
    }

    private void showDetail(HttpServletRequest request, HttpServletResponse response,
                            User user, Patient patient) throws ServletException, IOException {
        String id = normalize(request.getParameter("id"));
        if (id == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu mã hồ sơ bệnh án.");
            return;
        }

        MedicalReport report = medicalReportDAO.findByIdForPatient(id, patient.getId());
        if (report == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy hồ sơ bệnh án.");
            return;
        }

        String person;
        String examinedPersonLabel;
        if (report.getFamilyMemberId() == null) {
            person = "SELF";
            examinedPersonLabel = "Tôi - " + user.getFullName();
        } else {
            FamilyMember familyMember = familyMemberDAO.findByIdAndOwnerUserId(
                    report.getFamilyMemberId(), user.getId());
            if (familyMember == null) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền xem hồ sơ này.");
                return;
            }
            person = "FAMILY:" + familyMember.getId();
            examinedPersonLabel = relationshipLabel(familyMember.getRelationship()) + " - " + familyMember.getFullName();
        }

        request.setAttribute("report", report);
        request.setAttribute("selectedPerson", person);
        request.setAttribute("examinedPersonLabel", examinedPersonLabel);
        request.getRequestDispatcher("/WEB-INF/views/patient/medical-record-detail.jsp").forward(request, response);
    }

    private static LocalDate parseDate(String value) {
        if (value == null || value.isBlank()) return null;
        try {
            return LocalDate.parse(value);
        } catch (DateTimeParseException ignored) {
            return null;
        }
    }

    private static String normalize(String value) {
        if (value == null) return null;
        String normalized = value.trim();
        return normalized.isEmpty() ? null : normalized;
    }

    private static String relationshipLabel(String relationship) {
        if (relationship == null) return "Người thân";
        return switch (relationship) {
            case "FATHER" -> "Bố";
            case "MOTHER" -> "Mẹ";
            case "SPOUSE" -> "Vợ/Chồng";
            case "CHILD" -> "Con";
            case "OLDER_BROTHER" -> "Anh";
            case "OLDER_SISTER" -> "Chị";
            case "YOUNGER_BROTHER" -> "Em trai";
            case "YOUNGER_SISTER" -> "Em gái";
            case "GRANDPARENT" -> "Ông/Bà";
            default -> "Người thân";
        };
    }
}
