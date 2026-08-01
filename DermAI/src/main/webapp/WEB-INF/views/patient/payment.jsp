<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/global-header.jsp" />

<main class="container py-5 mt-4">
    <div class="row justify-content-center">
        <div class="col-lg-8">
            <div class="card border-0 shadow-sm rounded-4">
                <div class="card-body p-4 p-md-5">
                    <div class="text-center mb-4">
                        <h1 class="h3 fw-bold mb-1">Thanh toán hóa đơn</h1>
                        <p class="text-muted mb-0">Hoàn tất thanh toán để giữ lịch hẹn</p>
                        <c:if test="${not empty invoice}">
                            <div class="alert alert-info d-inline-block px-4 py-3 mt-3 mb-0">
                                <div class="small text-muted fw-bold">TỔNG TIỀN</div>
                                <div class="fs-3 fw-bold text-success">
                                    <fmt:formatNumber value="${invoice.totalAmount}" type="number" pattern="#,###"/>đ
                                </div>
                            </div>
                        </c:if>
                    </div>

                    <c:if test="${not empty errorMessage}">
                        <div class="alert alert-danger"><c:out value="${errorMessage}"/></div>
                    </c:if>

                    <c:if test="${not empty invoice}">
                        <div class="border rounded-3 p-3 mb-4">
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <div class="small text-muted">Mã hóa đơn</div>
                                    <div class="fw-semibold font-monospace">#${invoice.id.substring(0, 8)}…</div>
                                    <div class="small text-muted mt-2">Mô tả</div>
                                    <div><c:out value="${invoice.description}"/></div>
                                    <c:if test="${not empty appointment && not empty appointment.appointmentTime}">
                                        <div class="small text-muted mt-2">Thời gian hẹn</div>
                                        <div>${appointment.appointmentTimeFormatted}</div>
                                    </c:if>
                                </div>
                                <div class="col-md-6">
                                    <div class="small text-muted">Trạng thái</div>
                                    <c:choose>
                                        <c:when test="${invoice.status == 'PAID'}">
                                            <span class="badge text-bg-success">Đã thanh toán</span>
                                        </c:when>
                                        <c:when test="${invoice.status == 'UNPAID'}">
                                            <span class="badge text-bg-warning">Chưa thanh toán</span>
                                        </c:when>
                                        <c:when test="${invoice.status == 'CANCELLED'}">
                                            <span class="badge text-bg-secondary">Đã hủy</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge text-bg-light border"><c:out value="${invoice.status}"/></span>
                                        </c:otherwise>
                                    </c:choose>
                                    <c:if test="${not empty payment}">
                                        <div class="small text-muted mt-2">Thanh toán gần nhất</div>
                                        <div class="small"><c:out value="${payment.paymentMethod}"/> · <c:out value="${payment.status}"/></div>
                                    </c:if>
                                </div>
                            </div>
                        </div>

                        <c:if test="${invoice.status == 'UNPAID' && paymentRequired}">
                            <div class="alert alert-warning">
                                Vui lòng chọn phương thức thanh toán để tiếp tục.
                                Giao dịch VNPay hết hạn sau <strong>${paymentExpireMinutes}</strong> phút.
                            </div>
                        </c:if>
                        <div class="alert alert-light border small">
                            Nếu đã thanh toán online thành công, hủy lịch sẽ không được hoàn tiền.
                        </div>

                        <c:if test="${invoice.status == 'UNPAID' && !paymentViewOnly}">
                            <div class="d-grid gap-2 col-md-8 mx-auto">
                                <c:choose>
                                    <c:when test="${paymentApiAvailable}">
                                        <form method="post" action="${paymentApiBaseUrl}/api/invoices/${invoice.id}/payments/vnpay">
                                            <input type="hidden" name="locale" value="vn">
                                            <button type="submit" class="btn btn-success btn-lg w-100">
                                                Thanh toán VNPay
                                                <span class="d-block small fw-normal">
                                                    <fmt:formatNumber value="${invoice.totalAmount}" type="number" pattern="#,###"/>đ
                                                </span>
                                            </button>
                                        </form>
                                        <p class="text-muted small text-center mb-0">Chuyển qua Payment API đến VNPay Sandbox</p>
                                    </c:when>
                                    <c:otherwise>
                                        <button type="button" class="btn btn-secondary btn-lg w-100" disabled>
                                            Payment API chưa được cấu hình
                                        </button>
                                        <p class="text-danger small text-center mb-0">
                                            Khởi động payment-service trên cổng 3000 rồi thử lại.
                                        </p>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </c:if>

                        <c:if test="${invoice.status == 'PAID'}">
                            <div class="alert alert-success text-center mb-0">
                                Thanh toán hoàn tất. Hóa đơn đã được ghi nhận.
                            </div>
                        </c:if>

                        <div class="text-center mt-4">
                            <c:if test="${!paymentRequired || invoice.status != 'UNPAID'}">
                                <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/patient/appointments">
                                    Về danh sách lịch hẹn
                                </a>
                            </c:if>
                            <c:if test="${paymentRequired && invoice.status == 'UNPAID'}">
                                <a class="btn btn-link" href="${pageContext.request.contextPath}/patient/appointments">
                                    Thanh toán sau (từ danh sách lịch hẹn)
                                </a>
                            </c:if>
                        </div>
                    </c:if>

                    <c:if test="${empty invoice}">
                        <div class="text-center py-4">
                            <p class="text-muted">Không tìm thấy hóa đơn.</p>
                            <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/patient/appointments">
                                Về danh sách lịch hẹn
                            </a>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/views/layout/global-footer.jsp" />
