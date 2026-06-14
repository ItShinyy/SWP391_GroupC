package Ctrller;


import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/nahh")
public class ServletClone extends HttpServlet {

    public ServletClone() {


    }

    public void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {


    }
    public void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try(PrintWriter out = response.getWriter();) {

        }

    }
}
