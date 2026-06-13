<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/admin-header.jsp" />

<div class="container-fluid pt-3 pb-5">
    
    <!-- HEADER -->
    <div class="mb-4">
        <a href="${pageContext.request.contextPath}/admin/ai-results" class="text-decoration-none text-muted mb-2 d-inline-block fw-semibold small">
            <i class="fa-solid fa-arrow-left me-1"></i> Quay lại
        </a>
        <h3 class="page-title mb-1 fw-bold">Chi Tiết Báo Cáo Chẩn Đoán</h3>
        <div class="text-muted small d-flex align-items-center flex-wrap gap-2">
            <span>Mã báo cáo (Report ID): <span class="font-monospace">${report.id}</span></span>
        </div>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-danger shadow-sm rounded-3">
            <i class="fa-solid fa-triangle-exclamation me-2"></i> ${error}
        </div>
    </c:if>

    <c:if test="${not empty report}">
        
        <!-- CARD 1: DIAGNOSIS INFORMATION -->
        <div class="card shadow-sm border-0 rounded-4 mb-4">
            <div class="card-header bg-white border-bottom-0 pt-4 pb-0">
                <h6 class="fw-bold text-dark"><i class="fa-solid fa-file-medical text-warning me-2"></i> Thông tin báo cáo</h6>
            </div>
            <div class="card-body p-4">
                <div class="row g-4">
                    <div class="col-md-3">
                        <div class="text-muted small fw-bold text-uppercase mb-1">Mức độ rủi ro</div>
                        <c:choose>
                            <c:when test="${report.riskLevel == 'HIGH'}"><span class="badge bg-danger bg-opacity-10 text-danger border border-danger px-2 py-1 fs-6">NGUY CƠ CAO</span></c:when>
                            <c:when test="${report.riskLevel == 'MEDIUM'}"><span class="badge bg-warning bg-opacity-10 text-warning border border-warning px-2 py-1 fs-6">TRUNG BÌNH</span></c:when>
                            <c:when test="${report.riskLevel == 'LOW'}"><span class="badge bg-success bg-opacity-10 text-success border border-success px-2 py-1 fs-6">AN TOÀN</span></c:when>
                            <c:otherwise><span class="badge bg-secondary bg-opacity-10 text-secondary border border-secondary px-2 py-1 fs-6">ĐANG CHỜ</span></c:otherwise>
                        </c:choose>
                    </div>
                    <div class="col-md-3">
                        <div class="text-muted small fw-bold text-uppercase mb-1">Độ tin cậy</div>
                        <span class="badge bg-primary bg-opacity-10 text-primary border border-primary px-2 py-1 fs-6">
                            ${report.confidenceScore}%
                        </span>
                    </div>
                    <div class="col-md-3">
                        <div class="text-muted small fw-bold text-uppercase mb-1">Thời gian tạo</div>
                        <div class="fw-bold text-dark">
                            <fmt:parseDate value="${report.createdAt}" pattern="yyyy-MM-dd'T'HH:mm:ss" var="parsedCreatedAt" type="both" />
                            <fmt:formatDate pattern="dd/MM/yyyy HH:mm:ss" value="${parsedCreatedAt}" />
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="text-muted small fw-bold text-uppercase mb-1">Phiên bản AI</div>
                        <div class="text-dark small">
                            ${report.modelVersion}
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- CARD 2: ACTOR & TARGET -->
        <div class="card shadow-sm border-0 rounded-4 mb-4">
            <div class="card-header bg-white border-bottom-0 pt-4 pb-0">
                <h6 class="fw-bold text-dark"><i class="fa-solid fa-user-shield text-primary me-2"></i> Đối tượng & Mục tiêu</h6>
            </div>
            <div class="card-body p-4">
                <div class="row g-4">
                    <div class="col-md-4">
                        <div class="text-muted small fw-bold text-uppercase mb-1">Người thực hiện (Bệnh nhân)</div>
                        <div class="fw-bold text-primary text-break">
                            ${not empty report.patientName ? report.patientName : report.patientId}
                            <c:if test="${not empty report.patientEmail}">
                                <div class="text-muted fw-normal small">${report.patientEmail}</div>
                            </c:if>
                            <c:if test="${not empty report.patientPhone}">
                                <div class="text-muted fw-normal small"><i class="fa-solid fa-phone ms-1 me-1"></i>${report.patientPhone}</div>
                            </c:if>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="text-muted small fw-bold text-uppercase mb-1">Bệnh phát hiện</div>
                        <span class="badge bg-secondary bg-opacity-10 text-secondary border px-2 py-1 fs-6">
                            ${report.diseaseName != null ? report.diseaseName : 'Không xác định'}
                        </span>
                    </div>
                    <div class="col-md-4">
                        <div class="text-muted small fw-bold text-uppercase mb-1">Phòng khám</div>
                        <div class="d-flex align-items-center gap-2">
                            <c:choose>
                                <c:when test="${not empty report.clinicId}">
                                    <span class="font-monospace small text-muted bg-light px-2 py-1 rounded border">ID: ${report.clinicId}</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="text-muted small">N/A</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- CARD 3: TECHNICAL INFORMATION -->
        <div class="card shadow-sm border-0 rounded-4 mb-4">
            <div class="card-header bg-white border-bottom-0 pt-4 pb-0">
                <h6 class="fw-bold text-dark"><i class="fa-solid fa-image text-info me-2"></i> Thông tin hình ảnh</h6>
            </div>
            <div class="card-body p-4">
                <div class="row g-4">
                    <div class="col-12">
                        <div class="text-muted small fw-bold text-uppercase mb-2">Ảnh chẩn đoán</div>
                        <div class="border rounded p-2 bg-light d-inline-block">
                            <c:if test="${not empty report.imageUrl}">
                                <a href="${report.imageUrl}" target="_blank">
                                    <img src="${report.imageUrl}" alt="Diagnosis Image" class="img-fluid rounded" style="max-height: 300px; object-fit: contain;">
                                </a>
                            </c:if>
                            <c:if test="${empty report.imageUrl}">
                                <span class="text-muted small">Không có hình ảnh</span>
                            </c:if>
                        </div>
                        <div class="mt-2 text-truncate small">
                            <a href="${report.imageUrl}" target="_blank" class="text-muted">${report.imageUrl}</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- CARD 4: CHANGE DATA / EVENT DATA -->
        <div class="card shadow-sm border-0 rounded-4">
            <div class="card-header bg-white border-bottom-0 pt-4 pb-0">
                <h6 class="fw-bold text-dark"><i class="fa-solid fa-stethoscope text-success me-2"></i> Khuyến nghị từ AI</h6>
            </div>
            <div class="card-body p-4">
                <div class="row g-3">
                    <c:choose>
                        <c:when test="${not empty report.recommendation}">
                            <div class="col-12 d-flex flex-column">
                                <pre class="p-3 border border-secondary border-opacity-25 rounded small flex-grow-1 mb-0" style="background-color: #f8f9fa; color: #212529; white-space: pre-wrap; word-break: break-all; min-height: 100px; max-height: 500px; overflow-y: auto;"><c:out value="${report.recommendation}" /></pre>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="col-12 text-center py-4 mt-3 text-muted bg-light rounded">
                                <i class="fa-solid fa-box-open fa-2x mb-2 text-secondary opacity-50"></i>
                                <p class="mb-0 small">Không có dữ liệu khuyến nghị cho báo cáo này.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

    </c:if>
</div>

<jsp:include page="/WEB-INF/views/layout/admin-footer.jsp" />
