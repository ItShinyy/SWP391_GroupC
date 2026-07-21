<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="issueReportPath" value="${sessionScope.user.role == 'DOCTOR' ? '/doctor/issue-report' : '/patient/issue-report'}" />
<c:choose>
    <c:when test="${sessionScope.user.role == 'DOCTOR'}">
        <jsp:include page="/WEB-INF/views/layout/doctor-header.jsp" />
    </c:when>
    <c:otherwise>
        <jsp:include page="/WEB-INF/views/layout/guest-header.jsp" />
    </c:otherwise>
</c:choose>

<style>
    .issue-report-page .form-label { margin-bottom: .3rem; }
    .issue-report-page .form-text { margin-top: .25rem; }
    .issue-report-page .issue-heading { margin-bottom: .75rem; }
    .issue-report-page #description { min-height: 108px; resize: vertical; }
    .issue-report-page #imagePreview { max-height: 100px; }
    .issue-report-page .email-notice { padding: .65rem .8rem; }

    @media (max-width: 767.98px) {
        .issue-report-page { padding-top: 1rem !important; padding-bottom: 1rem !important; }
        .issue-report-page #description { min-height: 130px; }
    }
</style>

<div class="container py-2 issue-report-page">
    <div class="row justify-content-center">
        <div class="col-xl-8 col-lg-9">
                    <div class="d-flex align-items-center gap-3 issue-heading">
                        <div class="rounded-circle bg-danger bg-opacity-10 text-danger d-flex align-items-center justify-content-center flex-shrink-0" style="width: 42px; height: 42px;">
                            <i class="fa-solid fa-bug fs-5"></i>
                        </div>
                        <div>
                            <h3 class="fw-bold mb-0">Báo lỗi / Hỗ trợ</h3>
                            <p class="text-muted small mb-0">Hãy mô tả sự cố để đội ngũ quản trị có thể kiểm tra.</p>
                        </div>
                    </div>

                    <c:if test="${not empty sessionScope.successMessage}">
                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                            <i class="fa-solid fa-circle-check me-2"></i>${sessionScope.successMessage}
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                        <c:remove var="successMessage" scope="session" />
                    </c:if>
                    <c:if test="${not empty errorMessage}">
                        <div class="alert alert-danger" role="alert">
                            <i class="fa-solid fa-circle-exclamation me-2"></i>${errorMessage}
                        </div>
                    </c:if>

                    <form method="post" action="${pageContext.request.contextPath}${issueReportPath}" enctype="multipart/form-data" class="needs-validation" novalidate>
                        <div class="row g-2 mb-2">
                            <div class="col-md-7">
                                <label for="title" class="form-label fw-semibold">Tiêu đề sự cố <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" id="title" name="title" maxlength="150" required
                                       value="<c:out value='${formTitle}'/>"
                                       placeholder="Ví dụ: Không thể chuyển đến trang thanh toán">
                                <div class="invalid-feedback">Vui lòng nhập tiêu đề sự cố.</div>
                            </div>
                            <div class="col-md-5">
                                <label for="category" class="form-label fw-semibold">Loại sự cố <span class="text-danger">*</span></label>
                                <select class="form-select" id="category" name="category" required>
                                    <option value="">-- Chọn loại sự cố --</option>
                                    <option value="APPOINTMENT" ${formCategory == 'APPOINTMENT' ? 'selected' : ''}>Lịch hẹn</option>
                                    <option value="PAYMENT" ${formCategory == 'PAYMENT' ? 'selected' : ''}>Thanh toán</option>
                                    <option value="ACCOUNT" ${formCategory == 'ACCOUNT' ? 'selected' : ''}>Tài khoản</option>
                                    <option value="SYSTEM" ${formCategory == 'SYSTEM' ? 'selected' : ''}>Lỗi hệ thống</option>
                                    <option value="OTHER" ${formCategory == 'OTHER' ? 'selected' : ''}>Khác</option>
                                </select>
                                <div class="invalid-feedback">Vui lòng chọn loại sự cố.</div>
                            </div>
                        </div>

                        <div class="mb-2">
                            <label for="description" class="form-label fw-semibold">Mô tả lỗi <span class="text-danger">*</span></label>
                            <textarea class="form-control" id="description" name="description" rows="4" maxlength="2000" required
                                      placeholder="Hãy cho biết bạn đã thực hiện thao tác gì, lỗi xuất hiện vào lúc nào và thông báo lỗi (nếu có)..."><c:out value="${formDescription}" /></textarea>
                            <div class="invalid-feedback">Vui lòng mô tả sự cố bạn gặp phải.</div>
                            <div class="d-flex justify-content-between form-text">
                                <span>Không nhập mật khẩu, mã OTP hoặc thông tin thẻ ngân hàng.</span>
                                <span><span id="descriptionCount">0</span>/2000</span>
                            </div>
                        </div>

                        <div class="row g-2 align-items-end mb-2">
                            <div class="col-lg-7">
                                <label for="issueImage" class="form-label fw-semibold">Ảnh minh họa <span class="text-muted fw-normal">(tùy chọn)</span></label>
                                <input class="form-control" type="file" id="issueImage" name="issueImage" accept="image/jpeg,image/png,image/webp">
                                <div class="form-text">JPG, PNG hoặc WEBP; tối đa 5 MB.</div>
                                <img id="imagePreview" class="img-fluid rounded border mt-2 d-none" alt="Xem trước ảnh đính kèm">
                            </div>
                            <div class="col-lg-5">
                                <div class="alert alert-light border small text-muted email-notice mb-0">
                                    <i class="fa-solid fa-envelope me-2 text-primary"></i>
                                    Kết quả kiểm tra sẽ được gửi về email của bạn.
                                </div>
                            </div>
                        </div>

                        <div class="d-flex justify-content-end gap-2 pt-1">
                            <a class="btn btn-outline-secondary btn-sm px-3" href="${pageContext.request.contextPath}/home">Hủy</a>
                            <button class="btn btn-danger btn-sm px-3" type="submit"><i class="fa-solid fa-paper-plane me-2"></i>Gửi báo lỗi</button>
                        </div>
                    </form>
        </div>
    </div>
</div>

<script>
    (function () {
        const form = document.querySelector('.needs-validation');
        const description = document.getElementById('description');
        const count = document.getElementById('descriptionCount');
        const imageInput = document.getElementById('issueImage');
        const preview = document.getElementById('imagePreview');

        function updateCount() { count.textContent = description.value.length; }
        updateCount();
        description.addEventListener('input', updateCount);

        imageInput.addEventListener('change', function () {
            const file = this.files && this.files[0];
            if (!file) { preview.src = ''; preview.classList.add('d-none'); return; }
            preview.src = URL.createObjectURL(file);
            preview.classList.remove('d-none');
        });

        form.addEventListener('submit', function (event) {
            if (!form.checkValidity()) { event.preventDefault(); event.stopPropagation(); }
            form.classList.add('was-validated');
        });
    }());
</script>

<c:choose>
    <c:when test="${sessionScope.user.role == 'DOCTOR'}">
        <jsp:include page="/WEB-INF/views/layout/doctor-footer.jsp" />
    </c:when>
    <c:otherwise>
        <jsp:include page="/WEB-INF/views/layout/guest-footer.jsp" />
    </c:otherwise>
</c:choose>
