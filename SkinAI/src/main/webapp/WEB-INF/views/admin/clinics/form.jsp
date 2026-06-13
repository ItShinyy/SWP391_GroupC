<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/admin-header.jsp" />

<div class="container-fluid py-4">
    <div class="row mb-4">
        <div class="col-12 d-flex justify-content-between align-items-center">
            <div>
                <h3 class="fw-bold mb-1" style="color: var(--skin-primary);">${empty clinic ? 'Thêm' : 'Cập nhật'} Phòng Khám</h3>
                <p class="text-muted mb-0">Quản lý thông tin và tọa độ bản đồ</p>
            </div>
            <a href="${pageContext.request.contextPath}/admin/clinics" class="btn btn-outline-secondary fw-bold">
                <i class="fa-solid fa-arrow-left me-2"></i> Quay lại
            </a>
        </div>
    </div>

    <div class="card border-0 shadow-sm rounded-4">
        <div class="card-body p-4">
            <form action="${pageContext.request.contextPath}/admin/clinics" method="post">
    <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
                <input type="hidden" name="action" value="${empty clinic ? 'create' : 'edit'}">
                <c:if test="${not empty clinic}">
                    <input type="hidden" name="id" value="${clinic.id}">
                </c:if>

                <div class="row g-4">
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Tên Phòng Khám</label>
                        <input type="text" name="clinicName" class="form-control" value="${clinic.clinicName}" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Chuyên Khoa</label>
                        <input type="text" name="specialty" class="form-control" value="${clinic.specialty}">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Số điện thoại</label>
                        <input type="text" name="phone" class="form-control" value="${clinic.phone}">
                    </div>
                    <div class="col-md-12">
                        <label class="form-label fw-bold">Địa chỉ</label>
                        <input type="text" name="address" class="form-control" value="${clinic.address}" required>
                    </div>

                    <!-- Map Coordinates -->
                    <div class="col-12 mt-4">
                        <h5 class="fw-bold border-bottom pb-2">Tọa Độ Bản Đồ</h5>
                        <p class="text-muted small mb-3">Thông tin tọa độ được sử dụng để hiển thị phòng khám trên bản đồ cho bệnh nhân.</p>
                    </div>
                    
                    <div class="col-md-4">
                        <label class="form-label fw-bold text-muted">Mã Google Place</label>
                        <input type="text" name="googlePlaceId" class="form-control" value="${clinic.googlePlaceId}">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-bold text-muted">Vĩ độ</label>
                        <input type="text" name="latitude" class="form-control" value="${clinic.latitude}">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-bold text-muted">Kinh độ</label>
                        <input type="text" name="longitude" class="form-control" value="${clinic.longitude}">
                    </div>
                </div>

                <div class="mt-4 pt-3 border-top text-end">
                    <button type="submit" class="btn btn-skin fw-bold px-4">Lưu Thông Tin</button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/layout/admin-footer.jsp" />


