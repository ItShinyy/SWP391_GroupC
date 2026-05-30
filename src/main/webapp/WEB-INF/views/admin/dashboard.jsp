<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/admin-header.jsp" />

<div class="container-fluid">
    <div class="row mb-4">
        <div class="col-12">
            <h1 class="page-title">Dashboard Overview</h1>
        </div>
    </div>

    <!-- Stats Cards -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon bg-primary-light">
                <i class="fa-solid fa-users text-primary"></i>
            </div>
            <div class="stat-details">
                <h3>Total Users</h3>
                <p class="stat-number">${totalUsers}</p>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon bg-success-light">
                <i class="fa-solid fa-file-medical text-success"></i>
            </div>
            <div class="stat-details">
                <h3>Total Reports</h3>
                <p class="stat-number">${totalReports}</p>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon bg-warning-light">
                <i class="fa-solid fa-newspaper text-warning"></i>
            </div>
            <div class="stat-details">
                <h3>Articles</h3>
                <p class="stat-number">${totalArticles}</p>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon bg-info-light">
                <i class="fa-solid fa-viruses text-info"></i>
            </div>
            <div class="stat-details">
                <h3>Diseases Configured</h3>
                <p class="stat-number">${totalDiseases}</p>
            </div>
        </div>
    </div>

    <!-- Future: Recent Reports Table could go here -->
    
</div>

<jsp:include page="/WEB-INF/views/layout/admin-footer.jsp" />
