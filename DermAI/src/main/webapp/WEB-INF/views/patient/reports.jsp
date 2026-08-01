<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/global-header.jsp" />

<div class="container-fluid">
    <div class="table-container bg-white shadow-sm rounded-4 p-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h1 class="page-title mb-1">Lịch sử Sàng lọc AI</h1>
                <p class="text-muted mb-0 small">Chỉ hiển thị kết luận bác sĩ đã chọn chia sẻ với bạn.</p>
            </div>
        </div>

        <div class="table-responsive">
            <table class="table table-hover table-striped align-middle">
                <thead class="table-dark">
                    <tr>
                        <th scope="col" style="width: 12%">Mã (ID)</th>
                        <th scope="col" style="width: 34%">Kết luận</th>
                        <th scope="col" style="width: 12%">Độ tin cậy</th>
                        <th scope="col" style="width: 14%">Mức độ rủi ro</th>
                        <th scope="col" style="width: 16%">Ngày tạo</th>
                        <th scope="col" style="width: 12%" class="text-center">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty reports}">
                            <tr>
                                <td colspan="6" class="text-center py-5 text-muted">
                                    <i class="fas fa-notes-medical fa-3x mb-3 text-light"></i>
                                    <h5>Không tìm thấy kết quả</h5>
                                    <p class="mb-0">Chưa có kết luận sàng lọc AI nào được bác sĩ chia sẻ.</p>
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="r" items="${reports}">
                                <tr>
                                    <td>
                                        <span class="uuid-text text-secondary font-monospace" title="${r.id}">
                                            ${r.id.substring(0, 8)}<span class="text-muted">...</span>
                                        </span>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${r.doctorReviewStatus == 'CONFIRMED' or r.doctorReviewStatus == 'OVERRIDDEN'}">
                                                <span class="badge bg-secondary p-1">BS</span>
                                                <c:out value="${r.diseaseName}"/>
                                            </c:when>
                                            <c:when test="${r.doctorReviewStatus == 'REQUIRES_IN_PERSON_REVIEW'}">
                                                <span class="text-warning fw-semibold">
                                                    <i class="fas fa-user-doctor me-1"></i>Cần khám trực tiếp
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">Gợi ý AI đã bị bác sĩ bỏ qua</span>
                                            </c:otherwise>
                                        </c:choose>
                                        <div class="small text-muted mt-1">
                                            <c:out value="${r.doctorReviewStatus}"/>
                                        </div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${r.confidenceScore > 0}">
                                                <c:set var="confidenceClass" value="fw-bold"/>
                                                <c:if test="${r.riskLevel == 'HIGH'}">
                                                    <c:set var="confidenceClass" value="fw-bold text-danger"/>
                                                </c:if>
                                                <c:if test="${r.riskLevel == 'MEDIUM'}">
                                                    <c:set var="confidenceClass" value="fw-bold text-warning"/>
                                                </c:if>
                                                <c:if test="${r.riskLevel == 'LOW'}">
                                                    <c:set var="confidenceClass" value="fw-bold text-success"/>
                                                </c:if>
                                                <span class="${confidenceClass}">
                                                    <c:choose>
                                                        <c:when test="${r.confidenceScore > 0 and r.confidenceScore <= 1}">
                                                            <fmt:formatNumber value="${r.confidenceScore * 100}" type="number" maxFractionDigits="1"/>%
                                                        </c:when>
                                                        <c:otherwise>
                                                            <fmt:formatNumber value="${r.confidenceScore}" type="number" maxFractionDigits="1"/>%
                                                        </c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">—</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${r.riskLevel == 'HIGH'}">
                                                <span class="badge bg-danger px-3 py-2 text-uppercase" style="font-size: 85%;">Nguy cơ cao</span>
                                            </c:when>
                                            <c:when test="${r.riskLevel == 'MEDIUM'}">
                                                <span class="badge bg-warning text-dark px-3 py-2 text-uppercase" style="font-size: 85%;">Nguy cơ trung bình</span>
                                            </c:when>
                                            <c:when test="${r.riskLevel == 'LOW'}">
                                                <span class="badge bg-success px-3 py-2 text-uppercase" style="font-size: 85%;">Nguy cơ thấp</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-secondary px-3 py-2">ĐANG CHỜ</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty r.createdAt}">
                                                <c:set var="createdAtStr" value="${r.createdAt.toString()}" />
                                                <c:set var="dateOnly" value="${createdAtStr.substring(0, 10)}" />
                                                <c:set var="timeOnly" value="${createdAtStr.substring(11, 16)}" />
                                                <c:set var="year" value="${dateOnly.substring(0, 4)}" />
                                                <c:set var="month" value="${dateOnly.substring(5, 7)}" />
                                                <c:set var="day" value="${dateOnly.substring(8, 10)}" />
                                                <small class="text-muted">${day}/${month}/${year} ${timeOnly}</small>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">—</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-center">
                                        <div class="btn-group" role="group">
                                            <a href="${pageContext.request.contextPath}/patient/reports/view?id=${r.id}"
                                               class="btn btn-sm btn-outline-primary" title="Xem chi tiết">
                                                <i class="fas fa-eye"></i>
                                            </a>
                                            <a href="${pageContext.request.contextPath}/patient/booking?reportId=${r.id}"
                                               class="btn btn-sm btn-outline-success" title="Đặt lịch hẹn">
                                                <i class="fas fa-calendar-plus"></i>
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>

        <c:if test="${totalPages > 1}">
            <div class="mt-4">
                <nav aria-label="Phân trang kết quả sàng lọc">
                    <ul class="pagination justify-content-center mb-0">
                        <c:choose>
                            <c:when test="${currentPage == 1}">
                                <li class="page-item disabled"><span class="page-link">Trước</span></li>
                            </c:when>
                            <c:otherwise>
                                <li class="page-item"><a class="page-link" href="?page=${currentPage - 1}">Trước</a></li>
                            </c:otherwise>
                        </c:choose>
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <c:choose>
                                <c:when test="${i == currentPage}">
                                    <li class="page-item active"><span class="page-link">${i}</span></li>
                                </c:when>
                                <c:otherwise>
                                    <li class="page-item"><a class="page-link" href="?page=${i}">${i}</a></li>
                                </c:otherwise>
                            </c:choose>
                        </c:forEach>
                        <c:choose>
                            <c:when test="${currentPage == totalPages}">
                                <li class="page-item disabled"><span class="page-link">Sau</span></li>
                            </c:when>
                            <c:otherwise>
                                <li class="page-item"><a class="page-link" href="?page=${currentPage + 1}">Sau</a></li>
                            </c:otherwise>
                        </c:choose>
                    </ul>
                </nav>
                <div class="text-center text-muted mt-2">
                    <small>Trang ${currentPage} / ${totalPages}</small>
                </div>
            </div>
        </c:if>
    </div>
</div>

<style>
.page-title {
    color: #0f766e;
    font-weight: 700;
}
.uuid-text {
    font-size: 0.85rem;
}
.table-container {
    min-height: 400px;
}
</style>

<jsp:include page="/WEB-INF/views/layout/global-footer.jsp" />
