<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/admin-header.jsp" />

<div class="container-fluid admin-page admin-page--fit">
    <div class="table-container bg-white shadow-sm rounded-4 p-4">
        
        <div class="d-flex flex-wrap justify-content-between align-items-center gap-3 mb-4">
            <h1 class="page-title mb-0">
                <i class="fa-regular fa-bell text-primary me-2"></i>Thông báo
            </h1>
            <form method="post" action="${pageContext.request.contextPath}/admin/notifications">
                <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
                <input type="hidden" name="action" value="mark-all-read">
                <button type="submit" class="btn btn-light border shadow-sm">
                    <i class="fa-solid fa-check-double me-1"></i>Đánh dấu đã đọc tất cả
                </button>
            </form>
        </div>

        <div class="card border-0 shadow-sm rounded-3 overflow-hidden">
            <div class="card-body p-0">
                <c:choose>
                    <c:when test="${empty notifications}">
                        <div class="text-center py-5 text-muted">
                            <i class="fa-regular fa-bell-slash fa-3x mb-3 text-light"></i>
                            <h5 class="fw-semibold">Chưa có thông báo nào.</h5>
                            <p>Bạn đã xem tất cả các thông báo.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="notification" items="${notifications}">
                            <div class="p-4 border-bottom ${notification.read ? 'bg-white' : 'bg-primary bg-opacity-10'}">
                                <div class="d-flex gap-3 align-items-start">
                                    <div class="pt-1">
                                        <c:choose>
                                            <c:when test="${notification.type == 'PAYMENT'}">
                                                <i class="fa-solid fa-coins text-success"></i>
                                            </c:when>
                                            <c:when test="${notification.type == 'APPOINTMENT'}">
                                                <i class="fa-regular fa-calendar-check text-primary"></i>
                                            </c:when>
                                            <c:otherwise>
                                                <i class="fa-solid fa-circle-info text-primary"></i>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="flex-grow-1">
                                        <div class="d-flex justify-content-between gap-3">
                                            <h6 class="fw-bold mb-1"><c:out value="${notification.title}" /></h6>
                                            <small class="text-muted text-nowrap">${notification.createdAt.toString().replace('T', ' ')}</small>
                                        </div>
                                        <p class="mb-2 text-muted" style="white-space: pre-line;">
                                            <c:out value="${notification.message}" />
                                        </p>
                                        <div class="d-flex gap-2 align-items-center">
                                            <c:if test="${not empty notification.targetUrl}">
                                                <a class="btn btn-sm btn-primary" href="${pageContext.request.contextPath}${notification.targetUrl}">
                                                    Xem chi tiết
                                                </a>
                                            </c:if>
                                            <c:if test="${not notification.read}">
                                                <form method="post" action="${pageContext.request.contextPath}/admin/notifications">
                                                    <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
                                                    <input type="hidden" name="action" value="mark-read">
                                                    <input type="hidden" name="notificationId" value="${notification.id}">
                                                    <button type="submit" class="btn btn-sm btn-light border">Đã đọc</button>
                                                </form>
                                            </c:if>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

    </div>
</div>

<jsp:include page="/WEB-INF/views/layout/admin-footer.jsp"/>