<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/global-header.jsp" />

<div class="container-fluid">
    <div class="table-container bg-white shadow-sm rounded-4 p-4">
        <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
            <h1 class="page-title mb-0">
                <i class="fa-regular fa-calendar-check me-2"></i>Lịch Hẹn
            </h1>
            <a href="${pageContext.request.contextPath}/patient/booking" class="btn btn-primary">
                <i class="fas fa-plus me-2"></i>Đặt Lịch Hẹn Mới
            </a>
        </div>

        <c:if test="${param.success == 'true'}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle me-2"></i>Đã cập nhật lịch hẹn.
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${param.booked == '1'}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle me-2"></i>Đặt lịch thành công.
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${param.success == 'false'}">
            <div class="alert alert-warning alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-triangle me-2"></i>Không thể hủy lịch này (đã diễn ra hoặc không còn hủy được).
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${param.pay == 'success'}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle me-2"></i>Thanh toán thành công.
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${param.pay == 'failed' or param.pay == 'invalid'}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-circle me-2"></i>Thanh toán không thành công. Vui lòng thử lại.
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${param.pay == 'error' or param.pay == 'denied' or param.pay == 'missing'}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-circle me-2"></i>Không thể xử lý thanh toán. Vui lòng thử lại.
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <div class="table-responsive">
            <table class="table table-hover table-striped align-middle">
                <thead class="table-dark">
                    <tr>
                        <th scope="col" style="width: 8%">Mã ID</th>
                        <th scope="col" style="width: 14%">Phòng khám</th>
                        <th scope="col" style="width: 12%">Bác sĩ</th>
                        <th scope="col" style="width: 12%">Ngày &amp; Giờ</th>
                        <th scope="col" style="width: 14%">Hóa đơn</th>
                        <th scope="col" style="width: 12%">Trạng thái</th>
                        <th scope="col" style="width: 11%">Mục đích</th>
                        <th scope="col" style="width: 9%">Ghi chú</th>
                        <th scope="col" style="width: 8%" class="text-center">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty appointments}">
                            <tr>
                                <td colspan="9" class="text-center py-5 text-muted">
                                    <i class="fa-regular fa-calendar fa-3x mb-3 text-light"></i>
                                    <h5>Không tìm thấy lịch hẹn</h5>
                                    <p>Bạn chưa đặt lịch hẹn nào.</p>
                                    <a href="${pageContext.request.contextPath}/patient/booking" class="btn btn-primary mt-2">
                                        <i class="fas fa-plus me-2"></i>Đặt Lịch Hẹn Đầu Tiên
                                    </a>
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="a" items="${appointments}">
                                <c:set var="invoice" value="${invoicesByAppointment[a.id]}"/>
                                <c:set var="payment" value="${paymentsByAppointment[a.id]}"/>
                                <c:set var="medical" value="${medicalByAppointment[a.id]}"/>
                                <tr>
                                    <td>
                                        <span class="uuid-text text-secondary font-monospace" title="${a.id}">
                                            #${a.id.substring(0, 8)}
                                        </span>
                                    </td>
                                    <td>
                                        <div class="fw-bold">
                                            <c:out value="${empty a.clinicName ? '—' : a.clinicName}"/>
                                        </div>
                                    </td>
                                    <td>
                                        <div class="d-flex align-items-center gap-2">
                                            <i class="fa-regular fa-user text-primary"></i>
                                            <span class="fw-semibold">
                                                <c:out value="${empty a.doctorName ? 'Chưa xác định' : a.doctorName}"/>
                                            </span>
                                        </div>
                                    </td>
                                    <td>
                                        <div class="fw-medium">
                                            <c:choose>
                                                <c:when test="${not empty a.appointmentTime}">
                                                    ${a.appointmentTimeFormatted}
                                                </c:when>
                                                <c:otherwise>—</c:otherwise>
                                            </c:choose>
                                        </div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty invoice}">
                                                <c:choose>
                                                    <c:when test="${invoice.status == 'PAID'}">
                                                        <span class="badge bg-success px-3 py-2"><i class="fas fa-check-circle me-1"></i>Đã thanh toán</span>
                                                    </c:when>
                                                    <c:when test="${invoice.status == 'UNPAID'}">
                                                        <span class="badge bg-secondary px-3 py-2">Chưa thanh toán</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-light text-dark border px-3 py-2"><c:out value="${invoice.status}"/></span>
                                                    </c:otherwise>
                                                </c:choose>
                                                <div class="small text-muted mt-1">
                                                    <fmt:formatNumber value="${invoice.totalAmount}" type="number" pattern="#,###"/>đ
                                                </div>
                                                <c:if test="${not empty payment}">
                                                    <div class="small text-muted">
                                                        <c:out value="${payment.paymentMethod}"/> · <c:out value="${payment.status}"/>
                                                    </div>
                                                    <c:if test="${payment.status == 'PENDING' and payment.paymentMethod == 'VNPAY'}">
                                                        <div class="small text-warning">Đang chờ thanh toán VNPay</div>
                                                    </c:if>
                                                    <c:if test="${payment.status == 'EXPIRED' or payment.status == 'FAILED'}">
                                                        <div class="small text-danger">Hết hạn / thất bại — có thể thử lại</div>
                                                    </c:if>
                                                </c:if>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">—</span>
                                            </c:otherwise>
                                        </c:choose>
                                        <c:if test="${not empty medical}">
                                            <div class="small text-success mt-1">
                                                <i class="fas fa-file-medical me-1"></i>Có hồ sơ y tế
                                            </div>
                                        </c:if>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${a.status == 'COMPLETED'}">
                                                <span class="badge bg-primary px-3 py-2">Hoàn thành</span>
                                            </c:when>
                                            <c:when test="${a.status == 'CONFIRMED'}">
                                                <span class="badge bg-info text-dark px-3 py-2">Đã xác nhận</span>
                                            </c:when>
                                            <c:when test="${a.status == 'CREATED'}">
                                                <span class="badge bg-secondary px-3 py-2">Đã tạo</span>
                                            </c:when>
                                            <c:when test="${a.status == 'CANCELLED'}">
                                                <span class="badge bg-danger px-3 py-2">Đã hủy</span>
                                            </c:when>
                                            <c:when test="${a.status == 'NO_SHOW'}">
                                                <span class="badge bg-danger px-3 py-2">Không có mặt</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-light text-dark border px-3 py-2"><c:out value="${a.status}"/></span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty a.diagnosisReportId}">
                                                <div class="d-flex align-items-center">
                                                    <i class="fas fa-file-medical text-info me-2"></i>
                                                    <div>
                                                        <small class="fw-semibold">Tư vấn chẩn đoán</small>
                                                        <div class="text-muted small">Báo cáo: #${a.diagnosisReportId.substring(0, 8)}...</div>
                                                    </div>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="d-flex align-items-center">
                                                    <i class="fas fa-stethoscope text-primary me-2"></i>
                                                    <small>Tư vấn chung</small>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty a.notes}">
                                                <span class="text-truncate d-inline-block" style="max-width: 160px;" title="<c:out value='${a.notes}'/>">
                                                    <c:choose>
                                                        <c:when test="${a.notes.length() > 50}">
                                                            <c:out value="${a.notes.substring(0, 50)}"/>...
                                                        </c:when>
                                                        <c:otherwise>
                                                            <c:out value="${a.notes}"/>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted fst-italic">Không có ghi chú</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-center text-nowrap">
                                        <div class="btn-group" role="group">
                                            <c:if test="${not empty invoice}">
                                                <c:choose>
                                                    <c:when test="${invoice.status == 'UNPAID' and a.status != 'CANCELLED' and a.status != 'NO_SHOW'}">
                                                        <a class="btn btn-sm btn-primary"
                                                           href="${pageContext.request.contextPath}/patient/payment?action=create&amp;appointmentId=${a.id}"
                                                           title="Thanh toán">
                                                            <i class="fas fa-credit-card me-1"></i>Thanh toán
                                                        </a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <a class="btn btn-sm btn-outline-info"
                                                           href="${pageContext.request.contextPath}/patient/payment?action=view&amp;invoiceId=${invoice.id}"
                                                           title="Xem thông tin hóa đơn">
                                                            <i class="fas fa-circle-info me-1"></i>Thông tin
                                                        </a>
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:if>
                                            <c:if test="${a.status == 'CREATED' or a.status == 'CONFIRMED'}">
                                                <button type="button"
                                                        class="btn btn-sm btn-outline-danger ms-1"
                                                        onclick="cancelAppointment('${a.id}')"
                                                        title="Hủy lịch hẹn">
                                                    <i class="fas fa-times"></i>
                                                </button>
                                            </c:if>
                                            <c:set var="medicalDone" value="${not empty medicalByAppointment[a.id]}"/>
                                            <c:if test="${a.status == 'COMPLETED' or medicalDone}">
                                                <a href="${pageContext.request.contextPath}/patient/feedback?action=create&amp;appointmentId=${a.id}"
                                                   class="btn btn-sm btn-outline-warning ms-1"
                                                   title="Đánh giá dịch vụ">
                                                    <i class="fas fa-star"></i>
                                                </a>
                                            </c:if>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</div>

<div class="container-fluid text-end mt-3 mb-4">
    <a class="small text-muted text-decoration-none" href="${pageContext.request.contextPath}/patient/issue-report?category=APPOINTMENT">
        <i class="fa-solid fa-bug me-1 text-danger"></i>Cần hỗ trợ về lịch hẹn? Báo lỗi
    </a>
</div>

<!-- Cancel Appointment Modal -->
<div class="modal fade" id="cancelModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">
                    <i class="fas fa-exclamation-triangle text-danger me-2"></i>Hủy Lịch Hẹn
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p>Liệu bạn có muốn hủy lịch hẹn?</p>
                <p class="text-muted small">Hành động này không thể hoàn tác. Bạn sẽ cần đặt lịch hẹn mới nếu cần.</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Giữ Lịch Hẹn</button>
                <form id="cancelForm" method="post" action="${pageContext.request.contextPath}/patient/appointments" style="display: inline;">
                    <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
                    <input type="hidden" name="action" value="cancel">
                    <input type="hidden" name="appointmentId" id="cancelAppointmentId">
                    <button type="submit" class="btn btn-danger">Xác Nhận Hủy</button>
                </form>
            </div>
        </div>
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

<script>
function cancelAppointment(appointmentId) {
    document.getElementById('cancelAppointmentId').value = appointmentId;
    const modal = new bootstrap.Modal(document.getElementById('cancelModal'));
    modal.show();
}
</script>

<jsp:include page="/WEB-INF/views/layout/global-footer.jsp" />
