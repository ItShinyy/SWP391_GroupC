<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/admin-header.jsp" />

<div class="container-fluid pt-4 px-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="page-title h3 mb-0 text-gray-800">
            <a href="${pageContext.request.contextPath}/admin/ai-results" class="text-decoration-none text-muted me-2"><i class="fa-solid fa-arrow-left"></i></a>
            Diagnosis Report Details
        </h1>
    </div>

    <div class="card border-0 shadow-sm rounded-4">
        <div class="card-header bg-primary text-white p-4 rounded-top-4">
            <h5 class="mb-0"><i class="fas fa-file-medical mr-2"></i> Report Information</h5>
        </div>
        <div class="card-body p-4">
            <div class="row g-4">
                <div class="col-md-6">
                    <label class="font-weight-bold text-muted mb-1">Diagnosis ID:</label>
                    <p class="form-control-plaintext bg-light px-3 py-2 rounded font-weight-bold text-secondary font-monospace">${report.id}</p>
                </div>
                <div class="col-md-6">
                    <label class="font-weight-bold text-muted mb-1">Patient Name:</label>
                    <p class="form-control-plaintext bg-light px-3 py-2 rounded font-weight-bold text-dark">${report.patientName}</p>
                </div>
                <div class="col-md-6">
                    <label class="font-weight-bold text-muted mb-1">Disease Detected:</label>
                    <p class="form-control-plaintext bg-light px-3 py-2 rounded font-weight-bold text-dark">
                        ${report.diseaseName != null ? report.diseaseName : 'Unknown'}
                    </p>
                </div>
                <div class="col-md-3">
                    <label class="font-weight-bold text-muted mb-1">Confidence Score:</label>
                    <p class="form-control-plaintext bg-light px-3 py-2 rounded font-weight-bold text-primary">${report.confidenceScore}%</p>
                </div>
                <div class="col-md-3">
                    <label class="font-weight-bold text-muted mb-1">Risk Level:</label>
                    <div class="form-control-plaintext bg-light px-3 py-2 rounded font-weight-bold">
                        <c:choose>
                            <c:when test="${report.riskLevel == 'HIGH'}"><span class="badge bg-danger">HIGH RISK</span></c:when>
                            <c:when test="${report.riskLevel == 'MEDIUM'}"><span class="badge bg-warning text-white">MEDIUM RISK</span></c:when>
                            <c:when test="${report.riskLevel == 'LOW'}"><span class="badge bg-success">LOW RISK</span></c:when>
                            <c:otherwise><span class="badge bg-secondary">PENDING</span></c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <div class="col-md-6">
                    <label class="font-weight-bold text-muted mb-1">Clinic ID:</label>
                    <p class="form-control-plaintext bg-light px-3 py-2 rounded font-monospace">${report.clinicId != null ? report.clinicId : 'N/A'}</p>
                </div>
                <div class="col-md-6">
                    <label class="font-weight-bold text-muted mb-1">Model Version:</label>
                    <p class="form-control-plaintext bg-light px-3 py-2 rounded text-secondary">${report.modelVersion}</p>
                </div>
                <div class="col-md-6">
                    <label class="font-weight-bold text-muted mb-1">Created At:</label>
                    <p class="form-control-plaintext bg-light px-3 py-2 rounded text-secondary">
                        <fmt:parseDate value="${report.createdAt}" pattern="yyyy-MM-dd'T'HH:mm:ss" var="parsedDate" type="both" />
                        <fmt:formatDate pattern="dd/MM/yyyy HH:mm:ss" value="${parsedDate}" />
                    </p>
                </div>
                <div class="col-md-6">
                    <label class="font-weight-bold text-muted mb-1">Image URL:</label>
                    <p class="form-control-plaintext bg-light px-3 py-2 rounded text-truncate">
                        <a href="${report.imageUrl}" target="_blank">${report.imageUrl}</a>
                    </p>
                </div>
                <div class="col-12">
                    <label class="font-weight-bold text-muted mb-1">AI Recommendation:</label>
                    <div class="p-3 bg-light rounded text-dark border-start border-4 border-primary" style="font-size: 1.05rem; line-height: 1.6;">
                        ${report.recommendation != null ? report.recommendation : 'No recommendation available.'}
                    </div>
                </div>
            </div>
            <div class="mt-4 text-end">
                <a href="${pageContext.request.contextPath}/admin/ai-results" class="btn btn-secondary px-4">Back to Results</a>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/layout/admin-footer.jsp" />
