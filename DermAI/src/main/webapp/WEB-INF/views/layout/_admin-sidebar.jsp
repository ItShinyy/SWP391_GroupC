<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<style>
    .admin-sidebar {
        width: 240px;
        min-width: 240px;
        height: calc(100vh - 64px); /* Assuming 64px header */
        overflow-y: auto;
        background-color: #ffffff;
        border-right: 1px solid #e2e8f0;
        transition: width 0.3s ease;
        display: flex;
        flex-direction: column;
    }
    .sidebar-section-title {
        font-size: 0.7rem;
        font-weight: 700;
        color: #94a3b8;
        text-transform: uppercase;
        letter-spacing: 1px;
        padding: 1.5rem 1.25rem 0.5rem;
        transition: opacity 0.2s;
    }
    .sidebar-link {
        display: flex;
        align-items: center;
        padding: 0.75rem 1.25rem;
        color: #475569;
        text-decoration: none;
        font-weight: 500;
        font-size: 0.9rem;
        transition: all 0.2s ease;
        border-left: 3px solid transparent;
        white-space: nowrap;
    }
    .sidebar-link i {
        width: 24px;
        text-align: center;
        font-size: 1.1rem;
        margin-right: 12px;
        transition: margin 0.3s;
    }
    .sidebar-link:hover {
        background-color: #f1f5f9;
        color: #0f172a;
    }
    .sidebar-link.active {
        background-color: #eff6ff;
        color: #1e3a8a;
        border-left-color: #1e3a8a;
        font-weight: 600;
    }

    /* Scrollbar */
    .admin-sidebar::-webkit-scrollbar {
        width: 4px;
    }
    .admin-sidebar::-webkit-scrollbar-track {
        background: transparent;
    }
    .admin-sidebar::-webkit-scrollbar-thumb {
        background: #cbd5e1;
        border-radius: 4px;
    }
</style>

<aside class="admin-sidebar" id="adminSidebar">
    
    <div class="sidebar-section-title">Dashboard</div>
    <a href="${pageContext.request.contextPath}/admin/dashboard" class="sidebar-link ${pageContext.request.requestURI.contains('dashboard') ? 'active' : ''}" title="Dashboard" aria-label="Dashboard">
        <i class="fa-solid fa-chart-pie"></i>
        <span>Dashboard</span>
    </a>

    <div class="sidebar-section-title">Clinical</div>
    <a href="${pageContext.request.contextPath}/admin/bookings" class="sidebar-link ${pageContext.request.requestURI.contains('bookings') ? 'active' : ''}" title="Appointments" aria-label="Appointments">
        <i class="fa-regular fa-calendar-check"></i>
        <span>Appointments</span>
    </a>

    <div class="sidebar-section-title">AI</div>
    <a href="${pageContext.request.contextPath}/admin/ai-results" class="sidebar-link ${pageContext.request.requestURI.contains('ai-results') ? 'active' : ''}" title="AI Results" aria-label="AI Results">
        <i class="fa-solid fa-brain"></i>
        <span>AI Results</span>
    </a>

    <div class="sidebar-section-title">Financial</div>
    <a href="${pageContext.request.contextPath}/admin/invoices" class="sidebar-link ${pageContext.request.requestURI.contains('invoices') ? 'active' : ''}" title="Invoices" aria-label="Invoices">
        <i class="fa-solid fa-file-invoice-dollar"></i>
        <span>Invoices</span>
    </a>

    <div class="sidebar-section-title">Management</div>
    <a href="${pageContext.request.contextPath}/admin/users" class="sidebar-link ${pageContext.request.requestURI.contains('users') ? 'active' : ''}" title="Users &amp; Doctors" aria-label="Users and Doctors">
        <i class="fa-solid fa-users-gear"></i>
        <span>Users &amp; Doctors</span>
    </a>

    <div class="sidebar-section-title">System</div>
    <a href="${pageContext.request.contextPath}/admin/audit-logs" class="sidebar-link ${pageContext.request.requestURI.contains('audit') ? 'active' : ''}" title="Audit Logs" aria-label="Audit Logs">
        <i class="fa-solid fa-clipboard-list"></i>
        <span>Audit Logs</span>
    </a>
    <a href="${pageContext.request.contextPath}/admin/feedback" class="sidebar-link ${pageContext.request.requestURI.contains('feedback') ? 'active' : ''}" title="Feedback" aria-label="Feedback">
        <i class="fa-regular fa-comment-dots"></i>
        <span>Feedback</span>
    </a>
    <a href="${pageContext.request.contextPath}/admin/issue-reports" class="sidebar-link ${pageContext.request.requestURI.contains('issue-reports') ? 'active' : ''}" title="Bug Reports" aria-label="Bug Reports">
        <i class="fa-solid fa-bug"></i>
        <span>Bug Reports</span>
    </a>
    <a href="${pageContext.request.contextPath}/admin/notifications" class="sidebar-link ${pageContext.request.requestURI.contains('admin/notifications') ? 'active' : ''}" title="Notifications" aria-label="Notifications">
        <i class="fa-regular fa-bell"></i>
        <span>Notifications</span>
    </a>

    <div class="mt-auto"></div>
</aside>
