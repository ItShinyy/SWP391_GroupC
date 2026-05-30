<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/admin-header.jsp" />

<div class="container-fluid">
    <div class="table-container bg-white shadow-sm rounded-4 p-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h4 class="text-primary font-weight-bold mb-0"><i class="fas fa-microscope mr-2"></i>Danh sách chẩn đoán của hệ thống</h4>
        </div>
        
        <!-- Search & Filter Bar -->
        <div class="card shadow-sm mb-4 border-0 rounded-4 bg-light">
            <div class="card-body">
                <form action="${pageContext.request.contextPath}/admin/ai-results" method="get" class="row g-3 align-items-center">
                    <div class="col-md-4">
                        <input type="text" name="search" class="form-control" placeholder="Search by patient name or disease" value="${param.search}">
                    </div>
                    <div class="col-md-3">
                        <select name="risk" class="form-select">
                            <option value="">All Risk Levels</option>
                            <option value="LOW" ${param.risk == 'LOW' ? 'selected' : ''}>LOW</option>
                            <option value="MEDIUM" ${param.risk == 'MEDIUM' ? 'selected' : ''}>MEDIUM</option>
                            <option value="HIGH" ${param.risk == 'HIGH' ? 'selected' : ''}>HIGH</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <select name="sort" class="form-select">
                            <option value="date" ${param.sort == 'date' || empty param.sort ? 'selected' : ''}>Sort by Date (Newest)</option>
                            <option value="precision" ${param.sort == 'precision' ? 'selected' : ''}>Sort by Precision (Highest)</option>
                        </select>
                    </div>
                    <div class="col-md-2 d-grid">
                        <button type="submit" class="btn btn-primary"><i class="fa-solid fa-magnifying-glass me-2"></i>Filter</button>
                    </div>
                </form>
            </div>
        </div>

        <div class="table-responsive">
            <table class="table table-hover table-striped align-middle">
                <thead class="table-dark">
                    <tr>
                        <th scope="col" style="width: 12%">ID</th>
                        <th scope="col" style="width: 18%">Tên bệnh nhân</th>
                        <th scope="col" style="width: 20%">Bệnh lý</th>
                        <th scope="col" style="width: 12%">Độ tin cậy</th>
                        <th scope="col" style="width: 13%">Mức độ</th>
                        <th scope="col" style="width: 15%">Thời gian tạo</th>
                        <th scope="col" style="width: 10%" class="text-center">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty reports}">
                            <tr>
                                <td colspan="7" class="text-center py-4 text-muted">No diagnosis results found.</td>
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
                                                <span class="badge bg-danger px-3 py-2 text-uppercase" style="font-size: 85%;">Nguy cơ cao</span>
                                            </c:when>
                                            <c:when test="${r.riskLevel == 'MEDIUM'}">
                                                <span class="badge bg-warning text-white px-3 py-2 text-uppercase" style="font-size: 85%;">Trung bình</span>
                                            </c:when>
                                            <c:when test="${r.riskLevel == 'LOW'}">
                                                <span class="badge bg-success px-3 py-2 text-uppercase" style="font-size: 85%;">An toàn</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-secondary px-3 py-2">PENDING</span>
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
                                            <i class="fas fa-eye"></i> Xem
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
            <div class="mt-4">
                <nav aria-label="Page navigation">
                    <ul class="pagination justify-content-center mb-0">
                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                            <a class="page-link" href="?page=${currentPage - 1}&search=${param.search}&risk=${param.risk}&sort=${param.sort}">Previous</a>
                        </li>
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <li class="page-item ${i == currentPage ? 'active' : ''}">
                                <a class="page-link" href="?page=${i}&search=${param.search}&risk=${param.risk}&sort=${param.sort}">${i}</a>
                            </li>
                        </c:forEach>
                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                            <a class="page-link" href="?page=${currentPage + 1}&search=${param.search}&risk=${param.risk}&sort=${param.sort}">Next</a>
                        </li>
                    </ul>
                </nav>
            </div>
        </c:if>
    </div>
</div>

<jsp:include page="/WEB-INF/views/layout/admin-footer.jsp" />
