<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/doctor-header.jsp" />

<style>
    .schedule-card {
        border-radius: 16px;
        border: none;
        overflow: hidden;
    }
    .day-column {
        padding: 1rem;
        text-align: center;
        border-right: 1px solid #f1f5f9;
        min-width: 140px;
    }
    .day-column:last-child { border-right: none; }
    .day-header {
        font-weight: 700;
        font-size: 0.85rem;
        color: #0f172a;
        margin-bottom: 0.3rem;
    }
    .day-date {
        font-size: 0.75rem;
        color: #94a3b8;
        font-weight: 500;
    }
    .day-today {
        background: linear-gradient(135deg, #eff6ff, #dbeafe);
    }
    .slot-item {
        padding: 0.8rem;
        border-radius: 10px;
        margin: 0.5rem 0;
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        transition: all 0.2s;
        min-height: 145px;
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        align-items: center;
    }
    .slot-item:hover {
        border-color: #93c5fd;
    }
    .slot-item.slot-available {
        background: linear-gradient(135deg, #f0fdf4, #dcfce7);
        border-color: #86efac;
    }
    .slot-item.slot-unavailable {
        background: #f8fafc;
        border-color: #e2e8f0;
        opacity: 0.7;
    }
    .slot-name {
        font-size: 0.75rem;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.3px;
    }
    .slot-time {
        font-size: 0.65rem;
        color: #94a3b8;
        margin-top: 2px;
    }
    .form-switch .form-check-input {
        width: 2.5rem;
        height: 1.25rem;
        cursor: pointer;
    }
    .form-switch .form-check-input:checked {
        background-color: #22c55e;
        border-color: #22c55e;
    }
    .form-switch .form-check-input:focus {
        box-shadow: 0 0 0 0.2rem rgba(34, 197, 94, 0.25);
    }

    .week-nav-btn {
        padding: 0.5rem 1rem;
        border-radius: 8px;
        font-size: 0.85rem;
        font-weight: 600;
        color: #475569;
        background: white;
        border: 1px solid #e2e8f0;
        text-decoration: none;
        transition: all 0.2s ease;
        display: inline-flex;
        align-items: center;
        gap: 0.3rem;
    }
    .week-nav-btn:hover {
        background: #f1f5f9;
        color: #0f172a;
        border-color: #cbd5e1;
        transform: translateY(-1px);
    }

    .week-label {
        font-size: 1rem;
        font-weight: 700;
        color: #0f172a;
    }

    .schedule-header {
        background: linear-gradient(135deg, #1e3a8a 0%, #3b82f6 100%);
        border-radius: 16px 16px 0 0;
        padding: 1.5rem 2rem;
        color: white;
    }

    .btn-save-schedule {
        padding: 0.7rem 2rem;
        border-radius: 10px;
        font-weight: 700;
        font-size: 0.95rem;
        background: linear-gradient(135deg, #22c55e, #16a34a);
        color: white;
        border: none;
        transition: all 0.2s;
    }
    .btn-save-schedule:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(34, 197, 94, 0.4);
        color: white;
    }

    .appointment-count {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 22px;
        height: 22px;
        border-radius: 50%;
        background: #3b82f6;
        color: white;
        font-size: 0.65rem;
        font-weight: 700;
        margin-top: 4px;
    }
</style>

<div class="container-fluid py-4 px-4">

    <!-- Success/Error Alerts -->
    <c:if test="${param.success == 'true'}">
        <div class="alert alert-success alert-dismissible fade show rounded-3 border-0 shadow-sm" role="alert">
            <i class="fa-solid fa-circle-check me-2"></i>Cập nhật lịch khám thành công!
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>
    <c:if test="${param.error == 'true'}">
        <div class="alert alert-danger alert-dismissible fade show rounded-3 border-0 shadow-sm" role="alert">
            <i class="fa-solid fa-circle-exclamation me-2"></i>Có lỗi xảy ra khi cập nhật lịch. Vui lòng thử lại.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <!-- Page Title -->
    <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-3">
        <h4 class="fw-bold mb-0">
            <i class="fa-regular fa-calendar-check me-2 text-primary"></i>Quản Lý Lịch Khám
        </h4>
        <!-- Week Navigation -->
        <div class="d-flex align-items-center gap-3">
            <a href="${pageContext.request.contextPath}/doctor/schedule?week=${prevWeek}" class="week-nav-btn">
                <i class="fa-solid fa-chevron-left"></i> Tuần trước
            </a>
            <span class="week-label">
                <i class="fa-regular fa-calendar me-1"></i>
                ${weekStart} - ${weekEnd}
            </span>
            <a href="${pageContext.request.contextPath}/doctor/schedule?week=${nextWeek}" class="week-nav-btn">
                Tuần sau <i class="fa-solid fa-chevron-right"></i>
            </a>
        </div>
    </div>

    <!-- Schedule Grid -->
    <form method="post" action="${pageContext.request.contextPath}/doctor/schedule">
        <input type="hidden" name="weekStart" value="${weekStartValue}">

        <div class="card schedule-card shadow-sm">
            <div class="schedule-header">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h5 class="fw-bold mb-1"><i class="fa-solid fa-table-cells me-2"></i>Lịch Làm Việc Trong Tuần</h5>
                        <p class="mb-0 opacity-75" style="font-size: 0.85rem;">Bật/Tắt các khung giờ khám bệnh</p>
                    </div>
                    <button type="submit" class="btn-save-schedule">
                        <i class="fa-solid fa-floppy-disk me-2"></i>Lưu Lịch
                    </button>
                </div>
            </div>

            <div class="card-body p-0">
                <div class="table-responsive">
                    <div class="d-flex">
                        <c:forEach var="day" items="${weekDays}" varStatus="dayLoop">
                            <div class="day-column flex-fill ${day.isToday ? 'day-today' : ''}">
                                <div class="day-header">${day.dayName}</div>
                                <div class="day-date">${day.dateFormatted}</div>

                                <!-- Sáng (Morning) -->
                                <div class="slot-item ${day.morningAvailable ? 'slot-available' : 'slot-unavailable'} mt-3">
                                    <div class="slot-name text-warning">
                                        <i class="fa-solid fa-sun me-1"></i>Sáng
                                    </div>
                                    <div class="slot-time">07:00 - 11:30</div>
                                    <div class="form-check form-switch d-flex justify-content-center mt-2 mb-0">
                                        <input class="form-check-input" type="checkbox" role="switch"
                                            name="slot_${day.dateValue}_MORNING"
                                            id="slot_${day.dateValue}_MORNING"
                                            ${day.morningAvailable ? 'checked' : ''}>
                                    </div>
                                    <div class="mt-2 text-center" style="font-size: 0.75rem; font-weight: 600; color: #64748b;">
                                        Số ca: ${day.morningCount}/${day.morningMax}
                                    </div>
                                </div>

                                <!-- Chiều (Afternoon) -->
                                <div class="slot-item ${day.afternoonAvailable ? 'slot-available' : 'slot-unavailable'}">
                                    <div class="slot-name text-primary">
                                        <i class="fa-solid fa-cloud-sun me-1"></i>Chiều
                                    </div>
                                    <div class="slot-time">13:00 - 17:00</div>
                                    <div class="form-check form-switch d-flex justify-content-center mt-2 mb-0">
                                        <input class="form-check-input" type="checkbox" role="switch"
                                            name="slot_${day.dateValue}_AFTERNOON"
                                            id="slot_${day.dateValue}_AFTERNOON"
                                            ${day.afternoonAvailable ? 'checked' : ''}>
                                    </div>
                                    <div class="mt-2 text-center" style="font-size: 0.75rem; font-weight: 600; color: #64748b;">
                                        Số ca: ${day.afternoonCount}/${day.afternoonMax}
                                    </div>
                                </div>

                                <!-- Tối (Evening) -->
                                <div class="slot-item ${day.eveningAvailable ? 'slot-available' : 'slot-unavailable'}">
                                    <div class="slot-name" style="color: #7c3aed;">
                                        <i class="fa-solid fa-moon me-1"></i>Tối
                                    </div>
                                    <div class="slot-time">18:00 - 21:00</div>
                                    <div class="form-check form-switch d-flex justify-content-center mt-2 mb-0">
                                        <input class="form-check-input" type="checkbox" role="switch"
                                            name="slot_${day.dateValue}_EVENING"
                                            id="slot_${day.dateValue}_EVENING"
                                            ${day.eveningAvailable ? 'checked' : ''}>
                                    </div>
                                    <div class="mt-2 text-center" style="font-size: 0.75rem; font-weight: 600; color: #64748b;">
                                        Số ca: ${day.eveningCount}/${day.eveningMax}
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </div>
        </div>

        <!-- Legend -->
        <div class="d-flex flex-wrap gap-4 mt-3 px-1">
            <div class="d-flex align-items-center gap-2">
                <div style="width: 14px; height: 14px; border-radius: 4px; background: linear-gradient(135deg, #f0fdf4, #dcfce7); border: 1px solid #86efac;"></div>
                <span style="font-size: 0.8rem; font-weight: 600; color: #64748b;">Đang mở</span>
            </div>
            <div class="d-flex align-items-center gap-2">
                <div style="width: 14px; height: 14px; border-radius: 4px; background: #f8fafc; border: 1px solid #e2e8f0;"></div>
                <span style="font-size: 0.8rem; font-weight: 600; color: #64748b;">Đã đóng</span>
            </div>
            <div class="d-flex align-items-center gap-2">
                <span style="font-size: 0.8rem; font-weight: 700; color: #3b82f6;">Số ca: X/Y</span>
                <span style="font-size: 0.8rem; font-weight: 600; color: #64748b;">Số ca đã đặt / Số ca tối đa</span>
            </div>
        </div>
    </form>

    <!-- Upcoming Appointments Summary -->
    <div class="card border-0 shadow-sm rounded-4 mt-4">
        <div class="card-header bg-white border-0 p-4 pb-3">
            <h5 class="fw-bold mb-0">
                <i class="fa-solid fa-calendar-day me-2 text-primary"></i>Lịch Hẹn Trong Tuần Này
            </h5>
        </div>
        <div class="card-body p-0">
            <c:choose>
                <c:when test="${not empty upcomingAppointments}">
                    <div class="table-responsive">
                        <table class="table mb-0">
                            <thead>
                                <tr>
                                    <th style="background: #f8fafc; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; color: #64748b; padding: 1rem; border-bottom: 2px solid #e2e8f0;">Bệnh Nhân</th>
                                    <th style="background: #f8fafc; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; color: #64748b; padding: 1rem; border-bottom: 2px solid #e2e8f0;">Ngày Hẹn</th>
                                    <th style="background: #f8fafc; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; color: #64748b; padding: 1rem; border-bottom: 2px solid #e2e8f0;">Khung Giờ</th>
                                    <th style="background: #f8fafc; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; color: #64748b; padding: 1rem; border-bottom: 2px solid #e2e8f0;">Trạng Thái</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="uApt" items="${upcomingAppointments}">
                                    <tr style="transition: background 0.15s ease;">
                                        <td style="padding: 1rem; vertical-align: middle; border-bottom: 1px solid #f1f5f9;">
                                            <div class="d-flex align-items-center gap-2">
                                                <div class="rounded-circle bg-primary bg-opacity-10 d-flex align-items-center justify-content-center" style="width: 32px; height: 32px;">
                                                    <i class="fa-solid fa-user text-primary" style="font-size: 0.7rem;"></i>
                                                </div>
                                                <span class="fw-semibold" style="font-size: 0.9rem;">${uApt.patientName}</span>
                                            </div>
                                        </td>
                                        <td style="padding: 1rem; vertical-align: middle; border-bottom: 1px solid #f1f5f9; font-size: 0.9rem;">
                                            ${uApt.appointmentDate}
                                        </td>
                                        <td style="padding: 1rem; vertical-align: middle; border-bottom: 1px solid #f1f5f9; font-size: 0.9rem;">
                                            <c:choose>
                                                <c:when test="${uApt.timeSlot == 'MORNING'}"><span class="text-warning fw-semibold"><i class="fa-solid fa-sun me-1"></i>Sáng</span></c:when>
                                                <c:when test="${uApt.timeSlot == 'AFTERNOON'}"><span class="text-primary fw-semibold"><i class="fa-solid fa-cloud-sun me-1"></i>Chiều</span></c:when>
                                                <c:when test="${uApt.timeSlot == 'EVENING'}"><span style="color: #7c3aed;" class="fw-semibold"><i class="fa-solid fa-moon me-1"></i>Tối</span></c:when>
                                            </c:choose>
                                        </td>
                                        <td style="padding: 1rem; vertical-align: middle; border-bottom: 1px solid #f1f5f9;">
                                            <c:choose>
                                                <c:when test="${uApt.status == 'COMPLETED'}">
                                                    <span class="badge-status badge-accepted"><i class="fa-solid fa-circle-check me-1"></i>Đã khám xong</span>
                                                </c:when>
                                                <c:when test="${uApt.status == 'CANCELLED'}">
                                                    <span class="badge-status badge-rejected"><i class="fa-solid fa-circle-xmark me-1"></i>Đã hủy</span>
                                                </c:when>
                                                <c:when test="${uApt.status == 'NO_SHOW'}">
                                                    <span class="badge-status badge-rejected"><i class="fa-solid fa-circle-minus me-1"></i>Vắng mặt</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-status badge-pending"><i class="fa-solid fa-clock me-1"></i>Chờ khám</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="text-center py-5">
                        <i class="fa-regular fa-calendar-xmark text-muted" style="font-size: 3rem;"></i>
                        <p class="text-muted mt-3 mb-0">Chưa có lịch hẹn nào trong tuần này.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

</div>

<jsp:include page="/WEB-INF/views/layout/doctor-footer.jsp" />
