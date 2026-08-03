package com.dermathologyai.util;

import com.lowagie.text.*;
import com.lowagie.text.pdf.*;
import com.lowagie.text.pdf.draw.LineSeparator;
import com.dermathologyai.model.Appointment;

import java.io.IOException;
import java.time.format.DateTimeFormatter;

public class PdfReportGenerator {

    public static void generateAppointmentReportPdf(java.io.OutputStream os, Appointment appt, java.util.List<com.dermathologyai.model.Prescription> prescriptions) throws IOException {
        Document document = new Document(PageSize.A4, 50, 50, 50, 50);
        try {
            PdfWriter.getInstance(document, os);
            document.open();
            
            // Cấu hình font chữ hỗ trợ tiếng Việt Unicode
            String fontPath = "C:\\Windows\\Fonts\\arial.ttf";
            Font titleFont;
            Font subtitleFont;
            Font docTitleFont;
            Font infoBoldFont;
            Font infoFont;
            Font tableHeaderFont;
            Font tableBodyFont;
            
            java.io.File fontFile = new java.io.File(fontPath);
            if (fontFile.exists()) {
                FontFactory.register(fontPath, "Arial");
                titleFont = FontFactory.getFont("Arial", "Identity-H", true, 16, Font.BOLD);
                subtitleFont = FontFactory.getFont("Arial", "Identity-H", true, 9);
                docTitleFont = FontFactory.getFont("Arial", "Identity-H", true, 13, Font.BOLD);
                infoBoldFont = FontFactory.getFont("Arial", "Identity-H", true, 9, Font.BOLD);
                infoFont = FontFactory.getFont("Arial", "Identity-H", true, 9);
                tableHeaderFont = FontFactory.getFont("Arial", "Identity-H", true, 9, Font.BOLD);
                tableBodyFont = FontFactory.getFont("Arial", "Identity-H", true, 9);
            } else {
                titleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 16);
                subtitleFont = FontFactory.getFont(FontFactory.HELVETICA, 9);
                docTitleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 13);
                infoBoldFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 9);
                infoFont = FontFactory.getFont(FontFactory.HELVETICA, 9);
                tableHeaderFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 9);
                tableBodyFont = FontFactory.getFont(FontFactory.HELVETICA, 9);
            }
            
            // Clinic Title / Header
            Paragraph title = new Paragraph(appt.getClinicName() != null ? appt.getClinicName().toUpperCase() : "HỆ THỐNG PHÒNG KHÁM DERMAI", titleFont);
            title.setAlignment(Element.ALIGN_CENTER);
            document.add(title);
            
            Paragraph subtitle = new Paragraph("Đơn thuốc & Kết quả khám chuyên khoa da liễu", subtitleFont);
            subtitle.setAlignment(Element.ALIGN_CENTER);
            subtitle.setSpacingAfter(10);
            document.add(subtitle);
            
            // Divider 1
            LineSeparator line1 = new LineSeparator(1f, 100f, java.awt.Color.LIGHT_GRAY, Element.ALIGN_CENTER, 0);
            Paragraph line1Paragraph = new Paragraph(new Chunk(line1));
            line1Paragraph.setSpacingAfter(10);
            document.add(line1Paragraph);
            
            // Document Title
            Paragraph docTitle = new Paragraph("PHIẾU KHÁM BỆNH VÀ ĐƠN THUỐC", docTitleFont);
            docTitle.setAlignment(Element.ALIGN_CENTER);
            docTitle.setSpacingAfter(15);
            document.add(docTitle);
            
            // Patient details table
            PdfPTable infoTable = new PdfPTable(2);
            infoTable.setWidthPercentage(100);
            infoTable.setSpacingAfter(15);
            infoTable.setWidths(new float[]{1.0f, 1.0f});
            
            // Row 1: Name & Doctor
            PdfPCell cell1 = new PdfPCell();
            cell1.setBorder(Rectangle.NO_BORDER);
            Paragraph p1 = new Paragraph();
            p1.add(new Chunk("Họ và tên: ", infoBoldFont));
            p1.add(new Chunk(appt.getPatientName() != null ? appt.getPatientName() : "Không rõ", infoFont));
            cell1.addElement(p1);
            infoTable.addCell(cell1);
            
            PdfPCell cell2 = new PdfPCell();
            cell2.setBorder(Rectangle.NO_BORDER);
            Paragraph p2 = new Paragraph();
            p2.add(new Chunk("Bác sĩ điều trị: ", infoBoldFont));
            p2.add(new Chunk(appt.getDoctorName() != null ? appt.getDoctorName() : "Bác sĩ phòng khám", infoFont));
            cell2.addElement(p2);
            infoTable.addCell(cell2);
            
            // Row 2: Date & Phone
            PdfPCell cell3 = new PdfPCell();
            cell3.setBorder(Rectangle.NO_BORDER);
            Paragraph p3 = new Paragraph();
            p3.add(new Chunk("Ngày khám: ", infoBoldFont));
            String dateText = appt.getAppointmentTime() != null ? appt.getAppointmentTime().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")) : "N/A";
            p3.add(new Chunk(dateText, infoFont));
            cell3.addElement(p3);
            infoTable.addCell(cell3);
            
            PdfPCell cell4 = new PdfPCell();
            cell4.setBorder(Rectangle.NO_BORDER);
            Paragraph p4 = new Paragraph();
            p4.add(new Chunk("Số điện thoại: ", infoBoldFont));
            p4.add(new Chunk(appt.getPatientPhone() != null ? appt.getPatientPhone() : "N/A", infoFont));
            cell4.addElement(p4);
            infoTable.addCell(cell4);
            
            document.add(infoTable);

            
            // Divider 2
            LineSeparator line2 = new LineSeparator(1f, 100f, java.awt.Color.LIGHT_GRAY, Element.ALIGN_CENTER, 0);
            Paragraph line2Paragraph = new Paragraph(new Chunk(line2));
            line2Paragraph.setSpacingAfter(10);
            document.add(line2Paragraph);
            
            // Clinical Notes / Diagnosis
            Paragraph diagTitle = new Paragraph("CHẨN ĐOÁN LÂM SÀNG CỦA BÁC SĨ:", docTitleFont);
            diagTitle.setSpacingAfter(5);
            document.add(diagTitle);
            
            Paragraph diagNotes = new Paragraph(appt.getDoctorNotes() != null && !appt.getDoctorNotes().trim().isEmpty() ? appt.getDoctorNotes() : "Chưa có nhận định lâm sàng.", infoFont);
            diagNotes.setSpacingAfter(15);
            diagNotes.setLeading(12f);
            document.add(diagNotes);
            
            // Note: EXCLUDED AI diagnosis text from PDF according to user instruction!
            
            // Prescription Title
            Paragraph prescTitle = new Paragraph("ĐƠN THUỐC ĐIỀU TRỊ:", docTitleFont);
            prescTitle.setSpacingAfter(8);
            document.add(prescTitle);
            
            if (prescriptions == null || prescriptions.isEmpty()) {
                Paragraph noPresc = new Paragraph("Không có chỉ định kê đơn thuốc.", infoFont);
                noPresc.setSpacingAfter(30);
                document.add(noPresc);
            } else {
                // Table of drugs
                PdfPTable table = new PdfPTable(3);
                table.setWidthPercentage(100);
                table.setSpacingAfter(30);
                table.setWidths(new float[]{1.5f, 0.8f, 2.7f});
                
                // Headers
                PdfPCell h1 = new PdfPCell(new Paragraph("Tên thuốc", tableHeaderFont));
                h1.setBackgroundColor(java.awt.Color.LIGHT_GRAY);
                h1.setPadding(5);
                table.addCell(h1);
                
                PdfPCell h2 = new PdfPCell(new Paragraph("Số lượng", tableHeaderFont));
                h2.setBackgroundColor(java.awt.Color.LIGHT_GRAY);
                h2.setPadding(5);
                table.addCell(h2);
                
                PdfPCell h3 = new PdfPCell(new Paragraph("Cách dùng & Liều lượng", tableHeaderFont));
                h3.setBackgroundColor(java.awt.Color.LIGHT_GRAY);
                h3.setPadding(5);
                table.addCell(h3);
                
                for (com.dermathologyai.model.Prescription pr : prescriptions) {
                    PdfPCell c1 = new PdfPCell(new Paragraph(pr.getDrugName(), tableBodyFont));
                    c1.setPadding(5);
                    table.addCell(c1);
                    
                    PdfPCell c2 = new PdfPCell(new Paragraph(String.valueOf(pr.getQuantity()), tableBodyFont));
                    c2.setPadding(5);
                    table.addCell(c2);
                    
                    PdfPCell c3 = new PdfPCell(new Paragraph(pr.getDosage(), tableBodyFont));
                    c3.setPadding(5);
                    table.addCell(c3);
                }
                document.add(table);
            }
            
            // Signature footer
            PdfPTable footerTable = new PdfPTable(2);
            footerTable.setWidthPercentage(100);
            footerTable.setWidths(new float[]{1.0f, 1.0f});
            
            PdfPCell signCell1 = new PdfPCell(new Paragraph("Lời dặn: Tái khám theo lịch hẹn của bác sĩ.", infoFont));
            signCell1.setBorder(Rectangle.NO_BORDER);
            footerTable.addCell(signCell1);
            
            PdfPCell signCell2 = new PdfPCell();
            signCell2.setBorder(Rectangle.NO_BORDER);
            Paragraph signPara = new Paragraph("Bác sĩ điều trị\n(Ký và ghi rõ họ tên)\n\n\n\n" + (appt.getDoctorName() != null ? appt.getDoctorName() : ""), infoBoldFont);
            signPara.setAlignment(Element.ALIGN_CENTER);
            signCell2.addElement(signPara);
            footerTable.addCell(signCell2);
            
            document.add(footerTable);
            
        } catch (DocumentException e) {
            throw new IOException("Error generating PDF document structure", e);
        } finally {
            document.close();
        }
    }
}
