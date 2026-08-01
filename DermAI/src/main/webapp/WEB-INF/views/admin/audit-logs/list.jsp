<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/admin-header.jsp" />

<div class="container-fluid admin-page admin-page--fit">
    <div class="table-container bg-white shadow-sm rounded-4 p-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h1 class="page-title">Nhật Ký Hệ Thống</h1>
            <a href="${pageContext.request.contextPath}/admin/audit-logs?action=export&keyword=${param.keyword}&status=${param.status}&startDate=${param.startDate}&endDate=${param.endDate}" class="btn btn-success fw-bold">
                <i class="fa-solid fa-file-csv me-2"></i> Xuất CSV
            </a>
        </div>

        <!-- Search & Filter Bar -->
        <div class="card admin-filters shadow-sm mb-2 border-0 rounded-4 bg-light">
            <div class="card-body">
                <form action="${pageContext.request.contextPath}/admin/audit-logs" method="get" class="mb-0 row g-3">
                    <div class="col-md-3">
                        <input type="text" name="keyword" class="form-control" placeholder="Tìm theo Email, ID, IP..." value="${param.keyword}">
                    </div>
                    <div class="col-md-2">
                        <select name="status" class="form-select">
                            <option value="ALL" ${param.status == 'ALL' ? 'selected' : ''}>-- Tất cả trạng thái --</option>
                            <option value="SUCCESS" ${param.status == 'SUCCESS' ? 'selected' : ''}>Thành công</option>
                            <option value="FAILED" ${param.status == 'FAILED' ? 'selected' : ''}>Thất bại</option>
                        </select>
                    </div>
                        
                    <div class="col-md-2">
                        <input type="date" class="form-control" name="startDate" value="${param.startDate}" title="Từ ngày">
                    </div>
                    <div class="col-md-2">
                        <input type="date" class="form-control" name="endDate" value="${param.endDate}" title="Đến ngày">
                    </div>
                    
                    <div class="col-md-3 d-flex gap-2">
                        <button type="submit" class="btn btn-primary w-100">
                            <i class="fa-solid fa-magnifying-glass me-1"></i> Tìm kiếm
                        </button>
                        <a href="${pageContext.request.contextPath}/admin/audit-logs" class="btn btn-outline-secondary w-100">
                            <i class="fa-solid fa-eraser me-1"></i> Xóa bộ lọc
                        </a>
                    </div>
                </form>
            </div>
        </div>

        <div class="table-responsive">
            <table class="table table-hover table-striped align-middle admin-table-fixed">
                <colgroup>
                    <col style="width: 12%">
                    <col style="width: 14%">
                    <col style="width: 18%">
                    <col style="width: 24%">
                    <col style="width: 10%">
                    <col style="width: 12%">
                    <col style="width: 10%">
                </colgroup>
                <thead class="table-dark">
                    <tr>
                        <th scope="col">Thời gian</th>
                        <th scope="col">Người thực hiện</th>
                        <th scope="col">Hành động</th>
                        <th scope="col">Đối tượng</th>
                        <th scope="col">Trạng thái</th>
                        <th scope="col">Địa Chỉ IP</th>
                        <th scope="col" class="text-center">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty auditLogs}">
                            <tr>
                                <td colspan="7" class="text-center py-4 text-muted">Không tìm thấy bản ghi nào.</td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="log" items="${auditLogs}">
                                <tr>
                                    <td class="text-muted small">
                                        <fmt:parseDate value="${log.createdAt}" pattern="yyyy-MM-dd'T'HH:mm:ss" var="parsedDateTime" type="both" />
                                        <fmt:formatDate pattern="dd/MM/yyyy HH:mm:ss" value="${parsedDateTime}" var="createdAtFmt" />
                                        <span class="cell-clip" title="${createdAtFmt}">${createdAtFmt}</span>
                                    </td>
                                    <td class="fw-semibold">
                                        <span class="cell-clip" title="<c:out value='${log.userName}'/>"><c:out value="${log.userName}"/></span>
                                    </td>
                                    <td>
                                        <span class="badge bg-secondary bg-opacity-10 text-secondary border border-secondary border-opacity-25 px-2 py-1"
                                              title="<c:out value='${log.action}'/>"><c:out value="${log.action}"/></span>
                                    </td>
                                    <td class="text-muted">
                                        <div class="cell-clip-2" title="<c:out value='${log.entityType}'/> <c:out value='${log.recordId}'/>">
                                            <c:out value="${log.entityType}"/>
                                            <c:if test="${not empty log.recordId}">
                                                <br><span class="font-monospace small"><c:out value="${log.recordId}"/></span>
                                            </c:if>
                                        </div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${log.status == 'SUCCESS'}">
                                                <span class="badge bg-success">THÀNH CÔNG</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-danger">THẤT BẠI</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-muted small font-monospace">
                                        <span class="cell-clip" title="<c:out value='${log.ipAddress}'/>"><c:out value="${log.ipAddress}"/></span>
                                    </td>
                                    <td class="text-center">
                                        <a href="${pageContext.request.contextPath}/admin/audit-logs/detail?id=${log.id}&amp;page=${currentPage}&amp;keyword=${param.keyword}&amp;status=${param.status}&amp;startDate=${param.startDate}&amp;endDate=${param.endDate}" class="btn btn-sm btn-outline-primary">
                                            <i class="fas fa-eye"></i> Chi tiết
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>

        <c:set var="pageQuery" value="&amp;keyword=${param.keyword}&amp;status=${param.status}&amp;startDate=${param.startDate}&amp;endDate=${param.endDate}" scope="request"/>
        <jsp:include page="/WEB-INF/views/admin/common/_pagination.jsp"/>
    </div>
</div>

<jsp:include page="/WEB-INF/views/layout/admin-footer.jsp" />

