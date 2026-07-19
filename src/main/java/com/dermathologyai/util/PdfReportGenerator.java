package com.dermathologyai.util;

import com.lowagie.text.*;
import com.lowagie.text.pdf.*;
import com.lowagie.text.pdf.draw.LineSeparator;
import com.dermathologyai.model.Appointment;
import com.dermathologyai.model.AppointmentLabTest;

import java.io.FileOutputStream;
import java.io.IOException;
import java.time.format.DateTimeFormatter;

public class PdfReportGenerator {
    
    public static String generateLabTestPdf(String destFolder, AppointmentLabTest test, Appointment appt) throws IOException {
        String fileName = "lab_result_" + test.getId() + ".pdf";
        String relativePath = "uploads/lab_results/" + fileName;
        String absolutePath = destFolder + "/" + fileName;
        
        java.io.File file = new java.io.File(absolutePath);
        if (!file.getParentFile().exists()) {
            file.getParentFile().mkdirs();
        }
        
        Document document = new Document(PageSize.A4, 50, 50, 50, 50);
        try {
            PdfWriter.getInstance(document, new FileOutputStream(absolutePath));
            document.open();
            
            // Cấu hình font chữ hỗ trợ tiếng Việt Unicode
            String fontPath = "C:\\Windows\\Fonts\\arial.ttf";
            Font titleFont;
            Font subtitleFont;
            Font docTitleFont;
            Font infoBoldFont;
            Font infoFont;
            Font testNameFont;
            Font resultTitleFont;
            Font resultBodyFont;
            
            java.io.File fontFile = new java.io.File(fontPath);
            if (fontFile.exists()) {
                FontFactory.register(fontPath, "Arial");
                titleFont = FontFactory.getFont("Arial", "Identity-H", true, 18, Font.BOLD);
                subtitleFont = FontFactory.getFont("Arial", "Identity-H", true, 10);
                docTitleFont = FontFactory.getFont("Arial", "Identity-H", true, 14, Font.BOLD);
                infoBoldFont = FontFactory.getFont("Arial", "Identity-H", true, 10, Font.BOLD);
                infoFont = FontFactory.getFont("Arial", "Identity-H", true, 10);
                testNameFont = FontFactory.getFont("Arial", "Identity-H", true, 12, Font.BOLD);
                resultTitleFont = FontFactory.getFont("Arial", "Identity-H", true, 11, Font.BOLD);
                resultBodyFont = FontFactory.getFont("Arial", "Identity-H", true, 10);
            } else {
                titleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18);
                subtitleFont = FontFactory.getFont(FontFactory.HELVETICA, 10);
                docTitleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 14);
                infoBoldFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10);
                infoFont = FontFactory.getFont(FontFactory.HELVETICA, 10);
                testNameFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12);
                resultTitleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 11);
                resultBodyFont = FontFactory.getFont(FontFactory.HELVETICA, 10);
            }
            
            // Tiêu đề phòng khám
            Paragraph title = new Paragraph("PHÒNG KHÁM DA LIỄU SKINAI", titleFont);
            title.setAlignment(Element.ALIGN_CENTER);
            document.add(title);
            
            Paragraph subtitle = new Paragraph("Hệ thống chẩn đoán và điều trị bệnh da liễu ứng dụng AI", subtitleFont);
            subtitle.setAlignment(Element.ALIGN_CENTER);
            subtitle.setSpacingAfter(15);
            document.add(subtitle);
            
            // Đường phân cách 1
            LineSeparator line1 = new LineSeparator(1f, 100f, java.awt.Color.LIGHT_GRAY, Element.ALIGN_CENTER, 0);
            Paragraph line1Paragraph = new Paragraph(new Chunk(line1));
            line1Paragraph.setSpacingAfter(15);
            document.add(line1Paragraph);
            
            // Tiêu đề phiếu
            Paragraph docTitle = new Paragraph("PHIẾU KẾT QUẢ XÉT NGHIỆM LÂM SÀNG", docTitleFont);
            docTitle.setAlignment(Element.ALIGN_CENTER);
            docTitle.setSpacingAfter(20);
            document.add(docTitle);
            
            // Bảng thông tin hành chính 2 cột
            PdfPTable infoTable = new PdfPTable(2);
            infoTable.setWidthPercentage(100);
            infoTable.setSpacingAfter(15);
            infoTable.setWidths(new float[]{1.1f, 0.9f});
            
            // Cell 1: Bệnh nhân
            PdfPCell cell1 = new PdfPCell();
            cell1.setBorder(Rectangle.NO_BORDER);
            Paragraph p1 = new Paragraph();
            p1.add(new Chunk("Bệnh nhân: ", infoBoldFont));
            p1.add(new Chunk(appt.getPatientName() != null ? appt.getPatientName() : "Không rõ", infoFont));
            cell1.addElement(p1);
            infoTable.addCell(cell1);
            
            // Cell 2: Bác sĩ chỉ định
            PdfPCell cell2 = new PdfPCell();
            cell2.setBorder(Rectangle.NO_BORDER);
            Paragraph p2 = new Paragraph();
            p2.add(new Chunk("Bác sĩ chỉ định: ", infoBoldFont));
            p2.add(new Chunk(appt.getDoctorName() != null ? appt.getDoctorName() : "Bác sĩ phòng khám", infoFont));
            cell2.addElement(p2);
            infoTable.addCell(cell2);
            
            // Cell 3: Giới tính
            String genderText = appt.getPatientGender();
            if ("MALE".equalsIgnoreCase(genderText)) genderText = "Nam";
            else if ("FEMALE".equalsIgnoreCase(genderText)) genderText = "Nữ";
            else if ("OTHER".equalsIgnoreCase(genderText)) genderText = "Khác";
            else genderText = "N/A";
            
            PdfPCell cell3 = new PdfPCell();
            cell3.setBorder(Rectangle.NO_BORDER);
            Paragraph p3 = new Paragraph();
            p3.add(new Chunk("Giới tính: ", infoBoldFont));
            p3.add(new Chunk(genderText, infoFont));
            cell3.addElement(p3);
            infoTable.addCell(cell3);
            
            // Cell 4: Thời gian khám
            PdfPCell cell4 = new PdfPCell();
            cell4.setBorder(Rectangle.NO_BORDER);
            Paragraph p4 = new Paragraph();
            p4.add(new Chunk("Thời gian khám: ", infoBoldFont));
            String dateText = appt.getAppointmentTime() != null ? appt.getAppointmentTime().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")) : "N/A";
            p4.add(new Chunk(dateText, infoFont));
            cell4.addElement(p4);
            infoTable.addCell(cell4);
            
            // Cell 5: Số điện thoại
            PdfPCell cell5 = new PdfPCell();
            cell5.setBorder(Rectangle.NO_BORDER);
            Paragraph p5 = new Paragraph();
            p5.add(new Chunk("Số điện thoại: ", infoBoldFont));
            p5.add(new Chunk(appt.getPatientPhone() != null ? appt.getPatientPhone() : "N/A", infoFont));
            cell5.addElement(p5);
            infoTable.addCell(cell5);
            
            // Cell 6: Địa chỉ
            PdfPCell cell6 = new PdfPCell();
            cell6.setBorder(Rectangle.NO_BORDER);
            Paragraph p6 = new Paragraph();
            p6.add(new Chunk("Địa chỉ: ", infoBoldFont));
            p6.add(new Chunk(appt.getPatientAddress() != null ? appt.getPatientAddress() : "N/A", infoFont));
            cell6.addElement(p6);
            infoTable.addCell(cell6);
            
            document.add(infoTable);
            
            // Đường phân cách 2
            LineSeparator line2 = new LineSeparator(1f, 100f, java.awt.Color.LIGHT_GRAY, Element.ALIGN_CENTER, 0);
            Paragraph line2Paragraph = new Paragraph(new Chunk(line2));
            line2Paragraph.setSpacingAfter(15);
            document.add(line2Paragraph);
            
            // Tên xét nghiệm
            Paragraph testNamePara = new Paragraph("Tên xét nghiệm thực hiện: " + test.getTestName(), testNameFont);
            testNamePara.setSpacingBefore(15);
            testNamePara.setSpacingAfter(15);
            document.add(testNamePara);
            
            // Kết luận
            Paragraph resultTitle = new Paragraph("KẾT LUẬN Y KHOA CHI TIẾT:", resultTitleFont);
            resultTitle.setSpacingBefore(10);
            resultTitle.setSpacingAfter(8);
            document.add(resultTitle);
            
            Paragraph resultBody = new Paragraph(test.getResultSummary(), resultBodyFont);
            resultBody.setLeading(14f);
            resultBody.setSpacingAfter(50);
            document.add(resultBody);
            
            // Ký tên
            Paragraph signature = new Paragraph("Khoa Xét Nghiệm Cận Lâm Sàng\nTrưởng Bộ Phận\n(Đã ký số xác thực)", infoBoldFont);
            signature.setAlignment(Element.ALIGN_RIGHT);
            document.add(signature);
            
        } catch (DocumentException e) {
            throw new IOException("Lỗi khi sinh cấu trúc PDF", e);
        } finally {
            document.close();
        }
        
        return relativePath;
    }

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
            Paragraph title = new Paragraph(appt.getClinicName() != null ? appt.getClinicName().toUpperCase() : "HỆ THỐNG PHÒNG KHÁM SKINAI", titleFont);
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
            
            // Row 2: DOB & Date
            PdfPCell cell3 = new PdfPCell();
            cell3.setBorder(Rectangle.NO_BORDER);
            Paragraph p3 = new Paragraph();
            p3.add(new Chunk("Ngày sinh: ", infoBoldFont));
            p3.add(new Chunk(appt.getPatientDob() != null ? appt.getPatientDob() : "Chưa rõ", infoFont));
            cell3.addElement(p3);
            infoTable.addCell(cell3);
            
            PdfPCell cell4 = new PdfPCell();
            cell4.setBorder(Rectangle.NO_BORDER);
            Paragraph p4 = new Paragraph();
            p4.add(new Chunk("Ngày khám: ", infoBoldFont));
            String dateText = appt.getAppointmentTime() != null ? appt.getAppointmentTime().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")) : "N/A";
            p4.add(new Chunk(dateText, infoFont));
            cell4.addElement(p4);
            infoTable.addCell(cell4);
            
            // Row 3: Gender & Phone
            String genderText = appt.getPatientGender();
            if ("MALE".equalsIgnoreCase(genderText)) genderText = "Nam";
            else if ("FEMALE".equalsIgnoreCase(genderText)) genderText = "Nữ";
            else if ("OTHER".equalsIgnoreCase(genderText)) genderText = "Khác";
            else genderText = "N/A";
            
            PdfPCell cell5 = new PdfPCell();
            cell5.setBorder(Rectangle.NO_BORDER);
            Paragraph p5 = new Paragraph();
            p5.add(new Chunk("Giới tính: ", infoBoldFont));
            p5.add(new Chunk(genderText, infoFont));
            cell5.addElement(p5);
            infoTable.addCell(cell5);
            
            PdfPCell cell6 = new PdfPCell();
            cell6.setBorder(Rectangle.NO_BORDER);
            Paragraph p6 = new Paragraph();
            p6.add(new Chunk("Số điện thoại: ", infoBoldFont));
            p6.add(new Chunk(appt.getPatientPhone() != null ? appt.getPatientPhone() : "N/A", infoFont));
            cell6.addElement(p6);
            infoTable.addCell(cell6);
            
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
