package com.dermathologyai.controller.admin;

import com.dermathologyai.dao.InvoiceDAO;
import com.dermathologyai.model.Invoice;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.text.NumberFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/** Admin Invoice History. Routes to /admin/invoices. Default sort: Issue Date DESC. */
public class AdminInvoiceController extends HttpServlet {

    private static final int DEFAULT_PAGE_SIZE = 15;
    private static final DateTimeFormatter DATE_FMT     = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private static final DateTimeFormatter DATETIME_FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    private static final NumberFormat VND_FMT = NumberFormat.getNumberInstance(new Locale("vi", "VN"));

    private final InvoiceDAO invoiceDAO = new InvoiceDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String search    = trim(req.getParameter("search"));
        String status    = trim(req.getParameter("status"));
        String startDate = trim(req.getParameter("startDate"));
        String endDate   = trim(req.getParameter("endDate"));

        int page = parseInt(req.getParameter("page"), 1);
        int size = parseInt(req.getParameter("size"), DEFAULT_PAGE_SIZE);
        if (page < 1) page = 1;
        if (size < 1 || size > 100) size = DEFAULT_PAGE_SIZE;

        int total      = invoiceDAO.countAllForAdmin(search, status, startDate, endDate);
        int totalPages = (size > 0) ? (int) Math.ceil((double) total / size) : 1;
        List<Invoice> invoices = invoiceDAO.findAllForAdmin(search, status, startDate, endDate, page, size);

        // Pre-format dates and amounts: LocalDateTime is not JSTL-compatible.
        List<Map<String, Object>> rows = new ArrayList<>();
        for (Invoice inv : invoices) {
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("idShort",         inv.getId() != null ? inv.getId().substring(0, Math.min(8, inv.getId().length())) + "\u2026" : "\u2014");
            row.put("appointmentId",   inv.getAppointmentId());
            row.put("patientName",     inv.getPatientName() != null ? inv.getPatientName() : "\u2014");
            row.put("appointmentTime", fmt(inv.getAppointmentTime(), DATETIME_FMT));
            row.put("createdAt",       fmt(inv.getCreatedAt(), DATE_FMT));
            row.put("totalAmount",     fmtVnd(inv.getTotalAmount()));
            row.put("status",          inv.getStatus() != null ? inv.getStatus() : "");
            rows.add(row);
        }

        StringBuilder pq = new StringBuilder();
        if (search    != null) pq.append("&search=").append(enc(search));
        if (status    != null) pq.append("&status=").append(enc(status));
        if (startDate != null) pq.append("&startDate=").append(enc(startDate));
        if (endDate   != null) pq.append("&endDate=").append(enc(endDate));
        pq.append("&size=").append(size);

        req.setAttribute("rows",        rows);
        req.setAttribute("total",       total);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages",  totalPages);
        req.setAttribute("totalItems",  total);
        req.setAttribute("pageSize",    size);
        req.setAttribute("pageQuery",   pq.toString());
        req.setAttribute("search",      search);
        req.setAttribute("status",      status);
        req.setAttribute("startDate",   startDate);
        req.setAttribute("endDate",     endDate);

        req.getRequestDispatcher("/WEB-INF/views/admin/invoices/index.jsp").forward(req, resp);
    }

    private static String fmt(LocalDateTime ldt, DateTimeFormatter f) {
        return ldt != null ? ldt.format(f) : "\u2014";
    }

    private static String fmtVnd(BigDecimal amount) {
        if (amount == null) return "0 \u20ab";
        return VND_FMT.format(amount) + " \u20ab";
    }

    private static String enc(String s) {
        try { return java.net.URLEncoder.encode(s, "UTF-8"); }
        catch (java.io.UnsupportedEncodingException e) { return s; }
    }

    private static String trim(String s) { return (s != null && !s.isBlank()) ? s.trim() : null; }

    private static int parseInt(String s, int d) {
        if (s == null || s.isBlank()) return d;
        try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return d; }
    }
}