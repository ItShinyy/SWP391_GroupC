<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/admin-header.jsp" />

<div class="container-fluid">
    <div class="table-container bg-white shadow-sm rounded-4 p-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h1 class="page-title">Quản Lý Lịch Hẹn</h1>
        </div>

        <!-- Search and Filter Bar -->
        <div class="card shadow-sm mb-4 border-0 rounded-4 bg-light">
            <div class="card-body">
                <form action="${pageContext.request.contextPath}/admin/bookings" method="get" class="mb-0 row g-3">
                    <div class="col-md-3">
                        <input type="text" class="form-control" name="keyword" value="${param.keyword}" placeholder="Tìm theo bệnh nhân hoặc phòng khám">
                    </div>
                    
                    <div class="col-md-2">
                        <select class="form-select" name="status">
                            <option value="">-- Tất cả trạng thái --</option>
                            <option value="CREATED" <c:if test="${param.status == 'CREATED'}">selected</c:if>>Khởi tạo</option>
                            <option value="CONFIRMED" <c:if test="${param.status == 'CONFIRMED'}">selected</c:if>>Xác nhận</option>
                            <option value="COMPLETED" <c:if test="${param.status == 'COMPLETED'}">selected</c:if>>Hoàn thành</option>
                            <option value="CANCELLED" <c:if test="${param.status == 'CANCELLED'}">selected</c:if>>Đã hủy</option>
                            <option value="NO_SHOW" <c:if test="${param.status == 'NO_SHOW'}">selected</c:if>>Không đến</option>
                        </select>
                    </div>

                    <div class="col-md-2">
                        <input type="date" class="form-control" name="startDate" value="${param.startDate}" title="Từ ngày">
                    </div>
                    <div class="col-md-2">
                        <input type="date" class="form-control" name="endDate" value="${param.endDate}" title="Đến ngày">
                    </div>
                    
                    <div class="col-md-3 d-flex gap-2">
                        <button type="submit" class="btn btn-primary w-100">
                            <i class="fa-solid fa-magnifying-glass me-1"></i> Tìm kiếm
                        </button>
                        <a href="${pageContext.request.contextPath}/admin/bookings" class="btn btn-outline-secondary w-100">
                            <i class="fa-solid fa-eraser me-1"></i> Xóa bộ lọc
                        </a>
                    </div>
                </form>  
            </div>
        </div>
    </div>

    <div class="table-responsive">
        <table class="table table-hover table-striped align-middle">
            <thead class="table-dark">
                <tr>
                    <th scope="col" class="ps-4">Mã LH</th>
                    <th scope="col">Ngày Đặt</th>
                    <th scope="col">Bệnh Nhân</th>
                    <th scope="col">Phòng Khám</th>
                    <th scope="col">Trạng Thái</th>
                    <th scope="col" class="text-center pe-4">Thao tác</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${empty bookings}">
                        <tr>
                            <td colspan="6" class="text-center py-5 text-muted">
                                <div class="mb-3"><i class="fa-regular fa-calendar-xmark fa-3x text-light"></i></div>
                                <h5 class="fw-bold">Không tìm thấy lịch hẹn phù hợp</h5>
                                <p class="mb-0">Vui lòng thử nghiệm bộ lọc khác.</p>
                            </td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="appt" items="${bookings}">
                            <tr>
                                <td class="ps-4 fw-medium text-dark">
                                    <span class="badge bg-light text-dark border font-monospace" title="${appt.id}">${appt.id.substring(0, 8)}</span>
                                </td>
                                <td>
                                    <span class="d-block text-dark fw-medium">
                                        <fmt:parseDate value="${appt.appointmentTime}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedDate" type="both" />
                                        <fmt:formatDate pattern="dd/MM/yyyy HH:mm" value="${parsedDate}" />
                                    </span>
                                </td>
                                <td>
                                    <div class="d-flex align-items-center">
                                        <div class="bg-primary bg-opacity-10 text-primary rounded-circle d-flex align-items-center justify-content-center me-2" style="width: 32px; height: 32px;">
                                            <i class="fa-solid fa-user small"></i>
                                        </div>
                                        <div>
                                            <span class="d-block fw-bold text-dark">${appt.patientId}</span>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <span class="text-secondary fw-medium">
                                        <i class="fa-solid fa-hospital text-muted me-1"></i>
                                        ${appt.clinicName}
                                    </span>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${appt.status == 'CREATED'}"><span class="badge bg-secondary">Khởi tạo</span></c:when>
                                        <c:when test="${appt.status == 'CONFIRMED'}"><span class="badge bg-info text-dark">Xác nhận</span></c:when>
                                        <c:when test="${appt.status == 'COMPLETED'}"><span class="badge bg-success">Hoàn thành</span></c:when>
                                        <c:when test="${appt.status == 'CANCELLED'}"><span class="badge bg-danger">Đã hủy</span></c:when>
                                        <c:when test="${appt.status == 'NO_SHOW'}"><span class="badge bg-warning text-dark">Không đến</span></c:when>
                                        <c:otherwise><span class="badge bg-secondary px-3 py-2">${appt.status}</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-center pe-4">
                                    <a href="${pageContext.request.contextPath}/admin/bookings/detail/${appt.id}" class="btn btn-sm btn-outline-primary">
                                        <i class="fa-solid fa-eye me-1"></i> Xem chi tiết
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>

    <!-- Pagination -->
    <c:if test="${totalPages > 1}">
        <div class="mt-4 pt-3 border-top">
            <nav aria-label="Page navigation" class="mb-0">
                <ul class="pagination justify-content-center mb-0">
                    <c:set var="filterParams" value="&keyword=&status=&startDate=&endDate=" />

                    <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                        <a class="page-link" href="?page=${currentPage - 1}${filterParams}">Trước</a>
                    </li>
                    <c:forEach begin="1" end="${totalPages}" var="i">
                        <li class="page-item ${i == currentPage ? 'active' : ''}">
                            <a class="page-link" href="?page=${i}${filterParams}">${i}</a>
                        </li>
                    </c:forEach>
                    <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                        <a class="page-link" href="?page=${currentPage + 1}${filterParams}">Sau</a>
                    </li>
                </ul>
            </nav>
        </div>
    </c:if>
</div>
</div>

<jsp:include page="/WEB-INF/views/layout/admin-footer.jsp" />
