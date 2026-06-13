<%--
  Reusable 6-digit OTP Input Component (Non-JS).
  Usage: <jsp:include page="/WEB-INF/views/global/otp-input.jsp">
           <jsp:param name="inputName" value="otp"/>
         </jsp:include>
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<style>
  .otp-container { 
    display: flex; 
    justify-content: center; 
    margin: 16px 0; 
    position: relative;
  }
  .otp-single-box {
    font-size: 1.8rem;
    font-weight: 700;
    letter-spacing: 0.5em;
    text-align: center;
  }
</style>

<%
  String inputName = request.getParameter("inputName") != null ? request.getParameter("inputName") : "otp";
%>

<div class="otp-container">
  <input type="text" 
         id="<%= inputName %>" 
         name="<%= inputName %>" 
         class="form-control otp-single-box" 
         maxlength="6" 
         pattern="\d{6}" 
         required 
         autocomplete="one-time-code"
         placeholder="------"
         title="Vui lòng nhập 6 chữ số">
</div>
