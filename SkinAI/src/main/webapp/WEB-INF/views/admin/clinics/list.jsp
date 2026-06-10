<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/admin-header.jsp" />

<div class="container-fluid">
    <div class="table-container bg-white shadow-sm rounded-4 p-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h1 class="page-title">Quản Lý Phòng Khám</h1>
            <a href="${pageContext.request.contextPath}/admin/clinics?action=create" class="btn btn-primary">
                <i class="fa-solid fa-plus me-2"></i> Thêm Phòng Khám
            </a>
        </div>

        <div class="table-responsive">
            <table class="table table-hover table-striped align-middle">
                <thead class="table-dark">
                    <tr>
                        <th scope="col">Tên Phòng Khám</th>
                        <th scope="col">Địa chỉ</th>
                        <th scope="col">Số điện thoại</th>
                        <th scope="col">Chuyên khoa</th>
                        <th scope="col">Trạng thái</th>
                        <th scope="col">Đánh giá</th>
                        <th scope="col">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                        <c:forEach var="clinic" items="${clinics}">
                            <tr>
                                <td>
                                    <div class="d-flex align-items-center">
                                        <strong>${clinic.clinicName}</strong>
                                    </div>
                                </td>
                                <td>${clinic.address}</td>
                                <td>${clinic.phone}</td>
                                <td>${clinic.specialty}</td>
                                <td>
                                    <span class="badge ${clinic.active ? 'bg-success' : 'bg-danger'}">${clinic.active ? 'Đang hoạt động' : 'Đã đóng cửa'}</span>
                                </td>
                                <td>
                                    <div class="text-warning">
                                        <i class="fa-solid fa-star"></i> ${clinic.rating}
                                    </div>
                                </td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/admin/clinics?action=edit&id=${clinic.id}" class="btn btn-sm btn-outline-primary" title="Chỉnh sửa">Sửa</a>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty clinics}">
                            <tr>
                                <td colspan="7" class="text-center py-4 text-muted">Không tìm thấy phòng khám nào.</td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/layout/admin-footer.jsp" />
