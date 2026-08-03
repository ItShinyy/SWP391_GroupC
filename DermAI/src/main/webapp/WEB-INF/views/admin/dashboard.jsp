<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/admin-header.jsp" />

<style>
    /* CSS Grid */
    .admin-grid {
        display: grid;
        grid-template-columns: repeat(12, 1fr);
        gap: 16px;
    }
    .col-span-3 { grid-column: span 12; }
    .col-span-4 { grid-column: span 12; }
    .col-span-8 { grid-column: span 12; }
    .col-span-12 { grid-column: span 12; }

    @media (min-width: 992px) {
        .col-span-3 { grid-column: span 3; }
        .col-span-4 { grid-column: span 4; }
        .col-span-8 { grid-column: span 8; }
    }
    
    /* Standardized Card */
    .admin-card {
        background: white;
        border: 0;
        border-radius: 12px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.04);
        padding: 16px;
        display: flex;
        flex-direction: column;
    }
    .admin-card-title {
        font-size: 14px;
        font-weight: 600;
        color: #64748B;
        margin-bottom: 16px;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    .kpi-card {
        min-height: 120px;
    }
    .chart-card {
        height: 320px;
    }
    
    /* Table Wrapper */
    .diagnosis-table-wrapper {
        max-height: 55vh;
        overflow-y: auto;
    }
    .diagnosis-table-wrapper thead th {
        position: sticky;
        top: 0;
        background: white;
        z-index: 10;
        box-shadow: 0 2px 4px rgba(0,0,0,0.04);
    }
    
    /* Unified Toolbar */
    .unified-toolbar {
        display: flex;
        gap: 16px;
        align-items: center;
        flex-wrap: wrap;
        margin-bottom: 16px;
    }

    /* Interactive Table Row */
    .cursor-pointer {
        cursor: pointer;
    }
</style>

<div class="container-fluid pt-4 px-4">
    <!-- Header -->
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h1 class="page-title mb-0">Bảng Điều Khiển</h1>
        <div class="small text-muted fw-semibold">
            <i class="fa-regular fa-clock me-1"></i> Dữ liệu cập nhật lúc: <span id="last-updated">--:--:--</span>
        </div>
    </div>

    <!-- Unified Toolbar -->
    <div class="unified-toolbar bg-white p-3 rounded shadow-sm d-flex align-items-center flex-wrap gap-3">
        <div class="input-group flex-nowrap" style="width: 250px;">
            <span class="input-group-text bg-light border-0"><i class="fa-solid fa-search text-muted"></i></span>
            <input type="text" id="filter-search" class="form-control border-0 bg-light" placeholder="Tìm kiếm...">
        </div>
        
        <input type="date" id="filter-start-date" class="form-control bg-light border-0" style="width: 140px;" title="Từ ngày">
        <span class="text-muted"><i class="fa-solid fa-arrow-right"></i></span>
        <input type="date" id="filter-end-date" class="form-control bg-light border-0" style="width: 140px;" title="Đến ngày">
        
        <select id="filter-risk" class="form-select bg-light border-0" style="width: 140px;">
            <option value="">Mọi Rủi ro</option>
            <option value="LOW">An toàn</option>
            <option value="MEDIUM">Trung bình</option>
            <option value="HIGH">Nguy cơ cao</option>
        </select>

        <div class="ms-auto d-flex gap-2">
            <button class="btn btn-light shadow-sm text-danger" onclick="clearFilters()" title="Xóa bộ lọc">
                <i class="fa-solid fa-filter-circle-xmark"></i>
            </button>
            <button id="btn-refresh" class="btn btn-light shadow-sm" onclick="forceRefresh()">
                <i class="fa-solid fa-rotate-right"></i> Làm mới
            </button>
            <a href="${pageContext.request.contextPath}/admin/export/csv" class="btn btn-custom shadow-sm" id="btn-export">
                <i class="fa-solid fa-download"></i> Xuất CSV
            </a>
        </div>
    </div>
    
    <!-- Error Alert Container -->
    <div id="dashboard-error-container" class="d-none alert alert-danger shadow-sm border-0 d-flex align-items-center" role="alert">
        <i class="fa-solid fa-triangle-exclamation me-3 fa-lg"></i>
        <div id="dashboard-error-text">Đã xảy ra lỗi khi tải dữ liệu.</div>
    </div>

    <div class="admin-grid mb-4">
        <!-- ROW 1: KPIs (4 cards, span 3) -->
        <div class="admin-card kpi-card col-span-3">
            <div class="admin-card-title">Bệnh nhân <i class="fa-solid fa-users text-primary"></i></div>
            <h3 class="fw-bold mb-0 text-dark mt-auto" id="kpi-users">--</h3>
        </div>
        <div class="admin-card kpi-card col-span-3">
            <div class="admin-card-title">Độ chính xác TB <i class="fa-solid fa-bullseye text-success"></i></div>
            <h3 class="fw-bold mb-0 text-dark mt-auto" id="kpi-accuracy">--</h3>
        </div>
        <div class="admin-card kpi-card col-span-3">
            <div class="admin-card-title">Lượt quét <i class="fa-solid fa-microscope text-warning"></i></div>
            <h3 class="fw-bold mb-0 text-dark mt-auto" id="kpi-scans">--</h3>
        </div>
        <div class="admin-card kpi-card col-span-3">
            <div class="admin-card-title">Nguy cơ cao <i class="fa-solid fa-triangle-exclamation text-danger"></i></div>
            <h3 class="fw-bold mb-0 text-dark mt-auto" id="kpi-high-risk">--</h3>
        </div>

        <!-- ROW 2: Charts (span 8, span 4) -->
        <div class="admin-card chart-card col-span-8">
            <div class="admin-card-title mb-0">Xu hướng chẩn đoán (30 ngày)</div>
            <div class="flex-grow-1 position-relative mt-2">
                <canvas id="trendChart"></canvas>
            </div>
        </div>
        <div class="admin-card chart-card col-span-4">
            <div class="admin-card-title mb-0">Các bệnh phổ biến (AI)</div>
            <div class="flex-grow-1 position-relative mt-2">
                <canvas id="diseaseChart"></canvas>
            </div>
        </div>

        <!-- ROW 3: Finance (span 3 x 4) — click any to go to /admin/invoices -->
        <a href="${pageContext.request.contextPath}/admin/invoices?status=UNPAID" class="admin-card col-span-3 text-decoration-none" style="cursor:pointer;">
            <div class="admin-card-title">Hóa đơn chưa thanh toán <i class="fa-solid fa-clock text-warning"></i></div>
            <h4 class="fw-bold mb-0 mt-auto text-warning" id="kpi-unpaid-invoices">—</h4>
            <small class="text-muted mt-1">Nhấn để xem danh sách</small>
        </a>
        <a href="${pageContext.request.contextPath}/admin/invoices?status=PAID" class="admin-card col-span-3 text-decoration-none" style="cursor:pointer;">
            <div class="admin-card-title">Hóa đơn đã thanh toán <i class="fa-solid fa-circle-check text-success"></i></div>
            <h4 class="fw-bold mb-0 mt-auto text-success" id="kpi-paid-invoices">—</h4>
            <small class="text-muted mt-1">Nhấn để xem danh sách</small>
        </a>
        <a href="${pageContext.request.contextPath}/admin/invoices?status=PAID" class="admin-card col-span-3 text-decoration-none" style="cursor:pointer;">
            <div class="admin-card-title">Doanh thu thực tế <i class="fa-solid fa-coins text-primary"></i></div>
            <h4 class="fw-bold mb-0 mt-auto text-primary" id="kpi-collected-revenue">—</h4>
            <small class="text-muted mt-1">Tổng hóa đơn đã thu</small>
        </a>
        <a href="${pageContext.request.contextPath}/admin/invoices?status=UNPAID" class="admin-card col-span-3 text-decoration-none" style="cursor:pointer;">
            <div class="admin-card-title">Doanh thu dự kiến <i class="fa-solid fa-hourglass-half text-danger"></i></div>
            <h4 class="fw-bold mb-0 mt-auto text-danger" id="kpi-outstanding-revenue">—</h4>
            <small class="text-muted mt-1">Tổng hóa đơn chưa thu</small>
        </a>

        <!-- ROW 4: AI Diagnosis Table (span 12) -->
        <div class="admin-card col-span-12 p-0 position-relative">
            <div class="admin-card-title p-3 mb-0 border-bottom d-flex justify-content-between align-items-center">
                <span>Kết quả chẩn đoán AI</span>
                <span class="badge bg-light text-dark border" id="table-record-count">0 bản ghi</span>
            </div>
            <div class="diagnosis-table-wrapper">
                <table class="table table-custom text-start align-middle table-hover mb-0">
                    <thead>
                        <tr>
                            <th scope="col" tabindex="0">Ngày</th>
                            <th scope="col" tabindex="0">Tên Bệnh Nhân</th>
                            <th scope="col" tabindex="0">Bệnh</th>
                            <th scope="col" tabindex="0">Mức Độ Rủi Ro</th>
                            <th scope="col" tabindex="0">Độ Tin Cậy</th>
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
            
            <!-- Pagination Wrapper -->
            <jsp:include page="/WEB-INF/views/admin/common/_pagination.jsp" />
        </div>
    </div>
</div>

<!-- Drawer / Offcanvas -->
<div class="offcanvas offcanvas-end" tabindex="-1" id="scanDetailDrawer" style="width: 400px;">
    <div class="offcanvas-header border-bottom p-3">
        <h5 class="offcanvas-title fw-bold text-dark">Chi tiết chẩn đoán</h5>
        <button type="button" class="btn-close" data-bs-dismiss="offcanvas" aria-label="Close"></button>
    </div>
    <div class="offcanvas-body p-3">
        <div class="text-center mb-4">
            <div class="bg-light rounded d-flex align-items-center justify-content-center" style="height: 200px;">
                <i class="fa-solid fa-image text-muted fa-3x"></i>
            </div>
        </div>
        <div class="mb-3">
            <small class="text-muted d-block fw-semibold mb-1">Bệnh Nhân</small>
            <h6 id="drawer-patient" class="fw-bold text-dark">--</h6>
        </div>
        <div class="mb-3">
            <small class="text-muted d-block fw-semibold mb-1">Chẩn Đoán Bệnh</small>
            <h6 id="drawer-disease" class="fw-bold text-dark">--</h6>
        </div>
        <div class="row mb-3">
            <div class="col-6">
                <small class="text-muted d-block fw-semibold mb-1">Độ Tin Cậy</small>
                <h6 id="drawer-confidence" class="fw-bold text-dark">--</h6>
            </div>
            <div class="col-6">
                <small class="text-muted d-block fw-semibold mb-1">Mức Độ Rủi Ro</small>
                <span id="drawer-risk" class="badge">--</span>
            </div>
        </div>
        <div class="mb-3">
            <small class="text-muted d-block fw-semibold mb-1">Ngày quét</small>
            <h6 id="drawer-date" class="text-dark small">--</h6>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
    let trendChartInstance = null;
    let diseaseChartInstance = null;

    const themePrimary = '#4361ee'; 
    const themeSecondary = '#20c997'; 
    const themeWarning = '#fd7e14'; 
    
    let currentScans = [];
    let searchTimeout = null;

    function formatVnd(amount) {
        if (!amount) return '0 ₫';
        return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND', maximumFractionDigits: 0 }).format(amount);
    }

    // 1. Shared Dashboard State
    let dashboardState = {
        search: '',
        startDate: '',
        endDate: '',
        risk: ''
    };

    function initFilters() {
        try {
            const saved = localStorage.getItem('dashboardFilters');
            if (saved) {
                dashboardState = JSON.parse(saved);
                document.getElementById('filter-search').value = dashboardState.search || '';
                document.getElementById('filter-start-date').value = dashboardState.startDate || '';
                document.getElementById('filter-end-date').value = dashboardState.endDate || '';
                document.getElementById('filter-risk').value = dashboardState.risk || '';
            }
        } catch(e) { console.warn("Failed to load filters", e); }

        // Bind events
        document.getElementById('filter-search').addEventListener('input', (e) => {
            dashboardState.search = e.target.value;
            debounceRefresh();
        });
        document.getElementById('filter-start-date').addEventListener('change', (e) => {
            dashboardState.startDate = e.target.value;
            forceRefresh();
        });
        document.getElementById('filter-end-date').addEventListener('change', (e) => {
            dashboardState.endDate = e.target.value;
            forceRefresh();
        });
        document.getElementById('filter-risk').addEventListener('change', (e) => {
            dashboardState.risk = e.target.value;
            forceRefresh();
        });
    }

    function saveFilters() {
        localStorage.setItem('dashboardFilters', JSON.stringify(dashboardState));
    }

    function clearFilters() {
        dashboardState = { search: '', startDate: '', endDate: '', risk: '' };
        document.getElementById('filter-search').value = '';
        document.getElementById('filter-start-date').value = '';
        document.getElementById('filter-end-date').value = '';
        document.getElementById('filter-risk').value = '';
        forceRefresh();
    }

    function debounceRefresh() {
        clearTimeout(searchTimeout);
        searchTimeout = setTimeout(() => {
            forceRefresh();
        }, 500);
    }

    function forceRefresh() {
        saveFilters();
        loadDashboardData(true);
    }
    
    function renderDashboard(data) {
        document.getElementById('dashboard-error-container').classList.add('d-none');

        const now = new Date();
        document.getElementById('last-updated').textContent = now.toLocaleTimeString('vi-VN') + " " + now.toLocaleDateString('vi-VN');

        document.getElementById('kpi-users').textContent = data.activePatients || 0;
        document.getElementById('kpi-accuracy').textContent = (data.avgConfidence || 0) + '%';
        document.getElementById('kpi-scans').textContent = data.totalScans || 0;
        document.getElementById('kpi-high-risk').textContent = (data.highRiskRatio || 0) + '%';
        document.getElementById('kpi-unpaid-invoices').textContent = data.unpaidInvoices || 0;
        document.getElementById('kpi-paid-invoices').textContent = data.paidInvoices || 0;
        document.getElementById('kpi-collected-revenue').textContent = formatVnd(data.collectedRevenue || 0);
        document.getElementById('kpi-outstanding-revenue').textContent = formatVnd(data.outstandingRevenue || 0);
        
        document.getElementById('table-record-count').textContent = data.totalScans + " bản ghi";

        const commonOptions = {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            interaction: { mode: 'index', intersect: false }
        };

        // 1. Trend Chart
        let trendData = data.scansTrend || {};
        const trendLabels = Object.keys(trendData);
        const trendValues = Object.values(trendData);
        
        if (trendChartInstance) {
            trendChartInstance.data.labels = trendLabels;
            trendChartInstance.data.datasets[0].data = trendValues;
            trendChartInstance.update();
        } else {
            const ctx = document.getElementById('trendChart').getContext('2d');
            const gradient = ctx.createLinearGradient(0, 0, 0, 300);
            gradient.addColorStop(0, 'rgba(67, 97, 238, 0.4)');
            gradient.addColorStop(1, 'rgba(67, 97, 238, 0.02)');
            
            trendChartInstance = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: trendLabels,
                    datasets: [{
                        label: 'Số ca quét',
                        data: trendValues,
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
                    },
                    onClick: (evt, activeElements) => {
                        if (activeElements.length > 0) {
                            const idx = activeElements[0].index;
                            const clickedDate = trendLabels[idx];
                            dashboardState.startDate = clickedDate;
                            dashboardState.endDate = clickedDate;
                            document.getElementById('filter-start-date').value = clickedDate;
                            document.getElementById('filter-end-date').value = clickedDate;
                            forceRefresh();
                        }
                    }
                }
            });
        }

        // 2. Disease Chart
        let diseaseData = data.topDiseases || {};
        let keys = Object.keys(diseaseData);
        let values = Object.values(diseaseData);
        
        let displayLabels = [];
        let displayData = [];
        
        if (keys.length > 5) {
            displayLabels = keys.slice(0, 5);
            displayData = values.slice(0, 5);
            let othersSum = values.slice(5).reduce((a, b) => a + b, 0);
            if (othersSum > 0) {
                displayLabels.push("Others");
                displayData.push(othersSum);
            }
        } else {
            displayLabels = keys;
            displayData = values;
        }

        if (diseaseChartInstance) {
            diseaseChartInstance.data.labels = displayLabels;
            diseaseChartInstance.data.datasets[0].data = displayData;
            diseaseChartInstance.update();
        } else {
            diseaseChartInstance = new Chart(document.getElementById('diseaseChart'), {
                type: 'bar',
                data: {
                    labels: displayLabels,
                    datasets: [{
                        label: 'Số ca mắc',
                        data: displayData,
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
                    },
                    onClick: (evt, activeElements) => {
                        if (activeElements.length > 0) {
                            const idx = activeElements[0].index;
                            const label = displayLabels[idx];
                            if (label !== 'Others') {
                                dashboardState.search = label;
                                document.getElementById('filter-search').value = label;
                                forceRefresh();
                            }
                        }
                    }
                }
            });
        }

        currentScans = data.recentScans || [];
        renderTableRows(currentScans);
    }
    
    function renderTableRows(scans) {
        const tbody = document.getElementById('recent-scans-tbody');
        tbody.innerHTML = '';
        if (scans.length === 0) {
            tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted py-4">Không tìm thấy dữ liệu phù hợp với bộ lọc</td></tr>';
        } else {
            scans.forEach((scan, index) => {
                const tr = document.createElement('tr');
                tr.className = 'cursor-pointer';
                tr.tabIndex = 0;
                tr.onclick = () => openDrawer(index);
                tr.onkeydown = (e) => { if (e.key === 'Enter') openDrawer(index); };
                
                let riskBadgeClass = 'bg-secondary';
                let riskText = 'Đang chờ';
                if (scan.riskLevel === 'LOW') { riskBadgeClass = 'bg-success'; riskText = 'An toàn'; }
                else if (scan.riskLevel === 'MEDIUM') { riskBadgeClass = 'bg-warning'; riskText = 'Trung bình'; }
                else if (scan.riskLevel === 'HIGH') { riskBadgeClass = 'bg-danger'; riskText = 'Nguy cơ cao'; }

                tr.innerHTML = `
                    <td>${scan.createdAt}</td>
                    <td class="fw-semibold text-dark">${scan.patientName}</td>
                    <td>${scan.diseaseName || '<span class="text-muted">Không xác định</span>'}</td>
                    <td><span class="badge ${riskBadgeClass}">${riskText}</span></td>
                    <td><span class="badge bg-primary-light px-2 py-1 rounded-pill">${scan.confidenceScore}%</span></td>
                `;
                tbody.appendChild(tr);
            });
        }
    }

    function openDrawer(index) {
        const scan = currentScans[index];
        if (!scan) return;
        
        document.getElementById('drawer-patient').textContent = scan.patientName;
        document.getElementById('drawer-disease').textContent = scan.diseaseName || 'Không xác định';
        document.getElementById('drawer-confidence').textContent = scan.confidenceScore + '%';
        document.getElementById('drawer-date').textContent = scan.createdAt;
        
        const riskEl = document.getElementById('drawer-risk');
        if (scan.riskLevel === 'LOW') { riskEl.className = 'badge bg-success'; riskEl.textContent = 'An toàn'; }
        else if (scan.riskLevel === 'MEDIUM') { riskEl.className = 'badge bg-warning'; riskEl.textContent = 'Trung bình'; }
        else if (scan.riskLevel === 'HIGH') { riskEl.className = 'badge bg-danger'; riskEl.textContent = 'Nguy cơ cao'; }
        else { riskEl.className = 'badge bg-secondary'; riskEl.textContent = 'Đang chờ'; }
        
        const drawerEl = document.getElementById('scanDetailDrawer');
        const bsOffcanvas = new bootstrap.Offcanvas(drawerEl);
        bsOffcanvas.show();
    }

    function loadDashboardData(showLoading = false) {
        const btnRefresh = document.getElementById('btn-refresh');
        const iconRefresh = btnRefresh.querySelector('i');
        
        btnRefresh.disabled = true;
        iconRefresh.classList.add('fa-spin');
        
        if (showLoading) {
            document.getElementById('recent-scans-tbody').innerHTML = '<tr><td colspan="5" class="text-center py-4"><div class="spinner-border text-primary" role="status"></div></td></tr>';
        }

        const rawContextPath = '${pageContext.request.contextPath}';
        const contextPath = rawContextPath.startsWith('$') ? '' : rawContextPath;
        
        const urlParams = new URLSearchParams(window.location.search);
        const page = urlParams.get('page') || 1;
        const size = urlParams.get('size') || 10;
        
        const apiParams = new URLSearchParams();
        apiParams.append('page', page);
        apiParams.append('size', size);
        if (dashboardState.search) apiParams.append('search', dashboardState.search);
        if (dashboardState.startDate) apiParams.append('startDate', dashboardState.startDate);
        if (dashboardState.endDate) apiParams.append('endDate', dashboardState.endDate);
        if (dashboardState.risk) apiParams.append('risk', dashboardState.risk);

        const apiUrl = contextPath + '/admin/api/dashboard?' + apiParams.toString();

        fetch(apiUrl, { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
        .then(response => {
            if (response.status === 401 || response.status === 403) {
                window.location.href = contextPath + "/auth/login";
                throw new Error("Unauthorized");
            }
            if (!response.ok) throw new Error("Lỗi máy chủ (" + response.status + ")");
            return response.json();
        })
        .then(data => {
            if(data.error) {
                if (data.error === "Session expired") window.location.href = contextPath + "/auth/login";
                throw new Error(data.error);
            }
            renderDashboard(data);
        })
        .catch(error => {
            console.warn('API fetch failed:', error);
            const errBox = document.getElementById('dashboard-error-container');
            document.getElementById('dashboard-error-text').textContent = "Không thể tải dữ liệu: " + error.message;
            errBox.classList.remove('d-none');
            document.getElementById('recent-scans-tbody').innerHTML = '<tr><td colspan="5" class="text-center text-danger py-4">Lỗi kết nối máy chủ</td></tr>';
        })
        .finally(() => {
            btnRefresh.disabled = false;
            iconRefresh.classList.remove('fa-spin');
        });
    }

    document.addEventListener('DOMContentLoaded', () => {
        initFilters();
        loadDashboardData(true);
    });
</script>

<jsp:include page="/WEB-INF/views/layout/admin-footer.jsp" />

