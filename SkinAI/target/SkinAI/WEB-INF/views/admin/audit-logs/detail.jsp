<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/layout/admin-header.jsp" />

<div class="container-fluid pt-3 pb-5">
    
    <!-- HEADER -->
    <div class="mb-4">
        <a href="${pageContext.request.contextPath}/admin/audit-logs?page=${param.page}&keyword=${param.keyword}&status=${param.status}&startDate=${param.startDate}&endDate=${param.endDate}" class="text-decoration-none text-muted mb-2 d-inline-block fw-semibold small">
            <i class="fa-solid fa-arrow-left me-1"></i> Quay lại
        </a>
        <h3 class="page-title mb-1 fw-bold">Chi tiết Sự kiện</h3>
        <div class="text-muted small d-flex align-items-center flex-wrap gap-2">
            <span>Mã sự kiện (Audit ID): <span class="font-monospace">${log.id}</span></span>
        </div>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-danger shadow-sm rounded-3">
            <i class="fa-solid fa-triangle-exclamation me-2"></i> ${error}
        </div>
    </c:if>

    <c:if test="${not empty log}">
        
        <!-- CARD 1: EVENT INFORMATION -->
        <div class="card shadow-sm border-0 rounded-4 mb-4">
            <div class="card-header bg-white border-bottom-0 pt-4 pb-0">
                <h6 class="fw-bold text-dark"><i class="fa-solid fa-bolt text-warning me-2"></i> Thông tin sự kiện</h6>
            </div>
            <div class="card-body p-4">
                <div class="row g-4">
                    <div class="col-md-3">
                        <div class="text-muted small fw-bold text-uppercase mb-1">Hành động</div>
                        <c:set var="actionColor" value="bg-secondary" />
                        <c:if test="${fn:contains(log.action, 'LOGIN_SUCCESS')}"><c:set var="actionColor" value="bg-success" /></c:if>
                        <c:if test="${fn:contains(log.action, 'LOGIN_FAILED') || fn:contains(log.action, 'LOGIN_LOCKED')}"><c:set var="actionColor" value="bg-danger" /></c:if>
                        <c:if test="${fn:contains(log.action, 'CREATE')}"><c:set var="actionColor" value="bg-primary" /></c:if>
                        <c:if test="${fn:contains(log.action, 'UPDATE')}"><c:set var="actionColor" value="bg-warning text-dark" /></c:if>
                        <c:if test="${fn:contains(log.action, 'DELETE')}"><c:set var="actionColor" value="bg-danger" /></c:if>
                        
                        <span class="badge ${actionColor} px-2 py-1 fs-6 shadow-sm">
                            ${log.action}
                        </span>
                    </div>
                    <div class="col-md-3">
                        <div class="text-muted small fw-bold text-uppercase mb-1">Trạng thái</div>
                        <c:choose>
                            <c:when test="${log.status == 'SUCCESS'}"><span class="badge bg-success bg-opacity-10 text-success border border-success px-2 py-1 fs-6">Thành công</span></c:when>
                            <c:otherwise><span class="badge bg-danger bg-opacity-10 text-danger border border-danger px-2 py-1 fs-6">Thất bại</span></c:otherwise>
                        </c:choose>
                    </div>
                    <div class="col-md-3">
                        <div class="text-muted small fw-bold text-uppercase mb-1">Thời gian</div>
                        <div class="fw-bold text-dark">
                            <fmt:parseDate value="${log.createdAt}" pattern="yyyy-MM-dd'T'HH:mm:ss" var="parsedDateTime" type="both" />
                            <fmt:formatDate pattern="dd/MM/yyyy HH:mm:ss" value="${parsedDateTime}" />
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="text-muted small fw-bold text-uppercase mb-1">Mô tả</div>
                        <div class="text-dark small">
                            ${not empty log.errorMessage ? log.errorMessage : 'Không có mô tả chi tiết'}
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
                    <div class="col-md-3">
                        <div class="text-muted small fw-bold text-uppercase mb-1">Người thực hiện</div>
                        <div class="fw-bold text-primary text-break">
                            ${not empty log.userName ? log.userName : 'Hệ thống / Khách'}
                            <c:if test="${not empty log.userEmail}">
                                <div class="text-muted fw-normal small">${log.userEmail}</div>
                            </c:if>
                            <c:if test="${not empty log.userPhone}">
                                <div class="text-muted fw-normal small"><i class="fa-solid fa-phone ms-1 me-1"></i>${log.userPhone}</div>
                            </c:if>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="text-muted small fw-bold text-uppercase mb-1">Vai trò</div>
                        <span class="badge bg-secondary bg-opacity-10 text-secondary border px-2 py-1 fs-6">
                            ${not empty log.userRole ? log.userRole : 'N/A'}
                        </span>
                    </div>
                    <div class="col-md-3">
                        <div class="text-muted small fw-bold text-uppercase mb-1">Loại đối tượng</div>
                        <span class="badge bg-info bg-opacity-10 text-info border px-2 py-1 fs-6 text-uppercase">
                            ${log.entityType}
                        </span>
                    </div>
                    <div class="col-md-3">
                        <div class="text-muted small fw-bold text-uppercase mb-1">ID Đối tượng</div>
                        <div class="d-flex align-items-center gap-2">
                            <c:if test="${not empty log.recordId}">
                                <span class="font-monospace small text-muted bg-light px-2 py-1 rounded border">ID: ${log.recordId}</span>
                            </c:if>
                            <c:if test="${empty log.recordId}">
                                <span class="text-muted small">N/A</span>
                            </c:if>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- CARD 3: TECHNICAL INFORMATION -->
        <div class="card shadow-sm border-0 rounded-4 mb-4">
            <div class="card-header bg-white border-bottom-0 pt-4 pb-0">
                <h6 class="fw-bold text-dark"><i class="fa-solid fa-network-wired text-info me-2"></i> Thông tin kỹ thuật</h6>
            </div>
            <div class="card-body p-4">
                <div class="row g-4">
                    <div class="col-md-3">
                        <div class="text-muted small fw-bold text-uppercase mb-1">Địa chỉ IP</div>
                        <span class="font-monospace text-dark">${log.ipAddress}</span>
                    </div>
                    <div class="col-md-2">
                        <div class="text-muted small fw-bold text-uppercase mb-1">Phương thức HTTP</div>
                        <span class="font-monospace text-muted small">N/A</span>
                    </div>
                    <div class="col-md-3">
                        <div class="text-muted small fw-bold text-uppercase mb-1">Đường dẫn (Endpoint)</div>
                        <span class="font-monospace text-muted small">N/A</span>
                    </div>
                    
                    <%-- Tách Browser và OS từ User Agent --%>
                    <c:set var="ua" value="${fn:toLowerCase(log.userAgent)}" />
                    <c:set var="browser" value="Unknown Browser" />
                    <c:set var="os" value="Unknown OS" />
                    
                    <c:choose>
                        <c:when test="${fn:contains(ua, 'edg/')}"><c:set var="browser" value="Microsoft Edge" /></c:when>
                        <c:when test="${fn:contains(ua, 'chrome/') && !fn:contains(ua, 'edg/')}"><c:set var="browser" value="Google Chrome" /></c:when>
                        <c:when test="${fn:contains(ua, 'safari/') && !fn:contains(ua, 'chrome/')}"><c:set var="browser" value="Safari" /></c:when>
                        <c:when test="${fn:contains(ua, 'firefox/')}"><c:set var="browser" value="Mozilla Firefox" /></c:when>
                        <c:when test="${fn:contains(ua, 'postman')}"><c:set var="browser" value="Postman Runtime" /></c:when>
                    </c:choose>
                    
                    <c:choose>
                        <c:when test="${fn:contains(ua, 'windows')}"><c:set var="os" value="Windows" /></c:when>
                        <c:when test="${fn:contains(ua, 'mac os')}"><c:set var="os" value="macOS" /></c:when>
                        <c:when test="${fn:contains(ua, 'linux')}"><c:set var="os" value="Linux" /></c:when>
                        <c:when test="${fn:contains(ua, 'android')}"><c:set var="os" value="Android" /></c:when>
                        <c:when test="${fn:contains(ua, 'iphone') || fn:contains(ua, 'ipad')}"><c:set var="os" value="iOS" /></c:when>
                    </c:choose>

                    <div class="col-md-2">
                        <div class="text-muted small fw-bold text-uppercase mb-1">Trình duyệt</div>
                        <span class="text-dark small fw-semibold">${browser}</span>
                    </div>
                    <div class="col-md-2">
                        <div class="text-muted small fw-bold text-uppercase mb-1">Hệ điều hành</div>
                        <span class="text-dark small fw-semibold">${os}</span>
                    </div>

                    <div class="col-12 mt-3 pt-3 border-top">
                        <details>
                            <summary class="text-primary small fw-semibold" style="cursor: pointer;">Xem chi tiết User Agent</summary>
                            <div class="text-muted small text-break bg-light p-2 mt-2 rounded border border-light font-monospace">
                                ${log.userAgent}
                            </div>
                        </details>
                    </div>
                </div>
            </div>
        </div>

        <!-- CARD 4: CHANGE DATA / EVENT DATA -->
        <div class="card shadow-sm border-0 rounded-4">
            <div class="card-header bg-white border-bottom-0 pt-4 pb-0">
                <h6 class="fw-bold text-dark"><i class="fa-solid fa-database text-success me-2"></i> Dữ liệu tải trọng (Payload)</h6>
            </div>
            <div class="card-body p-4">

                <div class="row g-3">
                    <c:choose>
                        <%-- CHỈ HIỂN THỊ OLD / NEW NẾU LÀ UPDATE HOẶC CÓ CẢ 2 DỮ LIỆU --%>
                        <c:when test="${fn:contains(log.action, 'UPDATE') || (not empty log.oldValues && not empty log.newValues)}">
                            <div class="col-md-6 d-flex flex-column">
                                <h6 class="fw-bold text-danger small text-uppercase"><i class="fa-solid fa-minus me-1"></i> Dữ liệu cũ</h6>
                                <pre class="p-3 border border-danger border-opacity-25 rounded small flex-grow-1 mb-0" style="background-color: #fcf4f4; color: #cb2431; white-space: pre-wrap; word-break: break-all; min-height: 100px; max-height: 500px; overflow-y: auto;"><c:out value="${not empty log.oldValues ? log.oldValues : 'Không có dữ liệu'}" /></pre>
                            </div>
                            <div class="col-md-6 d-flex flex-column">
                                <h6 class="fw-bold text-success small text-uppercase"><i class="fa-solid fa-plus me-1"></i> Dữ liệu mới</h6>
                                <pre class="p-3 border border-success border-opacity-25 rounded small flex-grow-1 mb-0" style="background-color: #f1f8f6; color: #22863a; white-space: pre-wrap; word-break: break-all; min-height: 100px; max-height: 500px; overflow-y: auto;"><c:out value="${not empty log.newValues ? log.newValues : 'Không có dữ liệu'}" /></pre>
                            </div>
                        </c:when>

                        <%-- CÁC TRƯỜNG HỢP CÒN LẠI (LOGIN, CREATE, DELETE...) HIỂN THỊ 1 CỘT FULL-WIDTH --%>
                        <c:otherwise>
                            <c:set var="eventData" value="${not empty log.newValues ? log.newValues : log.oldValues}" />
                            <c:choose>
                                <c:when test="${not empty eventData}">
                                    <div class="col-12 d-flex flex-column">
                                        <h6 class="fw-bold text-dark small text-uppercase"><i class="fa-solid fa-code me-1"></i> Dữ liệu sự kiện</h6>
                                        <pre class="p-3 border border-secondary border-opacity-25 rounded small flex-grow-1 mb-0" style="background-color: #f8f9fa; color: #212529; white-space: pre-wrap; word-break: break-all; min-height: 100px; max-height: 500px; overflow-y: auto;"><c:out value="${eventData}" /></pre>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <c:if test="${empty log.errorMessage}">
                                        <div class="col-12 text-center py-4 mt-3 text-muted bg-light rounded">
                                            <i class="fa-solid fa-box-open fa-2x mb-2 text-secondary opacity-50"></i>
                                            <p class="mb-0 small">Không có dữ liệu (Payload) được ghi nhận cho sự kiện này.</p>
                                        </div>
                                    </c:if>
                                </c:otherwise>
                            </c:choose>
                        </c:otherwise>
                    </c:choose>
                </div>

            </div>
        </div>

    </c:if>
</div>

<jsp:include page="/WEB-INF/views/layout/admin-footer.jsp" />
