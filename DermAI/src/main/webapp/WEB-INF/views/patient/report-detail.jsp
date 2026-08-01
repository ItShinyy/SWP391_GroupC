<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/global-header.jsp" />

<section class="report-header py-4" style="background-color: var(--skin-primary, #0f766e);">
    <div class="container text-center text-white">
        <h2 class="fw-bold mb-2" style="font-family: 'Fragment Mono', sans-serif;">Báo Cáo Phân Tích AI</h2>
        <p class="mb-0 text-white-50">
            Mã báo cáo: #${report.id.substring(0, 8)}
            <c:if test="${not empty report.createdAt}">
                <c:set var="createdAtStr" value="${report.createdAt.toString()}" />
                <c:set var="dateOnly" value="${createdAtStr.substring(0, 10)}" />
                <c:set var="timeOnly" value="${createdAtStr.substring(11, 16)}" />
                <c:set var="year" value="${dateOnly.substring(0, 4)}" />
                <c:set var="month" value="${dateOnly.substring(5, 7)}" />
                <c:set var="day" value="${dateOnly.substring(8, 10)}" />
                | Ngày tạo: ${day}/${month}/${year} ${timeOnly}
            </c:if>
        </p>
    </div>
</section>

<section class="report-content py-5">
    <div class="container" style="max-width: 1100px;">
        <c:choose>
            <c:when test="${limitedView}">
                <div class="alert alert-warning border-0 rounded-4 shadow-sm mb-4" role="alert">
                    <strong><i class="fas fa-hourglass-half me-2"></i>Đang chờ bác sĩ da liễu duyệt.</strong>
                    Kết quả sàng lọc AI của bạn đã được lưu. Kết luận đầy đủ do bác sĩ xác nhận sẽ xuất hiện tại đây sau khi có đánh giá lâm sàng.
                </div>

                <div class="card shadow-sm border-0 rounded-4">
                    <div class="card-body p-4 p-md-5">
                        <h1 class="h3 fw-bold mb-3" style="color: var(--skin-primary, #0f766e);">Trạng thái sàng lọc</h1>
                        <p class="mb-1">
                            <span class="text-muted">Trạng thái duyệt:</span>
                            <strong><c:out value="${report.doctorReviewStatus}"/></strong>
                        </p>
                        <p class="mb-3">
                            <span class="text-muted">Hiển thị với bệnh nhân:</span>
                            <strong><c:out value="${report.patientVisibilityStatus}"/></strong>
                        </p>
                        <c:if test="${not empty report.diseaseName}">
                            <p class="mb-1">
                                <span class="text-muted">Gợi ý sơ bộ từ AI:</span>
                                <strong><c:out value="${report.diseaseName}"/></strong>
                                <span class="small text-muted">(chưa phải chẩn đoán cuối cùng)</span>
                            </p>
                        </c:if>
                        <c:if test="${report.confidenceScore > 0}">
                            <p class="mb-1">
                                <span class="text-muted">Độ tin cậy AI:</span>
                                <c:choose>
                                    <c:when test="${report.confidenceScore > 0 and report.confidenceScore <= 1}">
                                        <fmt:formatNumber value="${report.confidenceScore * 100}" type="number" maxFractionDigits="1"/>%
                                    </c:when>
                                    <c:otherwise>
                                        <fmt:formatNumber value="${report.confidenceScore}" type="number" maxFractionDigits="1"/>%
                                    </c:otherwise>
                                </c:choose>
                            </p>
                        </c:if>
                        <div class="d-flex flex-wrap gap-2 mt-4">
                            <a class="btn btn-primary rounded-pill fw-bold px-4"
                               href="${pageContext.request.contextPath}/patient/booking?reportId=${report.id}">
                                <i class="fas fa-calendar-plus me-2"></i>Tiếp tục đặt lịch
                            </a>
                            <a class="btn btn-outline-secondary rounded-pill px-4"
                               href="${pageContext.request.contextPath}/patient/reports">
                                Quay lại danh sách
                            </a>
                        </div>
                    </div>
                </div>
            </c:when>

            <c:otherwise>
                <div class="alert alert-success border-0 rounded-4 shadow-sm mb-4" role="alert">
                    <strong><i class="fas fa-user-doctor me-2"></i>Kết luận đã được bác sĩ duyệt.</strong>
                    Bác sĩ đã xem xét sàng lọc hỗ trợ bởi AI. Đây không phải chẩn đoán tự động và không thay thế chăm sóc y tế.
                </div>

                <div class="row g-4">
                    <div class="col-md-6">
                        <div class="card shadow-sm border-0 rounded-4 h-100">
                            <div class="card-header bg-white border-0 pt-4 pb-0 text-center">
                                <h4 class="fw-bold" style="color: var(--skin-primary, #0f766e);">Hình ảnh lâm sàng</h4>
                            </div>
                            <div class="card-body p-4">
                                <div class="row g-3">
                                    <c:if test="${not empty report.inputImageObjectKey}">
                                        <div class="col-6 text-center">
                                            <span class="badge bg-light text-dark mb-2 border">Ảnh gốc đã chuẩn hóa</span>
                                            <img src="${pageContext.request.contextPath}/reports/${report.id}/media/input"
                                                 class="img-fluid rounded-4 shadow-sm w-100"
                                                 style="object-fit: cover; height: 250px;"
                                                 alt="Ảnh đầu vào lâm sàng">
                                        </div>
                                    </c:if>
                                    <c:if test="${not empty report.eigencamObjectKey}">
                                        <div class="col-6 text-center">
                                            <span class="badge bg-primary mb-2 text-white">
                                                <i class="fa-solid fa-fire me-1"></i>Heatmap AI
                                            </span>
                                            <img src="${pageContext.request.contextPath}/reports/${report.id}/media/eigencam"
                                                 class="img-fluid rounded-4 shadow-sm w-100"
                                                 style="object-fit: cover; height: 250px;"
                                                 alt="Bản đồ giải thích AI">
                                            <p class="small text-muted mt-2 mb-0">Hỗ trợ bác sĩ xem xét; không phải chẩn đoán.</p>
                                        </div>
                                    </c:if>
                                    <c:if test="${empty report.inputImageObjectKey and empty report.eigencamObjectKey}">
                                        <div class="col-12 text-center text-muted py-4">
                                            <i class="fas fa-image fa-2x mb-2 d-block"></i>
                                            Không có hình ảnh đính kèm.
                                        </div>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="card shadow-sm border-0 rounded-4 h-100">
                            <div class="card-body p-4 p-lg-5">
                                <c:choose>
                                    <c:when test="${report.doctorReviewStatus == 'CONFIRMED' or report.doctorReviewStatus == 'OVERRIDDEN'}">
                                        <div class="d-flex justify-content-between align-items-start mb-4">
                                            <div>
                                                <h6 class="text-muted text-uppercase fw-bold mb-1">Kết luận bác sĩ</h6>
                                                <h2 class="fw-bold text-primary mb-0">
                                                    <c:out value="${report.diseaseName}"/>
                                                </h2>
                                            </div>
                                            <c:choose>
                                                <c:when test="${report.riskLevel == 'HIGH'}">
                                                    <span class="badge bg-danger rounded-pill px-3 py-2 fs-6 shadow-sm">
                                                        <i class="fa-solid fa-triangle-exclamation me-1"></i>Nguy cơ cao
                                                    </span>
                                                </c:when>
                                                <c:when test="${report.riskLevel == 'MEDIUM'}">
                                                    <span class="badge bg-warning text-dark rounded-pill px-3 py-2 fs-6 shadow-sm">
                                                        <i class="fa-solid fa-circle-exclamation me-1"></i>Nguy cơ vừa
                                                    </span>
                                                </c:when>
                                                <c:when test="${report.riskLevel == 'LOW'}">
                                                    <span class="badge bg-success rounded-pill px-3 py-2 fs-6 shadow-sm">
                                                        <i class="fa-solid fa-check-circle me-1"></i>Nguy cơ thấp
                                                    </span>
                                                </c:when>
                                            </c:choose>
                                        </div>

                                        <c:if test="${report.confidenceScore > 0}">
                                            <div class="mb-4">
                                                <div class="d-flex justify-content-between align-items-center mb-2">
                                                    <span class="fw-semibold text-dark">Độ tin cậy AI (tham khảo)</span>
                                                    <span class="badge bg-primary rounded-pill fs-6">
                                                        <c:choose>
                                                            <c:when test="${report.confidenceScore > 0 and report.confidenceScore <= 1}">
                                                                <fmt:formatNumber value="${report.confidenceScore * 100}" type="number" maxFractionDigits="1"/>%
                                                            </c:when>
                                                            <c:otherwise>
                                                                <fmt:formatNumber value="${report.confidenceScore}" type="number" maxFractionDigits="1"/>%
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                </div>
                                                <c:choose>
                                                    <c:when test="${report.confidenceScore > 0 and report.confidenceScore <= 1}">
                                                        <c:set var="confidencePercent" value="${report.confidenceScore * 100}"/>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <c:set var="confidencePercent" value="${report.confidenceScore}"/>
                                                    </c:otherwise>
                                                </c:choose>
                                                <div class="progress" style="height: 12px; border-radius: 10px;">
                                                    <div class="progress-bar progress-bar-striped progress-bar-animated bg-primary"
                                                         role="progressbar"
                                                         style="width: ${confidencePercent}%; border-radius: 10px;"
                                                         aria-valuenow="${confidencePercent}"
                                                         aria-valuemin="0"
                                                         aria-valuemax="100"></div>
                                                </div>
                                            </div>
                                        </c:if>

                                        <div class="alert alert-info border-0 rounded-4 p-4 mb-4" role="alert"
                                             style="background-color: #f0f9ff; border-left: 5px solid var(--skin-secondary, #0ea5e9) !important;">
                                            <h5 class="alert-heading fw-bold" style="color: var(--skin-primary, #0f766e);">
                                                <i class="fa-solid fa-user-doctor me-2"></i>Hướng dẫn đã duyệt
                                            </h5>
                                            <hr class="my-2 opacity-25">
                                            <p class="mb-0 text-dark">
                                                <c:choose>
                                                    <c:when test="${not empty report.patientGuidance}">
                                                        <c:out value="${report.patientGuidance}"/>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <c:out value="${report.recommendation}"/>
                                                    </c:otherwise>
                                                </c:choose>
                                            </p>
                                        </div>
                                    </c:when>

                                    <c:when test="${report.doctorReviewStatus == 'REQUIRES_IN_PERSON_REVIEW'}">
                                        <h2 class="fw-bold mb-3" style="color: var(--skin-primary, #0f766e);">Cần khám trực tiếp</h2>
                                        <div class="alert alert-warning border-0 rounded-4">
                                            Bác sĩ khuyến nghị đánh giá lâm sàng trực tiếp trước khi đưa ra kết luận.
                                        </div>
                                    </c:when>

                                    <c:otherwise>
                                        <h2 class="fw-bold mb-3" style="color: var(--skin-primary, #0f766e);">Gợi ý AI đã bị bác sĩ bỏ qua</h2>
                                        <div class="alert alert-secondary border-0 rounded-4">
                                            Không có gợi ý sàng lọc AI nào được trình bày như chẩn đoán của bạn.
                                        </div>
                                    </c:otherwise>
                                </c:choose>

                                <p class="text-muted small mb-3">
                                    Trạng thái duyệt: <c:out value="${report.doctorReviewStatus}"/>
                                </p>

                                <c:if test="${not empty report.doctorNote}">
                                    <div class="alert alert-light border rounded-4 mb-4">
                                        <strong>Ghi chú lâm sàng</strong><br>
                                        <c:out value="${report.doctorNote}"/>
                                    </div>
                                </c:if>

                                <div class="alert alert-warning border-0 rounded-4 d-flex align-items-start shadow-sm" role="alert">
                                    <i class="fa-solid fa-triangle-exclamation fs-4 me-3 text-warning"></i>
                                    <div>
                                        <strong>Lưu ý quan trọng:</strong>
                                        <p class="mb-0 small text-dark mt-1">
                                            Kết quả này được hỗ trợ bởi AI và đã được bác sĩ xem xét. Không thay thế chẩn đoán chuyên khoa trực tiếp khi cần thiết.
                                        </p>
                                    </div>
                                </div>

                                <div class="mt-4 text-center d-flex flex-wrap justify-content-center gap-2">
                                    <a href="${pageContext.request.contextPath}/patient/booking?reportId=${report.id}"
                                       class="btn btn-primary rounded-pill fw-bold px-4">
                                        <i class="fa-solid fa-calendar-plus me-2"></i>Đặt lịch khám
                                    </a>
                                    <a href="${pageContext.request.contextPath}/patient/reports"
                                       class="btn btn-outline-secondary rounded-pill px-4">
                                        Quay lại danh sách
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</section>

<jsp:include page="/WEB-INF/views/layout/global-footer.jsp" />
