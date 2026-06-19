package Ctrller;

import dal.ClinicDAO;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Clinic;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

public class ClinicFallbackServlet extends HttpServlet {

    // Nhận yêu cầu GET, lấy các cơ sở đang hoạt động từ database và trả về một mảng JSON.
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        ClinicDAO cldao = new ClinicDAO();
        List<Clinic> clinics = cldao.getActiveClinics();
        try (PrintWriter out = response.getWriter()) {
            out.print("[");
            for (int index = 0; index < clinics.size(); index++) {
                if (index > 0) {
                    out.print(",");
                }
                writeClinic(out, clinics.get(index));
            }
            out.print("]");
        }
    }

    // Chuyển một đối tượng Clinic thành một object JSON và ghi trực tiếp vào response.
    private void writeClinic(PrintWriter out, Clinic clinic) {
        out.print("{");
        writeString(out, "name", clinic.getClinicName());
        out.print(",");
        writeString(out, "address", clinic.getAddress());
        out.print(",");
        writeString(out, "phone", clinic.getPhone());
        out.print(",");
        writeString(out, "website", clinic.getWebsite());
        out.print(",");
        writeString(out, "type", clinic.getFacilityType());
        out.print(",\"latitude\":" + clinic.getLatitude());
        out.print(",\"longitude\":" + clinic.getLongitude());
        out.print("}");
    }

    // Ghi một thuộc tính chuỗi theo định dạng JSON và xử lý riêng trường hợp giá trị null.
    private void writeString(PrintWriter out, String name, String value) {
        out.print("\"" + name + "\":");
        if (value == null) {
            out.print("null");
            return;
        }

        // Escape các ký tự đặc biệt để value không làm hỏng cú pháp JSON:
        // \ thành \\, " thành \", ký tự xuống dòng CR/LF thành chuỗi \r và \n.
        String escaped = value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "\\r")
                .replace("\n", "\\n");
        out.print("\"" + escaped + "\"");
    }
}
