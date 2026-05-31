<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/admin-header.jsp" />

<div class="container-fluid">
    <div class="table-container bg-white shadow-sm rounded-4 p-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h1 class="page-title">Audit Logs</h1>
        </div>

        <!-- Search & Filter Bar -->
        <div class="card shadow-sm mb-4 border-0 rounded-4 bg-light">
        <div class="card-body">
            <form action="${pageContext.request.contextPath}/admin/audit-logs" method="get" class="row g-3 align-items-center">
                <div class="col-md-5">
                    <input type="text" name="search" class="form-control" placeholder="Search by User, Entity, or Record ID" value="${param.search}">
                </div>
                <div class="col-md-4">
                    <select name="action" class="form-select">
                        <option value="">All Actions</option>
                        <option value="LOGIN" ${param.action == 'LOGIN' ? 'selected' : ''}>LOGIN</option>
                        <option value="LOCK_USER" ${param.action == 'LOCK_USER' ? 'selected' : ''}>LOCK_USER</option>
                        <option value="UNLOCK_USER" ${param.action == 'UNLOCK_USER' ? 'selected' : ''}>UNLOCK_USER</option>
                        <option value="UPDATE_CLINIC" ${param.action == 'UPDATE_CLINIC' ? 'selected' : ''}>UPDATE_CLINIC</option>
                    </select>
                </div>
                <div class="col-md-3 d-flex gap-2">
                    <button type="submit" class="btn btn-primary flex-grow-1"><i class="fa-solid fa-magnifying-glass"></i> Search</button>
                    <a href="${pageContext.request.contextPath}/admin/audit-logs" class="btn btn-outline-secondary">Xóa Bộ Lọc</a>
                </div>
            </form>
        </div>
    </div>

        <div class="table-responsive">
            <table class="table table-hover table-striped align-middle">
                <thead class="table-dark">
                    <tr>
                        <th scope="col" class="ps-4">Time</th>
                        <th scope="col">User</th>
                        <th scope="col">Action</th>
                        <th scope="col">Entity</th>
                        <th scope="col">Record ID</th>
                        <th scope="col">Details (Reason)</th>
                        <th scope="col" class="pe-4 text-end">IP Address</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty auditLogs}">
                                <tr>
                                    <td colspan="7" class="text-center py-4 text-muted">No audit logs found.</td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="log" items="${auditLogs}">
                                    <tr>
                                        <td class="ps-4 text-muted small">
                                            <fmt:parseDate value="${log.createdAt}" pattern="yyyy-MM-dd'T'HH:mm:ss" var="parsedDateTime" type="both" />
                                            <fmt:formatDate pattern="dd/MM/yyyy HH:mm" value="${parsedDateTime}" />
                                        </td>
                                        <td class="fw-bold">${log.userName != null ? log.userName : 'System'}</td>
                                        <td>
                                            <span class="badge bg-secondary bg-opacity-10 text-secondary border border-secondary border-opacity-25 px-2 py-1">
                                                ${log.action}
                                            </span>
                                        </td>
                                        <td class="text-muted">${log.entityType}</td>
                                        <td class="text-muted font-monospace small">${log.recordId}</td>
                                        <td class="text-muted small">
                                            <c:if test="${not empty log.newValues}">
                                                ${log.newValues}
                                            </c:if>
                                        </td>
                                        <td class="pe-4 text-end text-muted small">${log.ipAddress}</td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
            
        <c:if test="${totalPages > 1}">
            <div class="p-3 border-top">
                <nav aria-label="Page navigation">
                    <ul class="pagination justify-content-center mb-0">
                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                            <a class="page-link" href="?page=${currentPage - 1}&search=${param.search}&action=${param.action}">Previous</a>
                        </li>
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <li class="page-item ${i == currentPage ? 'active' : ''}">
                                <a class="page-link" href="?page=${i}&search=${param.search}&action=${param.action}">${i}</a>
                            </li>
                        </c:forEach>
                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                            <a class="page-link" href="?page=${currentPage + 1}&search=${param.search}&action=${param.action}">Next</a>
                        </li>
                    </ul>
                </nav>
            </div>
        </c:if>
    </div>
</div>

<jsp:include page="/WEB-INF/views/layout/admin-footer.jsp" />
