<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/global-header.jsp" />

<div class="bg-light py-5">
    <div class="container mt-5">
        <div class="row align-items-center mb-5">
            <div class="col-md-6">
                <h1 class="fw-bold text-dark mb-3">Tra cứu phòng khám</h1>
                <p class="text-muted lead">Tìm kiếm và xem gợi ý phòng khám da liễu gần bạn.</p>
            </div>
            <div class="col-md-6 text-md-end">
                <div class="input-group bg-white rounded-pill shadow-sm p-1">
                    <input type="text" class="form-control border-0 bg-transparent ps-4" placeholder="Nhập tên phòng khám, địa chỉ..." aria-label="Search">
                    <button class="btn btn-primary rounded-pill px-4" type="button"><i class="fa-solid fa-search me-2"></i>Tìm kiếm</button>
                </div>
            </div>
        </div>

        <div class="row g-4">
            <c:forEach var="clinic" items="${clinics}">
                <div class="col-md-6 col-lg-4">
                    <div class="card h-100 border-0 shadow-sm rounded-4 hover-shadow transition">
                        <div class="card-body p-4">
                            <div class="d-flex justify-content-between align-items-start mb-3">
                                <h5 class="card-title fw-bold text-dark mb-0">${clinic.clinicName}</h5>
                                <span class="badge bg-success bg-opacity-10 text-success rounded-pill px-3">
                                    <i class="fa-solid fa-star text-warning me-1"></i> ${clinic.rating}
                                </span>
                            </div>
                            <p class="text-muted small mb-3">
                                <i class="fa-solid fa-location-dot me-2 text-primary"></i>${clinic.address}
                            </p>
                            <p class="text-muted small mb-3">
                                <i class="fa-solid fa-phone me-2 text-primary"></i>${clinic.phone}
                            </p>
                            <div class="d-flex justify-content-between align-items-center mt-4">
                                <span class="badge bg-primary bg-opacity-10 text-primary px-3 py-2 rounded-pill">
                                    ${clinic.specialty}
                                </span>
                                <a href="#" class="btn btn-outline-primary btn-sm rounded-pill px-3">Chi tiết</a>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>
            <c:if test="${empty clinics}">
                <div class="col-12 text-center py-5">
                    <p class="text-muted">Không tìm thấy phòng khám nào.</p>
                </div>
            </c:if>
        </div>
        
        <div class="mt-5">
            <!-- Pagination could go here -->
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/layout/global-footer.jsp" />
