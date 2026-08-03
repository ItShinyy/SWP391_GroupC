<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/admin-header.jsp" />

<div class="container-fluid admin-page admin-page--fit">
    <div class="table-container bg-white shadow-sm rounded-4 p-4">
        <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
            <h1 class="page-title mb-0">
                <i class="fas fa-comments me-2 text-primary"></i>Quản Lý Đánh Giá
            </h1>
        </div>

        <!-- Success/Error Messages -->
        <c:if test="${not empty sessionScope.successMessage}">
            <div class="alert alert-success alert-dismissible fade show rounded-3" role="alert">
                <i class="fas fa-check-circle me-2"></i>${sessionScope.successMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:remove var="successMessage" scope="session"/>
        </c:if>

        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show rounded-3" role="alert">
                <i class="fas fa-exclamation-circle me-2"></i>${sessionScope.errorMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <c:remove var="errorMessage" scope="session"/>
        </c:if>

        <!-- Search and Filter Form -->
        <div class="card admin-filters shadow-sm mb-4 border-0 rounded-4 bg-light">
            <div class="card-body">
                <form method="GET" action="${pageContext.request.contextPath}/admin/feedback" class="row g-3 align-items-center">
                    <div class="col-md-3">
                        <select class="form-select" id="status" name="status" aria-label="Trạng thái">
                            <option value="">Tất cả trạng thái</option>
                            <option value="Chưa xử lý" ${statusFilter == 'Chưa xử lý' ? 'selected' : ''}>Chưa xử lý</option>
                            <option value="Đang xử lý" ${statusFilter == 'Đang xử lý' ? 'selected' : ''}>Đang xử lý</option>
                            <option value="Đã xử lý" ${statusFilter == 'Đã xử lý' ? 'selected' : ''}>Đã xử lý</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <select class="form-select" id="category" name="category" aria-label="Loại đánh giá">
                            <option value="">Tất cả loại</option>
                            <option value="Khen" ${categoryFilter == 'Khen' ? 'selected' : ''}>Khen ngợi</option>
                            <option value="Góp ý" ${categoryFilter == 'Góp ý' ? 'selected' : ''}>Góp ý</option>
                            <option value="Khiếu nại" ${categoryFilter == 'Khiếu nại' ? 'selected' : ''}>Khiếu nại</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <input type="text" class="form-control" id="search" name="search" 
                               value="${searchTerm}" placeholder="Tìm theo nội dung, tên..." aria-label="Tìm kiếm">
                    </div>
                    <div class="col-md-3 d-flex gap-2">
                        <button type="submit" class="btn btn-primary w-100">
                            <i class="fas fa-search me-1"></i> Tìm
                        </button>
                        <a href="${pageContext.request.contextPath}/admin/feedback" class="btn btn-outline-secondary w-100">
                            <i class="fas fa-eraser me-1"></i> Xóa lọc
                        </a>
                    </div>
                </form>
            </div>
        </div>

        <c:choose>
            <c:when test="${empty feedbacks}">
                <div class="text-center py-5 text-muted">
                    <i class="fas fa-comments fa-3x mb-3 text-light"></i>
                    <h5 class="fw-semibold">Không Có Đánh Giá</h5>
                    <p>Chưa có đánh giá nào phù hợp với bộ lọc hiện tại.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="table-responsive">
                    <table class="table table-hover table-striped align-middle">
                        <thead class="table-dark">
                            <tr>
                                <th scope="col" style="width: 15%">Bệnh nhân</th>
                                <th scope="col" style="width: 10%">Đánh giá</th>
                                <th scope="col" style="width: 10%">Loại</th>
                                <th scope="col" style="width: 35%">Nội dung</th>
                                <th scope="col" style="width: 12%">Trạng thái</th>
                                <th scope="col" style="width: 13%">Ngày tạo</th>
                                <th scope="col" style="width: 5%">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="feedback" items="${feedbacks}">
                                <tr>
                                    <td>
                                        <div class="fw-bold text-dark">#${feedback.appointmentId.substring(0, 8)}&hellip;</div>
                                        <small class="text-muted">
                                            <c:choose>
                                                <c:when test="${not empty patientNames[feedback.id]}">
                                                    ${patientNames[feedback.id]}
                                                </c:when>
                                                <c:otherwise>
                                                    ID: ${feedback.patientId.substring(0, 8)}&hellip;
                                                </c:otherwise>
                                            </c:choose>
                                        </small>
                                    </td>
                                    <td>
                                        <div class="mb-1 text-nowrap">
                                            <c:forEach begin="1" end="5" var="i">
                                                <i class="fas fa-star ${i <= feedback.rating ? 'text-warning' : 'text-muted'}" style="font-size: 0.8rem;"></i>
                                            </c:forEach>
                                        </div>
                                        <c:choose>
                                            <c:when test="${feedback.rating >= 4}">
                                                <span class="badge bg-success">${feedback.rating}/5</span>
                                            </c:when>
                                            <c:when test="${feedback.rating >= 3}">
                                                <span class="badge bg-warning text-dark">${feedback.rating}/5</span>
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
                                                <span class="badge bg-info text-dark"><c:out value="${feedback.category}" /></span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-warning text-dark"><c:out value="${feedback.category}" /></span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="text-truncate" style="max-width: 300px;" title="<c:out value="${feedback.content}" />">
                                            <c:out value="${feedback.content}" />
                                        </div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${feedback.status == 'Chưa xử lý'}">
                                                <span class="badge bg-warning text-dark"><c:out value="${feedback.status}" /></span>
                                            </c:when>
                                            <c:when test="${feedback.status == 'Đang xử lý'}">
                                                <span class="badge bg-info text-dark"><c:out value="${feedback.status}" /></span>
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
                                        <div class="text-nowrap">${day}/${month}/${year}</div>
                                        <small class="text-muted text-nowrap">${timeOnly}</small>
                                    </td>
                                    <td class="text-center">
                                        <a href="${pageContext.request.contextPath}/admin/feedback?action=detail&id=${feedback.id}" 
                                           class="btn btn-sm btn-light border" aria-label="Xem chi tiết" title="Xem chi tiết">
                                            <i class="fas fa-eye text-primary"></i>
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

<jsp:include page="/WEB-INF/views/layout/admin-footer.jsp" />