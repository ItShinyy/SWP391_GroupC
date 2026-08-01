<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/admin-header.jsp" />

<div class="container-fluid admin-page admin-page--fit">
    <div class="table-container bg-white shadow-sm rounded-4 p-4">
        <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
            <h1 class="page-title mb-0">Quản Lý Người Dùng</h1>
            <c:if test="${segment == 'employee'}">
                <a href="${pageContext.request.contextPath}/admin/doctors?action=create" class="btn btn-primary">
                    <i class="fa-solid fa-plus me-2"></i> Thêm Bác Sĩ
                </a>
            </c:if>
        </div>

        <c:if test="${not empty successMessage}">
            <div class="alert alert-success rounded-3"><c:out value="${successMessage}"/></div>
        </c:if>
        <c:if test="${param.updated == '1'}">
            <div class="alert alert-success rounded-3">Đã cập nhật hồ sơ bác sĩ.</div>
        </c:if>

        <ul class="nav nav-tabs mb-4">
            <li class="nav-item">
                <a class="nav-link ${segment == 'regular' ? 'active' : ''}"
                   href="${pageContext.request.contextPath}/admin/users?segment=regular">Người dùng thường</a>
            </li>
            <li class="nav-item">
                <a class="nav-link ${segment == 'employee' ? 'active' : ''}"
                   href="${pageContext.request.contextPath}/admin/users?segment=employee">Nhân viên</a>
            </li>
        </ul>

        <div class="card admin-filters shadow-sm mb-2 border-0 rounded-4 bg-light">
            <div class="card-body">
                <form action="${pageContext.request.contextPath}/admin/users" method="get" class="row g-3 align-items-center">
                    <input type="hidden" name="segment" value="${segment}">
                    <div class="col-md-4">
                        <input type="text" name="search" class="form-control" placeholder="Tìm theo tên, email..." value="<c:out value='${param.search}'/>">
                    </div>
                    <div class="col-md-3">
                        <select name="role" class="form-select">
                            <option value="">Tất cả vai trò</option>
                            <c:choose>
                                <c:when test="${segment == 'employee'}">
                                    <option value="DOCTOR" ${param.role == 'DOCTOR' ? 'selected' : ''}>DOCTOR</option>
                                    <option value="ADMIN" ${param.role == 'ADMIN' ? 'selected' : ''}>ADMIN</option>
                                </c:when>
                                <c:otherwise>
                                    <option value="PATIENT" ${param.role == 'PATIENT' ? 'selected' : ''}>PATIENT</option>
                                    <option value="USER" ${param.role == 'USER' ? 'selected' : ''}>USER</option>
                                </c:otherwise>
                            </c:choose>
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
                        <a href="${pageContext.request.contextPath}/admin/users?segment=${segment}" class="btn btn-outline-secondary w-100">
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
                            <td><strong><c:out value="${u.fullName}"/></strong></td>
                            <td><c:out value="${u.email}"/></td>
                            <td>
                                <c:choose>
                                    <c:when test="${u.role == 'ADMIN'}"><span class="badge bg-primary">ADMIN</span></c:when>
                                    <c:when test="${u.role == 'DOCTOR'}"><span class="badge bg-info text-dark">DOCTOR</span></c:when>
                                    <c:otherwise><span class="badge bg-secondary"><c:out value="${u.role}"/></span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${u.status == 'ACTIVE'}"><span class="badge bg-success">ACTIVE</span></c:when>
                                    <c:otherwise><span class="badge bg-danger"><c:out value="${u.status}"/></span></c:otherwise>
                                </c:choose>
                            </td>
                            <td><c:out value="${u.createdAt}"/></td>
                            <td>
                                <div class="d-inline-flex flex-wrap gap-2 align-items-center">
                                <c:if test="${u.role == 'DOCTOR'}">
                                    <c:set var="doctorId" value="${doctorIdsByUserId[u.id]}"/>
                                    <c:if test="${not empty doctorId}">
                                        <a href="${pageContext.request.contextPath}/admin/doctors?action=edit&amp;id=${doctorId}"
                                           class="btn btn-sm btn-outline-primary">Sửa hồ sơ</a>
                                    </c:if>
                                </c:if>
                                <c:if test="${u.role != 'ADMIN' or u.id != sessionScope.user.id}">
                                    <c:choose>
                                        <c:when test="${u.status == 'ACTIVE'}">
                                            <a href="${pageContext.request.contextPath}/admin/users/status?action=lock&amp;id=${u.id}&amp;segment=${segment}"
                                               class="btn btn-sm btn-outline-danger" title="Khóa tài khoản">Khóa</a>
                                        </c:when>
                                        <c:otherwise>
                                            <a href="${pageContext.request.contextPath}/admin/users/status?action=unlock&amp;id=${u.id}&amp;segment=${segment}"
                                               class="btn btn-sm btn-outline-success" title="Mở khóa tài khoản">Mở khóa</a>
                                        </c:otherwise>
                                    </c:choose>
                                </c:if>
                                </div>
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

        <c:set var="pageQuery" value="&amp;search=${param.search}&amp;role=${param.role}&amp;status=${param.status}&amp;segment=${segment}" scope="request"/>
        <jsp:include page="/WEB-INF/views/admin/common/_pagination.jsp"/>
    </div>
</div>

<jsp:include page="/WEB-INF/views/layout/admin-footer.jsp" />
