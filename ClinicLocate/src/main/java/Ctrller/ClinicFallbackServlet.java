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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        List<Clinic> clinics = new ClinicDAO().getActiveClinics();
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

    private void writeClinic(PrintWriter out, Clinic clinic) {
        out.print("{");
        writeString(out, "name", clinic.getClinicName());
        out.print(",");
        writeString(out, "address", clinic.getAddress());
        out.print(",");
        writeString(out, "phone", clinic.getPhone());
        out.print(",");
        writeString(out, "type", clinic.getFacilityType());
        out.print(",\"latitude\":" + clinic.getLatitude());
        out.print(",\"longitude\":" + clinic.getLongitude());
        out.print("}");
    }

    private void writeString(PrintWriter out, String name, String value) {
        out.print("\"" + name + "\":");
        if (value == null) {
            out.print("null");
            return;
        }

        String escaped = value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "\\r")
                .replace("\n", "\\n");
        out.print("\"" + escaped + "\"");
    }
}
