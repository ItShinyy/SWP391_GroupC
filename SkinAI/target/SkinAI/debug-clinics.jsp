<%@ page import="com.dermathologyai.dao.ClinicDAO" %>
<%@ page import="com.dermathologyai.model.Clinic" %>
<%@ page import="java.util.List" %>
<%
ClinicDAO clinicDAO = new ClinicDAO();
List<Clinic> allClinics = clinicDAO.findAll();
List<Clinic> activeClinics = clinicDAO.findActive();
%>
<html>
<head><title>Debug Clinics</title></head>
<body>
<h1>Clinic Debug Page</h1>
<h2>All Clinics (<%=allClinics.size()%>):</h2>
<ul>
<% for(Clinic c : allClinics) { %>
    <li>ID: <%=c.getId()%> | Name: <%=c.getClinicName()%> | Active: <%=c.isActive()%> | Address: <%=c.getAddress()%></li>
<% } %>
</ul>

<h2>Active Clinics (<%=activeClinics.size()%>):</h2>
<ul>
<% for(Clinic c : activeClinics) { %>
    <li>ID: <%=c.getId()%> | Name: <%=c.getClinicName()%> | Address: <%=c.getAddress()%></li>
<% } %>
</ul>

<% if(allClinics.isEmpty()) { %>
<p style="color: red;"><strong>NO CLINICS FOUND! Need to insert sample data.</strong></p>
<% } %>
</body>
</html>