<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/admin-header.jsp" />

<div class="container-fluid">
    <div class="table-container bg-white shadow-sm rounded-4 p-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h1 class="page-title">User Management</h1>
        </div>

        <!-- Search & Filter Bar -->
        <div class="card shadow-sm mb-4 border-0 rounded-4 bg-light">
            <div class="card-body">
            <form action="${pageContext.request.contextPath}/admin/users" method="get" class="row g-3 align-items-center">
                <div class="col-md-4">
                    <input type="text" name="search" class="form-control" placeholder="Search by name, email or username" value="${param.search}">
                </div>
                <div class="col-md-3">
                    <select name="role" class="form-select">
                        <option value="">All Roles</option>
                        <option value="PATIENT" ${param.role == 'PATIENT' ? 'selected' : ''}>PATIENT</option>
                        <option value="ADMIN" ${param.role == 'ADMIN' ? 'selected' : ''}>ADMIN</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <select name="status" class="form-select">
                        <option value="">All Statuses</option>
                        <option value="ACTIVE" ${param.status == 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
                        <option value="LOCKED" ${param.status == 'LOCKED' ? 'selected' : ''}>LOCKED</option>
                    </select>
                </div>
                <div class="col-md-2 d-flex gap-2">
                    <button type="submit" class="btn btn-primary flex-grow-1"><i class="fa-solid fa-magnifying-glass"></i> Search</button>
                    <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-outline-secondary">Xóa Bộ Lọc</a>
                </div>
            </form>
        </div>
    </div>

        <div class="table-responsive">
            <table class="table table-hover table-striped align-middle">
                <thead class="table-dark">
                    <tr>
                        <th scope="col">Name</th>
                        <th scope="col">Email</th>
                        <th scope="col">Role</th>
                        <th scope="col">Status</th>
                        <th scope="col">Joined</th>
                        <th scope="col">Actions</th>
                    </tr>
                </thead>
                <tbody>
                        <c:forEach var="u" items="${users}">
                            <tr>
                                <td>
                                    <div class="d-flex align-items-center">
                                        <strong>${u.fullName}</strong>
                                    </div>
                                </td>
                                <td>${u.email}</td>
                                <td>
                                    <span class="badge ${u.role == 'ADMIN' ? 'bg-primary' : 'bg-secondary'}">${u.role}</span>
                                </td>
                                <td>
                                    <span class="badge ${u.status == 'ACTIVE' ? 'bg-success' : 'bg-danger'}">${u.status}</span>
                                </td>
                                <td>
                                    ${u.createdAt}
                                </td>
                                <td>
                                    <c:if test="${u.role != 'ADMIN' || u.id != sessionScope.user.id}">
                                        <c:choose>
                                            <c:when test="${u.status == 'ACTIVE'}">
                                                <a href="${pageContext.request.contextPath}/admin/users/status-change?id=${u.id}&action=lock" class="btn btn-sm btn-outline-danger">Lock</a>
                                            </c:when>
                                            <c:otherwise>
                                                <a href="${pageContext.request.contextPath}/admin/users/status-change?id=${u.id}&action=unlock" class="btn btn-sm btn-outline-success">Unlock</a>
                                            </c:otherwise>
                                        </c:choose>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty users}">
                            <tr>
                                <td colspan="6" class="text-center py-4">No users found.</td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
            
            <!-- Pagination -->
            <c:if test="${totalPages > 1}">
                <div class="p-3 border-top">
                    <nav aria-label="Page navigation" class="mb-0">
                        <ul class="pagination justify-content-center mb-0">
                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                            <a class="page-link" href="?page=${currentPage - 1}&search=${param.search}&role=${param.role}&status=${param.status}">Previous</a>
                        </li>
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <li class="page-item ${currentPage == i ? 'active' : ''}">
                                <a class="page-link" href="?page=${i}&search=${param.search}&role=${param.role}&status=${param.status}">${i}</a>
                            </li>
                        </c:forEach>
                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                            <a class="page-link" href="?page=${currentPage + 1}&search=${param.search}&role=${param.role}&status=${param.status}">Next</a>
                        </li>
                        </ul>
                    </nav>
                </div>
            </c:if>
    </div>
</div>

<jsp:include page="/WEB-INF/views/layout/admin-footer.jsp" />
