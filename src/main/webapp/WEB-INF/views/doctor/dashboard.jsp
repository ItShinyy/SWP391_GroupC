<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/doctor-header.jsp" />

<style>
    .stat-card {
        border-radius: 16px;
        padding: 1.5rem;
        border: none;
        transition: transform 0.2s ease, box-shadow 0.2s ease;
        position: relative;
        overflow: hidden;
    }
    .stat-card:hover {
        transform: translateY(-4px);
        box-shadow: 0 12px 30px rgba(0,0,0,0.1);
    }
    .stat-card .stat-icon {
        width: 48px;
        height: 98px;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.3rem;
    }
    .stat-card .stat-number {
        font-size: 2rem;
        font-weight: 700;
        line-height: 1;
    }
    .stat-card .stat-label {
        font-size: 0.8rem;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        color: #64748b;
    }
    .stat-card-total { background: linear-gradient(135deg, #f0f9ff, #e0f2fe); }
    .stat-card-total .stat-icon { background: #0ea5e9; color: white; }
    .stat-card-total .stat-number { color: #0369a1; }
    
    .stat-card-pending { background: linear-gradient(135deg, #fffbeb, #fef3c7); }
    .stat-card-pending .stat-icon { background: #f59e0b; color: white; }
    .stat-card-pending .stat-number { color: #b45309; }
    
    .stat-card-accepted { background: linear-gradient(135deg, #f0fdf4, #dcfce7); }
    .stat-card-accepted .stat-icon { background: #22c55e; color: white; }
    .stat-card-accepted .stat-number { color: #15803d; }
    
    .stat-card-rejected { background: linear-gradient(135deg, #fef2f2, #fecaca); }
    .stat-card-rejected .stat-icon { background: #ef4444; color: white; }
    .stat-card-rejected .stat-number { color: #b91c1c; }

    .filter-tabs {
        display: flex;
        gap: 0.5rem;
        padding: 0.4rem;
        background: #f1f5f9;
        border-radius: 12px;
        width: fit-content;
    }
    .filter-tab {
        padding: 0.5rem 1.2rem;
        border-radius: 8px;
        font-size: 0.85rem;
        font-weight: 600;
        color: #64748b;
        text-decoration: none;
        transition: all 0.2s ease;
        border: none;
        background: transparent;
    }
    .filter-tab:hover { color: #0f172a; background: rgba(255,255,255,0.5); }
    .filter-tab.active { background: white; color: #0f172a; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }

    .table-modern {
        border-collapse: separate;
        border-spacing: 0;
    }
    .table-modern thead th {
        background: #f8fafc;
        border-bottom: 2px solid #e2e8f0;
        font-size: 0.75rem;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        color: #64748b;
        padding: 1rem;
    }
    .table-modern tbody td {
        padding: 1rem;
        vertical-align: middle;
        border-bottom: 1px solid #f1f5f9;
        font-size: 0.9rem;
    }
    .table-modern tbody tr {
        transition: background 0.15s ease;
    }
    .table-modern tbody tr:hover {
        background: #f8fafc;
    }

    .badge-status {
        padding: 0.35rem 0.8rem;
        border-radius: 20px;
        font-size: 0.75rem;
        font-weight: 600;
    }
    .badge-pending { background: #fef3c7; color: #92400e; }
    .badge-accepted { background: #dcfce7; color: #166534; }
    .badge-rejected { background: #fecaca; color: #991b1b; }

    .btn-view-detail {
        padding: 0.4rem 1rem;
        border-radius: 8px;
        font-size: 0.8rem;
        font-weight: 600;
        background: linear-gradient(135deg, #3b82f6, #2563eb);
        color: white;
        border: none;
        text-decoration: none;
        transition: all 0.2s ease;
    }
    .btn-view-detail:hover {
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(37, 99, 235, 0.3);
        color: white;
    }

    .welcome-section {
        background: linear-gradient(135deg, #1e3a8a 0%, #3b82f6 100%);
        border-radius: 20px;
        padding: 2rem 2.5rem;
        color: white;
        position: relative;
        overflow: hidden;
    }
    .welcome-section::before {
        content: '';
        position: absolute;
        top: -50%;
        right: -20%;
        width: 300px;
        height: 300px;
        background: rgba(255,255,255,0.05);
        border-radius: 50%;
    }
    .welcome-section::after {
        content: '';
        position: absolute;
        bottom: -30%;
        right: 5%;
        width: 200px;
        height: 200px;
        background: rgba(255,255,255,0.03);
        border-radius: 50%;
    }

    .risk-badge {
        padding: 0.25rem 0.6rem;
        border-radius: 6px;
        font-size: 0.75rem;
        font-weight: 700;
    }
    .risk-high { background: #fecaca; color: #991b1b; }
    .risk-medium { background: #fef3c7; color: #92400e; }
    .risk-low { background: #dcfce7; color: #166534; }
</style>

<div class="container-fluid py-4 px-4">

    <!-- Success/Error Alerts -->
    <c:if test="${param.transferSuccess == 'true'}">
        <div class="alert alert-success alert-dismissible fade show rounded-3 border-0 shadow-sm mb-4" role="alert">
            <i class="fa-solid fa-circle-check me-2"></i>Chuyển giao hồ sơ bệnh nhân thành công!
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <!-- Welcome Section -->
    <div class="welcome-section mb-4">
        <div class="position-relative">
            <h2 class="fw-bold mb-1">
                <i class="fa-solid fa-stethoscope me-2"></i>Xin chào, ${doctor.fullName}
            </h2>
            <p class="mb-0 opacity-75">
                <i class="fa-solid fa-hospital me-1"></i> ${doctor.clinicName}
                <span class="mx-2">|</span>
                <i class="fa-solid fa-briefcase-medical me-1"></i> ${doctor.specialization}
            </p>
        </div>
    </div>

    <!-- Stat Cards -->
    <div class="row g-4 mb-4">
        <div class="col-xl-3 col-md-6">
            <div class="stat-card stat-card-total shadow-sm">
                <div class="d-flex align-items-center justify-content-between">
                    <div>
                        <div class="stat-label mb-2">Tổng Hồ Sơ</div>
                        <div class="stat-number">${totalCount}</div>
                    </div>
                    <div class="stat-icon">
                        <i class="fa-solid fa-folder-open"></i>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-md-6">
            <div class="stat-card stat-card-pending shadow-sm">
                <div class="d-flex align-items-center justify-content-between">
                    <div>
                        <div class="stat-label mb-2">Chờ Khám</div>
                        <div class="stat-number">${confirmedCount}</div>
                    </div>
                    <div class="stat-icon">
                        <i class="fa-solid fa-clock"></i>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-md-6">
            <div class="stat-card stat-card-accepted shadow-sm">
                <div class="d-flex align-items-center justify-content-between">
                    <div>
                        <div class="stat-label mb-2">Đã Khám Xong</div>
                        <div class="stat-number">${completedCount}</div>
                    </div>
                    <div class="stat-icon">
                        <i class="fa-solid fa-check-circle"></i>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-md-6">
            <div class="stat-card stat-card-rejected shadow-sm">
                <div class="d-flex align-items-center justify-content-between">
                    <div>
                        <div class="stat-label mb-2">Đã Hủy</div>
                        <div class="stat-number">${cancelledCount}</div>
                    </div>
                    <div class="stat-icon">
                        <i class="fa-solid fa-times-circle"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Appointments Table -->
    <div class="card border-0 shadow-sm rounded-4">
        <div class="card-header bg-white border-0 p-4 pb-3">
            <div class="d-flex flex-wrap justify-content-between align-items-center gap-3">
                <h5 class="fw-bold mb-0">
                    <i class="fa-solid fa-list-check me-2 text-primary"></i>Danh Sách Bệnh Nhân Chờ Khám
                </h5>
                <!-- Form Filter & Search -->
                <form method="get" action="${pageContext.request.contextPath}/doctor/dashboard" class="d-flex flex-wrap gap-2 align-items-center">
                    <c:if test="${not empty statusFilter}">
                        <input type="hidden" name="status" value="${statusFilter}">
                    </c:if>
                    
                    <div class="input-group input-group-sm" style="max-width: 250px;">
                        <span class="input-group-text bg-light border-end-0"><i class="fa-solid fa-magnifying-glass text-muted"></i></span>
                        <input type="text" name="keyword" class="form-control bg-light border-start-0" placeholder="Tên hoặc SĐT..." value="${param.keyword}">
                    </div>
                    
                    <select name="riskFilter" class="form-select form-select-sm bg-light" style="width: 140px;">
                        <option value="">-- Mức rủi ro --</option>
                        <option value="LOW" ${param.riskFilter == 'LOW' ? 'selected' : ''}>Thấp</option>
                        <option value="MEDIUM" ${param.riskFilter == 'MEDIUM' ? 'selected' : ''}>Trung bình</option>
                        <option value="HIGH" ${param.riskFilter == 'HIGH' ? 'selected' : ''}>Cao</option>
                    </select>
                    
                    <select name="sortBy" class="form-select form-select-sm bg-light" style="width: 160px;">
                        <option value="time_asc" ${param.sortBy == 'time_asc' ? 'selected' : ''}>Giờ hẹn (Sớm nhất)</option>
                        <option value="time_desc" ${param.sortBy == 'time_desc' ? 'selected' : ''}>Giờ hẹn (Muộn nhất)</option>
                        <option value="risk_desc" ${param.sortBy == 'risk_desc' ? 'selected' : ''}>Rủi ro giảm dần</option>
                    </select>
                    
                    <button type="submit" class="btn btn-sm btn-primary fw-bold px-3 rounded-2">
                        <i class="fa-solid fa-filter me-1"></i>Lọc
                    </button>
                    <a href="${pageContext.request.contextPath}/doctor/dashboard?status=${statusFilter}" class="btn btn-sm btn-outline-secondary fw-bold px-3 rounded-2">
                        <i class="fa-solid fa-rotate-left"></i>
                    </a>
                </form>
            </div>
        </div>
        <div class="card-body p-0">
            <c:choose>
                <c:when test="${not empty appointments}">
                    <div class="table-responsive">
                        <table class="table table-modern mb-0">
                            <thead>
                                <tr>
                                    <th>STT</th>
                                    <th>Bệnh Nhân</th>
                                    <th>Bệnh Phát Hiện</th>
                                    <th>Độ Chính Xác</th>
                                    <th>Mức Rủi Ro</th>
                                    <th>Ngày Đặt Lịch</th>
                                    <th>Ngày Hẹn Khám</th>
                                    <th>Trạng Thái</th>
                                    <th class="text-center">Hành Động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="apt" items="${appointments}" varStatus="loop">
                                    <tr>
                                        <td class="fw-bold text-muted">${(currentPage - 1) * 10 + loop.index + 1}</td>
                                        <td>
                                            <div class="d-flex align-items-center gap-2">
                                                <div class="rounded-circle bg-primary bg-opacity-10 d-flex align-items-center justify-content-center" style="width: 36px; height: 36px;">
                                                    <i class="fa-solid fa-user text-primary" style="font-size: 0.8rem;"></i>
                                                </div>
                                                <div>
                                                    <div class="fw-semibold">${apt.patientName != null ? apt.patientName : 'N/A'}</div>
                                                    <div class="text-muted" style="font-size: 0.75rem;">${apt.patientPhone}</div>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <span class="fw-semibold">${apt.diseaseName != null ? apt.diseaseName : 'Chưa xác định'}</span>
                                        </td>
                                        <td>
                                            <c:if test="${apt.confidenceScore > 0}">
                                                <div class="d-flex align-items-center gap-2">
                                                    <div class="progress" style="width: 60px; height: 6px;">
                                                        <div class="progress-bar bg-primary" style="width: ${apt.confidenceScore}%"></div>
                                                    </div>
                                                    <span class="fw-bold text-primary" style="font-size: 0.85rem;">
                                                        <fmt:formatNumber value="${apt.confidenceScore}" pattern="#0.0"/>%
                                                    </span>
                                                </div>
                                            </c:if>
                                            <c:if test="${apt.confidenceScore == 0}">
                                                <span class="text-muted">N/A</span>
                                            </c:if>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${apt.riskLevel == 'HIGH'}"><span class="risk-badge risk-high">Cao</span></c:when>
                                                <c:when test="${apt.riskLevel == 'MEDIUM'}"><span class="risk-badge risk-medium">Trung bình</span></c:when>
                                                <c:when test="${apt.riskLevel == 'LOW'}"><span class="risk-badge risk-low">Thấp</span></c:when>
                                                <c:otherwise><span class="text-muted">-</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            ${apt.createdDateFormatted}
                                            <div class="text-muted" style="font-size: 0.75rem;">
                                                ${apt.createdTimeOnlyFormatted}
                                            </div>
                                        </td>
                                        <td>
                                            <span class="fw-semibold text-primary">${apt.appointmentDateFormatted}</span>
                                            <div class="text-primary" style="font-size: 0.75rem; font-weight: 600;">
                                                ${apt.appointmentTimeOnlyFormatted}
                                            </div>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${apt.status == 'COMPLETED'}">
                                                    <span class="badge-status badge-accepted"><i class="fa-solid fa-circle-check me-1"></i>Đã khám xong</span>
                                                </c:when>
                                                <c:when test="${apt.status == 'CANCELLED'}">
                                                    <span class="badge-status badge-rejected"><i class="fa-solid fa-circle-xmark me-1"></i>Đã hủy</span>
                                                </c:when>
                                                <c:when test="${apt.status == 'NO_SHOW'}">
                                                    <span class="badge-status badge-rejected"><i class="fa-solid fa-circle-minus me-1"></i>Vắng mặt</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-status badge-pending"><i class="fa-solid fa-clock me-1"></i>Chờ khám</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-center">
                                            <a href="${pageContext.request.contextPath}/doctor/appointments/detail?id=${apt.id}" class="btn-view-detail">
                                                <i class="fa-solid fa-eye me-1"></i>Xem
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>

                    <!-- Pagination -->
                    <c:if test="${totalPages > 1}">
                        <div class="d-flex justify-content-center py-4">
                            <nav>
                                <ul class="pagination mb-0">
                                    <c:if test="${currentPage > 1}">
                                        <li class="page-item">
                                            <a class="page-link" href="${pageContext.request.contextPath}/doctor/dashboard?page=${currentPage - 1}${not empty statusFilter ? '&status='.concat(statusFilter) : ''}${not empty param.keyword ? '&keyword='.concat(param.keyword) : ''}${not empty param.riskFilter ? '&riskFilter='.concat(param.riskFilter) : ''}${not empty param.sortBy ? '&sortBy='.concat(param.sortBy) : ''}">
                                                <i class="fa-solid fa-chevron-left"></i>
                                            </a>
                                        </li>
                                    </c:if>
                                    <c:forEach begin="1" end="${totalPages}" var="i">
                                        <li class="page-item ${i == currentPage ? 'active' : ''}">
                                            <a class="page-link" href="${pageContext.request.contextPath}/doctor/dashboard?page=${i}${not empty statusFilter ? '&status='.concat(statusFilter) : ''}${not empty param.keyword ? '&keyword='.concat(param.keyword) : ''}${not empty param.riskFilter ? '&riskFilter='.concat(param.riskFilter) : ''}${not empty param.sortBy ? '&sortBy='.concat(param.sortBy) : ''}">${i}</a>
                                        </li>
                                    </c:forEach>
                                    <c:if test="${currentPage < totalPages}">
                                        <li class="page-item">
                                            <a class="page-link" href="${pageContext.request.contextPath}/doctor/dashboard?page=${currentPage + 1}${not empty statusFilter ? '&status='.concat(statusFilter) : ''}${not empty param.keyword ? '&keyword='.concat(param.keyword) : ''}${not empty param.riskFilter ? '&riskFilter='.concat(param.riskFilter) : ''}${not empty param.sortBy ? '&sortBy='.concat(param.sortBy) : ''}">
                                                <i class="fa-solid fa-chevron-right"></i>
                                            </a>
                                        </li>
                                    </c:if>
                                </ul>
                            </nav>
                        </div>
                    </c:if>
                </c:when>
                <c:otherwise>
                    <div class="text-center py-5">
                        <i class="fa-solid fa-inbox text-muted" style="font-size: 3rem;"></i>
                        <p class="text-muted mt-3 mb-0">Chưa có hồ sơ bệnh nhân nào.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

</div>

<jsp:include page="/WEB-INF/views/layout/doctor-footer.jsp" />
