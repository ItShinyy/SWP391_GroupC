<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/admin-header.jsp" />

<div class="container-fluid">
    <div class="table-container bg-white shadow-sm rounded-4 p-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h1 class="page-title">Quản Lý Người Dùng</h1>
        </div>

        <!-- Search & Filter Bar -->
        <div class="card shadow-sm mb-4 border-0 rounded-4 bg-light">
            <div class="card-body">
            <form action="${pageContext.request.contextPath}/admin/users" method="get" class="row g-3 align-items-center">
                <div class="col-md-4">
                    <input type="text" name="search" class="form-control" placeholder="Tìm theo tên, email..." value="${param.search}">
                </div>
                <div class="col-md-3">
                    <select name="role" class="form-select">
                        <option value="">Tất cả vai trò</option>
                        <option value="PATIENT" ${param.role == 'PATIENT' ? 'selected' : ''}>PATIENT</option>
                        <option value="ADMIN" ${param.role == 'ADMIN' ? 'selected' : ''}>ADMIN</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <select name="status" class="form-select">
                        <option value="">Tất cả trạng thái</option>
                        <option value="ACTIVE" ${param.status == 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
                        <option value="LOCKED" ${param.status == 'LOCKED' ? 'selected' : ''}>LOCKED</option>
                    </select>
                </div>
                <div class="col-md-3 d-flex gap-2">
                    <button type="submit" class="btn btn-primary w-100">
                        <i class="fa-solid fa-magnifying-glass me-1"></i> Tìm kiếm
                    </button>
                    <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-outline-secondary w-100">
                        <i class="fa-solid fa-eraser me-1"></i> Xóa bộ lọc
                    </a>
                </div>
            </form>
        </div>
    </div>

        <div class="table-responsive">
            <table class="table table-hover table-striped align-middle">
                <thead class="table-dark">
                    <tr>
                        <th scope="col">Tên</th>
                        <th scope="col">Email</th>
                        <th scope="col">Vai trò</th>
                        <th scope="col">Trạng thái</th>
                        <th scope="col">Ngày tham gia</th>
                        <th scope="col">Thao tác</th>
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
                                                <a href="${pageContext.request.contextPath}/admin/users/status?action=lock&id=${u.id}" class="btn btn-sm btn-outline-danger" title="Khóa tài khoản">Khóa</a>
                                            </c:when>
                                            <c:otherwise>
                                                <a href="${pageContext.request.contextPath}/admin/users/status?action=unlock&id=${u.id}" class="btn btn-sm btn-outline-success" title="Mở khóa tài khoản">Mở khóa</a>
                                            </c:otherwise>
                                        </c:choose>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty users}">
                            <tr>
                                <td colspan="6" class="text-center py-4 text-muted">Không tìm thấy người dùng nào.</td>
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
                            <a class="page-link" href="?page=${currentPage - 1}&search=${param.search}&role=${param.role}&status=${param.status}">Trước</a>
                        </li>
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <li class="page-item ${currentPage == i ? 'active' : ''}">
                                <a class="page-link" href="?page=${i}&search=${param.search}&role=${param.role}&status=${param.status}">${i}</a>
                            </li>
                        </c:forEach>
                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                            <a class="page-link" href="?page=${currentPage + 1}&search=${param.search}&role=${param.role}&status=${param.status}">Sau</a>
                        </li>
                        </ul>
                    </nav>
                </div>
            </c:if>
    </div>
</div>

<jsp:include page="/WEB-INF/views/layout/admin-footer.jsp" />

