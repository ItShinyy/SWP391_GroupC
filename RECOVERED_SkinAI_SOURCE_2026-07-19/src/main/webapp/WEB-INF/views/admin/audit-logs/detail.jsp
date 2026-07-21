<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/admin-header.jsp" />

<div class="container-fluid">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="page-title"><i class="fa-solid fa-file-waveform me-2"></i> Chi tiết Nhật Ký</h1>
        <a href="${pageContext.request.contextPath}/admin/audit-logs" class="btn btn-outline-secondary fw-bold">
            <i class="fa-solid fa-arrow-left me-2"></i> Quay lại
        </a>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-danger shadow-sm rounded-3">
            <i class="fa-solid fa-triangle-exclamation me-2"></i> ${error}
        </div>
    </c:if>

    <c:if test="${not empty log}">
        <div class="row">
            <div class="col-lg-4 mb-4">
                <div class="card shadow-sm border-0 rounded-4 h-100">
                    <div class="card-header bg-white border-bottom-0 pt-4 pb-0">
                        <h5 class="fw-bold"><i class="fa-solid fa-circle-info me-2 text-primary"></i> Thông tin chung</h5>
                    </div>
                    <div class="card-body">
                        <ul class="list-group list-group-flush">
                            <li class="list-group-item px-0 py-3 d-flex justify-content-between align-items-center">
                                <span class="text-muted fw-bold small">Mã Log (ID)</span>
                                <span class="font-monospace small text-end text-break ms-3">${log.id}</span>
                            </li>
                            <li class="list-group-item px-0 py-3 d-flex justify-content-between align-items-center">
                                <span class="text-muted fw-bold small">Thời gian</span>
                                <span class="fw-bold text-end">
                                    <fmt:parseDate value="${log.createdAt}" pattern="yyyy-MM-dd'T'HH:mm:ss" var="parsedDateTime" type="both" />
                                    <fmt:formatDate pattern="dd/MM/yyyy HH:mm:ss" value="${parsedDateTime}" />
                                </span>
                            </li>
                            <li class="list-group-item px-0 py-3 d-flex justify-content-between align-items-center">
                                <span class="text-muted fw-bold small">Trạng thái</span>
                                <span class="text-end">
                                    <c:choose>
                                        <c:when test="${log.status == 'SUCCESS'}">
                                            <span class="badge bg-success">THÀNH CÔNG</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-danger">THẤT BẠI</span>
                                        </c:otherwise>
                                    </c:choose>
                                </span>
                            </li>
                            <li class="list-group-item px-0 py-3 d-flex justify-content-between align-items-center">
                                <span class="text-muted fw-bold small">Hành động</span>
                                <span class="badge bg-secondary bg-opacity-10 text-secondary border border-secondary border-opacity-25 px-2 py-1 text-end">${log.action}</span>
                            </li>
                            <li class="list-group-item px-0 py-3 d-flex flex-column">
                                <span class="text-muted fw-bold small mb-1">Người thực hiện</span>
                                <span class="fw-bold text-primary">${log.userName}</span>
                                <c:if test="${not empty log.userId}">
                                    <span class="font-monospace small text-muted mt-1 text-break">${log.userId}</span>
                                </c:if>
                            </li>
                            <li class="list-group-item px-0 py-3 d-flex flex-column">
                                <span class="text-muted fw-bold small mb-1">Đối tượng (Target)</span>
                                <span class="fw-bold text-dark">${log.entityType}</span>
                                <c:if test="${not empty log.recordId}">
                                    <span class="font-monospace small text-muted mt-1 text-break">${log.recordId}</span>
                                </c:if>
                            </li>
                            <li class="list-group-item px-0 py-3 d-flex justify-content-between align-items-center">
                                <span class="text-muted fw-bold small">IP Address</span>
                                <span class="font-monospace small text-end">${log.ipAddress}</span>
                            </li>
                            <li class="list-group-item px-0 py-3 d-flex flex-column">
                                <span class="text-muted fw-bold small mb-1">Thiết bị / User Agent</span>
                                <span class="small text-muted text-break p-2 bg-light rounded">${log.userAgent}</span>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>

            <div class="col-lg-8 mb-4">
                <div class="card shadow-sm border-0 rounded-4 h-100">
                    <div class="card-header bg-white border-bottom-0 pt-4 pb-0">
                        <h5 class="fw-bold"><i class="fa-solid fa-code-compare me-2 text-primary"></i> Dữ liệu thay đổi</h5>
                    </div>
                    <div class="card-body">
                        
                        <c:if test="${log.status == 'FAILED' && not empty log.errorMessage}">
                            <div class="mb-4">
                                <h6 class="fw-bold text-danger"><i class="fa-solid fa-triangle-exclamation me-1"></i> Lỗi hệ thống</h6>
                                <div class="p-3 bg-danger bg-opacity-10 text-danger rounded small text-wrap">
                                    <c:out value="${log.errorMessage}" />
                                </div>
                            </div>
                        </c:if>

                        <div class="row h-100">
                            <div class="col-md-6 mb-3 mb-md-0 d-flex flex-column">
                                <h6 class="fw-bold text-danger"><i class="fa-solid fa-minus me-1"></i> Dữ liệu cũ</h6>
                                <pre id="oldDataPre" class="p-3 border border-danger border-opacity-25 rounded small flex-grow-1" style="background-color: #fdf8f8; color: #cb2431; white-space: pre-wrap; word-break: break-all; min-height: 250px;"><c:out value="${log.oldValues}" /></pre>
                            </div>
                            <div class="col-md-6 d-flex flex-column">
                                <h6 class="fw-bold text-success"><i class="fa-solid fa-plus me-1"></i> Dữ liệu mới</h6>
                                <pre id="newDataPre" class="p-3 border border-success border-opacity-25 rounded small flex-grow-1" style="background-color: #f1f8f6; color: #22863a; white-space: pre-wrap; word-break: break-all; min-height: 250px;"><c:out value="${log.newValues}" /></pre>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </c:if>
</div>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        function formatJsonStr(str) {
            if (!str || str.trim() === '') return 'Không có dữ liệu';
            try {
                const obj = JSON.parse(str);
                return JSON.stringify(obj, null, 2);
            } catch (e) {
                return str;
            }
        }

        const oldPre = document.getElementById('oldDataPre');
        if (oldPre) {
            oldPre.textContent = formatJsonStr(oldPre.textContent);
        }

        const newPre = document.getElementById('newDataPre');
        if (newPre) {
            newPre.textContent = formatJsonStr(newPre.textContent);
        }
    });
</script>

<jsp:include page="/WEB-INF/views/layout/admin-footer.jsp" />
