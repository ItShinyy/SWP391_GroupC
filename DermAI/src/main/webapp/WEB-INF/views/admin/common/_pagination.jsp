<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%--
  Compact admin pager. Expects:
    currentPage, totalPages
    pageQuery (optional) — extra query string starting with &, e.g. &keyword=x&status=y
--%>
<c:if test="${totalPages > 1}">
    <c:set var="startPage" value="${currentPage - 2}"/>
    <c:if test="${startPage < 1}"><c:set var="startPage" value="1"/></c:if>
    <c:set var="endPage" value="${currentPage + 2}"/>
    <c:if test="${endPage > totalPages}"><c:set var="endPage" value="${totalPages}"/></c:if>

    <div class="p-3 border-top">
        <nav aria-label="Page navigation" class="mb-0">
            <ul class="pagination pagination-sm justify-content-center flex-wrap mb-0 gap-1">
                <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                    <a class="page-link" href="?page=${currentPage - 1}${pageQuery}">Trước</a>
                </li>

                <c:if test="${startPage > 1}">
                    <li class="page-item">
                        <a class="page-link" href="?page=1${pageQuery}">1</a>
                    </li>
                    <c:if test="${startPage > 2}">
                        <li class="page-item disabled"><span class="page-link">…</span></li>
                    </c:if>
                </c:if>

                <c:forEach begin="${startPage}" end="${endPage}" var="i">
                    <li class="page-item ${i == currentPage ? 'active' : ''}">
                        <a class="page-link" href="?page=${i}${pageQuery}">${i}</a>
                    </li>
                </c:forEach>

                <c:if test="${endPage < totalPages}">
                    <c:if test="${endPage < totalPages - 1}">
                        <li class="page-item disabled"><span class="page-link">…</span></li>
                    </c:if>
                    <li class="page-item">
                        <a class="page-link" href="?page=${totalPages}${pageQuery}">${totalPages}</a>
                    </li>
                </c:if>

                <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                    <a class="page-link" href="?page=${currentPage + 1}${pageQuery}">Sau</a>
                </li>
            </ul>
        </nav>
        <div class="text-center text-muted small mt-2">
            Trang ${currentPage} / ${totalPages}
            <c:if test="${not empty totalItems}"> — ${totalItems} dòng</c:if>
            <c:if test="${not empty pageSize}"> · ${pageSize}/trang</c:if>
        </div>
    </div>
</c:if>
