<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/admin-header.jsp" />

<style>
    .issue-admin-page { min-height: calc(100vh - 80px); }
    .issue-card { border: 1px solid #e2e8f0; border-radius: 16px; }
    .issue-table thead th { background: #212529; color: #fff; white-space: nowrap; }
    .issue-description { min-width: 260px; max-width: 390px; white-space: normal; }
    .issue-actions { min-width: 245px; }
    .status-badge { font-size: .78rem; padding: .5rem .7rem; }
</style>

<section class="issue-admin-page py-4">
    <div class="container-fluid px-3 px-xl-4">
        <div class="issue-card bg-white shadow-sm p-4">
            <div class="d-flex flex-column flex-lg-row justify-content-between align-items-lg-center gap-3 mb-4">
                <div>
                    <h1 class="h3 fw-bold mb-1"><i class="fa-solid fa-bug text-danger me-2"></i>Issue Reports</h1>
                    <p class="text-muted mb-0">Báo cáo sự cố được gửi từ người dùng đến quản trị viên.</p>
                </div>
                <form class="d-flex flex-wrap gap-2" method="get" action="${pageContext.request.contextPath}/admin/issue-reports">
                    <input class="form-control" style="min-width:240px" name="search" value="<c:out value='${search}'/>"
                           placeholder="Mã, tiêu đề hoặc người gửi">
                    <select class="form-select" style="width:auto" name="status">
                        <option value="ALL" ${selectedStatus == 'ALL' ? 'selected' : ''}>Tất cả trạng thái</option>
                        <option value="PENDING" ${selectedStatus == 'PENDING' ? 'selected' : ''}>Chờ kiểm tra</option>
                        <option value="IN_PROGRESS" ${selectedStatus == 'IN_PROGRESS' ? 'selected' : ''}>Đang xử lý</option>
                        <option value="RESOLVED" ${selectedStatus == 'RESOLVED' ? 'selected' : ''}>Đã xử lý</option>
                        <option value="REJECTED" ${selectedStatus == 'REJECTED' ? 'selected' : ''}>Chưa thể xác nhận</option>
                    </select>
                    <button class="btn btn-success" type="submit"><i class="fa-solid fa-search me-1"></i>Lọc</button>
                </form>
            </div>

            <c:if test="${not empty sessionScope.successMessage}">
                <div class="alert alert-success alert-dismissible fade show">
                    <i class="fa-solid fa-circle-check me-2"></i>${sessionScope.successMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <c:remove var="successMessage" scope="session" />
            </c:if>
            <c:if test="${not empty sessionScope.warningMessage}">
                <div class="alert alert-warning alert-dismissible fade show">
                    <i class="fa-solid fa-triangle-exclamation me-2"></i>${sessionScope.warningMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <c:remove var="warningMessage" scope="session" />
            </c:if>
            <c:if test="${not empty sessionScope.errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fa-solid fa-circle-exclamation me-2"></i>${sessionScope.errorMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <c:remove var="errorMessage" scope="session" />
            </c:if>

            <div class="table-responsive">
                <table class="table table-striped table-hover align-middle issue-table mb-0">
                    <thead>
                        <tr>
                            <th>Mã báo cáo</th>
                            <th>Người gửi</th>
                            <th>Sự cố</th>
                            <th>Mô tả</th>
                            <th>Ảnh</th>
                            <th>Ngày gửi</th>
                            <th>Trạng thái</th>
                            <th>Thao tác & email</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty reports}">
                                <tr><td colspan="8" class="text-center text-muted py-5">Chưa có báo cáo sự cố phù hợp.</td></tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="report" items="${reports}">
                                    <tr>
                                        <td class="font-monospace fw-semibold">${report.reportCode}</td>
                                        <td>
                                            <div class="fw-semibold">${report.reporterName}</div>
                                            <small class="text-muted">${report.reporterEmail}</small>
                                        </td>
                                        <td>
                                            <div class="fw-semibold">${report.title}</div>
                                            <small class="text-muted">${report.category}</small>
                                        </td>
                                        <td class="issue-description">${report.description}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty report.imageUrl}">
                                                    <a class="btn btn-sm btn-outline-primary" target="_blank"
                                                       href="${pageContext.request.contextPath}/${report.imageUrl}">
                                                        <i class="fa-regular fa-image"></i> Xem ảnh
                                                    </a>
                                                </c:when>
                                                <c:otherwise><span class="text-muted">Không có</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>${report.createdAtDisplay}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${report.status == 'PENDING'}">
                                                    <span class="badge bg-warning text-dark status-badge">Chờ kiểm tra</span>
                                                </c:when>
                                                <c:when test="${report.status == 'IN_PROGRESS'}">
                                                    <span class="badge bg-primary status-badge">Đang xử lý</span>
                                                </c:when>
                                                <c:when test="${report.status == 'RESOLVED'}">
                                                    <span class="badge bg-success status-badge">Đã xử lý</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary status-badge">Chưa thể xác nhận</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="issue-actions">
                                            <c:if test="${report.status == 'PENDING'}">
                                                <div class="d-flex flex-wrap gap-2">
                                                    <form method="post" action="${pageContext.request.contextPath}/admin/issue-reports">
                                                        <input type="hidden" name="id" value="${report.id}">
                                                        <input type="hidden" name="action" value="acknowledge">
                                                        <button class="btn btn-sm btn-primary" type="submit">
                                                            <i class="fa-solid fa-screwdriver-wrench me-1"></i>Xác nhận lỗi
                                                        </button>
                                                    </form>
                                                    <form method="post" action="${pageContext.request.contextPath}/admin/issue-reports"
                                                          onsubmit="return confirm('Xác nhận chưa thể ghi nhận sự cố này?');">
                                                        <input type="hidden" name="id" value="${report.id}">
                                                        <input type="hidden" name="action" value="reject">
                                                        <button class="btn btn-sm btn-outline-secondary" type="submit">Chưa thể xác nhận</button>
                                                    </form>
                                                </div>
                                            </c:if>
                                            <c:if test="${report.status == 'IN_PROGRESS'}">
                                                <div class="d-flex flex-wrap gap-2">
                                                    <form method="post" action="${pageContext.request.contextPath}/admin/issue-reports">
                                                        <input type="hidden" name="id" value="${report.id}">
                                                        <input type="hidden" name="action" value="resolve">
                                                        <button class="btn btn-sm btn-success" type="submit">
                                                            <i class="fa-solid fa-check me-1"></i>Đã sửa xong
                                                        </button>
                                                    </form>
                                                    <form method="post" action="${pageContext.request.contextPath}/admin/issue-reports"
                                                          onsubmit="return confirm('Xác nhận chưa thể ghi nhận sự cố này?');">
                                                        <input type="hidden" name="id" value="${report.id}">
                                                        <input type="hidden" name="action" value="reject">
                                                        <button class="btn btn-sm btn-outline-secondary" type="submit">Chưa thể xác nhận</button>
                                                    </form>
                                                </div>
                                            </c:if>
                                            <c:if test="${report.status == 'RESOLVED' or report.status == 'REJECTED'}">
                                                <span class="text-muted small">Đã hoàn tất xử lý</span>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</section>

<jsp:include page="/WEB-INF/views/layout/admin-footer.jsp" />
