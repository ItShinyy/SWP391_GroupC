<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- Expects: avatarUser (User), fallbackIcon (optional FA class, default fa-regular fa-user) --%>
<c:set var="navAvatarIcon" value="${empty fallbackIcon ? 'fa-regular fa-user' : fallbackIcon}"/>
<c:choose>
    <c:when test="${not empty avatarUser.avatar}">
        <img src="<c:out value='${avatarUser.avatar}'/>"
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
