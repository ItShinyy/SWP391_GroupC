<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/admin-header.jsp" />

<div class="container-fluid admin-page admin-page--fit">
    <div class="d-flex justify-content-between align-items-center admin-toolbar">
        <h1 class="page-title mb-0">
            <i class="fas fa-comments me-2 text-primary"></i>Quản Lý Đánh Giá
        </h1>
    </div>

    <!-- Success/Error Messages -->
    <c:if test="${not empty sessionScope.successMessage}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fas fa-check-circle me-2"></i>${sessionScope.successMessage}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <c:remove var="successMessage" scope="session"/>
    </c:if>

    <c:if test="${not empty sessionScope.errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="fas fa-exclamation-circle me-2"></i>${sessionScope.errorMessage}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <c:remove var="errorMessage" scope="session"/>
    </c:if>

    <div class="row g-2 mb-2">
        <div class="col-6 col-md-3">
            <div class="card admin-kpi-card bg-warning text-white border-0">
                <div class="card-body py-2 px-3">
                    <div class="fw-semibold">${pendingCount}</div>
                    <small>Chưa xử lý</small>
                </div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="card admin-kpi-card bg-info text-white border-0">
                <div class="card-body py-2 px-3">
                    <div class="fw-semibold">${processingCount}</div>
                    <small>Đang xử lý</small>
                </div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="card admin-kpi-card bg-success text-white border-0">
                <div class="card-body py-2 px-3">
                    <div class="fw-semibold">${completedCount}</div>
                    <small>Đã xử lý</small>
                </div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="card admin-kpi-card bg-primary text-white border-0">
                <div class="card-body py-2 px-3">
                    <div class="fw-semibold">${totalFeedbacks}</div>
                    <small>Tổng đánh giá</small>
                </div>
            </div>
        </div>
    </div>

    <!-- Search and Filter Form -->
    <div class="card admin-filters mb-2 border-0 shadow-sm">
        <div class="card-body">
            <form method="GET" action="${pageContext.request.contextPath}/admin/feedback" class="row g-2 align-items-end">
                <div class="col-md-3">
                    <label for="status" class="form-label small mb-1">Trạng thái</label>
                    <select class="form-select form-select-sm" id="status" name="status">
                        <option value="">Tất cả trạng thái</option>
                        <option value="Chưa xử lý" ${statusFilter == 'Chưa xử lý' ? 'selected' : ''}>Chưa xử lý</option>
                        <option value="Đang xử lý" ${statusFilter == 'Đang xử lý' ? 'selected' : ''}>Đang xử lý</option>
                        <option value="Đã xử lý" ${statusFilter == 'Đã xử lý' ? 'selected' : ''}>Đã xử lý</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label for="category" class="form-label">Loại đánh giá</label>
                    <select class="form-select" id="category" name="category">
                        <option value="">Tất cả loại</option>
                        <option value="Khen" ${categoryFilter == 'Khen' ? 'selected' : ''}>Khen ngợi</option>
                        <option value="Góp ý" ${categoryFilter == 'Góp ý' ? 'selected' : ''}>Góp ý</option>
                        <option value="Khiếu nại" ${categoryFilter == 'Khiếu nại' ? 'selected' : ''}>Khiếu nại</option>
                    </select>
                </div>
                <div class="col-md-4">
                    <label for="search" class="form-label">Tìm kiếm</label>
                    <input type="text" class="form-control" id="search" name="search" 
                           value="${searchTerm}" placeholder="Tìm theo nội dung hoặc tên bệnh nhân">
                </div>
                <div class="col-md-2">
                    <label class="form-label">&nbsp;</label>
                    <button type="submit" class="btn btn-primary d-block w-100">
                        <i class="fas fa-search me-2"></i>Tìm kiếm
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Feedback List -->
    <div class="card">
        <div class="card-body">
            <c:choose>
                <c:when test="${empty feedbacks}">
                    <div class="text-center py-5 text-muted">
                        <i class="fas fa-comments fa-3x mb-3 text-light"></i>
                        <h5>Không Có Đánh Giá</h5>
                        <p>Chưa có đánh giá nào phù hợp với bộ lọc hiện tại</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead class="table-dark">
                                <tr>
                                    <th style="width: 15%">Bệnh nhân</th>
                                    <th style="width: 10%">Đánh giá</th>
                                    <th style="width: 10%">Loại</th>
                                    <th style="width: 35%">Nội dung</th>
                                    <th style="width: 12%">Trạng thái</th>
                                    <th style="width: 13%">Ngày tạo</th>
                                    <th style="width: 5%">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="feedback" items="${feedbacks}">
                                    <tr>
                                        <td>
                                            <div class="fw-bold">#${feedback.appointmentId.substring(0, 8)}...</div>
                                            <small class="text-muted">
                                                <c:choose>
                                                    <c:when test="${not empty patientNames[feedback.id]}">
                                                        ${patientNames[feedback.id]}
                                                    </c:when>
                                                    <c:otherwise>
                                                        Patient ID: ${feedback.patientId.substring(0, 8)}...
                                                    </c:otherwise>
                                                </c:choose>
                                            </small>
                                        </td>
                                        <td class="text-center">
                                            <div class="mb-1">
                                                <c:forEach begin="1" end="5" var="i">
                                                    <i class="fas fa-star ${i <= feedback.rating ? 'text-warning' : 'text-muted'}" style="font-size: 0.8rem;"></i>
                                                </c:forEach>
                                            </div>
                                            <c:choose>
                                                <c:when test="${feedback.rating >= 4}">
                                                    <span class="badge bg-success">${feedback.rating}/5</span>
                                                </c:when>
                                                <c:when test="${feedback.rating >= 3}">
                                                    <span class="badge bg-warning">${feedback.rating}/5</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-danger">${feedback.rating}/5</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${feedback.category == 'Khen'}">
                                                    <span class="badge bg-success"><c:out value="${feedback.category}" /></span>
                                                </c:when>
                                                <c:when test="${feedback.category == 'Góp ý'}">
                                                    <span class="badge bg-info"><c:out value="${feedback.category}" /></span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-warning"><c:out value="${feedback.category}" /></span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="text-truncate" style="max-width: 300px;">
                                                <c:out value="${feedback.content}" />
                                            </div>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${feedback.status == 'Chưa xử lý'}">
                                                    <span class="badge bg-warning"><c:out value="${feedback.status}" /></span>
                                                </c:when>
                                                <c:when test="${feedback.status == 'Đang xử lý'}">
                                                    <span class="badge bg-info"><c:out value="${feedback.status}" /></span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-success"><c:out value="${feedback.status}" /></span>
                                                </c:otherwise>
                                            </c:choose>
                                            <c:if test="${feedback.hasAdminReply()}">
                                                <br><small class="text-success"><i class="fas fa-reply me-1"></i>Đã phản hồi</small>
                                            </c:if>
                                        </td>
                                        <td>
                                            <c:set var="createdAtStr" value="${feedback.createdAt.toString()}" />
                                            <c:set var="dateOnly" value="${createdAtStr.substring(0, 10)}" />
                                            <c:set var="timeOnly" value="${createdAtStr.substring(11, 16)}" />
                                            <c:set var="year" value="${dateOnly.substring(0, 4)}" />
                                            <c:set var="month" value="${dateOnly.substring(5, 7)}" />
                                            <c:set var="day" value="${dateOnly.substring(8, 10)}" />
                                            <div>${day}/${month}/${year}</div>
                                            <small class="text-muted">${timeOnly}</small>
                                        </td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/admin/feedback?action=detail&id=${feedback.id}" 
                                               class="btn btn-sm btn-outline-primary" title="Xem chi tiết">
                                                <i class="fas fa-eye"></i>
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>

                    <!-- Pagination -->
                    <c:set var="pageQuery" value="&amp;status=${statusFilter}&amp;category=${categoryFilter}&amp;search=${searchTerm}" scope="request"/>
                    <jsp:include page="/WEB-INF/views/admin/common/_pagination.jsp"/>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<style>
.page-title {
    color: #0d6efd;
    font-weight: 700;
}

.card {
    border: none;
    box-shadow: 0 0 20px rgba(0,0,0,0.1);
    border-radius: 10px;
}

.table th {
    border: none;
    font-weight: 600;
    font-size: 0.9rem;
}

.table td {
    border-top: 1px solid #e9ecef;
    vertical-align: middle;
    font-size: 0.9rem;
}

.badge {
    font-size: 0.75rem;
}

@media (max-width: 768px) {
    .table-responsive {
        font-size: 0.8rem;
    }
    
    .badge {
        font-size: 0.7rem;
    }
}
</style>

<jsp:include page="/WEB-INF/views/layout/admin-footer.jsp" />
