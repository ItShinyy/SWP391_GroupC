<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/guest-header.jsp" />

<div class="container py-5">
    <div class="d-flex flex-wrap justify-content-between align-items-center gap-3 mb-4">
        <div>
            <h2 class="fw-bold mb-1"><i class="fa-regular fa-bell text-success me-2"></i>Thông báo</h2>
            <p class="text-muted mb-0">Cập nhật về lịch khám và hóa đơn của bạn.</p>
        </div>
        <form method="post" action="${pageContext.request.contextPath}/patient/notifications">
            <input type="hidden" name="action" value="mark-all-read">
            <button type="submit" class="btn btn-outline-secondary">
                <i class="fa-solid fa-check-double me-1"></i>Đánh dấu đã đọc tất cả
            </button>
        </form>
    </div>

    <c:choose>
        <c:when test="${empty notifications}">
            <div class="card border-0 shadow-sm rounded-4">
                <div class="card-body text-center py-5 text-muted">
                    <i class="fa-regular fa-bell-slash fa-3x mb-3"></i>
                    <p class="mb-0">Bạn chưa có thông báo nào.</p>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
                <c:forEach var="notification" items="${notifications}">
                    <div class="p-4 border-bottom ${notification.read ? 'bg-white' : 'bg-success bg-opacity-10'}">
                        <div class="d-flex gap-3 align-items-start">
                            <div class="text-success pt-1"><i class="fa-solid fa-circle-info"></i></div>
                            <div class="flex-grow-1">
                                <div class="d-flex justify-content-between gap-3">
                                    <h6 class="fw-bold mb-1"><c:out value="${notification.title}" /></h6>
                                    <small class="text-muted text-nowrap">${notification.createdAt.toString().replace('T', ' ')}</small>
                                </div>
                                <p class="mb-2 text-muted" style="white-space: pre-line;"><c:out value="${notification.message}" /></p>
                                <div class="d-flex gap-2 align-items-center">
                                    <c:if test="${not empty notification.targetUrl}">
                                        <a class="btn btn-sm btn-success" href="${pageContext.request.contextPath}${notification.targetUrl}">
                                            Xem chi tiết
                                        </a>
                                    </c:if>
                                    <c:if test="${not notification.read}">
                                        <form method="post" action="${pageContext.request.contextPath}/patient/notifications">
                                            <input type="hidden" name="action" value="mark-read">
                                            <input type="hidden" name="notificationId" value="${notification.id}">
                                            <button type="submit" class="btn btn-sm btn-outline-secondary">Đã đọc</button>
                                        </form>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="/WEB-INF/views/layout/guest-footer.jsp" />
