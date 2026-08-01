<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/global-header.jsp" />

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-lg-10">
            <div class="card border-0 shadow-sm rounded-4">
                <div class="card-body p-4 p-md-5">
                    <div class="d-flex align-items-center gap-3 mb-4">
                        <div class="rounded-circle bg-primary bg-opacity-10 text-primary d-flex align-items-center justify-content-center flex-shrink-0" style="width: 48px; height: 48px;">
                            <i class="fa-solid fa-user-plus fs-4"></i>
                        </div>
                        <div>
                            <h2 class="fw-bold mb-1">Thêm thành viên gia đình</h2>
                            <p class="text-muted mb-0">Thông tin này sẽ được dùng khi bạn đặt lịch khám cho người thân.</p>
                        </div>
                    </div>

                    <c:if test="${not empty errorMessage}">
                        <div class="alert alert-danger"><i class="fa-solid fa-circle-exclamation me-2"></i>${errorMessage}</div>
                    </c:if>

                    <form method="post" action="${pageContext.request.contextPath}/patient/family-members" class="needs-validation" novalidate>
                        <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
                        <h5 class="fw-bold border-bottom pb-2 mb-3">Thông tin người thân</h5>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="fullName" class="form-label fw-semibold">Tên người thân <span class="text-danger">*</span></label>
                                <input id="fullName" name="fullName" type="text" class="form-control" maxlength="100" required value="<c:out value='${member.fullName}'/>" placeholder="Nhập họ và tên đầy đủ">
                                <div class="invalid-feedback">Vui lòng nhập tên người thân.</div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="dateOfBirth" class="form-label fw-semibold">Ngày tháng năm sinh <span class="text-danger">*</span></label>
                                <input id="dateOfBirth" name="dateOfBirth" type="date" class="form-control" required max="<%= java.time.LocalDate.now() %>" value="<c:out value='${member.dateOfBirth}'/>">
                                <div class="invalid-feedback">Vui lòng chọn ngày sinh hợp lệ.</div>
                            </div>

                            <div class="col-md-6 mb-3">
                                <label for="relationship" class="form-label fw-semibold">Mối quan hệ <span class="text-danger">*</span></label>
                                <select id="relationship" name="relationship" class="form-select" required>
                                    <option value="">-- Chọn mối quan hệ --</option>
                                    <option value="FATHER" ${member.relationship == 'FATHER' ? 'selected' : ''}>Bố</option>
                                    <option value="MOTHER" ${member.relationship == 'MOTHER' ? 'selected' : ''}>Mẹ</option>
                                    <option value="SPOUSE" ${member.relationship == 'SPOUSE' ? 'selected' : ''}>Vợ/Chồng</option>
                                    <option value="CHILD" ${member.relationship == 'CHILD' ? 'selected' : ''}>Con</option>
                                    <option value="OLDER_BROTHER" ${member.relationship == 'OLDER_BROTHER' ? 'selected' : ''}>Anh</option>
                                    <option value="OLDER_SISTER" ${member.relationship == 'OLDER_SISTER' ? 'selected' : ''}>Chị</option>
                                    <option value="YOUNGER_BROTHER" ${member.relationship == 'YOUNGER_BROTHER' ? 'selected' : ''}>Em trai</option>
                                    <option value="YOUNGER_SISTER" ${member.relationship == 'YOUNGER_SISTER' ? 'selected' : ''}>Em gái</option>
                                    <option value="GRANDPARENT" ${member.relationship == 'GRANDPARENT' ? 'selected' : ''}>Ông/Bà</option>
                                    <option value="OTHER" ${member.relationship == 'OTHER' ? 'selected' : ''}>Khác</option>
                                </select>
                            </div>
                        </div>

                        <h5 class="fw-bold border-bottom pb-2 mb-3 mt-4">Thông tin liên hệ và địa chỉ</h5>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="phone" class="form-label fw-semibold">Số điện thoại <span class="text-danger">*</span></label>
                                <input id="phone" name="phone" type="tel" class="form-control" maxlength="20" required value="<c:out value='${member.phone}'/>" placeholder="Nhập số điện thoại">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="email" class="form-label fw-semibold">Email <span class="text-muted fw-normal">(tùy chọn)</span></label>
                                <input id="email" name="email" type="email" class="form-control" maxlength="100" value="<c:out value='${member.email}'/>" placeholder="Nhập email">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="province" class="form-label fw-semibold">Tỉnh/Thành phố <span class="text-danger">*</span></label>
                                <input id="province" name="province" type="text" class="form-control" required maxlength="100" value="<c:out value='${member.province}'/>" placeholder="Ví dụ: Thành phố Hà Nội">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="ward" class="form-label fw-semibold">Xã/Phường <span class="text-danger">*</span></label>
                                <input id="ward" name="ward" type="text" class="form-control" required maxlength="100" value="<c:out value='${member.ward}'/>" placeholder="Nhập xã/phường">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="addressDetail" class="form-label fw-semibold">Địa chỉ chi tiết <span class="text-danger">*</span></label>
                                <input id="addressDetail" name="addressDetail" type="text" class="form-control" required maxlength="255" value="<c:out value='${member.addressDetail}'/>" placeholder="Số nhà, tên đường...">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="country" class="form-label fw-semibold">Quốc gia <span class="text-danger">*</span></label>
                                <input id="country" name="country" type="text" class="form-control" required maxlength="100" value="<c:out value='${member.country}'/>" placeholder="Ví dụ: Việt Nam">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="ethnicity" class="form-label fw-semibold">Dân tộc <span class="text-danger">*</span></label>
                                <input id="ethnicity" name="ethnicity" type="text" class="form-control" required maxlength="100" value="<c:out value='${member.ethnicity}'/>" placeholder="Ví dụ: Kinh">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="occupation" class="form-label fw-semibold">Nghề nghiệp <span class="text-danger">*</span></label>
                                <input id="occupation" name="occupation" type="text" class="form-control" required maxlength="100" value="<c:out value='${member.occupation}'/>" placeholder="Nhập nghề nghiệp">
                            </div>
                        </div>

                        <div class="d-flex flex-column flex-sm-row justify-content-end gap-2 mt-3">
                            <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/account/profile">Quay lại</a>
                            <button type="submit" class="btn btn-primary"><i class="fa-solid fa-floppy-disk me-2"></i>Lưu thành viên</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    document.querySelector('.needs-validation').addEventListener('submit', function (event) {
        if (!this.checkValidity()) { event.preventDefault(); event.stopPropagation(); }
        this.classList.add('was-validated');
    });
</script>
<jsp:include page="/WEB-INF/views/layout/global-footer.jsp" />
