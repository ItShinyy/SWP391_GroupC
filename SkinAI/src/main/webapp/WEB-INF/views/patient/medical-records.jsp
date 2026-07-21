<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/guest-header.jsp" />

<style>
    .medical-records-page { background: #f8fafc; min-height: calc(100vh - 80px); }
    .medical-records-card { border: 1px solid #e2e8f0; border-radius: 16px; }
    .person-select { min-width: 290px; }
    .filter-card { background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 14px; }
    .medical-records-table thead th { background: #212529; color: #fff; white-space: nowrap; }
    .diagnosis-cell { max-width: 420px; }
    .record-code { color: #64748b; font-family: monospace; }
    .prescription-modal .modal-content { border-radius: 16px; overflow: hidden; }
    .prescription-modal-content { padding: 26px 28px; }
    .prescription-modal-title {
        display: flex;
        align-items: center;
        gap: 10px;
        font-size: 1.6rem;
        font-weight: 700;
        padding-bottom: 14px;
        margin-bottom: 26px;
        border-bottom: 2px solid #e2e8f0;
    }
    .prescription-modal-title i { color: #198754; }
    .prescription-modal-table thead th {
        background: #198754;
        color: #fff;
        padding: 13px 12px;
        border-color: #d1d5db;
    }
    .prescription-modal-table tbody td {
        padding: 12px;
        border-color: #d1d5db;
    }
    .prescription-modal-close {
        position: absolute;
        top: 18px;
        right: 20px;
        z-index: 2;
    }
    @media (max-width: 767.98px) {
        .person-select { min-width: 100%; width: 100%; }
    }
</style>

<section class="medical-records-page py-4">
    <div class="container-fluid px-3 px-lg-4">
        <div class="medical-records-card bg-white shadow-sm p-3 p-lg-4">
            <form method="get" action="${pageContext.request.contextPath}/patient/medical-records">
                <div class="d-flex flex-column flex-md-row align-items-md-center gap-3 mb-4">
                    <h1 class="mb-0">Hồ sơ bệnh án của</h1>
                    <select class="form-select form-select-lg person-select" name="person"
                            aria-label="Chọn người có hồ sơ bệnh án" onchange="this.form.submit()">
                        <option value="SELF" ${selectedPerson == 'SELF' ? 'selected' : ''}>
                            Tôi - ${sessionScope.user.fullName}
                        </option>
                        <c:forEach var="member" items="${familyMembers}">
                            <c:set var="memberValue" value="FAMILY:${member.id}" />
                            <option value="${memberValue}" ${selectedPerson == memberValue ? 'selected' : ''}>
                                <c:choose>
                                    <c:when test="${member.relationship == 'FATHER'}">Bố</c:when>
                                    <c:when test="${member.relationship == 'MOTHER'}">Mẹ</c:when>
                                    <c:when test="${member.relationship == 'SPOUSE'}">Vợ/Chồng</c:when>
                                    <c:when test="${member.relationship == 'CHILD'}">Con</c:when>
                                    <c:when test="${member.relationship == 'OLDER_BROTHER'}">Anh</c:when>
                                    <c:when test="${member.relationship == 'OLDER_SISTER'}">Chị</c:when>
                                    <c:when test="${member.relationship == 'YOUNGER_BROTHER'}">Em trai</c:when>
                                    <c:when test="${member.relationship == 'YOUNGER_SISTER'}">Em gái</c:when>
                                    <c:when test="${member.relationship == 'GRANDPARENT'}">Ông/Bà</c:when>
                                    <c:otherwise>Người thân</c:otherwise>
                                </c:choose>
                                - ${member.fullName}
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="filter-card p-3 mb-4">
                    <div class="row g-3 align-items-end">
                        <div class="col-12 col-lg-3">
                            <label class="form-label fw-semibold" for="medicalSearch">Chẩn đoán hoặc triệu chứng</label>
                            <input id="medicalSearch" class="form-control" type="search" name="search"
                                   value="<c:out value='${search}'/>" placeholder="Tìm kiếm nội dung hồ sơ...">
                        </div>
                        <div class="col-12 col-md-4 col-lg-2">
                            <label class="form-label fw-semibold" for="fromDate">Từ ngày</label>
                            <input id="fromDate" class="form-control" type="date" name="fromDate" value="${fromDate}">
                        </div>
                        <div class="col-12 col-md-4 col-lg-2">
                            <label class="form-label fw-semibold" for="toDate">Đến ngày</label>
                            <input id="toDate" class="form-control" type="date" name="toDate" value="${toDate}">
                        </div>
                        <div class="col-12 col-md-4 col-lg-2">
                            <label class="form-label fw-semibold" for="sort">Sắp xếp</label>
                            <select id="sort" class="form-select" name="sort">
                                <option value="newest" ${sort == 'newest' ? 'selected' : ''}>Ngày khám mới nhất</option>
                                <option value="oldest" ${sort == 'oldest' ? 'selected' : ''}>Ngày khám cũ nhất</option>
                            </select>
                        </div>
                        <div class="col-12 col-lg-3 d-flex gap-2">
                            <button class="btn btn-primary flex-grow-1" type="submit">
                                <i class="fa-solid fa-magnifying-glass me-1"></i> Tìm kiếm
                            </button>
                            <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/patient/medical-records?person=${selectedPerson}">
                                Xóa bộ lọc
                            </a>
                        </div>
                    </div>
                </div>
            </form>

            <div class="d-flex justify-content-between align-items-center mb-3">
                <h5 class="mb-0 text-secondary">${selectedPersonLabel}</h5>
                <span class="badge rounded-pill bg-success-subtle text-success px-3 py-2">
                    ${reports.size()} hồ sơ
                </span>
            </div>

            <div class="table-responsive">
                <table class="table table-striped table-hover align-middle medical-records-table mb-0">
                    <thead>
                        <tr>
                            <th>Mã hồ sơ</th>
                            <th>Chẩn đoán của bác sĩ</th>
                            <th>Bác sĩ</th>
                            <th>Phòng khám</th>
                            <th>Ngày khám</th>
                            <th>Ngày tái khám</th>
                            <th>Đơn thuốc</th>
                            <th class="text-center">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty reports}">
                                <tr>
                                    <td colspan="8" class="text-center text-muted py-5">
                                        <i class="fa-regular fa-folder-open fs-2 d-block mb-2"></i>
                                        Chưa có hồ sơ bệnh án của ${selectedPersonLabel}.
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="report" items="${reports}">
                                    <tr>
                                        <td><span class="record-code">#${report.shortId}</span></td>
                                        <td class="diagnosis-cell fw-semibold">${report.doctorDiagnosis}</td>
                                        <td>${report.doctorName}</td>
                                        <td>${report.clinicName}</td>
                                        <td>${report.appointmentTimeDisplay}</td>
                                        <td>${report.followUpDateDisplay}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${report.prescriptionCount > 0}">
                                                    <button type="button" class="btn btn-sm btn-success"
                                                            data-bs-toggle="modal"
                                                            data-bs-target="#prescriptionModal_${report.shortId}">
                                                        <i class="fa-solid fa-prescription-bottle-medical me-1"></i>
                                                        Xem đơn thuốc
                                                    </button>
                                                </c:when>
                                                <c:otherwise><span class="text-muted">Không có</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-center">
                                            <a class="btn btn-sm btn-outline-primary"
                                               href="${pageContext.request.contextPath}/patient/medical-records?action=view&id=${report.id}">
                                                <i class="fa-regular fa-eye me-1"></i> Xem
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

            <c:forEach var="report" items="${reports}">
                <c:if test="${report.prescriptionCount > 0}">
                    <div class="modal fade prescription-modal" id="prescriptionModal_${report.shortId}" tabindex="-1"
                         aria-labelledby="prescriptionModalLabel_${report.shortId}" aria-hidden="true">
                        <div class="modal-dialog modal-dialog-centered modal-xl">
                            <div class="modal-content border-0 shadow">
                                <button type="button" class="btn-close prescription-modal-close"
                                        data-bs-dismiss="modal" aria-label="Đóng"></button>
                                <div class="prescription-modal-content">
                                    <div class="prescription-modal-title" id="prescriptionModalLabel_${report.shortId}">
                                        <i class="fa-solid fa-prescription-bottle-medical"></i>
                                        <span>Đơn thuốc</span>
                                    </div>
                                    <div class="table-responsive">
                                        <table class="table table-bordered align-middle mb-0 prescription-modal-table">
                                            <thead>
                                                <tr>
                                                    <th style="width: 28%">Tên thuốc</th>
                                                    <th style="width: 12%">Số lượng</th>
                                                    <th>Liều dùng</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="prescription" items="${report.prescriptions}">
                                                    <tr>
                                                        <td class="fw-semibold">${prescription.drugName}</td>
                                                        <td>${prescription.quantity}</td>
                                                        <td>${prescription.dosage}</td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:if>
            </c:forEach>
        </div>
    </div>
</section>

<jsp:include page="/WEB-INF/views/layout/guest-footer.jsp" />
