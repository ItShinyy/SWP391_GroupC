<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/admin-header.jsp" />

<div class="container-fluid pt-4 px-4">
    <div class="d-flex align-items-center gap-3 mb-4">
        <a href="${pageContext.request.contextPath}/admin/invoices" class="btn btn-light border" aria-label="Quay lại">
            <i class="fa-solid fa-arrow-left"></i>
        </a>
        <h1 class="page-title mb-0">Chi tiết Hóa đơn</h1>
    </div>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger">
            <i class="fa-solid fa-triangle-exclamation me-2"></i>${errorMessage}
        </div>
    </c:if>

    <c:if test="${not empty invoice}">
        <div class="row g-4">
            <%-- Invoice summary --%>
            <div class="col-12 col-lg-6">
                <div class="card border-0 shadow-sm rounded-3 h-100">
                    <div class="card-header bg-transparent border-bottom fw-semibold py-3">
                        <i class="fa-solid fa-file-invoice-dollar text-primary me-2"></i>Thông tin Hóa đơn
                    </div>
                    <div class="card-body">
                        <dl class="row mb-0">
                            <dt class="col-5 text-muted">Mã hóa đơn</dt>
                            <dd class="col-7 font-monospace small">${invoice.id}</dd>

                            <dt class="col-5 text-muted">Mã lịch hẹn</dt>
                            <dd class="col-7 font-monospace small">${invoice.appointmentId}</dd>

                            <dt class="col-5 text-muted">Mô tả</dt>
                            <dd class="col-7"><c:out value="${invoice.description}" default="—"/></dd>

                            <dt class="col-5 text-muted">Số tiền</dt>
                            <dd class="col-7 fw-bold">${invoice.totalAmount} ₫</dd>

                            <dt class="col-5 text-muted">Trạng thái</dt>
                            <dd class="col-7">
                                <c:choose>
                                    <c:when test="${invoice.status == 'PAID'}">
                                        <span class="badge bg-success">Đã thanh toán</span>
                                    </c:when>
                                    <c:when test="${invoice.status == 'UNPAID'}">
                                        <span class="badge bg-warning text-dark">Chưa thanh toán</span>
                                    </c:when>
                                    <c:when test="${invoice.status == 'CANCELLED'}">
                                        <span class="badge bg-secondary">Đã hủy</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-light text-dark border">${invoice.status}</span>
                                    </c:otherwise>
                                </c:choose>
                            </dd>

                            <dt class="col-5 text-muted">Ngày lập</dt>
                            <dd class="col-7">${invoice.createdAt}</dd>

                            <c:if test="${not empty invoice.paidAt}">
                                <dt class="col-5 text-muted">Ngày thanh toán</dt>
                                <dd class="col-7">${invoice.paidAt}</dd>
                            </c:if>
                        </dl>
                    </div>
                </div>
            </div>

            <%-- Latest payment --%>
            <div class="col-12 col-lg-6">
                <div class="card border-0 shadow-sm rounded-3 h-100">
                    <div class="card-header bg-transparent border-bottom fw-semibold py-3">
                        <i class="fa-solid fa-credit-card text-success me-2"></i>Giao dịch gần nhất
                    </div>
                    <div class="card-body">
                        <c:choose>
                            <c:when test="${empty latestPayment}">
                                <p class="text-muted text-center py-3 mb-0">Chưa có giao dịch nào.</p>
                            </c:when>
                            <c:otherwise>
                                <dl class="row mb-0">
                                    <dt class="col-5 text-muted">Mã giao dịch</dt>
                                    <dd class="col-7 font-monospace small">${latestPayment.txnRef}</dd>

                                    <dt class="col-5 text-muted">Phương thức</dt>
                                    <dd class="col-7">${latestPayment.paymentMethod}</dd>

                                    <dt class="col-5 text-muted">Số tiền</dt>
                                    <dd class="col-7 fw-bold">${latestPayment.amount} ₫</dd>

                                    <dt class="col-5 text-muted">Trạng thái</dt>
                                    <dd class="col-7">
                                        <c:choose>
                                            <c:when test="${latestPayment.status == 'SUCCESS'}">
                                                <span class="badge bg-success">Thành công</span>
                                            </c:when>
                                            <c:when test="${latestPayment.status == 'PENDING'}">
                                                <span class="badge bg-warning text-dark">Đang xử lý</span>
                                            </c:when>
                                            <c:when test="${latestPayment.status == 'FAILED'}">
                                                <span class="badge bg-danger">Thất bại</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-secondary">${latestPayment.status}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </dd>

                                    <dt class="col-5 text-muted">Ngày tạo</dt>
                                    <dd class="col-7">${latestPayment.createdAt}</dd>

                                    <c:if test="${not empty latestPayment.processedAt}">
                                        <dt class="col-5 text-muted">Ngày xử lý</dt>
                                        <dd class="col-7">${latestPayment.processedAt}</dd>
                                    </c:if>

                                    <c:if test="${not empty latestPayment.vnpTransactionNo}">
                                        <dt class="col-5 text-muted">VNPay Ref</dt>
                                        <dd class="col-7 font-monospace small">${latestPayment.vnpTransactionNo}</dd>
                                    </c:if>
                                </dl>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>
    </c:if>
</div>

<jsp:include page="/WEB-INF/views/layout/admin-footer.jsp"/>