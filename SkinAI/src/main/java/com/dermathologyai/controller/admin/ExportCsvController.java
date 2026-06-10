package com.dermathologyai.controller.admin;

import com.dermathologyai.dao.DiagnosisReportDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Map;
import com.dermathologyai.util.FormatUtil;

public class ExportCsvController extends HttpServlet {
    private DiagnosisReportDAO reportDAO;

    @Override
    public void init() throws ServletException {
        reportDAO = new DiagnosisReportDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("text/csv");
        resp.setHeader("Content-Disposition", "attachment; filename=\"SkinAI_Report.csv\"");
        resp.setCharacterEncoding("UTF-8");

        try (PrintWriter out = resp.getWriter()) {
            // Chèn BOM để Excel hiển thị đúng Tiếng Việt
            out.write("\ufeff");

            out.println("SkinAI - BÁO CÁO THỐNG KÊ HỆ THỐNG");
            out.println();

            out.println("PHÂN BỔ MỨC ĐỘ RỦI RO");
            out.println("Mức độ,Số ca mắc");
            Map<String, Integer> riskData = reportDAO.getRiskLevelDistribution();
            for (Map.Entry<String, Integer> entry : riskData.entrySet()) {
                out.println(entry.getKey() + "," + entry.getValue());
            }
            out.println();

            out.println("TOP BỆNH LÝ PHÁT HIỆN");
            out.println("Tên bệnh,Số ca mắc");
            Map<String, Integer> topDiseases = reportDAO.getTopDiseases(10);
            for (Map.Entry<String, Integer> entry : topDiseases.entrySet()) {
                // Wrap in quotes in case of commas in disease name and prevent CSV injection
                out.println(FormatUtil.escapeCsv(entry.getKey()) + "," + entry.getValue());
            }
            out.println();

            out.println("XU HƯỚNG QUÉT AI (30 NGÀY QUA)");
            out.println("Ngày,Số lượng");
            Map<String, Integer> scansTrend = reportDAO.getScansTrend();
            for (Map.Entry<String, Integer> entry : scansTrend.entrySet()) {
                out.println(entry.getKey() + "," + entry.getValue());
            }
            
            out.flush();
        }
    }
}
