<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/admin-header.jsp" />

<div class="container-fluid">
    <div class="table-container bg-white shadow-sm rounded-4 p-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h1 class="page-title">Kết Quả Chẩn Đoán AI</h1>
        </div>
        
        <!-- Search & Filter Bar -->
        <div class="card shadow-sm mb-4 border-0 rounded-4 bg-light">
            <div class="card-body">
                <form action="${pageContext.request.contextPath}/admin/ai-results" method="get" class="row g-3 align-items-center">
                    <div class="col-md-4">
                        <input type="text" name="search" class="form-control" placeholder="Tìm theo tên bệnh nhân hoặc bệnh" value="${param.search}">
                    </div>
                    <div class="col-md-3">
                        <select name="risk" class="form-select">
                            <option value="">Tất cả mức độ rủi ro</option>
                            <option value="LOW" ${param.risk == 'LOW' ? 'selected' : ''}>LOW</option>
                            <option value="MEDIUM" ${param.risk == 'MEDIUM' ? 'selected' : ''}>MEDIUM</option>
                            <option value="HIGH" ${param.risk == 'HIGH' ? 'selected' : ''}>HIGH</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <select name="sort" class="form-select">
                            <option value="date" ${param.sort == 'date' || empty param.sort ? 'selected' : ''}>Sắp xếp theo ngày (Mới nhất)</option>
                            <option value="precision" ${param.sort == 'precision' ? 'selected' : ''}>Sắp xếp theo độ tin cậy (Cao nhất)</option>
                        </select>
                    </div>
                    <div class="col-md-2 d-flex gap-2">
                        <button type="submit" class="btn btn-primary flex-grow-1"><i class="fa-solid fa-magnifying-glass"></i> Tìm kiếm</button>
                        <a href="${pageContext.request.contextPath}/admin/ai-results" class="btn btn-outline-secondary">Xóa Bộ Lọc</a>
                    </div>
                </form>
            </div>
        </div>

        <div class="table-responsive">
            <table class="table table-hover table-striped align-middle">
                <thead class="table-dark">
                    <tr>
                        <th scope="col" style="width: 12%">Mã (ID)</th>
                        <th scope="col" style="width: 18%">Tên Bệnh Nhân</th>
                        <th scope="col" style="width: 20%">Bệnh</th>
                        <th scope="col" style="width: 12%">Độ Tin Cậy</th>
                        <th scope="col" style="width: 13%">Mức Độ Rủi Ro</th>
                        <th scope="col" style="width: 15%">Ngày Tạo</th>
                        <th scope="col" style="width: 10%" class="text-center">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty reports}">
                            <tr>
                                <td colspan="7" class="text-center py-4 text-muted">Không tìm thấy kết quả chẩn đoán nào.</td>
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
                                    <td class="font-weight-bold text-dark">${r.patientName}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${r.diseaseName != null}">
                                                <span class="badge bg-secondary p-1">SYS</span> ${r.diseaseName}
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">Unknown</span>
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
                                                <span class="badge bg-danger">Nguy cơ cao</span>
                                            </c:when>
                                            <c:when test="${r.riskLevel == 'MEDIUM'}">
                                                <span class="badge bg-warning">Trung bình</span>
                                            </c:when>
                                            <c:when test="${r.riskLevel == 'LOW'}">
                                                <span class="badge bg-success">An toàn</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-secondary">PENDING</span>
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
                                        <a href="${pageContext.request.contextPath}/admin/ai-results/detail?id=${r.id}" class="btn btn-sm btn-outline-primary">
                                            <i class="fas fa-eye"></i> Xem chi tiết
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
        
        <!-- Pagination -->
        <c:if test="${totalPages > 1}">
            <div class="p-3 border-top">
                <nav aria-label="Page navigation" class="mb-0">
                    <ul class="pagination justify-content-center mb-0">
                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                            <a class="page-link" href="?page=${currentPage - 1}&search=${param.search}&risk=${param.risk}&sort=${param.sort}">Trước</a>
                        </li>
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <li class="page-item ${i == currentPage ? 'active' : ''}">
                                <a class="page-link" href="?page=${i}&search=${param.search}&risk=${param.risk}&sort=${param.sort}">${i}</a>
                            </li>
                        </c:forEach>
                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                            <a class="page-link" href="?page=${currentPage + 1}&search=${param.search}&risk=${param.risk}&sort=${param.sort}">Sau</a>
                        </li>
                    </ul>
                </nav>
            </div>
        </c:if>
    </div>
</div>

<jsp:include page="/WEB-INF/views/layout/admin-footer.jsp" />
