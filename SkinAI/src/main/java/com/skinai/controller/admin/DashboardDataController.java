package com.skinai.controller.admin;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class DashboardDataController extends HttpServlet {
    private UserDAO userDAO;
    private ClinicDAO clinicDAO;
    private DiagnosisReportDAO reportDAO;
    private Gson gson;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        clinicDAO = new ClinicDAO();
        reportDAO = new DiagnosisReportDAO();
        gson = new GsonBuilder().create();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        Map<String, Object> data = new HashMap<>();

        try {
            // KPI Cards
            int activePatients = userDAO.countActivePatients();
            int totalScans = reportDAO.countAll();
            
            data.put("activePatients", activePatients);
            data.put("totalScans", totalScans);
            data.put("totalClinics", clinicDAO.countAll());
            
            double avgConf = reportDAO.getAverageConfidenceScore();
            data.put("avgConfidence", Math.round(avgConf)); // e.g. 95

            // Risk Data
            Map<String, Integer> riskData = reportDAO.getRiskLevelDistribution();
            data.put("riskLevelDistribution", riskData);
            
            // Calculate High Risk Ratio
            int highRiskScans = riskData.getOrDefault("HIGH", 0);
            double highRiskRatio = 0;
            if (totalScans > 0) {
                highRiskRatio = (highRiskScans * 100.0) / totalScans;
            }
            data.put("highRiskRatio", Math.round(highRiskRatio));

            // Charts Data
            data.put("topDiseases", reportDAO.getTopDiseases(5));
            data.put("scansTrend", reportDAO.getScansTrend());

            // Recent Scans Table
            List<DiagnosisReport> recentList = reportDAO.findAll(1, 5);
            List<Map<String, Object>> recentScans = new ArrayList<>();
            DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
            
            for (DiagnosisReport dr : recentList) {
                Map<String, Object> scanMap = new HashMap<>();
                scanMap.put("id", dr.getId());
                scanMap.put("patientName", dr.getPatientName());
                scanMap.put("diseaseName", dr.getDiseaseName());
                scanMap.put("riskLevel", dr.getRiskLevel());
                scanMap.put("confidenceScore", Math.round(dr.getConfidenceScore()));
                if (dr.getCreatedAt() != null) {
                    scanMap.put("createdAt", dr.getCreatedAt().format(dtf));
                } else {
                    scanMap.put("createdAt", "");
                }
                recentScans.add(scanMap);
            }
            data.put("recentScans", recentScans);

        } catch (Exception e) {
            e.printStackTrace();
            data.put("error", "Failed to fetch dashboard data");
        }

        try (PrintWriter out = resp.getWriter()) {
            out.print(gson.toJson(data));
            out.flush();
        }
    }
}
