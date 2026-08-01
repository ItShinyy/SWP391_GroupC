package com.dermathologyai.controller.patient;

import com.dermathologyai.dao.FamilyMemberDAO;
import com.dermathologyai.model.FamilyMember;
import com.dermathologyai.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.Set;

/** Maintains the logged-in patient's family members. */
public class FamilyMemberController extends HttpServlet {
    private static final Set<String> RELATIONSHIPS = Set.of(
            "FATHER", "MOTHER", "SPOUSE", "CHILD", "OLDER_BROTHER", "OLDER_SISTER",
            "YOUNGER_BROTHER", "YOUNGER_SISTER", "GRANDPARENT", "OTHER");
    private FamilyMemberDAO familyMemberDAO;

    @Override
    public void init() {
        familyMemberDAO = new FamilyMemberDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = requirePatient(request, response);
        if (user == null) return;

        String action = request.getParameter("action");
        if ("view".equals(action)) {
            FamilyMember member = familyMemberDAO.findByIdAndOwnerUserId(request.getParameter("id"), user.getId());
            if (member == null) {
                request.getSession().setAttribute("errorMessage", "Không tìm thấy thông tin người thân.");
                response.sendRedirect(request.getContextPath() + "/account/profile");
                return;
            }
            request.setAttribute("member", member);
            request.getRequestDispatcher("/WEB-INF/views/patient/family-member-detail.jsp").forward(request, response);
            return;
        }
        request.getRequestDispatcher("/WEB-INF/views/patient/family-member-form.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = requirePatient(request, response);
        if (user == null) return;

        FamilyMember member = new FamilyMember();
        member.setOwnerUserId(user.getId());
        member.setFullName(trim(request.getParameter("fullName")));
        // The UI no longer asks for gender. Keep a neutral internal value so
        // existing databases with a NOT NULL gender column remain compatible.
        member.setGender("OTHER");
        member.setRelationship(trim(request.getParameter("relationship")));
        member.setPhone(trim(request.getParameter("phone")));
        member.setEmail(trim(request.getParameter("email")));
        member.setProvince(trim(request.getParameter("province")));
        member.setWard(trim(request.getParameter("ward")));
        member.setAddressDetail(trim(request.getParameter("addressDetail")));
        member.setCountry(trim(request.getParameter("country")));
        member.setEthnicity(trim(request.getParameter("ethnicity")));
        member.setOccupation(trim(request.getParameter("occupation")));

        try {
            member.setDateOfBirth(LocalDate.parse(trim(request.getParameter("dateOfBirth"))));
        } catch (DateTimeParseException exception) {
            showFormError(request, response, member, "Ngày sinh không hợp lệ.");
            return;
        }

        if (!isValid(member)) {
            showFormError(request, response, member, "Vui lòng điền đầy đủ các thông tin bắt buộc.");
            return;
        }
        if (member.getDateOfBirth().isAfter(LocalDate.now())) {
            showFormError(request, response, member, "Ngày sinh không thể ở tương lai.");
            return;
        }

        if (familyMemberDAO.create(member) == null) {
            showFormError(request, response, member, "Không thể thêm người thân lúc này. Vui lòng thử lại sau.");
            return;
        }

        request.getSession().setAttribute("successMessage", "Đã thêm thành viên gia đình thành công.");
        response.sendRedirect(request.getContextPath() + "/account/profile");
    }

    private static boolean isValid(FamilyMember member) {
        return !member.getFullName().isEmpty() && member.getFullName().length() <= 100
                && RELATIONSHIPS.contains(member.getRelationship())
                && !member.getPhone().isEmpty() && member.getPhone().length() <= 20
                && !member.getProvince().isEmpty() && !member.getWard().isEmpty()
                && !member.getAddressDetail().isEmpty() && !member.getCountry().isEmpty()
                && !member.getEthnicity().isEmpty() && !member.getOccupation().isEmpty();
    }

    private User requirePatient(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return null;
        }
        if (!user.isPatient()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }
        return user;
    }

    private void showFormError(HttpServletRequest request, HttpServletResponse response,
                               FamilyMember member, String error) throws ServletException, IOException {
        request.setAttribute("member", member);
        request.setAttribute("errorMessage", error);
        request.getRequestDispatcher("/WEB-INF/views/patient/family-member-form.jsp").forward(request, response);
    }

    private static String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
