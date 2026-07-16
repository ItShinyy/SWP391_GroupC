<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/layout/doctor-header.jsp" />

<div class="container-fluid py-4 px-4">
    <!-- Page Title -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h4 class="fw-bold mb-0">
            <i class="fa-solid fa-clock-rotate-left me-2 text-primary"></i>Lịch Sử Ca Khám Đã Qua
        </h4>
        <!-- Filter Tabs -->
        <div class="btn-group shadow-sm rounded-3">
            <a href="?status=COMPLETED" class="btn btn-sm ${statusFilter == 'COMPLETED' ? 'btn-primary' : 'btn-outline-primary bg-white'} fw-bold">
                <i class="fa-solid fa-circle-check me-1"></i>Đã Khám Xong
            </a>
            <a href="?status=CANCELLED" class="btn btn-sm ${statusFilter == 'CANCELLED' ? 'btn-primary' : 'btn-outline-primary bg-white'} fw-bold">
                <i class="fa-solid fa-circle-xmark me-1"></i>Đã Hủy
            </a>
        </div>
    </div>

    <!-- History Table Card -->
    <div class="card border-0 shadow-sm rounded-4">
        <div class="card-body p-0">
            <c:choose>
                <c:when test="${not empty historyList}">
                    <div class="table-responsive">
                        <table class="table mb-0 align-middle">
                            <thead>
                                <tr>
                                    <th style="background: #f8fafc; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; color: #64748b; padding: 1.2rem 1rem;">Mã Ca Khám</th>
                                    <th style="background: #f8fafc; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; color: #64748b; padding: 1.2rem 1rem;">Bệnh Nhân</th>
                                    <th style="background: #f8fafc; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; color: #64748b; padding: 1.2rem 1rem;">Ngày Hẹn Khám</th>
                                    <th style="background: #f8fafc; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; color: #64748b; padding: 1.2rem 1rem;">Chẩn Đoán Lâm Sàng</th>
                                    <th style="background: #f8fafc; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; color: #64748b; padding: 1.2rem 1rem; text-align: center;">Hành Động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="appt" items="${historyList}">
                                    <tr style="transition: background 0.15s ease;">
                                        <td style="padding: 1rem; font-size: 0.85rem; font-weight: 600; color: #64748b;">
                                            #${appt.id.substring(0, 8)}
                                        </td>
                                        <td style="padding: 1rem;">
                                            <div class="d-flex align-items-center gap-2">
                                                <div class="rounded-circle bg-primary bg-opacity-10 d-flex align-items-center justify-content-center text-primary" style="width: 36px; height: 36px;">
                                                    <i class="fa-solid fa-user" style="font-size: 0.85rem;"></i>
                                                </div>
                                                <div>
                                                    <span class="fw-bold d-block text-dark" style="font-size: 0.9rem;">${appt.patientName}</span>
                                                    <span class="text-muted" style="font-size: 0.75rem;">${appt.patientPhone}</span>
                                                </div>
                                            </div>
                                        </td>
                                        <td style="padding: 1rem; font-size: 0.85rem; color: #334155;">
                                            <i class="fa-regular fa-calendar me-1 text-primary"></i>${appt.appointmentTimeFormatted}
                                        </td>
                                        <td style="padding: 1rem; font-size: 0.85rem; color: #475569; max-width: 300px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                                            <c:choose>
                                                <c:when test="${not empty appt.doctorNotes}">
                                                    ${appt.doctorNotes}
                                                </c:when>
                                                <c:otherwise>
                                                     <span class="text-muted italic">Chưa ghi nhận chẩn đoán</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="padding: 1rem; text-align: center;">
                                            <a href="${pageContext.request.contextPath}/doctor/appointments/detail?id=${appt.id}" class="btn btn-sm btn-outline-primary rounded-3 fw-semibold">
                                                <i class="fa-solid fa-folder-open me-1"></i>Xem Bệnh Án
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="text-center py-5">
                        <i class="fa-regular fa-folder-open text-muted mb-3" style="font-size: 4rem;"></i>
                        <h6 class="fw-bold text-muted">Không tìm thấy ca khám nào</h6>
                        <p class="text-muted small mb-0">Lịch sử khám bệnh của bác sĩ hiện chưa có dữ liệu nào.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- Pagination -->
    <c:if test="${totalPages > 1}">
        <div class="d-flex justify-content-center mt-4">
            <nav>
                <ul class="pagination pagination-sm shadow-sm rounded-3 overflow-hidden">
                    <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                        <a class="page-link" href="?status=${statusFilter}&page=${currentPage - 1}">
                            <i class="fa-solid fa-chevron-left"></i>
                        </a>
                    </li>
                    <c:forEach var="i" begin="1" end="${totalPages}">
                        <li class="page-item ${currentPage == i ? 'active' : ''}">
                            <a class="page-link" href="?status=${statusFilter}&page=${i}">${i}</a>
                        </li>
                    </c:forEach>
                    <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                        <a class="page-link" href="?status=${statusFilter}&page=${currentPage + 1}">
                            <i class="fa-solid fa-chevron-right"></i>
                        </a>
                    </li>
                </ul>
            </nav>
        </div>
    </c:if>
</div>

<jsp:include page="/WEB-INF/views/layout/doctor-footer.jsp" />
