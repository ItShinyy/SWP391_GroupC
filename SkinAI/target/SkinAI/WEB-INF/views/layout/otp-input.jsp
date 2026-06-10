<%--
  Reusable 6-digit OTP Input Component (Non-JS).
  Usage: <jsp:include page="/WEB-INF/views/layout/otp-input.jsp">
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
    font-family: monospace;
    letter-spacing: 1.5em; /* Create optical illusion of separate boxes */
    padding-left: 1em;
    font-size: 1.8rem;
    font-weight: 700;
    width: 100%;
    text-align: left;
    border: 2px solid #dee2e6;
    border-radius: 10px;
    outline: none;
    transition: border-color .2s, box-shadow .2s;
    background-color: #f8f9fa;
  }
  .otp-single-box:focus { 
    border-color: #198754; 
    box-shadow: 0 0 0 3px rgba(25,135,84,.15); 
    background-color: #fff;
  }
</style>

<%
  String inputName = request.getParameter("inputName") != null ? request.getParameter("inputName") : "otp";
%>

<div class="otp-container">
  <input type="text" 
         id="<%= inputName %>" 
         name="<%= inputName %>" 
         class="otp-single-box" 
         maxlength="6" 
         pattern="\d{6}" 
         required 
         autocomplete="one-time-code"
         placeholder="------"
         title="Vui lòng nhập 6 chữ số">
</div>
