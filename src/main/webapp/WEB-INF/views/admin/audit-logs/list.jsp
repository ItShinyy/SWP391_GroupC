<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/admin-header.jsp" />

<div class="container-fluid">
    <div class="table-container bg-white shadow-sm rounded-4 p-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h1 class="page-title">Nhật Ký Hệ Thống</h1>
            <a href="${pageContext.request.contextPath}/admin/audit-logs?action=export&keyword=${param.keyword}&status=${param.status}&startDate=${param.startDate}&endDate=${param.endDate}" class="btn btn-success fw-bold">
                <i class="fa-solid fa-file-csv me-2"></i> Xuất CSV
            </a>
        </div>

        <!-- Search & Filter Bar -->
        <div class="card shadow-sm mb-4 border-0 rounded-4 bg-light">
            <div class="card-body">
                <form action="${pageContext.request.contextPath}/admin/audit-logs" method="get" class="mb-0 row g-3">
                    <div class="col-md-3">
                        <input type="text" name="keyword" class="form-control" placeholder="Tìm theo Email, ID, IP..." value="${param.keyword}">
                    </div>
                    <div class="col-md-2">
                        <select name="status" class="form-select">
                            <option value="ALL" ${param.status == 'ALL' ? 'selected' : ''}>-- Tất cả trạng thái --</option>
                            <option value="SUCCESS" ${param.status == 'SUCCESS' ? 'selected' : ''}>Thành công</option>
                            <option value="FAILED" ${param.status == 'FAILED' ? 'selected' : ''}>Thất bại</option>
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
                        <a href="${pageContext.request.contextPath}/admin/audit-logs" class="btn btn-outline-secondary w-100">
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
                    <th scope="col" class="ps-4">Thời gian</th>
                    <th scope="col">Người thực hiện</th>
                    <th scope="col">Hành động</th>
                    <th scope="col">Đối tượng</th>
                    <th scope="col">Trạng thái</th>
                    <th scope="col" class="pe-4 text-end">Địa Chỉ IP</th>
                    <th scope="col" class="text-center">Thao tác</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${empty auditLogs}">
                        <tr>
                            <td colspan="7" class="text-center py-4 text-muted">Không tìm thấy bản ghi nào.</td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="log" items="${auditLogs}">
                            <tr>
                                <td class="ps-4 text-muted small">
                                    <fmt:parseDate value="${log.createdAt}" pattern="yyyy-MM-dd'T'HH:mm:ss" var="parsedDateTime" type="both" />
                                    <fmt:formatDate pattern="dd/MM/yyyy HH:mm:ss" value="${parsedDateTime}" />
                                </td>
                                <td class="fw-bold">${log.userName}</td>
                                <td>
                                    <span class="badge bg-secondary bg-opacity-10 text-secondary border border-secondary border-opacity-25 px-2 py-1">
                                        ${log.action}
                                    </span>
                                </td>
                                <td class="text-muted">
                                    ${log.entityType} 
                                    <c:if test="${not empty log.recordId}">
                                        <br><span class="font-monospace small">${log.recordId}</span>
                                    </c:if>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${log.status == 'SUCCESS'}">
                                            <span class="badge bg-success">THÀNH CÔNG</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-danger">THẤT BẠI</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="pe-4 text-end text-muted small font-monospace">${log.ipAddress}</td>
                                <td class="text-center">
                                    <a href="${pageContext.request.contextPath}/admin/audit-logs/detail?id=${log.id}&page=${currentPage}&keyword=${param.keyword}&status=${param.status}&startDate=${param.startDate}&endDate=${param.endDate}" class="btn btn-sm btn-outline-primary">
                                        <i class="fas fa-eye"></i> Xem chi tiết
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>

    <c:if test="${totalPages > 1}">
        <div class="p-3 border-top">
            <nav aria-label="Page navigation" class="mb-0">
                <ul class="pagination justify-content-center mb-0">
                    <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                        <a class="page-link" href="?page=${currentPage - 1}&keyword=${param.keyword}&status=${param.status}&startDate=${param.startDate}&endDate=${param.endDate}">Trước</a>
                    </li>
                    <c:forEach begin="1" end="${totalPages}" var="i">
                        <li class="page-item ${i == currentPage ? 'active' : ''}">
                            <a class="page-link" href="?page=${i}&keyword=${param.keyword}&status=${param.status}&startDate=${param.startDate}&endDate=${param.endDate}">${i}</a>
                        </li>
                    </c:forEach>
                    <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                        <a class="page-link" href="?page=${currentPage + 1}&keyword=${param.keyword}&status=${param.status}&startDate=${param.startDate}&endDate=${param.endDate}">Sau</a>
                    </li>
                </ul>
            </nav>
        </div>
    </c:if>
</div>
</div>

<jsp:include page="/WEB-INF/views/layout/admin-footer.jsp" />

