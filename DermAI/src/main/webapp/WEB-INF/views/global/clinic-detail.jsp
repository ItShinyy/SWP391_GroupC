<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:url var="mapUrl" value="/global/clinics/map">
    <c:param name="id" value="${clinic.id}" />
</c:url>
<jsp:include page="/WEB-INF/views/layout/global-header.jsp" />

<div class="bg-light py-5">
    <div class="container mt-4" style="max-width: 880px;">
        <a href="${pageContext.request.contextPath}/global/clinics" class="text-decoration-none small text-muted">
            <i class="fa-solid fa-arrow-left me-2"></i>Quay lại danh sách phòng khám
        </a>

        <article class="card border-0 shadow-sm rounded-4 mt-3 overflow-hidden">
            <div class="card-body p-4 p-md-5">
                <div class="d-flex flex-column flex-md-row justify-content-between gap-3 mb-4">
                    <div>
                        <span class="text-primary small fw-semibold text-uppercase">Phòng khám da liễu</span>
                        <h1 class="h2 fw-bold text-dark mt-1 mb-2"><c:out value="${clinic.clinicName}" /></h1>
                        <c:if test="${not empty clinic.specialty}">
                            <span class="badge bg-primary bg-opacity-10 text-primary px-3 py-2 rounded-pill"><c:out value="${clinic.specialty}" /></span>
                        </c:if>
                    </div>
                    <c:if test="${clinic.rating > 0}">
                        <div class="text-md-end">
                            <span class="badge bg-success bg-opacity-10 text-success rounded-pill px-3 py-2 fs-6">
                                <i class="fa-solid fa-star text-warning me-1"></i> <c:out value="${clinic.rating}" /> / 5
                            </span>
                        </div>
                    </c:if>
                </div>

                <dl class="row gy-4 mb-4">
                    <dt class="col-sm-3 text-muted fw-medium"><i class="fa-solid fa-location-dot text-primary me-2"></i>Địa chỉ</dt>
                    <dd class="col-sm-9 mb-0"><c:out value="${clinic.address}" /></dd>

                    <c:if test="${not empty clinic.phone}">
                        <dt class="col-sm-3 text-muted fw-medium"><i class="fa-solid fa-phone text-primary me-2"></i>Điện thoại</dt>
                        <dd class="col-sm-9 mb-0"><a class="text-decoration-none" href="tel:${clinic.phone}"><c:out value="${clinic.phone}" /></a></dd>
                    </c:if>

                    <c:if test="${not empty clinic.website and (fn:startsWith(clinic.website, 'https://') or fn:startsWith(clinic.website, 'http://'))}">
                        <dt class="col-sm-3 text-muted fw-medium"><i class="fa-solid fa-globe text-primary me-2"></i>Website</dt>
                        <dd class="col-sm-9 mb-0"><a class="text-decoration-none" href="<c:out value='${clinic.website}'/>" target="_blank" rel="noopener noreferrer">Truy cập website <i class="fa-solid fa-arrow-up-right-from-square ms-1 small"></i></a></dd>
                    </c:if>
                </dl>

                <a href="${mapUrl}" class="btn btn-primary rounded-pill px-4">
                    <i class="fa-solid fa-map-location-dot me-2"></i>Xem vị trí trên bản đồ
                </a>
            </div>
        </article>
    </div>
</div>

<jsp:include page="/WEB-INF/views/layout/global-footer.jsp" />
