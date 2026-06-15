<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/guest-header.jsp" />

<div class="container-fluid">
    <div class="table-container bg-white shadow-sm rounded-4 p-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h1 class="page-title">Lịch Sử Y tế </h1>
        </div>
        
        <div class="card shadow-sm mb-4 border-0 rounded-4 bg-light">
            <div class="card-body">
                <form action="${pageContext.request.contextPath}/patient/reports" method="get" class="row g-3 align-items-center">
                    <div class="col-md-3">
                        <input type="text" name="search" class="form-control" placeholder="Tìm kiếm theo tên bệnh" value="${param.search}">
                    </div>
                    
                    <div class="col-md-2">
                        <input type="date" name="fromDate" class="form-control" value="${param.fromDate}" title="Từ ngày">
                    </div>
                    
                    <div class="col-md-2">
                        <input type="date" name="toDate" class="form-control" value="${param.toDate}" title="Đến ngày">
                    </div>
                    
                    <div class="col-md-3">
                        <select name="sort" class="form-select">
                            <option value="date" ${param.sort == 'date' || empty param.sort ? 'selected' : ''}>Sắp xếp theo Ngày (Mới nhất)</option>
                            <option value="confidence" ${param.sort == 'confidence' ? 'selected' : ''}>Sắp xếp theo Độ tin cậy (Cao nhất)</option>
                            <option value="risk" ${param.sort == 'risk' ? 'selected' : ''}>Sắp xếp theo Mức độ rủi ro (Cao đến Thấp)</option>
                        </select>
                    </div>
                    
                    <div class="col-md-2 d-flex gap-2">
                        <button type="submit" class="btn btn-primary flex-grow-1"><i class="fa-solid fa-magnifying-glass"></i> Tìm kiếm</button>
                        <a href="${pageContext.request.contextPath}/patient/reports" class="btn btn-outline-secondary">Xóa bộ lọc</a>
                    </div>
                </form>
            </div>
        </div>

        <div class="table-responsive">
            <table class="table table-hover table-striped align-middle">
                <thead class="table-dark">
                    <tr>
                        <th scope="col" style="width: 12%">Mã ID</th>
                        <th scope="col" style="width: 38%">Bệnh được phát hiện</th>
                        <th scope="col" style="width: 12%">Độ tin cậy</th>
                        <th scope="col" style="width: 13%">Mức độ rủi ro</th>
                        <th scope="col" style="width: 15%">Ngày quét</th>
                        <th scope="col" style="width: 10%" class="text-center">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty reports}">
                            <tr>
                                <td colspan="6" class="text-center py-4 text-muted">Không tìm thấy kết quả chẩn đoán nào.</td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="r" items="${reports}">
                                <tr>
                                    <td>
                                        <span class="uuid-text text-secondary font-monospace" title="${r.id}">
                                            ${r.id.substring(0, 8)}<span class="text-muted">...</span>
                                        </span>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${r.diseaseName != null}">
                                                <span class="badge bg-secondary p-1">SYS</span> ${r.diseaseName}
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">Không rõ</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="font-weight-bold
                                        <c:choose>
                                            <c:when test="${r.riskLevel == 'HIGH'}">text-danger</c:when>
                                            <c:when test="${r.riskLevel == 'MEDIUM'}">text-warning</c:when>
                                            <c:when test="${r.riskLevel == 'LOW'}">text-success</c:when>
                                        </c:choose>">
                                        ${r.confidenceScore}%
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${r.riskLevel == 'HIGH'}">
                                                <span class="badge bg-danger px-3 py-2 text-uppercase" style="font-size: 85%;">Nguy cơ cao</span>
                                            </c:when>
                                            <c:when test="${r.riskLevel == 'MEDIUM'}">
                                                <span class="badge bg-warning text-white px-3 py-2 text-uppercase" style="font-size: 85%;">Nguy cơ trung bình</span>
                                            </c:when>
                                            <c:when test="${r.riskLevel == 'LOW'}">
                                                <span class="badge bg-success px-3 py-2 text-uppercase" style="font-size: 85%;">Nguy cơ thấp</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-secondary px-3 py-2">ĐANG CHỜ</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <small class="text-muted">
                                            <fmt:parseDate value="${r.createdAt}" pattern="yyyy-MM-dd'T'HH:mm:ss" var="parsedDate" type="both" />
                                            <fmt:formatDate pattern="dd/MM/yyyy HH:mm" value="${parsedDate}" />
                                        </small>
                                    </td>
                                    <td class="text-center">
                                        <div class="btn-group" role="group">
                                            <a href="${pageContext.request.contextPath}/patient/reports/view?id=${r.id}" class="btn btn-sm btn-outline-primary" title="Xem chi tiết">
                                                <i class="fas fa-eye"></i>
                                            </a>
                                            <a href="${pageContext.request.contextPath}/patient/booking?reportId=${r.id}" class="btn btn-sm btn-outline-success" title="Đặt lịch hẹn">
                                                <i class="fas fa-calendar-plus"></i>
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
        
        <c:if test="${totalPages > 1}">
            <div class="mt-4">
                <nav aria-label="Page navigation">
                    <ul class="pagination justify-content-center mb-0">
                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                            <a class="page-link" href="?page=${currentPage - 1}&search=${param.search}&fromDate=${param.fromDate}&toDate=${param.toDate}&sort=${param.sort}">Trước</a>
                        </li>
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <li class="page-item ${i == currentPage ? 'active' : ''}">
                                <a class="page-link" href="?page=${i}&search=${param.search}&fromDate=${param.fromDate}&toDate=${param.toDate}&sort=${param.sort}">${i}</a>
                            </li>
                        </c:forEach>
                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                            <a class="page-link" href="?page=${currentPage + 1}&search=${param.search}&fromDate=${param.fromDate}&toDate=${param.toDate}&sort=${param.sort}">Sau</a>
                        </li>
                    </ul>
                </nav>
            </div>
        </c:if>
    </div>
</div>

<jsp:include page="/WEB-INF/views/layout/guest-footer.jsp" />
