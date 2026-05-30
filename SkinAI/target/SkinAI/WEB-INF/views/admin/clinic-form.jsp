<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/admin-header.jsp" />

<div class="container-fluid py-4">
    <div class="row mb-4">
        <div class="col-12 d-flex justify-content-between align-items-center">
            <div>
                <h3 class="fw-bold mb-1" style="color: var(--skin-primary);">${empty clinic ? 'Add' : 'Update'} Clinic</h3>
                <p class="text-muted mb-0">Manage information and map coordinates</p>
            </div>
            <a href="${pageContext.request.contextPath}/admin/clinics" class="btn btn-outline-secondary fw-bold">
                <i class="fa-solid fa-arrow-left me-2"></i> Back
            </a>
        </div>
    </div>

    <div class="card border-0 shadow-sm rounded-4">
        <div class="card-body p-4">
            <form action="${pageContext.request.contextPath}/admin/clinics" method="post">
                <input type="hidden" name="action" value="${empty clinic ? 'create' : 'edit'}">
                <c:if test="${not empty clinic}">
                    <input type="hidden" name="id" value="${clinic.id}">
                </c:if>

                <div class="row g-4">
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Clinic Name</label>
                        <input type="text" name="clinicName" class="form-control" value="${clinic.clinicName}" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Specialty</label>
                        <input type="text" name="specialty" class="form-control" value="${clinic.specialty}">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Phone Number</label>
                        <input type="text" name="phone" class="form-control" value="${clinic.phone}">
                    </div>
                    <div class="col-md-12">
                        <label class="form-label fw-bold">Address</label>
                        <input type="text" name="address" class="form-control" value="${clinic.address}" required>
                    </div>

                    <!-- Map Coordinates -->
                    <div class="col-12 mt-4">
                        <h5 class="fw-bold border-bottom pb-2">Map Coordinates (Google Maps)</h5>
                        <p class="text-muted small mb-3">Coordinate information is used to show the clinic on the map for patients.</p>
                    </div>
                    
                    <div class="col-md-4">
                        <label class="form-label fw-bold text-muted">Google Place ID</label>
                        <input type="text" name="googlePlaceId" class="form-control" value="${clinic.googlePlaceId}">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-bold text-muted">Latitude</label>
                        <input type="text" name="latitude" class="form-control" value="${clinic.latitude}">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-bold text-muted">Longitude</label>
                        <input type="text" name="longitude" class="form-control" value="${clinic.longitude}">
                    </div>
                </div>

                <div class="mt-4 pt-3 border-top text-end">
                    <button type="submit" class="btn btn-skin fw-bold px-4">Save Information</button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/layout/admin-footer.jsp" />
