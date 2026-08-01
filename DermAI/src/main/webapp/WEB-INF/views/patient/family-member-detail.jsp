<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/global-header.jsp" />

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-lg-8">
            <div class="card border-0 shadow-sm rounded-4">
                <div class="card-body p-4 p-md-5">
                    <div class="d-flex justify-content-between align-items-start mb-4">
                        <div>
                            <div class="text-primary small fw-semibold mb-1"><i class="fa-solid fa-people-roof me-1"></i><c:out value="${member.relationshipLabel}" /></div>
                            <h2 class="fw-bold mb-1"><c:out value="${member.fullName}" /></h2>
                            <p class="text-muted mb-0">Thông tin cá nhân người thân</p>
                        </div>
                        <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/account/profile"><i class="fa-solid fa-arrow-left me-1"></i>Quay lại</a>
                    </div>

                    <div class="row g-4">
                        <div class="col-md-6"><div class="text-muted small">Ngày sinh</div><div class="fw-semibold"><c:out value="${member.dateOfBirth}" /></div></div>
                        <div class="col-md-6"><div class="text-muted small">Số điện thoại</div><div class="fw-semibold"><c:out value="${member.phone}" /></div></div>
                        <div class="col-md-6"><div class="text-muted small">Email</div><div class="fw-semibold"><c:out value="${empty member.email ? 'Chưa cập nhật' : member.email}" /></div></div>
                        <div class="col-md-6"><div class="text-muted small">Tỉnh/Thành phố</div><div class="fw-semibold"><c:out value="${member.province}" /></div></div>
                        <div class="col-md-6"><div class="text-muted small">Xã/Phường</div><div class="fw-semibold"><c:out value="${member.ward}" /></div></div>
                        <div class="col-md-6"><div class="text-muted small">Địa chỉ chi tiết</div><div class="fw-semibold"><c:out value="${member.addressDetail}" /></div></div>
                        <div class="col-md-6"><div class="text-muted small">Quốc gia</div><div class="fw-semibold"><c:out value="${member.country}" /></div></div>
                        <div class="col-md-6"><div class="text-muted small">Dân tộc</div><div class="fw-semibold"><c:out value="${member.ethnicity}" /></div></div>
                        <div class="col-md-6"><div class="text-muted small">Nghề nghiệp</div><div class="fw-semibold"><c:out value="${member.occupation}" /></div></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/layout/global-footer.jsp" />
