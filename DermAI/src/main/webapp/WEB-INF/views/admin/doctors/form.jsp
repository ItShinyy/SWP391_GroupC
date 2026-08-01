<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/admin-header.jsp" />

<div class="container-fluid py-4">
    <div class="row mb-4">
        <div class="col-12 d-flex justify-content-between align-items-center">
            <div>
                <h3 class="fw-bold mb-1">${empty doctor ? 'Thêm' : 'Cập nhật'} Bác Sĩ</h3>
                <p class="text-muted mb-0">
                    <c:choose>
                        <c:when test="${empty doctor}">
                            Admin-only. Creates a normal DOCTOR login plus a full doctors profile. Schedule is set later by the doctor.
                        </c:when>
                        <c:otherwise>
                            Update account display fields and doctors profile. Schedule stays on the doctor portal.
                        </c:otherwise>
                    </c:choose>
                </p>
            </div>
            <a href="${pageContext.request.contextPath}/admin/users?segment=employee" class="btn btn-outline-secondary fw-bold">
                <i class="fa-solid fa-arrow-left me-2"></i> Quay lại
            </a>
        </div>
    </div>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger"><c:out value="${errorMessage}"/></div>
    </c:if>

    <div class="card border-0 shadow-sm rounded-4">
        <div class="card-body p-4">
            <form action="${pageContext.request.contextPath}/admin/doctors" method="post" autocomplete="off">
                <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
                <input type="hidden" name="action" value="${empty doctor ? 'create' : 'update'}">
                <c:if test="${not empty doctor}">
                    <input type="hidden" name="id" value="${doctor.id}">
                </c:if>

                <h5 class="fw-bold border-bottom pb-2 mb-3">Account (users)</h5>
                <p class="text-muted small mb-3">All fields required except Bio.</p>
                <div class="row g-3 mb-4">
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Full name <span class="text-danger">*</span></label>
                        <input type="text" name="fullName" class="form-control" value="<c:out value='${doctor.fullName}'/>" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Email <span class="text-danger">*</span></label>
                        <input type="email" name="email" class="form-control" value="<c:out value='${doctor.email}'/>"
                               ${empty doctor ? 'required' : 'readonly'}>
                    </div>
                    <c:if test="${empty doctor}">
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Username <span class="text-danger">*</span></label>
                            <input type="text" name="username" class="form-control" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Phone <span class="text-danger">*</span></label>
                            <input type="text" name="phone" class="form-control" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Password <span class="text-danger">*</span></label>
                            <input type="password" name="password" class="form-control" required minlength="8" autocomplete="new-password">
                            <div class="form-text small"><c:out value="${passwordRequirements}"/></div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Confirm password <span class="text-danger">*</span></label>
                            <input type="password" name="confirmPassword" class="form-control" required minlength="8" autocomplete="new-password">
                        </div>
                    </c:if>
                    <c:if test="${not empty doctor}">
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Phone <span class="text-danger">*</span></label>
                            <input type="text" name="phone" class="form-control" value="<c:out value='${doctor.phone}'/>" required>
                        </div>
                    </c:if>
                </div>

                <h5 class="fw-bold border-bottom pb-2 mb-3">Doctor profile (doctors)</h5>
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Clinic <span class="text-danger">*</span></label>
                        <select name="clinicId" class="form-select" required>
                            <option value="">-- Select clinic --</option>
                            <c:forEach var="clinic" items="${clinics}">
                                <option value="${clinic.id}" ${doctor.clinicId == clinic.id ? 'selected' : ''}><c:out value="${clinic.clinicName}"/></option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Specialization <span class="text-danger">*</span></label>
                        <input type="text" name="specialization" class="form-control" maxlength="255" required
                               value="<c:out value='${doctor.specialization}'/>">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-bold">License number <span class="text-danger">*</span></label>
                        <input type="text" name="licenseNumber" class="form-control" maxlength="100" required
                               value="<c:out value='${doctor.licenseNumber}'/>">
                    </div>
                    <div class="col-12">
                        <label class="form-label fw-bold">Bio <span class="text-muted fw-normal">(optional)</span></label>
                        <textarea name="bio" class="form-control" rows="3" maxlength="2000"><c:out value="${doctor.bio}"/></textarea>
                    </div>
                    <c:if test="${not empty doctor}">
                        <div class="col-md-6">
                            <label class="form-label text-muted small mb-0">Doctor id</label>
                            <div class="form-control-plaintext small"><c:out value="${doctor.id}"/></div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label text-muted small mb-0">Linked user id</label>
                            <div class="form-control-plaintext small"><c:out value="${doctor.userId}"/></div>
                        </div>
                    </c:if>
                </div>

                <div class="mt-4 pt-3 border-top text-end">
                    <button type="submit" class="btn btn-primary fw-bold px-4">
                        ${empty doctor ? 'Create doctor account' : 'Save changes'}
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/layout/admin-footer.jsp" />
