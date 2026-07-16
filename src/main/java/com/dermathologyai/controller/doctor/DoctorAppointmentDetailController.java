package com.dermathologyai.controller.doctor;

import com.dermathologyai.dao.AppointmentDAO;
import com.dermathologyai.dao.DoctorDAO;
import com.dermathologyai.dao.AppointmentLabTestDAO;
import com.dermathologyai.model.Appointment;
import com.dermathologyai.model.Doctor;
import com.dermathologyai.model.AppointmentLabTest;
import com.dermathologyai.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * Controller xử lý xem chi tiết hồ sơ bệnh nhân, ghi nhận xét, chuyển viện/bác sĩ,
 * chỉ định xét nghiệm và cập nhật kết quả xét nghiệm dành cho Bác sĩ.
 */
public class DoctorAppointmentDetailController extends HttpServlet {
    private DoctorDAO doctorDAO;
    private AppointmentDAO appointmentDAO;
    private AppointmentLabTestDAO labTestDAO;

    @Override
    public void init() throws ServletException {
        doctorDAO = new DoctorDAO();
        appointmentDAO = new AppointmentDAO();
        labTestDAO = new AppointmentLabTestDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("user");
        Doctor doctor = doctorDAO.findByUserId(user.getId());
        
        if (doctor == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Doctor profile not found.");
            return;
        }
        
        // Lấy ID lịch hẹn từ tham số yêu cầu
        String appointmentId = req.getParameter("id");
        if (appointmentId == null || appointmentId.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/doctor/dashboard");
            return;
        }
        
        // Nạp thông tin lịch hẹn chi tiết đầy đủ (bệnh nhân, AI report) bằng truy vấn tối ưu
        Appointment fullAppointment = appointmentDAO.findByIdFull(appointmentId);
        
        if (fullAppointment == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Appointment not found.");
            return;
        }
        
        // Lấy danh sách bác sĩ khác cùng phòng khám để phục vụ tính năng chuyển bệnh án
        List<Doctor> sameClinicDoctors = doctorDAO.findByClinicId(doctor.getClinicId());
        sameClinicDoctors.removeIf(d -> d.getId().equals(doctor.getId())); // Loại trừ chính bác sĩ hiện tại
        
        // Lấy danh sách các xét nghiệm đã chỉ định cho lịch hẹn này
        List<AppointmentLabTest> labTests = labTestDAO.findByAppointmentId(appointmentId);
        
        // Gắn dữ liệu bác sĩ, lịch hẹn, danh sách bác sĩ cùng phòng khám và các xét nghiệm vào request
        req.setAttribute("doctor", doctor);
        req.setAttribute("appointment", fullAppointment);
        req.setAttribute("sameClinicDoctors", sameClinicDoctors);
        req.setAttribute("labTests", labTests);
        
        // Forward tới trang chi tiết lịch hẹn của bác sĩ
        req.getRequestDispatcher("/WEB-INF/views/doctor/appointment-detail.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("user");
        Doctor doctor = doctorDAO.findByUserId(user.getId());
        
        if (doctor == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        
        String appointmentId = req.getParameter("appointmentId");
        String action = req.getParameter("action"); // "saveNotes", "transfer", "orderTest", "submitMockResult"
        
        if (appointmentId == null || action == null) {
            resp.sendRedirect(req.getContextPath() + "/doctor/dashboard");
            return;
        }
        
        boolean success = false;
        
        switch (action) {
            case "saveNotes":
                String doctorNotes = req.getParameter("doctorNotes");
                success = appointmentDAO.updateDoctorStatus(appointmentId, "ACCEPTED", doctorNotes);
                resp.sendRedirect(req.getContextPath() + "/doctor/appointments/detail?id=" + appointmentId + "&success=" + success);
                break;
                
            case "completeAppointment":
                success = appointmentDAO.updateStatus(appointmentId, "COMPLETED");
                resp.sendRedirect(req.getContextPath() + "/doctor/appointments/detail?id=" + appointmentId + "&success=" + success);
                break;
                
            case "transfer":
                String newDoctorId = req.getParameter("newDoctorId");
                String transferNotes = req.getParameter("transferNotes");
                if (newDoctorId != null && !newDoctorId.trim().isEmpty()) {
                    success = appointmentDAO.transferDoctor(appointmentId, newDoctorId, transferNotes);
                }
                if (success) {
                    // Chuyển hồ sơ thành công thì quay về Dashboard (hồ sơ này không còn thuộc bác sĩ hiện tại nữa)
                    resp.sendRedirect(req.getContextPath() + "/doctor/dashboard?transferSuccess=true");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/doctor/appointments/detail?id=" + appointmentId + "&error=true");
                }
                break;
                
            case "orderTest":
                String[] testNames = req.getParameterValues("testNames");
                if (testNames != null && testNames.length > 0) {
                    for (String testName : testNames) {
                        AppointmentLabTest test = new AppointmentLabTest();
                        test.setAppointmentId(appointmentId);
                        test.setTestName(testName);
                        test.setStatus("PENDING");
                        labTestDAO.create(test);
                    }
                    success = true;
                }
                resp.sendRedirect(req.getContextPath() + "/doctor/appointments/detail?id=" + appointmentId + "&success=" + success);
                break;
                
            case "submitMockResult":
                String testId = req.getParameter("testId");
                String preset = req.getParameter("preset"); // "positive", "negative", "suspicious"
                String resultSummary = req.getParameter("resultSummary");
                String testName = req.getParameter("testName");
                
                if (testId != null && resultSummary != null) {
                    AppointmentLabTest test = new AppointmentLabTest();
                    test.setId(testId);
                    test.setTestName(testName);
                    test.setResultSummary(resultSummary);
                    
                    // Lấy đầy đủ thông tin bệnh nhân và bác sĩ vẽ lên PDF
                    Appointment appt = appointmentDAO.findByIdFull(appointmentId);
                    
                    try {
                        String destFolder = req.getServletContext().getRealPath("/uploads/lab_results");
                        // Tự động vẽ và xuất file PDF lưu trữ trên máy chủ
                        String pdfRelativeUrl = com.dermathologyai.util.PdfReportGenerator.generateLabTestPdf(destFolder, test, appt);
                        
                        // Cập nhật đường dẫn file PDF vừa sinh vào database
                        success = labTestDAO.updateResult(testId, resultSummary, pdfRelativeUrl);
                    } catch (Exception e) {
                        e.printStackTrace();
                        success = false;
                    }
                }
                resp.sendRedirect(req.getContextPath() + "/doctor/appointments/detail?id=" + appointmentId + "&success=" + success);
                break;
                
            default:
                resp.sendRedirect(req.getContextPath() + "/doctor/dashboard");
                break;
        }
    }
}
