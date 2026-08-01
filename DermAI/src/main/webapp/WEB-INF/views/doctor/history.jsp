<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/WEB-INF/views/layout/doctor-header.jsp" />

<div class="container-fluid py-4 px-4">
    <!-- Page Title & Tabs -->
    <div class="d-flex flex-wrap justify-content-between align-items-center gap-3 mb-4">
        <h4 class="fw-bold mb-0" style="color: #1e293b;">
            <i class="fa-solid fa-clock-rotate-left me-2 text-success"></i>Lịch Sử Ca Khám Đã Qua
        </h4>
        <div class="btn-group shadow-sm rounded-3">
            <a href="?status=COMPLETED" class="btn btn-sm ${statusFilter == 'COMPLETED' ? 'btn-success text-white' : 'btn-outline-success bg-white'} fw-bold">
                <i class="fa-solid fa-circle-check me-1"></i>Đã Khám Xong
            </a>
            <a href="?status=CANCELLED" class="btn btn-sm ${statusFilter == 'CANCELLED' ? 'btn-success text-white' : 'btn-outline-success bg-white'} fw-bold">
                <i class="fa-solid fa-circle-xmark me-1"></i>Đã Hủy
            </a>
        </div>
    </div>

    <!-- Filter & Search Form -->
    <div class="card border-0 shadow-sm rounded-4 mb-4">
        <div class="card-body p-3">
            <form method="get" action="${pageContext.request.contextPath}/doctor/appointments/history" class="d-flex flex-wrap gap-2 align-items-center">
                <input type="hidden" name="status" value="${statusFilter}">
                
                <div class="input-group input-group-sm" style="max-width: 250px;">
                    <span class="input-group-text bg-light border-end-0"><i class="fa-solid fa-magnifying-glass text-muted"></i></span>
                    <input type="text" name="keyword" class="form-control bg-light border-start-0" placeholder="Tên hoặc SĐT..." value="${param.keyword}">
                </div>
                
                <select name="riskFilter" class="form-select form-select-sm bg-light" style="width: 140px;">
                    <option value="">-- Mức rủi ro --</option>
                    <option value="LOW" ${param.riskFilter == 'LOW' ? 'selected' : ''}>Thấp</option>
                    <option value="MEDIUM" ${param.riskFilter == 'MEDIUM' ? 'selected' : ''}>Trung bình</option>
                    <option value="HIGH" ${param.riskFilter == 'HIGH' ? 'selected' : ''}>Cao</option>
                </select>
                
                <select name="sortBy" class="form-select form-select-sm bg-light" style="width: 160px;">
                    <option value="time_desc" ${param.sortBy == 'time_desc' || empty param.sortBy ? 'selected' : ''}>Giờ hẹn (Mới nhất)</option>
                    <option value="time_asc" ${param.sortBy == 'time_asc' ? 'selected' : ''}>Giờ hẹn (Cũ nhất)</option>
                    <option value="risk_desc" ${param.sortBy == 'risk_desc' ? 'selected' : ''}>Rủi ro giảm dần</option>
                </select>
                
                <button type="submit" class="btn btn-sm btn-success text-white fw-bold px-3 rounded-2">
                    <i class="fa-solid fa-filter me-1"></i>Lọc
                </button>
                <a href="${pageContext.request.contextPath}/doctor/appointments/history?status=${statusFilter}" class="btn btn-sm btn-outline-secondary fw-bold px-3 rounded-2">
                    <i class="fa-solid fa-rotate-left"></i>
                </a>
            </form>
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
                                    <th style="background: #f8fafc; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; color: #64748b; padding: 1.2rem 1rem; text-align: center;">Trạng Thái</th>
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
                                            <c:choose>
                                                <c:when test="${appt.status == 'COMPLETED'}">
                                                    <span class="badge text-bg-success rounded-pill px-3 py-2 fw-semibold">
                                                        <i class="fa-solid fa-circle-check me-1"></i>Đã Hoàn Thành
                                                    </span>
                                                </c:when>
                                                <c:when test="${appt.status == 'CANCELLED'}">
                                                    <span class="badge text-bg-danger rounded-pill px-3 py-2 fw-semibold">
                                                        <i class="fa-solid fa-circle-xmark me-1"></i>Đã Hủy
                                                    </span>
                                                </c:when>
                                                <c:when test="${appt.status == 'NO_SHOW'}">
                                                    <span class="badge text-bg-secondary rounded-pill px-3 py-2 fw-semibold">
                                                        <i class="fa-solid fa-user-slash me-1"></i>Không Đến
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge text-bg-light border rounded-pill px-3 py-2 fw-semibold">
                                                        <c:out value="${appt.status}"/>
                                                    </span>
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
                        <a class="page-link" href="?status=${statusFilter}&page=${currentPage - 1}${not empty param.keyword ? '&keyword='.concat(param.keyword) : ''}${not empty param.riskFilter ? '&riskFilter='.concat(param.riskFilter) : ''}${not empty param.sortBy ? '&sortBy='.concat(param.sortBy) : ''}">
                            <i class="fa-solid fa-chevron-left"></i>
                        </a>
                    </li>
                    <c:forEach var="i" begin="1" end="${totalPages}">
                        <li class="page-item ${currentPage == i ? 'active' : ''}">
                            <a class="page-link" href="?status=${statusFilter}&page=${i}${not empty param.keyword ? '&keyword='.concat(param.keyword) : ''}${not empty param.riskFilter ? '&riskFilter='.concat(param.riskFilter) : ''}${not empty param.sortBy ? '&sortBy='.concat(param.sortBy) : ''}">${i}</a>
                        </li>
                    </c:forEach>
                    <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                        <a class="page-link" href="?status=${statusFilter}&page=${currentPage + 1}${not empty param.keyword ? '&keyword='.concat(param.keyword) : ''}${not empty param.riskFilter ? '&riskFilter='.concat(param.riskFilter) : ''}${not empty param.sortBy ? '&sortBy='.concat(param.sortBy) : ''}">
                            <i class="fa-solid fa-chevron-right"></i>
                        </a>
                    </li>
                </ul>
            </nav>
        </div>
    </c:if>
</div>

<jsp:include page="/WEB-INF/views/layout/doctor-footer.jsp" />
