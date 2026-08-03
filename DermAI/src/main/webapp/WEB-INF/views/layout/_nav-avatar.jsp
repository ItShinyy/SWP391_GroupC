<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%-- Expects: avatarUser (User), fallbackIcon (optional FA class, default fa-regular fa-user) --%>
<c:set var="navAvatarIcon" value="${empty fallbackIcon ? 'fa-regular fa-user' : fallbackIcon}"/>
<c:choose>
    <c:when test="${not empty avatarUser.avatar}">
        <c:set var="resolvedAvatar" value="${avatarUser.avatar}" />
        <c:if test="${not fn:startsWith(resolvedAvatar, 'http') and not fn:startsWith(resolvedAvatar, '/')}">
            <c:set var="resolvedAvatar" value="/${resolvedAvatar}" />
        </c:if>
        <c:if test="${fn:startsWith(resolvedAvatar, '/') and not fn:startsWith(resolvedAvatar, pageContext.request.contextPath)}">
            <c:set var="resolvedAvatar" value="${pageContext.request.contextPath}${resolvedAvatar}" />
        </c:if>
        <img src="<c:out value='${resolvedAvatar}'/>"
             alt=""
             class="nav-avatar"
             width="28"
             height="28"
             referrerpolicy="no-referrer"
             loading="lazy">
    </c:when>
    <c:otherwise>
        <i class="${navAvatarIcon} me-1"></i>
    </c:otherwise>
</c:choose>
