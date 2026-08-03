package com.dermathologyai.controller.admin;

import com.dermathologyai.dao.DiagnosisReportDAO;
import com.dermathologyai.dao.UserDAO;
import com.dermathologyai.model.DiagnosisReport;
import com.dermathologyai.service.BillingService;
import com.dermathologyai.util.FormatUtil;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class DashboardApiController extends HttpServlet {
    private UserDAO userDAO;
    private DiagnosisReportDAO reportDAO;
    private BillingService billingService;
    private static final Gson GSON = new Gson();

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        reportDAO = new DiagnosisReportDAO();
        billingService = new BillingService();
    }

    private static class RecentScanDTO {
        String id;
        String patientName;
        String diseaseName;
        String riskLevel;
        long confidenceScore;
        String createdAt;

        public RecentScanDTO(DiagnosisReport dr) {
            this.id = dr.getId();
            this.patientName = dr.getPatientName();
            this.diseaseName = dr.getDiseaseName();
            this.riskLevel = dr.getRiskLevel();
            this.confidenceScore = FormatUtil.confidencePercentRounded(dr.getConfidenceScore());
            this.createdAt = dr.getCreatedAt() != null ? dr.getCreatedAt().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")) : "";
        }
    }

    private static class DashboardDataDTO {
        int activePatients;
        int totalScans;
        long avgConfidence;
        long highRiskRatio;
        Map<String, Integer> topDiseases;
        Map<String, Integer> scansTrend;
        List<RecentScanDTO> recentScans;
        int unpaidInvoices;
        int paidInvoices;
        long collectedRevenue;    // PAID invoices total (VND)
        long outstandingRevenue;  // UNPAID invoices total (VND)
        String error;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        String pageStr = req.getParameter("page");
        String sizeStr = req.getParameter("size");
        
        String search = req.getParameter("search");
        String startDate = req.getParameter("startDate");
        String endDate = req.getParameter("endDate");
        String doctorId = req.getParameter("doctorId");
        String diseaseId = req.getParameter("diseaseId");
        String risk = req.getParameter("risk");
        
        int page = 1;
        int size = 10;
        
        if (pageStr != null && !pageStr.isEmpty()) {
            try { page = Integer.parseInt(pageStr); } catch (NumberFormatException ignored) {}
        }
        if (sizeStr != null && !sizeStr.isEmpty()) {
            try { size = Integer.parseInt(sizeStr); } catch (NumberFormatException ignored) {}
        }

        DiagnosisReportDAO.ReportFilter filter = new DiagnosisReportDAO.ReportFilter();
        filter.search = search;
        filter.startDate = startDate;
        filter.endDate = endDate;
        filter.doctorId = doctorId;
        filter.diseaseId = diseaseId;
        filter.riskLevel = risk;

        DashboardDataDTO data = new DashboardDataDTO();

        try {
            data.activePatients = userDAO.countActivePatients();
            data.totalScans = reportDAO.countAll(filter);
            data.avgConfidence = FormatUtil.confidencePercentRounded(reportDAO.getAverageConfidenceScore(filter));

            Map<String, Integer> riskLevels = reportDAO.getRiskLevelDistribution(filter);
            int highRiskScans = riskLevels.getOrDefault("HIGH", 0);
            data.highRiskRatio = data.totalScans > 0 ? Math.round((highRiskScans * 100.0) / data.totalScans) : 0;

            data.topDiseases = reportDAO.getTopDiseases(5, filter);
            data.scansTrend = reportDAO.getScansTrend(filter);

            List<DiagnosisReport> recentList = reportDAO.findAll(filter, null, page, size);
            data.recentScans = new ArrayList<>();
            for (DiagnosisReport dr : recentList) {
                data.recentScans.add(new RecentScanDTO(dr));
            }

            data.unpaidInvoices = billingService.countInvoicesByStatus("UNPAID");
            data.paidInvoices = billingService.countInvoicesByStatus("PAID");
            data.collectedRevenue = billingService.sumCollectedRevenue().longValue();
            data.outstandingRevenue = billingService.sumOutstandingRevenue().longValue();
        } catch (Exception e) {
            e.printStackTrace();
            data = new DashboardDataDTO();
            data.error = "Failed to fetch dashboard data";
        }

        try (PrintWriter out = resp.getWriter()) {
            out.print(GSON.toJson(data));
            out.flush();
        }
    }
}
