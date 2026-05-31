package com.skinai.controller.admin;

import com.skinai.dal.ClinicDAO;
import com.skinai.dal.DiagnosisReportDAO;
import com.skinai.dal.UserDAO;
import com.skinai.model.DiagnosisReport;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

public class DashboardDataController extends HttpServlet {
    private UserDAO userDAO;
    private ClinicDAO clinicDAO;
    private DiagnosisReportDAO reportDAO;
    public void init() throws ServletException {
        userDAO = new UserDAO();
        clinicDAO = new ClinicDAO();
        reportDAO = new DiagnosisReportDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        StringBuilder json = new StringBuilder("{");

        try {
            // KPI Cards
            int activePatients = userDAO.countActivePatients();
            int totalScans = reportDAO.countAll();
            
            json.append("\"activePatients\":").append(activePatients).append(",");
            json.append("\"totalScans\":").append(totalScans).append(",");
            json.append("\"totalClinics\":").append(clinicDAO.countAll()).append(",");
            
            double avgConf = reportDAO.getAverageConfidenceScore();
            json.append("\"avgConfidence\":").append(Math.round(avgConf)).append(",");

            // Risk Data
            Map<String, Integer> riskData = reportDAO.getRiskLevelDistribution();
            json.append("\"riskLevelDistribution\":").append(mapToJsonString(riskData)).append(",");
            
            // Calculate High Risk Ratio
            int highRiskScans = riskData.getOrDefault("HIGH", 0);
            double highRiskRatio = 0;
            if (totalScans > 0) {
                highRiskRatio = (highRiskScans * 100.0) / totalScans;
            }
            json.append("\"highRiskRatio\":").append(Math.round(highRiskRatio)).append(",");

            // Charts Data
            json.append("\"topDiseases\":").append(mapToJsonString(reportDAO.getTopDiseases(5))).append(",");
            json.append("\"scansTrend\":").append(mapToJsonString(reportDAO.getScansTrend())).append(",");

            // Recent Scans Table
            List<DiagnosisReport> recentList = reportDAO.findAll(1, 5);
            DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
            
            json.append("\"recentScans\":[");
            for (int i = 0; i < recentList.size(); i++) {
                DiagnosisReport dr = recentList.get(i);
                json.append("{");
                json.append("\"id\":\"").append(escapeJson(dr.getId())).append("\",");
                json.append("\"patientName\":\"").append(escapeJson(dr.getPatientName())).append("\",");
                json.append("\"diseaseName\":\"").append(escapeJson(dr.getDiseaseName())).append("\",");
                json.append("\"riskLevel\":\"").append(escapeJson(dr.getRiskLevel())).append("\",");
                json.append("\"confidenceScore\":").append(Math.round(dr.getConfidenceScore())).append(",");
                
                String createdAt = dr.getCreatedAt() != null ? dr.getCreatedAt().format(dtf) : "";
                json.append("\"createdAt\":\"").append(createdAt).append("\"");
                json.append("}");
                if (i < recentList.size() - 1) {
                    json.append(",");
                }
            }
            json.append("]");

        } catch (Exception e) {
            e.printStackTrace();
            json = new StringBuilder("{\"error\":\"Failed to fetch dashboard data\"");
        }

        json.append("}");

        try (PrintWriter out = resp.getWriter()) {
            out.print(json.toString());
            out.flush();
        }
    }

    private String mapToJsonString(Map<String, Integer> map) {
        StringBuilder sb = new StringBuilder("{");
        boolean first = true;
        for (Map.Entry<String, Integer> entry : map.entrySet()) {
            if (!first) sb.append(",");
            sb.append("\"").append(escapeJson(entry.getKey())).append("\":").append(entry.getValue());
            first = false;
        }
        sb.append("}");
        return sb.toString();
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}
