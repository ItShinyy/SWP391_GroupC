<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:choose>
    <c:when test="${user.role == 'ADMIN'}">
        <jsp:include page="/WEB-INF/views/layout/admin-header.jsp" />
    </c:when>
    <c:when test="${user.role == 'DOCTOR'}">
        <jsp:include page="/WEB-INF/views/layout/doctor-header.jsp" />
    </c:when>
    <c:otherwise>
        <jsp:include page="/WEB-INF/views/layout/global-header.jsp" />
    </c:otherwise>
</c:choose>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/profile.css">

<c:set var="isDoctor" value="${user.role == 'DOCTOR'}"/>
<c:set var="isAdmin" value="${user.role == 'ADMIN'}"/>
<c:set var="isPatient" value="${user.role == 'PATIENT' || user.role == 'USER'}"/>

<c:set var="roleLabel" value="${user.role}"/>
<c:choose>
    <c:when test="${isAdmin}"><c:set var="roleLabel" value="Admin"/></c:when>
    <c:when test="${isDoctor}"><c:set var="roleLabel" value="Bác sĩ"/></c:when>
    <c:when test="${isPatient}"><c:set var="roleLabel" value="Bệnh nhân"/></c:when>
</c:choose>

<section class="bento-page">
    <div class="bento-page__inner">
        <h1 class="bento-page__title">Hồ sơ</h1>

        <c:if test="${not empty successMessage}">
            <div class="alert alert-success mb-3" role="alert"><i class="fa-solid fa-circle-check me-2"></i>${successMessage}</div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger mb-3" role="alert"><i class="fa-solid fa-circle-xmark me-2"></i>${errorMessage}</div>
        </c:if>

        <div class="bento-grid ${isDoctor ? '' : 'bento-grid--compact'}">

            <!-- Profile Summary -->
            <article class="bento-card bento-summary">
                <div class="bento-avatar-wrap">
                    <div class="bento-avatar">
                        <c:choose>
                            <c:when test="${not empty user.avatar}">
                                <img src="<c:out value='${user.avatar}'/>" alt="<c:out value='${user.fullName}'/>" referrerpolicy="no-referrer">
                            </c:when>
                            <c:otherwise>
                                <i class="fa-regular fa-user"></i>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <h2 class="bento-summary__name"><c:out value="${user.fullName}"/></h2>
                <p class="bento-summary__user">@<c:out value="${user.username}"/></p>

                <div class="bento-badges">
                    <span class="bento-pill bento-pill--role"><c:out value="${roleLabel}"/></span>
                    <c:if test="${not empty user.googleId}">
                        <span class="bento-pill bento-pill--google">Google</span>
                    </c:if>
                </div>

                <div class="bento-info-rows">
                    <div class="bento-info-row">
                        <span>Role</span>
                        <span><c:out value="${roleLabel}"/></span>
                    </div>
                    <c:if test="${isDoctor && not empty doctorProfile}">
                        <div class="bento-info-row">
                            <span>Clinic</span>
                            <span><c:out value="${doctorProfile.clinicName}"/></span>
                        </div>
                        <div class="bento-info-row">
                            <span>Specialty</span>
                            <span><c:out value="${doctorProfile.specialization}"/></span>
                        </div>
                        <div class="bento-info-row">
                            <span>Doctor ID</span>
                            <span class="bento-field__value--mono"><c:out value="${doctorProfile.id}"/></span>
                        </div>
                    </c:if>
                    <c:if test="${isAdmin}">
                        <div class="bento-info-row">
                            <span>System</span>
                            <span>Full access</span>
                        </div>
                    </c:if>
                </div>

            </article>

            <!-- Account -->
            <article class="bento-card bento-account" id="account">
                <div class="bento-card__head">
                    <div class="bento-card__head-left">
                        <span class="bento-card__icon"><i class="fa-regular fa-user"></i></span>
                        <h2 class="bento-card__title">Account Information</h2>
                    </div>
                </div>
                <div class="bento-fields">
                    <div>
                        <span class="bento-field__label">Full Name</span>
                        <div class="bento-field__value"><c:out value="${user.fullName}"/></div>
                    </div>
                    <div>
                        <span class="bento-field__label">Registration Date</span>
                        <div class="bento-field__value"><c:out value="${empty profileCreatedAt ? '—' : profileCreatedAt}"/></div>
                    </div>
                    <div>
                        <span class="bento-field__label">Username</span>
                        <div class="bento-field__value">@<c:out value="${user.username}"/></div>
                    </div>
                    <div>
                        <span class="bento-field__label">Phone</span>
                        <div class="bento-field__value"><c:out value="${empty profilePhone ? 'Not linked' : profilePhone}"/></div>
                    </div>
                    <div>
                        <span class="bento-field__label">Email</span>
                        <div class="bento-field__value"><c:out value="${empty maskedProfileEmail ? '—' : maskedProfileEmail}"/></div>
                    </div>
                    <div>
                        <span class="bento-field__label">User ID</span>
                        <div class="bento-field__value bento-field__value--mono"><c:out value="${user.id}"/></div>
                    </div>
                </div>
            </article>

            <!-- Security -->
            <article class="bento-card bento-security" id="security">
                <div class="bento-card__head">
                    <div class="bento-card__head-left">
                        <span class="bento-card__icon"><i class="fa-solid fa-shield-halved"></i></span>
                        <h2 class="bento-card__title">Security</h2>
                    </div>
                </div>

                <div class="bento-setting">
                    <div>
                        <h3 class="bento-setting__label">Email</h3>
                        <p class="bento-setting__value">${empty maskedProfileEmail ? 'Not linked' : maskedProfileEmail}</p>
                    </div>
                    <form action="${pageContext.request.contextPath}/account/profile" method="post" class="m-0">
                        <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
                        <input type="hidden" name="action" value="init_security_change">
                        <input type="hidden" name="target" value="EMAIL">
                        <button type="submit" class="btn btn-outline-dark btn-sm">Change</button>
                    </form>
                </div>

                <div class="bento-setting">
                    <div>
                        <h3 class="bento-setting__label">Password</h3>
                        <p class="bento-setting__value">${empty user.passwordHash ? 'Not set' : '••••••••'}</p>
                    </div>
                    <form action="${pageContext.request.contextPath}/account/profile" method="post" class="m-0">
                        <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
                        <input type="hidden" name="action" value="init_security_change">
                        <input type="hidden" name="target" value="PASSWORD">
                        <button type="submit" class="btn btn-outline-dark btn-sm">${empty user.passwordHash ? 'Add' : 'Change'}</button>
                    </form>
                </div>

                <div class="bento-setting">
                    <div style="flex:1;min-width:0;">
                        <h3 class="bento-setting__label">Phone</h3>
                        <p class="bento-setting__value">${empty profilePhone ? 'Not linked' : profilePhone}</p>
                        <form action="${pageContext.request.contextPath}/account/profile" method="post" class="mt-2">
                            <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
                            <input type="hidden" name="action" value="update_contact_phone">
                            <div class="input-group input-group-sm">
                                <input type="text" name="phone" class="form-control" maxlength="20"
                                       placeholder="Phone number" value="${empty profilePhone ? '' : profilePhone}">
                                <button type="submit" class="btn btn-outline-dark">${empty profilePhone ? 'Add' : 'Save'}</button>
                            </div>
                        </form>
                    </div>
                </div>

                <div class="bento-setting">
                    <div>
                        <h3 class="bento-setting__label">Google Account</h3>
                        <p class="bento-setting__value">${empty user.googleId ? 'Not connected' : 'Connected'}</p>
                    </div>
                    <span class="bento-pill ${empty user.googleId ? 'bento-pill--muted' : 'bento-pill--google'}">
                        ${empty user.googleId ? 'None' : 'Google'}
                    </span>
                </div>
            </article>

            <!-- Role Information (doctor / admin only — patient uses Family card) -->
            <c:if test="${isDoctor || isAdmin}">
                <article class="bento-card bento-role" id="role-info">
                    <div class="bento-card__head">
                        <div class="bento-card__head-left">
                            <span class="bento-card__icon"><i class="fa-solid fa-briefcase"></i></span>
                            <h2 class="bento-card__title">Role Information</h2>
                        </div>
                    </div>

                    <c:choose>
                        <c:when test="${isDoctor}">
                            <c:choose>
                                <c:when test="${empty doctorProfile}">
                                    <p class="bento-setting__value mb-0">No doctor profile linked. Contact admin.</p>
                                </c:when>
                                <c:otherwise>
                                    <div class="bento-fields">
                                        <div>
                                            <span class="bento-field__label">Clinic</span>
                                            <div class="bento-field__value"><c:out value="${doctorProfile.clinicName}"/></div>
                                        </div>
                                        <div>
                                            <span class="bento-field__label">License</span>
                                            <div class="bento-field__value"><c:out value="${doctorProfile.licenseNumber}"/></div>
                                        </div>
                                        <div>
                                            <span class="bento-field__label">Specialty</span>
                                            <div class="bento-field__value"><c:out value="${doctorProfile.specialization}"/></div>
                                        </div>
                                        <div>
                                            <span class="bento-field__label">Practice</span>
                                            <div class="bento-field__value">
                                                ${doctorProfile.active ? 'Accepting appointments' : 'Paused'}
                                            </div>
                                        </div>
                                        <div style="grid-column:1/-1;">
                                            <span class="bento-field__label">Bio</span>
                                            <div class="bento-field__value"><c:out value="${empty doctorProfile.bio ? '—' : doctorProfile.bio}"/></div>
                                        </div>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </c:when>
                        <c:otherwise>
                            <div class="bento-fields">
                                <div>
                                    <span class="bento-field__label">System Role</span>
                                    <div class="bento-field__value"><span class="bento-pill bento-pill--role">Administrator</span></div>
                                </div>
                                <div>
                                    <span class="bento-field__label">Permission Level</span>
                                    <div class="bento-field__value">Full system</div>
                                </div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </article>
            </c:if>

            <!-- Family — patients only -->
            <c:if test="${isPatient}">
                <article class="bento-card bento-wide" id="family">
                    <div class="bento-card__head">
                        <div class="bento-card__head-left">
                            <span class="bento-card__icon"><i class="fa-solid fa-people-group"></i></span>
                            <h2 class="bento-card__title">Family</h2>
                        </div>
                        <a class="btn btn-sm btn-success" href="${pageContext.request.contextPath}/patient/family-members">Manage</a>
                    </div>
                    <div class="bento-wide-inner">
                        <div>
                            <strong>
                                <c:choose>
                                    <c:when test="${empty familyMembers}">0 Family Members</c:when>
                                    <c:otherwise>${familyMembers.size} Family Members</c:otherwise>
                                </c:choose>
                            </strong>
                            <p>Book appointments for relatives.</p>
                        </div>
                    </div>
                    <c:if test="${not empty familyMembers}">
                        <ul class="bento-family-list">
                            <c:forEach items="${familyMembers}" var="fm" end="2">
                                <li>
                                    <div>
                                        <div class="fw-semibold"><c:out value="${fm.fullName}"/></div>
                                        <div class="small text-muted"><c:out value="${fm.relationshipLabel}"/></div>
                                    </div>
                                    <a class="btn btn-sm btn-outline-secondary"
                                       href="${pageContext.request.contextPath}/patient/family-members?action=view&amp;id=${fm.id}">View</a>
                                </li>
                            </c:forEach>
                        </ul>
                    </c:if>
                </article>
            </c:if>

        </div>
    </div>
</section>

<c:choose>
    <c:when test="${user.role == 'ADMIN'}">
        <jsp:include page="/WEB-INF/views/layout/admin-footer.jsp" />
    </c:when>
    <c:when test="${user.role == 'DOCTOR'}">
        <jsp:include page="/WEB-INF/views/layout/doctor-footer.jsp" />
    </c:when>
    <c:otherwise>
        <jsp:include page="/WEB-INF/views/layout/global-footer.jsp" />
    </c:otherwise>
</c:choose>
