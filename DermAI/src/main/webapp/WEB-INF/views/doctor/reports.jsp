<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/layout/doctor-header.jsp" />

<div class="container-fluid py-4 px-4">
    <!-- Page Title & Time -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h4 class="fw-bold mb-1">
                <i class="fa-solid fa-chart-line me-2 text-primary"></i>Báo Cáo Năng Suất Cá Nhân
            </h4>
            <p class="text-muted small mb-0">Thống kê và đánh giá kết quả điều trị chuyên môn lâm sàng của riêng Bác sĩ.</p>
        </div>
        <span class="text-muted small fw-semibold" id="last-updated">Cập nhật: --:--:--</span>
    </div>

    <!-- KPIs Row -->
    <div class="row g-4 mb-4">
        <!-- KPI 1 -->
        <div class="col-md-3">
            <div class="card border-0 shadow-sm rounded-4 p-3 bg-white">
                <div class="d-flex align-items-center justify-content-between">
                    <div>
                        <span class="text-muted small fw-bold text-uppercase" style="letter-spacing: 0.5px;">Bệnh nhân đã trị</span>
                        <h3 class="fw-bold text-dark mt-2 mb-0" id="kpi-patients">-</h3>
                    </div>
                    <div class="rounded-circle bg-primary bg-opacity-10 d-flex align-items-center justify-content-center text-primary" style="width: 48px; height: 48px;">
                        <i class="fa-solid fa-user-group fs-5"></i>
                    </div>
                </div>
            </div>
        </div>
        <!-- KPI 2 -->
        <div class="col-md-3">
            <div class="card border-0 shadow-sm rounded-4 p-3 bg-white">
                <div class="d-flex align-items-center justify-content-between">
                    <div>
                        <span class="text-muted small fw-bold text-uppercase" style="letter-spacing: 0.5px;">Tổng ca hoàn thành</span>
                        <h3 class="fw-bold text-dark mt-2 mb-0" id="kpi-completed">-</h3>
                    </div>
                    <div class="rounded-circle bg-success bg-opacity-10 d-flex align-items-center justify-content-center text-success" style="width: 48px; height: 48px;">
                        <i class="fa-solid fa-circle-check fs-5"></i>
                    </div>
                </div>
            </div>
        </div>
        <!-- KPI 3 -->
        <div class="col-md-3">
            <div class="card border-0 shadow-sm rounded-4 p-3 bg-white">
                <div class="d-flex align-items-center justify-content-between">
                    <div>
                        <span class="text-muted small fw-bold text-uppercase" style="letter-spacing: 0.5px;">Độ chính xác chẩn đoán AI</span>
                        <h3 class="fw-bold text-dark mt-2 mb-0" id="kpi-accuracy">-</h3>
                    </div>
                    <div class="rounded-circle bg-info bg-opacity-10 d-flex align-items-center justify-content-center text-info" style="width: 48px; height: 48px;">
                        <i class="fa-solid fa-brain fs-5"></i>
                    </div>
                </div>
            </div>
        </div>
        <!-- KPI 4 -->
        <div class="col-md-3">
            <div class="card border-0 shadow-sm rounded-4 p-3 bg-white">
                <div class="d-flex align-items-center justify-content-between">
                    <div>
                        <span class="text-muted small fw-bold text-uppercase" style="letter-spacing: 0.5px;">Tỷ lệ ca rủi ro cao</span>
                        <h3 class="fw-bold text-dark mt-2 mb-0" id="kpi-high-risk">-</h3>
                    </div>
                    <div class="rounded-circle bg-danger bg-opacity-10 d-flex align-items-center justify-content-center text-danger" style="width: 48px; height: 48px;">
                        <i class="fa-solid fa-triangle-exclamation fs-5"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Charts Section -->
    <div class="row g-4">
        <!-- 1. Appointments Trend Chart -->
        <div class="col-lg-8">
            <div class="card border-0 shadow-sm rounded-4 p-4 h-100 bg-white">
                <h5 class="fw-bold text-dark mb-4">
                    <i class="fa-solid fa-chart-line me-2 text-primary"></i>Xu hướng ca khám hoàn thành
                </h5>
                <div style="height: 300px; position: relative;">
                    <canvas id="trendChart"></canvas>
                    <div id="trendChart-empty" class="d-none text-center py-5 text-muted">
                        <i class="fa-regular fa-chart-bar fs-1 mb-3"></i>
                        <p class="mb-0">Chưa có dữ liệu thống kê tuần này.</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- 2. Risk Distribution Chart -->
        <div class="col-lg-4">
            <div class="card border-0 shadow-sm rounded-4 p-4 h-100 bg-white">
                <h5 class="fw-bold text-dark mb-4">
                    <i class="fa-solid fa-shield-halved me-2 text-primary"></i>Phân bố mức độ rủi ro
                </h5>
                <div style="height: 300px; position: relative;" class="d-flex align-items-center justify-content-center">
                    <canvas id="riskChart"></canvas>
                    <div id="riskChart-empty" class="d-none text-center py-5 text-muted">
                        <i class="fa-regular fa-chart-bar fs-1 mb-3"></i>
                        <p class="mb-0">Chưa có dữ liệu.</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- 3. Top Diseases diagnosed -->
        <div class="col-lg-12">
            <div class="card border-0 shadow-sm rounded-4 p-4 bg-white">
                <h5 class="fw-bold text-dark mb-4">
                    <i class="fa-solid fa-notes-medical me-2 text-primary"></i>Cơ cấu mặt bệnh chẩn đoán hàng đầu
                </h5>
                <div class="row align-items-center g-4">
                    <div class="col-md-6 d-flex align-items-center justify-content-center" style="height: 280px; position: relative;">
                        <canvas id="diseaseChart"></canvas>
                        <div id="diseaseChart-empty" class="d-none text-center py-5 text-muted">
                            <i class="fa-regular fa-chart-bar fs-1 mb-3"></i>
                            <p class="mb-0">Chưa có dữ liệu thống kê mặt bệnh.</p>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="table-responsive">
                            <table class="table table-borderless align-middle mb-0">
                                <thead>
                                    <tr class="border-bottom">
                                        <th style="color: #64748b; font-weight: 700; font-size: 0.8rem;">Mặt Bệnh</th>
                                        <th style="color: #64748b; font-weight: 700; font-size: 0.8rem; text-align: center;">Số ca đã chẩn đoán</th>
                                    </tr>
                                </thead>
                                <tbody id="top-diseases-list">
                                    <tr>
                                        <td colspan="2" class="text-center text-muted py-4 small">Đang tải dữ liệu...</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
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

    const themePrimary = '#1e3a8a'; 
    const themeSecondary = '#3b82f6'; 
    const themeWarning = '#fd7e14'; 
    const themeDanger = '#dc2626';

    function loadReportsData() {
        fetch('${pageContext.request.contextPath}/doctor/api/reports-data')
            .then(res => res.json())
            .then(data => {
                if (data.error) {
                    console.error(data.error);
                    return;
                }
                renderReports(data);
            })
            .catch(err => {
                console.error("Lỗi khi tải báo cáo:", err);
            });
    }

    function renderReports(data) {
        // Update Time
        const now = new Date();
        document.getElementById('last-updated').textContent = "Cập nhật: " + now.toLocaleTimeString('vi-VN') + " " + now.toLocaleDateString('vi-VN');

        // KPIs
        document.getElementById('kpi-patients').textContent = data.totalPatients || 0;
        document.getElementById('kpi-completed').textContent = data.totalCompleted || 0;
        document.getElementById('kpi-accuracy').textContent = (data.avgConfidence || 0) + '%';
        document.getElementById('kpi-high-risk').textContent = (data.highRiskRatio || 0) + '%';

        const commonOptions = {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { display: false } }
        };

        // 1. Line Chart: Appointments Trend
        let trendData = data.appointmentsTrend || {};
        if (Object.keys(trendData).length === 0) {
            document.getElementById('trendChart').classList.add('d-none');
            document.getElementById('trendChart-empty').classList.remove('d-none');
        } else {
            document.getElementById('trendChart').classList.remove('d-none');
            document.getElementById('trendChart-empty').classList.add('d-none');
            
            const ctx = document.getElementById('trendChart').getContext('2d');
            const gradient = ctx.createLinearGradient(0, 0, 0, 300);
            gradient.addColorStop(0, 'rgba(30, 58, 138, 0.4)');
            gradient.addColorStop(1, 'rgba(30, 58, 138, 0.02)');

            if (trendChartInstance) trendChartInstance.destroy();
            trendChartInstance = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: Object.keys(trendData).map(k => k.substring(5)), // Format to MM/DD
                    datasets: [{
                        label: 'Số ca khám hoàn thành',
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

        // 2. Doughnut Chart: Risk Level
        let riskData = data.riskLevelDistribution || {};
        let riskLabels = Object.keys(riskData);
        let riskValues = Object.values(riskData);
        if (riskValues.length === 0) {
            document.getElementById('riskChart').classList.add('d-none');
            document.getElementById('riskChart-empty').classList.remove('d-none');
        } else {
            document.getElementById('riskChart').classList.remove('d-none');
            document.getElementById('riskChart-empty').classList.add('d-none');
            
            const ctx = document.getElementById('riskChart').getContext('2d');
            if (riskChartInstance) riskChartInstance.destroy();
            riskChartInstance = new Chart(ctx, {
                type: 'doughnut',
                data: {
                    labels: riskLabels.map(l => l === 'HIGH' ? 'Cao' : (l === 'MEDIUM' ? 'Trung bình' : 'Thấp')),
                    datasets: [{
                        data: riskValues,
                        backgroundColor: [themeDanger, themeWarning, themeSecondary, '#cbd5e1'],
                        borderWidth: 2,
                        borderColor: '#fff'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { display: true, position: 'bottom', labels: { boxWidth: 12, padding: 15, font: { family: 'Rethink Sans', size: 11 } } }
                    },
                    cutout: '65%'
                }
            });
        }

        // 3. Pie Chart & Table: Top Diseases
        let diseaseData = data.topDiseases || {};
        let diseaseLabels = Object.keys(diseaseData);
        let diseaseValues = Object.values(diseaseData);
        if (diseaseValues.length === 0) {
            document.getElementById('diseaseChart').classList.add('d-none');
            document.getElementById('diseaseChart-empty').classList.remove('d-none');
            document.getElementById('top-diseases-list').innerHTML = `<tr><td colspan="2" class="text-center py-4 text-muted small">Chưa có dữ liệu</td></tr>`;
        } else {
            document.getElementById('diseaseChart').classList.remove('d-none');
            document.getElementById('diseaseChart-empty').classList.add('d-none');

            // Render Chart
            const ctx = document.getElementById('diseaseChart').getContext('2d');
            if (diseaseChartInstance) diseaseChartInstance.destroy();
            diseaseChartInstance = new Chart(ctx, {
                type: 'pie',
                data: {
                    labels: diseaseLabels,
                    datasets: [{
                        data: diseaseValues,
                        backgroundColor: [themePrimary, themeSecondary, themeWarning, themeDanger, '#8b5cf6'],
                        borderWidth: 2,
                        borderColor: '#fff'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { display: true, position: 'right', labels: { boxWidth: 12, font: { family: 'Rethink Sans', size: 11 } } }
                    }
                }
            });

            // Render Table
            let tbodyHtml = '';
            diseaseLabels.forEach((lbl, idx) => {
                let color = ['#1e3a8a', '#3b82f6', '#fd7e14', '#dc2626', '#8b5cf6'][idx % 5];
                tbodyHtml += '<tr class="border-bottom">' +
                             '<td>' +
                             '<div class="d-flex align-items-center gap-2">' +
                             '<span class="d-inline-block rounded-circle" style="width: 10px; height: 10px; background-color: ' + color + ';"></span>' +
                             '<span class="fw-semibold small text-dark">' + lbl + '</span>' +
                             '</div>' +
                             '</td>' +
                             '<td class="text-center fw-bold text-secondary small">' + diseaseValues[idx] + ' ca</td>' +
                             '</tr>';
            });
            document.getElementById('top-diseases-list').innerHTML = tbodyHtml;
        }
    }

    // Load reports when page loads
    window.addEventListener('DOMContentLoaded', loadReportsData);
</script>

<jsp:include page="/WEB-INF/views/layout/doctor-footer.jsp" />
