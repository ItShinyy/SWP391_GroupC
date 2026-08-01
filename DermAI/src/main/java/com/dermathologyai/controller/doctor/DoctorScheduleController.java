package com.dermathologyai.controller.doctor;

import com.dermathologyai.dao.AppointmentDAO;
import com.dermathologyai.dao.DoctorDAO;
import com.dermathologyai.dao.DoctorScheduleDAO;
import com.dermathologyai.model.Appointment;
import com.dermathologyai.model.Doctor;
import com.dermathologyai.model.DoctorSchedule;
import com.dermathologyai.model.User;
import com.dermathologyai.util.InputValidator;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

public class DoctorScheduleController extends HttpServlet {
    private DoctorDAO doctorDAO;
    private DoctorScheduleDAO scheduleDAO;
    private AppointmentDAO appointmentDAO;

    @Override
    public void init() throws ServletException {
        // Khởi tạo các DAO truy cập cơ sở dữ liệu
        doctorDAO = new DoctorDAO();
        scheduleDAO = new DoctorScheduleDAO();
        appointmentDAO = new AppointmentDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Lấy session hiện tại
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("user");
        // Tìm thông tin bác sĩ từ tài khoản đăng nhập
        Doctor doctor = doctorDAO.findByUserId(user.getId());
        
        if (doctor == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy hồ sơ bác sĩ.");
            return;
        }
        
        // Phân tích tham số tuần (week offset) từ URL để biết đang xem tuần hiện tại (0), tuần trước (-1) hay tuần sau (1)
        int weekOffset = 0;
        try {
            String weekParam = req.getParameter("week");
            if (weekParam != null) {
                weekOffset = Integer.parseInt(weekParam);
            }
        } catch (NumberFormatException ignored) {}
        
        // Tính toán khoảng ngày cho tuần được chọn (căn lề theo Thứ Hai đầu tuần)
        LocalDate today = LocalDate.now();
        LocalDate mondayOfThisWeek = today.with(java.time.DayOfWeek.MONDAY);
        LocalDate weekStart = mondayOfThisWeek.plusWeeks(weekOffset);
        LocalDate weekEnd = weekStart.plusDays(6); // 7 ngày trong tuần từ Thứ Hai đến Chủ Nhật
        
        // Truy vấn danh sách lịch làm việc đã đăng ký của bác sĩ trong khoảng ngày của tuần này
        List<DoctorSchedule> existingSchedules = scheduleDAO.findByDoctorAndDateRange(doctor.getId(), weekStart, weekEnd);
        
        // Chuyển danh sách lịch làm việc thành Map dạng "ngày_khunggiờ" -> DoctorSchedule để tra cứu nhanh
        Map<String, DoctorSchedule> scheduleMap = new HashMap<>();
        for (DoctorSchedule s : existingSchedules) {
            scheduleMap.put(s.getScheduleDate() + "_" + s.getSlot(), s);
        }

        // Default: Mon–Fri all slots open, Sat–Sun closed (only fills missing rows; never overwrites saved prefs)
        ensureWeekDefaults(doctor.getId(), weekStart, scheduleMap);
        
        // Truy vấn tất cả lịch hẹn của bác sĩ trong tuần này để thống kê số lượng bệnh nhân đã đặt
        List<Appointment> weekAppointments = appointmentDAO.findByDoctorAndDateRange(doctor.getId(), weekStart, weekEnd);
        
        // Xây dựng danh sách 7 ngày trong tuần để truyền sang JSP hiển thị giao diện lưới (Grid)
        List<DayScheduleDto> weekDays = new ArrayList<>();
        for (int i = 0; i < 7; i++) {
            LocalDate date = weekStart.plusDays(i);
            DayScheduleDto dto = new DayScheduleDto();
            dto.setDayName(getDayNameVN(date)); // Lấy tên thứ bằng tiếng Việt
            dto.setDateFormatted(date.format(DateTimeFormatter.ofPattern("dd/MM"))); // Định dạng ngày dd/MM để hiển thị
            dto.setDateValue(date.toString()); // Giá trị ngày định dạng yyyy-MM-dd để submit form
            dto.setToday(date.equals(today)); // Kiểm tra xem ngày này có phải hôm nay hay không
            
            // Trạng thái khả dụng (trống lịch/nhận khám) cho từng khung giờ
            DoctorSchedule morningSch = scheduleMap.get(date + "_MORNING");
            DoctorSchedule afternoonSch = scheduleMap.get(date + "_AFTERNOON");
            DoctorSchedule eveningSch = scheduleMap.get(date + "_EVENING");
            
            dto.setMorningAvailable(morningSch != null && morningSch.isAvailable());
            dto.setAfternoonAvailable(afternoonSch != null && afternoonSch.isAvailable());
            dto.setEveningAvailable(eveningSch != null && eveningSch.isAvailable());
            
            dto.setMorningMax(morningSch != null ? morningSch.getMaxPatients() : 5);
            dto.setAfternoonMax(afternoonSch != null ? afternoonSch.getMaxPatients() : 5);
            dto.setEveningMax(eveningSch != null ? eveningSch.getMaxPatients() : 5);

            // Match patient booking capacity (doctor_schedules.booked_count)
            dto.setMorningCount(morningSch != null ? morningSch.getBookedCount() : 0);
            dto.setAfternoonCount(afternoonSch != null ? afternoonSch.getBookedCount() : 0);
            dto.setEveningCount(eveningSch != null ? eveningSch.getBookedCount() : 0);
            
            weekDays.add(dto);
        }
        
        // Upcoming: any live appointment this week (same universe as patient bookings)
        List<UpcomingAppointmentDto> upcomingAppointments = new ArrayList<>();
        for (Appointment a : weekAppointments) {
            if ("CANCELLED".equals(a.getStatus()) || "NO_SHOW".equals(a.getStatus())) continue;
            UpcomingAppointmentDto dto = new UpcomingAppointmentDto();
            dto.setPatientName(a.getPatientName() != null ? a.getPatientName() : "N/A");
            dto.setAppointmentDate(a.getAppointmentTime().format(DateTimeFormatter.ofPattern("dd/MM/yyyy")));
            dto.setTimeSlot(getSlotFromTime(a.getAppointmentTime()));
            dto.setStatus(a.getStatus());
            upcomingAppointments.add(dto);
        }
        
        // Thiết lập các thuộc tính gửi lên JSP
        req.setAttribute("doctor", doctor);
        req.setAttribute("weekDays", weekDays);
        req.setAttribute("upcomingAppointments", upcomingAppointments);
        req.setAttribute("weekStart", weekStart.format(DateTimeFormatter.ofPattern("dd/MM/yyyy")));
        req.setAttribute("weekEnd", weekEnd.format(DateTimeFormatter.ofPattern("dd/MM/yyyy")));
        req.setAttribute("weekStartValue", weekStart.toString());
        req.setAttribute("prevWeek", weekOffset - 1);
        req.setAttribute("nextWeek", weekOffset + 1);
        
        // Chuyển tiếp tới giao diện quản lý lịch khám
        req.getRequestDispatcher("/WEB-INF/views/doctor/schedule.jsp").forward(req, resp);
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
        
        // Đọc ngày bắt đầu của tuần đang cập nhật
        String weekStartParam = req.getParameter("weekStart");
        if (weekStartParam == null || weekStartParam.isBlank()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "weekStart is required.");
            return;
        }
        LocalDate weekStart;
        try {
            weekStart = LocalDate.parse(weekStartParam.trim());
        } catch (Exception e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid weekStart date.");
            return;
        }

        String[] slots = {"MORNING", "AFTERNOON", "EVENING"};

        // Duyệt qua 7 ngày trong tuần và cập nhật lịch cho cả 3 khung giờ
        for (int i = 0; i < 7; i++) {
            LocalDate date = weekStart.plusDays(i);
            for (String slot : slots) {
                InputValidator.requireValidScheduleSlot(slot);
                String paramName = "slot_" + date + "_" + slot;
                String available = req.getParameter(paramName);
                String maxParam = req.getParameter("max_" + date + "_" + slot);
                int maxPatients = 5;
                if (maxParam != null && !maxParam.isBlank()) {
                    try {
                        maxPatients = Integer.parseInt(maxParam.trim());
                    } catch (NumberFormatException e) {
                        resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid max patients.");
                        return;
                    }
                }
                if (maxPatients < 1) {
                    resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "max patients must be >= 1.");
                    return;
                }

                DoctorSchedule schedule = new DoctorSchedule();
                schedule.setDoctorId(doctor.getId());
                schedule.setScheduleDate(date);
                schedule.setSlot(slot);
                schedule.setAvailable(available != null);
                schedule.setMaxPatients(maxPatients);
                scheduleDAO.upsertSchedule(schedule);
            }
        }
        
        // Tính toán độ lệch tuần (weekOffset) hiện tại so với Thứ Hai tuần này để redirect về đúng tuần đang xem
        LocalDate today = LocalDate.now();
        LocalDate mondayOfThisWeek = today.with(java.time.DayOfWeek.MONDAY);
        long daysDiff = java.time.temporal.ChronoUnit.DAYS.between(mondayOfThisWeek, weekStart);
        long weekOffset = daysDiff / 7;
        
        // Redirect về trang GET kèm thông báo cập nhật thành công và hiển thị đúng tuần vừa cập nhật
        resp.sendRedirect(req.getContextPath() + "/doctor/schedule?week=" + weekOffset + "&success=true");
    }
    
    /** Mon–Fri open by default; Sat–Sun closed. Only inserts missing rows. */
    private void ensureWeekDefaults(String doctorId, LocalDate weekStart, Map<String, DoctorSchedule> scheduleMap) {
        String[] slots = {"MORNING", "AFTERNOON", "EVENING"};
        for (int i = 0; i < 7; i++) {
            LocalDate date = weekStart.plusDays(i);
            boolean weekday = isWeekday(date);
            for (String slot : slots) {
                String key = date + "_" + slot;
                if (scheduleMap.containsKey(key)) continue;
                DoctorSchedule schedule = new DoctorSchedule();
                schedule.setDoctorId(doctorId);
                schedule.setScheduleDate(date);
                schedule.setSlot(slot);
                schedule.setAvailable(weekday);
                schedule.setMaxPatients(5);
                scheduleDAO.upsertSchedule(schedule);
                scheduleMap.put(key, schedule);
            }
        }
    }

    private static boolean isWeekday(LocalDate date) {
        java.time.DayOfWeek day = date.getDayOfWeek();
        return day != java.time.DayOfWeek.SATURDAY && day != java.time.DayOfWeek.SUNDAY;
    }

    // Hàm chuyển đổi thứ sang định dạng tiếng Việt
    private String getDayNameVN(LocalDate date) {
        if (date.equals(LocalDate.now())) {
            return "Hôm nay";
        }
        return switch (date.getDayOfWeek()) {
            case MONDAY -> "Thứ Hai";
            case TUESDAY -> "Thứ Ba";
            case WEDNESDAY -> "Thứ Tư";
            case THURSDAY -> "Thứ Năm";
            case FRIDAY -> "Thứ Sáu";
            case SATURDAY -> "Thứ Bảy";
            case SUNDAY -> "Chủ Nhật";
        };
    }
    
    // Hàm phân tích giờ khám để quy về khung giờ MORNING/AFTERNOON/EVENING
    private String getSlotFromTime(LocalDateTime time) {
        int hour = time.getHour();
        if (hour >= 7 && hour < 12) return "MORNING";
        if (hour >= 12 && hour < 18) return "AFTERNOON";
        if (hour >= 18 && hour < 22) return "EVENING";
        return "MORNING";
    }
    
    // Lớp DTO trung chuyển dữ liệu lịch khám mỗi ngày để hiển thị lên bảng giao diện JSP
    public static class DayScheduleDto {
        private String dayName;            // Tên thứ (Thứ Hai, Thứ Ba...) hoặc "Hôm nay"
        private String dateFormatted;      // Ngày định dạng dd/MM để hiển thị
        private String dateValue;          // Ngày định dạng yyyy-MM-dd để dùng trong code
        private boolean morningAvailable;   // Ca sáng có nhận bệnh không
        private boolean afternoonAvailable; // Ca chiều có nhận bệnh không
        private boolean eveningAvailable;   // Ca tối có nhận bệnh không
        private int morningCount;          // Số ca đã đặt trong ca sáng
        private int afternoonCount;        // Số ca đã đặt trong ca chiều
        private int eveningCount;          // Số ca đã đặt trong ca tối
        private int morningMax;            // Số ca tối đa ca sáng
        private int afternoonMax;          // Số ca tối đa ca chiều
        private int eveningMax;            // Số ca tối đa ca tối
        private boolean isToday;           // Có phải ngày hôm nay không

        public String getDayName() { return dayName; }
        public void setDayName(String dayName) { this.dayName = dayName; }

        public String getDateFormatted() { return dateFormatted; }
        public void setDateFormatted(String dateFormatted) { this.dateFormatted = dateFormatted; }

        public String getDateValue() { return dateValue; }
        public void setDateValue(String dateValue) { this.dateValue = dateValue; }

        public boolean isMorningAvailable() { return morningAvailable; }
        public void setMorningAvailable(boolean morningAvailable) { this.morningAvailable = morningAvailable; }

        public boolean isAfternoonAvailable() { return afternoonAvailable; }
        public void setAfternoonAvailable(boolean afternoonAvailable) { this.afternoonAvailable = afternoonAvailable; }

        public boolean isEveningAvailable() { return eveningAvailable; }
        public void setEveningAvailable(boolean eveningAvailable) { this.eveningAvailable = eveningAvailable; }

        public int getMorningCount() { return morningCount; }
        public void setMorningCount(int morningCount) { this.morningCount = morningCount; }

        public int getAfternoonCount() { return afternoonCount; }
        public void setAfternoonCount(int afternoonCount) { this.afternoonCount = afternoonCount; }

        public int getEveningCount() { return eveningCount; }
        public void setEveningCount(int eveningCount) { this.eveningCount = eveningCount; }

        public int getMorningMax() { return morningMax; }
        public void setMorningMax(int morningMax) { this.morningMax = morningMax; }

        public int getAfternoonMax() { return afternoonMax; }
        public void setAfternoonMax(int afternoonMax) { this.afternoonMax = afternoonMax; }

        public int getEveningMax() { return eveningMax; }
        public void setEveningMax(int eveningMax) { this.eveningMax = eveningMax; }

        public boolean getIsToday() { return isToday; }
        public void setToday(boolean isToday) { this.isToday = isToday; }
    }

    // Lớp DTO trung chuyển dữ liệu lịch hẹn sắp tới
    public static class UpcomingAppointmentDto {
        private String patientName;     // Tên bệnh nhân
        private String appointmentDate; // Ngày hẹn khám
        private String timeSlot;        // Khung giờ hẹn
        private String status;          // Trạng thái lâm sàng lịch hẹn

        public String getPatientName() { return patientName; }
        public void setPatientName(String patientName) { this.patientName = patientName; }

        public String getAppointmentDate() { return appointmentDate; }
        public void setAppointmentDate(String appointmentDate) { this.appointmentDate = appointmentDate; }

        public String getTimeSlot() { return timeSlot; }
        public void setTimeSlot(String timeSlot) { this.timeSlot = timeSlot; }

        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }
    }
}
