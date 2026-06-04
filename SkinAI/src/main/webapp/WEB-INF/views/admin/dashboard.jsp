<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/admin-header.jsp" />

<!-- Thêm thư viện CSS trực tiếp để đảm bảo bố cục không bị vỡ -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">

<style>
    /* Nền trang màu xám nhạt để làm nổi bật Card trắng */
    body { background-color: #f3f6f9; }
    
    /* Làm mềm bóng đổ và bo góc */
    .card { border-radius: 12px !important; box-shadow: 0 4px 15px rgba(0,0,0,0.03) !important; transition: all 0.3s ease; }
    
    /* Hiệu ứng nổi lên khi di chuột vào KPI */
    .kpi-card:hover { transform: translateY(-5px); box-shadow: 0 10px 20px rgba(0,0,0,0.08) !important; }
    
    /* Box chứa icon với các tone màu hiện đại */
    .icon-box { width: 64px; height: 64px; border-radius: 16px; display: flex; align-items: center; justify-content: center; }
    .bg-primary-light { background-color: rgba(67, 97, 238, 0.1); color: #4361ee; }
    .bg-success-light { background-color: rgba(32, 201, 151, 0.1); color: #20c997; }
    .bg-warning-light { background-color: rgba(253, 126, 20, 0.1); color: #fd7e14; }
    .bg-info-light { background-color: rgba(13, 202, 240, 0.1); color: #0dcaf0; }
    
    /* Nút bấm tinh tế hơn */
    .btn-custom { background-color: #4361ee; color: white; border-radius: 8px; font-weight: 500; transition: 0.3s; }
    .btn-custom:hover { background-color: #364fc7; color: white; box-shadow: 0 4px 10px rgba(67, 97, 238, 0.3); }
    
    /* Bảng dữ liệu */
    .table-custom th { border-bottom: 2px solid #e9ecef; font-weight: 600; color: #495057; border-top: none; }
    .table-hover tbody tr:hover { background-color: rgba(67, 97, 238, 0.04); }
</style>

<div class="container-fluid pt-4 px-4">
    <!-- Header Actions -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h1 class="page-title">Dashboard</h1>
        </div>
        <div class="small text-muted fw-semibold">
            <i class="fa-regular fa-clock me-1"></i> Data updated at: <span id="last-updated">--:--:--</span>
        </div>
        <div>
            <button id="btn-refresh" class="btn btn-outline-secondary shadow-sm px-4 py-2 me-2" onclick="refreshDashboard()">
                <i class="fa-solid fa-rotate-right me-2"></i> Refresh
            </button>
            <a href="${pageContext.request.contextPath}/admin/export/csv" class="btn btn-custom shadow-sm px-4 py-2" id="btn-export">
                <i class="fa-solid fa-download me-2"></i> Export CSV
            </a>
        </div>
    </div>

    <!-- Row 1: KPI Cards -->
    <div class="row g-4 mb-4">
        <!-- Active Patients Card -->
        <div class="col-sm-12 col-xl-4">
            <div class="card kpi-card bg-white border-0 shadow-sm rounded h-100 p-4">
                <div class="d-flex align-items-center mb-3">
                    <div class="icon-box bg-primary-light me-4">
                        <i class="fa-solid fa-users fa-2x"></i>
                    </div>
                    <div>
                        <p class="mb-1 text-muted fw-semibold">Active Patients</p>
                        <h4 class="mb-0 fw-bold text-dark" id="kpi-users">
                            <span class="spinner-border spinner-border-sm text-primary" role="status"></span>
                        </h4>
                    </div>
                </div>
            </div>
        </div>

        <!-- Merged AI KPIs Card -->
        <div class="col-sm-12 col-xl-8">
            <div class="card bg-white border-0 shadow-sm rounded h-100 p-4">
                <div class="row h-100 align-items-center">
                    <div class="col-4 border-end text-center">
                        <p class="mb-2 text-muted fw-semibold"><i class="fa-solid fa-bullseye text-success me-2"></i>Avg. Precision</p>
                        <h3 class="mb-0 fw-bold text-dark" id="kpi-accuracy">
                            <span class="spinner-border spinner-border-sm text-success" role="status"></span>
                        </h3>
                    </div>
                    <div class="col-4 border-end text-center">
                        <p class="mb-2 text-muted fw-semibold"><i class="fa-solid fa-microscope text-warning me-2"></i>Scans</p>
                        <h3 class="mb-0 fw-bold text-dark" id="kpi-scans">
                            <span class="spinner-border spinner-border-sm text-warning" role="status"></span>
                        </h3>
                    </div>
                    <div class="col-4 text-center">
                        <p class="mb-2 text-muted fw-semibold"><i class="fa-solid fa-triangle-exclamation text-info me-2"></i>High Risk</p>
                        <h3 class="mb-0 fw-bold text-dark" id="kpi-high-risk">
                            <span class="spinner-border spinner-border-sm text-info" role="status"></span>
                        </h3>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Row 2: Main Charts (50/50 Split) -->
    <div class="row g-4 mb-4">
        <!-- Line Chart: Trends -->
        <div class="col-sm-12 col-xl-6">
            <div class="card bg-white border-0 shadow-sm rounded h-100">
                <div class="card-header bg-white border-0 d-flex justify-content-between align-items-center pt-4 px-4 pb-0">
                    <h6 class="fw-bold mb-0 text-dark">Diagnosis Trend (30 Days)</h6>
                </div>
                <div class="card-body p-4">
                    <div style="position: relative; height: 300px; width: 100%;">
                        <canvas id="trendChart"></canvas>
                        <div id="trendChart-empty" class="position-absolute top-50 start-50 translate-middle text-center text-muted d-none w-100">
                            <i class="fa-solid fa-chart-line fa-3x mb-3 text-light"></i>
                            <p class="fw-bold mb-0">No Data</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Bar Chart: Top Diseases -->
        <div class="col-sm-12 col-xl-6">
            <div class="card bg-white border-0 shadow-sm rounded h-100">
                <div class="card-header bg-white border-0 d-flex justify-content-between align-items-center pt-4 px-4 pb-0">
                    <h6 class="fw-bold mb-0 text-dark">Top Diseases (AI)</h6>
                </div>
                <div class="card-body p-4">
                    <div style="position: relative; height: 300px; width: 100%;">
                        <canvas id="diseaseChart"></canvas>
                        <div id="diseaseChart-empty" class="position-absolute top-50 start-50 translate-middle text-center text-muted d-none w-100">
                            <i class="fa-solid fa-chart-bar fa-3x mb-3 text-light"></i>
                            <p class="fw-bold mb-0">No Data</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Row 3: Merged AI Diagnosis Results Box -->
    <div class="row g-4 mb-4">
        <!-- AI Diagnosis Results Full Width -->
        <div class="col-12">
            <div class="card bg-white border-0 shadow-sm rounded h-100">
                <div class="card-header bg-white border-0 d-flex justify-content-between align-items-center pt-4 px-4 pb-0">
                    <h6 class="fw-bold mb-0 text-dark">AI Diagnosis Results Overview</h6>
                </div>
                <div class="card-body p-4">
                    <div class="table-responsive">
                        <table class="table table-custom text-start align-middle table-hover mb-0">
                            <thead>
                                <tr>
                                    <th scope="col">Date</th>
                                    <th scope="col">Patient Name</th>
                                    <th scope="col">Disease</th>
                                    <th scope="col">Risk Level</th>
                                    <th scope="col">Confidence</th>
                                </tr>
                            </thead>
                            <tbody id="recent-scans-tbody">
                                <tr>
                                    <td colspan="5" class="text-center py-4 text-muted">
                                        <div class="spinner-border text-primary" role="status"></div>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
    let trendChartInstance = null;
    let diseaseChartInstance = null;
    let riskChartInstance = null;

    const themePrimary = '#4361ee'; 
    const themeSecondary = '#20c997'; 
    const themeWarning = '#fd7e14'; 
    
    function renderDashboard(data) {
        // Update Time
        const now = new Date();
        document.getElementById('last-updated').textContent = now.toLocaleTimeString('vi-VN') + " " + now.toLocaleDateString('vi-VN');

        // KPIs
        document.getElementById('kpi-users').textContent = data.activePatients || 0;
        document.getElementById('kpi-accuracy').textContent = (data.avgConfidence || 0) + '%';
        document.getElementById('kpi-scans').textContent = data.totalScans || 0;
        document.getElementById('kpi-high-risk').textContent = (data.highRiskRatio || 0) + '%';

        const commonOptions = {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { display: false } }
        };

        // 1. Trend Chart
        let trendData = data.scansTrend || {};
        if (Object.keys(trendData).length === 0) {
            document.getElementById('trendChart').classList.add('d-none');
            document.getElementById('trendChart-empty').classList.remove('d-none');
        } else {
            document.getElementById('trendChart').classList.remove('d-none');
            document.getElementById('trendChart-empty').classList.add('d-none');
            
            const ctx = document.getElementById('trendChart').getContext('2d');
            const gradient = ctx.createLinearGradient(0, 0, 0, 300);
            gradient.addColorStop(0, 'rgba(67, 97, 238, 0.4)');
            gradient.addColorStop(1, 'rgba(67, 97, 238, 0.02)');

            if (trendChartInstance) trendChartInstance.destroy();
            trendChartInstance = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: Object.keys(trendData),
                    datasets: [{
                        label: 'Số ca quét',
                        data: Object.values(trendData),
                        borderColor: themePrimary,
                        backgroundColor: gradient,
                        borderWidth: 3,
                        pointBackgroundColor: '#fff',
                        pointBorderColor: themePrimary,
                        pointBorderWidth: 2,
                        pointRadius: 4,
                        pointHoverRadius: 6,
                        fill: true,
                        tension: 0.4
                    }]
                },
                options: {
                    ...commonOptions,
                    scales: {
                        y: { beginAtZero: true, grid: { color: 'rgba(0,0,0,0.04)' }, border: { display: false } },
                        x: { grid: { display: false }, border: { display: false } }
                    }
                }
            });
        }

        // 2. Disease Chart
        let diseaseData = data.topDiseases || {};
        if (Object.keys(diseaseData).length === 0) {
            document.getElementById('diseaseChart').classList.add('d-none');
            document.getElementById('diseaseChart-empty').classList.remove('d-none');
        } else {
            document.getElementById('diseaseChart').classList.remove('d-none');
            document.getElementById('diseaseChart-empty').classList.add('d-none');
            
            if (diseaseChartInstance) diseaseChartInstance.destroy();
            diseaseChartInstance = new Chart(document.getElementById('diseaseChart'), {
                type: 'bar',
                data: {
                    labels: Object.keys(diseaseData),
                    datasets: [{
                        label: 'Số ca mắc',
                        data: Object.values(diseaseData),
                        backgroundColor: themePrimary,
                        borderRadius: 6,
                        barPercentage: 0.5
                    }]
                },
                options: {
                    ...commonOptions,
                    scales: {
                        y: { beginAtZero: true, grid: { color: 'rgba(0,0,0,0.04)' }, border: { display: false } },
                        x: { grid: { display: false }, border: { display: false } }
                    }
                }
            });
        }

        // 3. Risk Chart logic removed because canvas does not exist in DOM

        // 4. Recent Scans Table
        const tbody = document.getElementById('recent-scans-tbody');
        tbody.innerHTML = '';
        if (!data.recentScans || data.recentScans.length === 0) {
            tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted">No Data</td></tr>';
        } else {
            data.recentScans.forEach(scan => {
                const tr = document.createElement('tr');
                
                // Risk Badge styling
                let riskBadgeClass = 'bg-secondary';
                let riskText = 'PENDING';
                if (scan.riskLevel === 'LOW') { riskBadgeClass = 'bg-success'; riskText = 'An toàn'; }
                else if (scan.riskLevel === 'MEDIUM') { riskBadgeClass = 'bg-warning'; riskText = 'Trung bình'; }
                else if (scan.riskLevel === 'HIGH') { riskBadgeClass = 'bg-danger'; riskText = 'Nguy cơ cao'; }

                tr.innerHTML = `
                    <td>\${scan.createdAt}</td>
                    <td class="fw-semibold text-dark">\${scan.patientName}</td>
                    <td>\${scan.diseaseName || '<span class="text-muted">Unknown</span>'}</td>
                    <td><span class="badge \${riskBadgeClass}">\${riskText}</span></td>
                    <td><span class="badge bg-primary-light px-2 py-1 rounded-pill">\${scan.confidenceScore}%</span></td>
                `;
                tbody.appendChild(tr);
            });
        }
    }

    function loadDashboardData() {
        const btnRefresh = document.getElementById('btn-refresh');
        const iconRefresh = btnRefresh.querySelector('i');
        
        btnRefresh.disabled = true;
        iconRefresh.classList.add('fa-spin');

        const rawContextPath = '${pageContext.request.contextPath}';
        const contextPath = rawContextPath.startsWith('$') ? '' : rawContextPath;
        const apiUrl = contextPath + '/admin/api/dashboard';

        fetch(apiUrl, {
            headers: { 'X-Requested-With': 'XMLHttpRequest' }
        })
        .then(response => {
            if (response.status === 401 || response.status === 403) {
                window.location.href = contextPath + "/auth/login";
                throw new Error("Unauthorized");
            }
            if (!response.ok) throw new Error("API not available");
            return response.json();
        })
        .then(data => {
            if(data.error) {
                if (data.error === "Session expired") {
                    window.location.href = contextPath + "/auth/login";
                }
                throw new Error(data.error);
            }
            renderDashboard(data);
        })
        .catch(error => {
            console.warn('API fetch failed:', error);
            // Optionally show toast or error UI
        })
        .finally(() => {
            btnRefresh.disabled = false;
            iconRefresh.classList.remove('fa-spin');
        });
    }

    function refreshDashboard() {
        loadDashboardData();
    }

    // Auto load on init
    loadDashboardData();
</script>

<jsp:include page="/WEB-INF/views/layout/admin-footer.jsp" />
