<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
    <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

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

        <c:set var="isDoctor" value="${user.role == 'DOCTOR'}" />
        <c:set var="isAdmin" value="${user.role == 'ADMIN'}" />
        <c:set var="isPatient" value="${user.role == 'PATIENT' || user.role == 'USER'}" />

        <c:set var="roleLabel" value="${user.role}" />
        <c:choose>
            <c:when test="${isAdmin}">
                <c:set var="roleLabel" value="Admin" />
            </c:when>
            <c:when test="${isDoctor}">
                <c:set var="roleLabel" value="Bác sĩ" />
            </c:when>
            <c:when test="${isPatient}">
                <c:set var="roleLabel" value="Bệnh nhân" />
            </c:when>
        </c:choose>

        <style>
            body {
                background-color: #F8FAFC !important;
                font-family: 'Inter', sans-serif;
            }

            .profile-container {
                max-width: 1400px;
                margin: 0 auto;
                padding: 12px 24px 4px;
            }

            /* Layout */
            .profile-hero {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 12px;
            }

            .hero-title {
                font-size: 36px;
                font-weight: 700;
                color: #0F172A;
                line-height: 1.1;
                letter-spacing: -1px;
            }

            .hero-title span {
                color: #16A34A;
            }

            .hero-subtitle {
                color: #64748B;
                font-size: 14px;
                margin-top: 4px;
            }

            .hero-illustration {
                width: 200px;
                height: 100px;
                background: url('https://illustrations.popsy.co/green/security.svg') no-repeat center right;
                background-size: contain;
            }

            .cards-row {
                display: flex;
                gap: 16px;
                align-items: stretch;
            }

            /* Cards */
            .p-card {
                background: #FFFFFF;
                border-radius: 20px;
                box-shadow: 0 8px 30px rgba(0, 0, 0, .03);
                border: 1px solid #E8EEF3;
                flex: 1;
                display: flex;
                flex-direction: column;
                overflow: hidden;
            }

            .card-header-main {
                display: flex;
                align-items: center;
                padding: 8px 16px;
                border-bottom: 1px solid #EEF2F7;
            }

            .c-icon {
                width: 40px;
                height: 40px;
                background: #F0FDF4;
                color: #16A34A;
                border-radius: 12px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 18px;
                margin-right: 16px;
            }

            .c-title {
                font-size: 20px;
                font-weight: 700;
                color: #0F172A;
                margin: 0;
            }

            /* Card 1: Profile */
            .p-cover {
                height: 50px;
                background: linear-gradient(135deg, #F0FDF4 0%, #DCFCE7 100%);
                border-radius: 20px 20px 0 0;
                position: relative;
            }

            /* SVG curve at bottom of cover */
            .p-cover::after {
                content: '';
                position: absolute;
                bottom: 0;
                left: 0;
                width: 100%;
                height: 16px;
                background: white;
                border-radius: 16px 16px 0 0;
            }

            .p-avatar-wrapper {
                display: flex;
                margin-bottom: -10px;
                justify-content: center;
                position: relative;
                z-index: 2;
            }

            .p-avatar {
                width: 90px;
                height: 90px;
                border-radius: 50%;
                border: 4px solid #FFFFFF;
                background: #E2E8F0;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 36px;
                color: #94A3B8;
                object-fit: cover;
                position: relative;
            }

            .p-avatar-btn {
                position: absolute;
                bottom: 0;
                right: 0;
                width: 32px;
                height: 32px;
                background: #16A34A;
                color: white;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                border: 3px solid white;
                cursor: pointer;
            }

            .p-info-center {
                text-align: center;
                padding: 8px 16px 16px;
            }

            .p-name {
                font-size: 28px;
                font-weight: 700;
                color: #0F172A;
                margin: 0 0 16px;
            }

            .p-badges {
                display: flex;
                justify-content: center;
                gap: 12px;
            }

            .badge-pill {
                height: 32px;
                padding: 0 16px;
                border-radius: 99px;
                display: inline-flex;
                align-items: center;
                font-size: 13px;
                font-weight: 600;
            }

            .badge-role {
                background: #DCFCE7;
                color: #15803D;
            }

            .badge-google {
                background: white;
                color: #334155;
                border: 1px solid #E2E8F0;
                gap: 6px;
            }

            /* Card 2: Account Info */
            .acc-grid {
                padding: 8px 16px;
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 8px;
            }

            .acc-item {
                display: flex;
                align-items: flex-start;
                gap: 12px;
            }

            .acc-icon {
                width: 32px;
                height: 32px;
                background: #F8FAFC;
                color: #94A3B8;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 14px;
                flex-shrink: 0;
            }

            .acc-label {
                font-size: 13px;
                color: #64748B;
                font-weight: 500;
                margin-bottom: 4px;
            }

            .acc-val {
                font-size: 15px;
                color: #0F172A;
                font-weight: 500;
                word-break: break-all;
            }

            /* Card 3: Security */
            .sec-list {
                padding: 4px 16px;
            }

            .sec-row {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 10px 0;
                border-bottom: 1px solid #EEF2F7;
            }

            .sec-row:last-child {
                border-bottom: none;
            }

            .sec-info {
                display: flex;
                align-items: center;
                gap: 16px;
            }

            .sec-icon {
                width: 36px;
                height: 36px;
                background: #F8FAFC;
                color: #64748B;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
            }

            .sec-label {
                font-size: 14px;
                font-weight: 600;
                color: #0F172A;
                margin: 0 0 2px;
            }

            .sec-val {
                font-size: 13px;
                color: #64748B;
                margin: 0;
            }

            .btn-action {
                height: 36px;
                padding: 0 20px;
                border-radius: 10px;
                font-size: 14px;
                font-weight: 600;
                border: 1px solid #E2E8F0;
                background: white;
                color: #334155;
                transition: all 0.2s;
                text-decoration: none;
                display: inline-flex;
                align-items: center;
                justify-content: center;
            }

            .btn-action:hover {
                background: #F8FAFC;
                border-color: #CBD5E1;
                color: #0F172A;
            }

            /* Family Section Container */
            .fam-section {
                margin-top: 24px;
                background: white;
                border-radius: 20px;
                box-shadow: 0 8px 30px rgba(0, 0, 0, .03);
                border: 1px solid #E8EEF3;
                height: 340px;
                display: flex;
                flex-direction: column;
                overflow: hidden;
            }

            .fam-header-flex {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 20px 24px;
                border-bottom: 1px solid #EEF2F7;
                flex-shrink: 0;
            }

            .fam-btn {
                background: #16A34A;
                color: white;
                border: none;
                height: 40px;
                padding: 0 20px;
                border-radius: 10px;
                font-weight: 600;
                transition: background 0.2s;
                text-decoration: none;
                display: inline-flex;
                align-items: center;
            }

            .fam-btn:hover {
                background: #15803D;
                color: white;
            }

            .fam-btn-outline {
                background: white;
                color: #16A34A;
                border: 1px solid #16A34A;
                height: 40px;
                padding: 0 20px;
                border-radius: 10px;
                font-weight: 600;
                text-decoration: none;
                display: inline-flex;
                align-items: center;
                transition: all 0.2s;
            }

            .fam-btn-outline:hover {
                background: #F0FDF4;
                color: #15803D;
            }

            .fam-body-grid-container {
                flex: 1;
                padding: 24px;
                overflow-y: auto;
            }

            .fam-body-grid-container::-webkit-scrollbar {
                width: 6px;
            }

            .fam-body-grid-container::-webkit-scrollbar-thumb {
                background-color: #CBD5E1;
                border-radius: 6px;
            }

            .fam-grid {
                display: flex;
                flex-wrap: wrap;
                gap: 16px;
            }

            /* Family Member Card */
            .fm-card {
                height: 120px;
                width: 120px;
                border-radius: 16px;
                border: 1px solid #E8EEF3;
                padding: 12px;
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                position: relative;
                transition: all 0.2s ease;
                background: white;
                text-decoration: none;
                color: inherit;
            }

            .fm-card:hover {
                transform: translateY(-2px);
                border-color: #16A34A;
                box-shadow: 0 4px 12px rgba(22, 163, 74, 0.08);
                color: inherit;
            }

            .fm-avatar {
                width: 48px;
                height: 48px;
                border-radius: 50%;
                background: #DCFCE7;
                color: #15803D;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 18px;
                margin-bottom: 8px;
                flex-shrink: 0;
            }

            .fm-info {
                flex: 1;
                width: 100%;
                text-align: center;
            }

            .fm-name {
                font-size: 14px;
                font-weight: 600;
                color: #0F172A;
                margin: 0 0 2px;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
            }

            .fm-rel {
                font-size: 12px;
                color: #64748B;
                margin: 0;
            }

            .fm-more {
                position: absolute;
                top: 8px;
                right: 4px;
                z-index: 5;
            }

            /* Add Member Card */
            .fm-add-card {
                height: 120px;
                width: 120px;
                border-radius: 16px;
                border: 2px dashed #CBD5E1;
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                gap: 8px;
                color: #16A34A;
                font-weight: 600;
                text-decoration: none;
                transition: all 0.2s ease;
                background: transparent;
            }

            .fm-add-card:hover {
                background: #F0FDF4;
                border-color: #16A34A;
                border-style: solid;
                color: #15803D;
            }

            .fm-add-icon {
                font-size: 24px;
            }

            .fm-add-text {
                font-size: 13px;
                text-align: center;
            }

            /* Empty State */
            .fm-empty {
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                height: 100%;
                text-align: center;
            }

            .fm-empty-img {
                width: 120px;
                height: 80px;
                background: url('https://illustrations.popsy.co/green/teamwork.svg') no-repeat center;
                background-size: contain;
                margin-bottom: 16px;
            }
        </style>

        <div class="profile-container">

            <c:if test="${not empty successMessage}">
                <div class="alert alert-success mb-4" style="border-radius:12px;"><i
                        class="fa-solid fa-circle-check me-2"></i>${successMessage}</div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger mb-4" style="border-radius:12px;"><i
                        class="fa-solid fa-circle-xmark me-2"></i>${errorMessage}</div>
            </c:if>

            <!-- Hero -->
            <div class="profile-hero">
                <div>
                    <h1 class="hero-title">Hồ sơ của <span>bạn</span></h1>
                    <p class="hero-subtitle">Quản lý thông tin tài khoản và bảo mật.</p>
                </div>
                <!-- Placeholder illustration -->
                <div class="hero-illustration d-none d-md-block"></div>
            </div>

            <!-- 3 Cards Row -->
            <div class="cards-row">

                <!-- Card 1: Profile -->
                <div class="p-card">
                    <div class="p-cover"></div>
                    <div class="p-avatar-wrapper">
                        <c:choose>
                            <c:when test="${not empty user.avatar}">
                                <c:set var="resolvedAvatar" value="${user.avatar}" />
                                <c:if test="${not fn:startsWith(resolvedAvatar, 'http') and not fn:startsWith(resolvedAvatar, '/')}">
                                    <c:set var="resolvedAvatar" value="/${resolvedAvatar}" />
                                </c:if>
                                <c:if test="${fn:startsWith(resolvedAvatar, '/') and not fn:startsWith(resolvedAvatar, pageContext.request.contextPath)}">
                                    <c:set var="resolvedAvatar" value="${pageContext.request.contextPath}${resolvedAvatar}" />
                                </c:if>
                                <img src="<c:out value='${resolvedAvatar}'/>" alt="Avatar" class="p-avatar"
                                    referrerpolicy="no-referrer">
                            </c:when>
                            <c:otherwise>
                                <div class="p-avatar"><i class="fa-solid fa-user"></i></div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="p-info-center">
                        <h2 class="p-name">
                            <c:out value="${user.fullName}" />
                        </h2>
                    </div>
                </div>

                <!-- Card 2: Account Info -->
                <div class="p-card">
                    <div class="card-header-main">
                        <div class="c-icon"><i class="fa-regular fa-user"></i></div>
                        <h3 class="c-title">Thông tin tài khoản</h3>
                    </div>
                    <div class="acc-grid">
                        <!-- Col 1 -->
                        <div class="d-flex flex-column gap-4">
                            <div class="acc-item">
                                <div class="acc-icon"><i class="fa-solid fa-user-group"></i></div>
                                <div>
                                    <div class="acc-label">Họ và tên</div>
                                    <div class="acc-val">
                                        <c:out value="${user.fullName}" />
                                    </div>
                                </div>
                            </div>
                            <div class="acc-item">
                                <div class="acc-icon"><i class="fa-solid fa-at"></i></div>
                                <div>
                                    <div class="acc-label">Tên người dùng</div>
                                    <div class="acc-val">@
                                        <c:out value="${user.username}" />
                                    </div>
                                </div>
                            </div>
                            <div class="acc-item">
                                <div class="acc-icon"><i class="fa-regular fa-envelope"></i></div>
                                <div>
                                    <div class="acc-label">Email</div>
                                    <div class="acc-val">
                                        <c:out value="${empty maskedProfileEmail ? '—' : maskedProfileEmail}" />
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!-- Col 2 -->
                        <div class="d-flex flex-column gap-4">
                            <div class="acc-item">
                                <div class="acc-icon"><i class="fa-regular fa-calendar"></i></div>
                                <div>
                                    <div class="acc-label">Ngày đăng ký</div>
                                    <div class="acc-val">
                                        <c:out value="${empty profileCreatedAt ? '—' : profileCreatedAt}" />
                                    </div>
                                </div>
                            </div>
                            <div class="acc-item">
                                <div class="acc-icon"><i class="fa-solid fa-phone"></i></div>
                                <div>
                                    <div class="acc-label">Số điện thoại</div>
                                    <div class="acc-val">
                                        <c:out value="${empty profilePhone ? 'Not linked' : profilePhone}" />
                                    </div>
                                </div>
                            </div>
                            <div class="acc-item">
                                <div class="acc-icon"><i class="fa-solid fa-id-badge"></i></div>
                                <div>
                                    <div class="acc-label">User ID</div>
                                    <div class="acc-val text-truncate" style="max-width: 150px;"
                                        title="<c:out value='${user.id}'/>">
                                        <c:out value="${user.id}" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Card 3: Security -->
                <div class="p-card">
                    <div class="card-header-main">
                        <div class="c-icon"><i class="fa-solid fa-shield-halved"></i></div>
                        <h3 class="c-title">Bảo mật</h3>
                    </div>
                    <div class="sec-list">
                        <!-- Email -->
                        <div class="sec-row">
                            <div class="sec-info">
                                <div class="sec-icon"><i class="fa-regular fa-envelope"></i></div>
                                <div>
                                    <h4 class="sec-label">Email</h4>
                                    <p class="sec-val">${empty maskedProfileEmail ? 'Chưa liên kết' :
                                        maskedProfileEmail}</p>
                                </div>
                            </div>
                            <form action="${pageContext.request.contextPath}/account/profile" method="post" class="m-0">
                                <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
                                <input type="hidden" name="action" value="init_security_change">
                                <input type="hidden" name="target" value="EMAIL">
                                <button type="submit" class="btn-action">Đổi</button>
                            </form>
                        </div>
                        <!-- Password -->
                        <div class="sec-row">
                            <div class="sec-info">
                                <div class="sec-icon"><i class="fa-solid fa-lock"></i></div>
                                <div>
                                    <h4 class="sec-label">Mật khẩu</h4>
                                    <p class="sec-val">${empty user.passwordHash ? 'Chưa thiết lập' : 'Đã thiết lập'}
                                    </p>
                                </div>
                            </div>
                            <form action="${pageContext.request.contextPath}/account/profile" method="post" class="m-0">
                                <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
                                <input type="hidden" name="action" value="init_security_change">
                                <input type="hidden" name="target" value="PASSWORD">
                                <button type="submit" class="btn-action">${empty user.passwordHash ? 'Thêm' :
                                    'Đổi'}</button>
                            </form>
                        </div>
                        <!-- Phone -->
                        <div class="sec-row">
                            <div class="sec-info">
                                <div class="sec-icon"><i class="fa-solid fa-phone"></i></div>
                                <div>
                                    <h4 class="sec-label">Số điện thoại</h4>
                                    <p class="sec-val">${empty profilePhone ? 'Chưa liên kết' : profilePhone}</p>
                                </div>
                            </div>
                            <button type="button" class="btn-action" data-bs-toggle="modal"
                                data-bs-target="#phoneModal">${empty profilePhone ? 'Thêm' : 'Đổi'}</button>
                        </div>
                        <!-- Google -->
                        <div class="sec-row">
                            <div class="sec-info">
                                <div class="sec-icon" style="background:white; border:1px solid #EEF2F7;"><img
                                        src="https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg"
                                        style="width:18px;"></div>
                                <div>
                                    <h4 class="sec-label">Tài khoản Google</h4>
                                    <p class="sec-val">${empty user.googleId ? 'Chưa liên kết' : 'Đã liên kết'}</p>
                                </div>
                            </div>
                            <c:if test="${not empty user.googleId}">
                                <div class="badge-pill badge-google bg-light text-muted border-0"><img
                                        src="https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg"
                                        style="width:14px;"> Google</div>
                            </c:if>
                            <c:if test="${empty user.googleId}">
                                <a href="${pageContext.request.contextPath}/auth/google" class="btn-action">Liên kết</a>
                            </c:if>
                        </div>
                    </div>
                </div>

            </div>

            <!-- Family Section -->
            <c:if test="${isPatient}">
                <div class="fam-section">
                    <div class="fam-header-flex">
                        <div class="d-flex align-items-center">
                            <div class="c-icon" style="width:48px;height:48px;margin-right:20px;"><i
                                    class="fa-solid fa-people-group"></i></div>
                            <div>
                                <h3 class="c-title mb-1">Gia đình</h3>
                                <p class="text-muted small mb-0">Quản lý thành viên trong gia đình.</p>
                            </div>
                        </div>
                        <div class="d-flex gap-2">
                            <a href="${pageContext.request.contextPath}/patient/family-members"
                                class="fam-btn-outline d-none d-md-flex">Quản lý gia đình</a>
                            <a href="${pageContext.request.contextPath}/patient/family-members?action=add"
                                class="fam-btn"><i class="fa-solid fa-plus me-2"></i> Thêm thành viên</a>
                        </div>
                    </div>

                    <div class="fam-body-grid-container">
                        <c:choose>
                            <c:when test="${empty familyMembers}">
                                <div class="fm-empty">
                                    <div class="fm-empty-img"></div>
                                    <h4 class="fw-bold mb-2" style="color:#0F172A;font-size:20px;">Bạn chưa thêm thành
                                        viên nào</h4>
                                    <p class="text-muted mb-3 small">Thêm thành viên gia đình để dễ dàng đặt lịch khám
                                        cho người thân.</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="fam-grid">
                                    <c:forEach items="${familyMembers}" var="fm">
                                        <a href="${pageContext.request.contextPath}/patient/family-members?action=view&amp;id=${fm.id}"
                                            class="fm-card">
                                            <div class="fm-avatar"><i class="fa-regular fa-user"></i></div>
                                            <div class="fm-info">
                                                <h4 class="fm-name">
                                                    <c:out value="${fm.fullName}" />
                                                </h4>
                                                <p class="fm-rel">
                                                    <c:out value="${fm.relationshipLabel}" />
                                                </p>
                                            </div>
                                            <div class="fm-more dropdown" onclick="event.preventDefault();">
                                                <button class="bg-transparent border-0 text-muted p-2"
                                                    data-bs-toggle="dropdown" aria-expanded="false">
                                                    <i class="fa-solid fa-ellipsis-vertical"></i>
                                                </button>
                                                <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0">
                                                    <li><a class="dropdown-item"
                                                            href="${pageContext.request.contextPath}/patient/family-members?action=view&amp;id=${fm.id}">Xem
                                                            chi tiết</a></li>
                                                    <li><a class="dropdown-item"
                                                            href="${pageContext.request.contextPath}/patient/family-members?action=edit&amp;id=${fm.id}">Chỉnh
                                                            sửa</a></li>
                                                    <li>
                                                        <hr class="dropdown-divider">
                                                    </li>
                                                    <li><a class="dropdown-item text-danger"
                                                            href="${pageContext.request.contextPath}/patient/family-members?action=delete&amp;id=${fm.id}">Xóa
                                                            thành viên</a></li>
                                                </ul>
                                            </div>
                                        </a>
                                    </c:forEach>
                                    <a href="${pageContext.request.contextPath}/patient/family-members?action=add"
                                        class="fm-add-card" style="width:120px;">
                                        <i class="fa-solid fa-plus fm-add-icon"></i>
                                        <span class="fm-add-text">Thêm thành viên</span>
                                    </a>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </c:if>

        </div>

        <!-- Phone Modal -->
        <div class="modal fade" id="phoneModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content"
                    style="border-radius:20px; border:none; box-shadow:0 10px 40px rgba(0,0,0,0.1);">
                    <div class="modal-header border-0 pb-0">
                        <h5 class="modal-title fw-bold">Cập nhật số điện thoại</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <form action="${pageContext.request.contextPath}/account/profile" method="post">
                        <div class="modal-body py-4">
                            <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
                            <input type="hidden" name="action" value="update_contact_phone">
                            <input type="text" name="phone" class="form-control form-control-lg" maxlength="20"
                                placeholder="Số điện thoại" value="${empty profilePhone ? '' : profilePhone}"
                                style="border-radius:12px;">
                        </div>
                        <div class="modal-footer border-0 pt-0">
                            <button type="button" class="btn-action" data-bs-dismiss="modal">Hủy</button>
                            <button type="submit" class="fam-btn">Lưu thay đổi</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

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