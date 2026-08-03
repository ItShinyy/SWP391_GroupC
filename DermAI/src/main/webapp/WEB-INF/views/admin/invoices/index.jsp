<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <jsp:include page="/WEB-INF/views/layout/admin-header.jsp" />

        <div class="container-fluid admin-page admin-page--fit">
            <div class="table-container bg-white shadow-sm rounded-4 p-4">

                <%-- Page header --%>
                    <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
                        <h1 class="page-title mb-0">
                            Lịch sử Hóa đơn
                        </h1>
                        <span class="badge bg-light text-dark border fs-6 px-3 py-2">${total} hóa đơn</span>
                    </div>

                    <%-- Toolbar / Filter form --%>
                        <div class="card admin-filters shadow-sm mb-4 border-0 rounded-4 bg-light">
                            <div class="card-body">
                                <form method="get" action="${pageContext.request.contextPath}/admin/invoices"
                                    class="row g-3 align-items-center" role="search" aria-label="Bộ lọc hóa đơn">
                                    <input type="hidden" name="page" value="1">
                                    <input type="hidden" name="size" value="${pageSize}">

                                    <div class="col-md-3">
                                        <select name="status" id="filter-status" class="form-select"
                                            aria-label="Lọc theo trạng thái">
                                            <option value="">Tất cả trạng thái</option>
                                            <option value="UNPAID" <c:if test="${status == 'UNPAID'}">selected</c:if>
                                                >Chưa thanh toán</option>
                                            <option value="PAID" <c:if test="${status == 'PAID'}">selected</c:if>>Đã
                                                thanh toán</option>
                                            <option value="CANCELLED" <c:if test="${status == 'CANCELLED'}">selected
                                                </c:if>>Đã hủy</option>
                                        </select>
                                    </div>

                                    <div class="col-md-4 d-flex align-items-center gap-2">
                                        <input type="date" name="startDate" id="filter-start-date" class="form-control"
                                            value="${startDate != null ? startDate : ''}" title="Từ ngày"
                                            aria-label="Từ ngày">
                                        <span class="text-muted"><i class="fa-solid fa-arrow-right"></i></span>
                                        <input type="date" name="endDate" id="filter-end-date" class="form-control"
                                            value="${endDate != null ? endDate : ''}" title="Đến ngày"
                                            aria-label="Đến ngày">
                                    </div>

                                    <div class="col-md-3">
                                        <input type="text" name="search" id="filter-search" class="form-control"
                                            placeholder="Tìm mã HĐ, bệnh nhân…" value="${search != null ? search : ''}"
                                            aria-label="Tìm kiếm hóa đơn">
                                    </div>

                                    <div class="col-md-2 d-flex gap-2">
                                        <button type="submit" class="btn btn-primary w-100">
                                            <i class="fa-solid fa-magnifying-glass me-1"></i> Tìm
                                        </button>
                                        <a href="${pageContext.request.contextPath}/admin/invoices"
                                            class="btn btn-outline-secondary w-100" title="Xóa bộ lọc"
                                            aria-label="Xóa bộ lọc">
                                            <i class="fa-solid fa-eraser me-1"></i> Xóa
                                        </a>
                                    </div>
                                </form>
                            </div>
                        </div>

                        <c:choose>
                            <%-- Empty State --%>
                                <c:when test="${empty rows}">
                                    <div class="text-center py-5 text-muted">
                                        <i class="fa-solid fa-file-invoice-dollar fa-3x mb-3 text-light"></i>
                                        <h5 class="fw-semibold">Không tìm thấy hóa đơn phù hợp</h5>
                                        <p>Thử thay đổi bộ lọc hoặc <a
                                                href="${pageContext.request.contextPath}/admin/invoices">xem tất cả</a>.
                                        </p>
                                    </div>
                                </c:when>

                                <%-- Data Table --%>
                                    <c:otherwise>
                                        <div class="table-responsive">
                                            <table class="table table-hover table-striped align-middle"
                                                aria-label="Danh sách hóa đơn">
                                                <thead class="table-dark">
                                                    <tr>
                                                        <th scope="col">Mã HĐ</th>
                                                        <th scope="col">Bệnh nhân</th>
                                                        <th scope="col">Ngày hẹn</th>
                                                        <th scope="col">Ngày lập</th>
                                                        <th scope="col" class="text-end">Số tiền</th>
                                                        <th scope="col">Trạng thái</th>
                                                        <th scope="col" class="text-center">Thao tác</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach var="row" items="${rows}">
                                                        <tr>
                                                            <td class="font-monospace small text-muted">${row.idShort}
                                                            </td>
                                                            <td class="fw-semibold text-dark">${row.patientName}</td>
                                                            <td class="small">${row.appointmentTime}</td>
                                                            <td class="small">${row.createdAt}</td>
                                                            <td class="text-end fw-semibold text-nowrap">
                                                                ${row.totalAmount}</td>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${row.status == 'PAID'}">
                                                                        <span class="badge bg-success">Đã thanh
                                                                            toán</span>
                                                                    </c:when>
                                                                    <c:when test="${row.status == 'UNPAID'}">
                                                                        <span class="badge bg-warning text-dark">Chưa
                                                                            thanh toán</span>
                                                                    </c:when>
                                                                    <c:when test="${row.status == 'CANCELLED'}">
                                                                        <span class="badge bg-secondary">Đã hủy</span>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span
                                                                            class="badge bg-light text-dark border">${row.status}</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            <td class="text-center">
                                                                <a href="${pageContext.request.contextPath}/admin/invoices/detail?appointmentId=${row.appointmentId}"
                                                                    class="btn btn-sm btn-light border"
                                                                    aria-label="Xem hóa đơn" title="Xem hóa đơn">
                                                                    <i class="fa-solid fa-eye text-primary"></i>
                                                                </a>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </tbody>
                                            </table>
                                        </div>

                                        <%-- Reuse existing _pagination.jsp --%>
                                            <jsp:include page="/WEB-INF/views/admin/common/_pagination.jsp" />

                                    </c:otherwise>
                        </c:choose>

            </div>
        </div>

        <jsp:include page="/WEB-INF/views/layout/admin-footer.jsp" />