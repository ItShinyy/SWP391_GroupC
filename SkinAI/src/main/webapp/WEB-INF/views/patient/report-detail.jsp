<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/public-header.jsp" />

<section class="report-header py-4" style="background-color: var(--skin-primary);">
    <div class="container text-center text-white">
        <h2 class="fw-bold mb-2" style="font-family: 'Fragment Mono', sans-serif;">Báo Cáo Phân Tích AI</h2>
        <p class="mb-0 text-white-50">Mã báo cáo: #${report.id.substring(0,8)} | Ngày tạo: <fmt:parseDate value="${report.createdAt}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedDate" type="both" /><fmt:formatDate pattern="dd/MM/yyyy HH:mm" value="${parsedDate}" /></p>
    </div>
</section>

<section class="report-content py-5">
    <div class="container">
        <div class="row g-4">
            <!-- Cột trái: Hình ảnh -->
            <div class="col-md-6">
                <div class="card shadow-sm border-0 rounded-4 h-100">
                    <div class="card-header bg-white border-0 pt-4 pb-0 text-center">
                        <h4 class="fw-bold" style="color: var(--skin-primary);">Hình ảnh chẩn đoán</h4>
                    </div>
                    <div class="card-body p-4">
                        <div class="row g-3">
                            <div class="col-6 text-center">
                                <span class="badge bg-light text-dark mb-2 border">Ảnh gốc</span>
                                <img src="${pageContext.request.contextPath}${report.imageUrl}" class="img-fluid rounded-4 shadow-sm w-100" style="object-fit: cover; height: 250px;" alt="Original">
                            </div>
                            <div class="col-6 text-center">
                                <span class="badge bg-primary mb-2 text-white"><i class="fa-solid fa-fire me-1"></i>Heatmap AI</span>
                                <img src="${pageContext.request.contextPath}${report.heatmapUrl}" class="img-fluid rounded-4 shadow-sm w-100" style="object-fit: cover; height: 250px;" alt="Heatmap">
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Cột phải: Data -->
            <div class="col-md-6">
                <div class="card shadow-sm border-0 rounded-4 h-100">
                    <div class="card-body p-4 p-lg-5">
                        <div class="d-flex justify-content-between align-items-start mb-4">
                            <div>
                                <h6 class="text-muted text-uppercase fw-bold mb-1">Kết quả dự đoán</h6>
                                <h2 class="fw-bold text-primary mb-0">${report.diseaseName != null ? report.diseaseName : "Viêm da cơ địa"}</h2>
                            </div>
                            <!-- Risk Level Badge -->
                            <c:choose>
                                <c:when test="${report.riskLevel == 'HIGH'}">
                                    <span class="badge bg-danger rounded-pill px-3 py-2 fs-6 shadow-sm"><i class="fa-solid fa-triangle-exclamation me-1"></i>Nguy hiểm cao</span>
                                </c:when>
                                <c:when test="${report.riskLevel == 'MEDIUM'}">
                                    <span class="badge bg-warning text-dark rounded-pill px-3 py-2 fs-6 shadow-sm"><i class="fa-solid fa-circle-exclamation me-1"></i>Nguy hiểm vừa</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-success rounded-pill px-3 py-2 fs-6 shadow-sm"><i class="fa-solid fa-check-circle me-1"></i>Nguy hiểm thấp</span>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <!-- Progress Bar -->
                        <div class="mb-5">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <span class="fw-semibold text-dark">Độ tin cậy của AI (Confidence)</span>
                                <span class="badge bg-primary rounded-pill fs-6"><fmt:formatNumber value="${report.confidenceScore}" type="number" maxFractionDigits="1"/>%</span>
                            </div>
                            <div class="progress" style="height: 12px; border-radius: 10px;">
                                <div class="progress-bar progress-bar-striped progress-bar-animated bg-primary" role="progressbar" style="width: ${report.confidenceScore}%; border-radius: 10px;" aria-valuenow="${report.confidenceScore}" aria-valuemin="0" aria-valuemax="100"></div>
                            </div>
                        </div>

                        <!-- Recommendations -->
                        <div class="alert alert-info border-0 rounded-4 p-4 mb-4" role="alert" style="background-color: #f0f9ff; border-left: 5px solid var(--skin-secondary) !important;">
                            <h5 class="alert-heading fw-bold" style="color: var(--skin-primary);"><i class="fa-solid fa-user-doctor me-2"></i>Khuyến nghị sơ bộ</h5>
                            <hr class="my-2 opacity-25">
                            <p class="mb-0 text-dark">${report.recommendation}</p>
                        </div>

                        <!-- Medical Disclaimer -->
                        <div class="alert alert-warning border-0 rounded-4 d-flex align-items-start shadow-sm" role="alert">
                            <i class="fa-solid fa-triangle-exclamation fs-4 me-3 text-warning"></i>
                            <div>
                                <strong>Lưu ý quan trọng:</strong>
                                <p class="mb-0 small text-dark mt-1">Kết quả phân tích này được tạo ra bởi Trí tuệ nhân tạo (AI) và chỉ mang tính chất tham khảo. Không được sử dụng để thay thế chẩn đoán chuyên khoa của Bác sĩ.</p>
                            </div>
                        </div>
                        
                        <div class="mt-4 text-center">
                            <a href="${pageContext.request.contextPath}/clinics" class="btn btn-outline-primary rounded-pill fw-bold px-4">
                                <i class="fa-solid fa-location-dot me-2"></i>Tìm phòng khám gần nhất
                            </a>
                        </div>
                    </div>
                </div>
            </div>
            
        </div>
    </div>
</section>

<jsp:include page="/WEB-INF/views/layout/public-footer.jsp" />
