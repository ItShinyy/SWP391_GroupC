<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/admin-header.jsp" />

<div class="container-fluid admin-page">
    <div class="d-flex flex-wrap justify-content-between align-items-center admin-toolbar">
        <div>
            <h1 class="page-title mb-0">AI Models</h1>
            <p class="page-subtitle mb-0">Packages, activation, and clinical policy guidance</p>
        </div>
    </div>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-warning py-2"><c:out value="${errorMessage}"/></div>
    </c:if>
    <c:if test="${param.updated == '1'}">
        <div class="alert alert-success py-2">Saved.</div>
    </c:if>

    <div class="row g-2 admin-kpi-row mb-2">
        <div class="col-6 col-md-3">
            <div class="card admin-kpi-card border-0 shadow-sm h-100">
                <div class="card-body py-2 px-3">
                    <div class="text-muted small">Installed</div>
                    <div class="fs-4 fw-semibold">${modelCount}</div>
                </div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="card admin-kpi-card border-0 shadow-sm h-100">
                <div class="card-body py-2 px-3">
                    <div class="text-muted small">Active</div>
                    <div class="fs-4 fw-semibold text-success">${activeModelCount}</div>
                </div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="card admin-kpi-card border-0 shadow-sm h-100">
                <div class="card-body py-2 px-3">
                    <div class="text-muted small">Policies</div>
                    <div class="fs-4 fw-semibold">${policyCount}</div>
                </div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="card admin-kpi-card border-0 shadow-sm h-100">
                <div class="card-body py-2 px-3">
                    <div class="text-muted small">Manage</div>
                    <div class="small fw-semibold">Models · Policy</div>
                </div>
            </div>
        </div>
    </div>

    <div class="card border-0 shadow-sm admin-section mb-2">
        <div class="card-body py-2 px-3">
            <h2 class="h6 mb-1">Upload package</h2>
            <p class="small text-muted mb-2">Zip must contain <code>model.onnx</code>, <code>labels.json</code>, <code>reference_features.npz</code>, <code>metadata.json</code> (package_version 1).</p>
            <form method="post" enctype="multipart/form-data" class="row g-2 align-items-end">
                <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
                <input type="hidden" name="action" value="upload">
                <div class="col-md-9">
                    <input class="form-control form-control-sm" type="file" name="packageZip" accept=".zip,application/zip" required>
                </div>
                <div class="col-md-3">
                    <button class="btn btn-sm btn-primary w-100" type="submit">Upload</button>
                </div>
            </form>
        </div>
    </div>

    <div class="card border-0 shadow-sm admin-section mb-2">
        <div class="card-body py-2 px-3">
            <h2 class="h6 mb-2">Installed models</h2>
            <div class="table-responsive">
                <table class="table table-sm table-hover align-middle mb-0">
                    <thead class="table-dark">
                        <tr>
                            <th>Name</th>
                            <th>Version</th>
                            <th>Status</th>
                            <th>Created</th>
                            <th class="text-end">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty models}">
                                <tr><td colspan="5" class="text-center text-muted py-3">No models uploaded yet.</td></tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach items="${models}" var="m">
                                    <tr>
                                        <td class="fw-semibold"><c:out value="${m.name}"/></td>
                                        <td>v<c:out value="${m.version}"/></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${m.active}"><span class="badge bg-success">ACTIVE</span></c:when>
                                                <c:otherwise><span class="badge bg-secondary">INACTIVE</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="small text-muted"><c:out value="${m.createdAt}"/></td>
                                        <td class="text-end">
                                            <div class="d-inline-flex flex-wrap gap-1 justify-content-end">
                                                <c:if test="${not m.active}">
                                                    <form method="post" class="m-0">
                                                        <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
                                                        <input type="hidden" name="action" value="activate">
                                                        <input type="hidden" name="modelId" value="${m.id}">
                                                        <button class="btn btn-sm btn-success" type="submit">Activate</button>
                                                    </form>
                                                    <form method="post" class="m-0">
                                                        <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
                                                        <input type="hidden" name="action" value="delete">
                                                        <input type="hidden" name="modelId" value="${m.id}">
                                                        <button class="btn btn-sm btn-outline-danger" type="submit">Delete</button>
                                                    </form>
                                                </c:if>
                                                <c:if test="${m.active}">
                                                    <form method="post" class="m-0">
                                                        <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
                                                        <input type="hidden" name="action" value="deactivate">
                                                        <input type="hidden" name="modelId" value="${m.id}">
                                                        <button class="btn btn-sm btn-outline-secondary" type="submit">Deactivate</button>
                                                    </form>
                                                </c:if>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <div class="card border-0 shadow-sm admin-section mb-2">
        <div class="card-body py-2 px-3">
            <h2 class="h6 mb-2">Clinical policies</h2>
            <div class="table-responsive">
                <table class="table table-sm table-hover align-middle mb-0">
                    <thead class="table-dark">
                        <tr>
                            <th>Code</th>
                            <th>Display name</th>
                            <th>Risk</th>
                            <th>Recommendation</th>
                            <th class="text-end">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty policies}">
                                <tr><td colspan="5" class="text-center text-muted py-3">No policies configured.</td></tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach items="${policies}" var="p">
                                    <tr>
                                        <td class="font-monospace small"><c:out value="${p.diseaseCode}"/></td>
                                        <td><c:out value="${p.displayName}"/></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${p.riskLevel == 'HIGH'}"><span class="badge bg-danger">HIGH</span></c:when>
                                                <c:when test="${p.riskLevel == 'MEDIUM'}"><span class="badge bg-warning text-dark">MEDIUM</span></c:when>
                                                <c:otherwise><span class="badge bg-success">LOW</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="small text-truncate" style="max-width: 280px;"><c:out value="${p.recommendation}"/></td>
                                        <td class="text-end">
                                            <button type="button"
                                                    class="btn btn-sm btn-outline-primary"
                                                    data-bs-toggle="modal"
                                                    data-bs-target="#policyModal"
                                                    data-code="<c:out value='${p.diseaseCode}'/>"
                                                    data-name="<c:out value='${p.displayName}'/>"
                                                    data-risk="<c:out value='${p.riskLevel}'/>"
                                                    data-recommendation="<c:out value='${p.recommendation}'/>"
                                                    data-disclaimer="<c:out value='${p.disclaimer}'/>">
                                                Edit
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <div class="modal fade" id="policyModal" tabindex="-1" aria-labelledby="policyModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-scrollable">
            <form method="post" class="modal-content">
                <input type="hidden" name="csrf_token" value="${sessionScope.csrfToken}">
                <input type="hidden" name="action" value="savePolicy">
                <input type="hidden" name="diseaseCode" id="policyDiseaseCode">
                <div class="modal-header py-2">
                    <h5 class="modal-title h6 mb-0" id="policyModalLabel">Edit clinical policy</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-2">
                        <label class="form-label small mb-1">Disease code</label>
                        <input class="form-control form-control-sm" id="policyCodeDisplay" readonly>
                    </div>
                    <div class="row g-2">
                        <div class="col-md-8">
                            <label class="form-label small mb-1">Display name</label>
                            <input class="form-control form-control-sm" name="displayName" id="policyDisplayName" required>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label small mb-1">Risk</label>
                            <select class="form-select form-select-sm" name="riskLevel" id="policyRiskLevel" required>
                                <option value="LOW">LOW</option>
                                <option value="MEDIUM">MEDIUM</option>
                                <option value="HIGH">HIGH</option>
                            </select>
                        </div>
                        <div class="col-12">
                            <label class="form-label small mb-1">Recommendation</label>
                            <textarea class="form-control form-control-sm" name="recommendation" id="policyRecommendation" rows="3" required></textarea>
                        </div>
                        <div class="col-12">
                            <label class="form-label small mb-1">Disclaimer</label>
                            <textarea class="form-control form-control-sm" name="disclaimer" id="policyDisclaimer" rows="3" required></textarea>
                        </div>
                    </div>
                </div>
                <div class="modal-footer py-2">
                    <button type="button" class="btn btn-sm btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-sm btn-primary">Save policy</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        (function () {
            var modal = document.getElementById('policyModal');
            if (!modal) return;
            modal.addEventListener('show.bs.modal', function (event) {
                var btn = event.relatedTarget;
                if (!btn) return;
                document.getElementById('policyDiseaseCode').value = btn.getAttribute('data-code') || '';
                document.getElementById('policyCodeDisplay').value = btn.getAttribute('data-code') || '';
                document.getElementById('policyDisplayName').value = btn.getAttribute('data-name') || '';
                document.getElementById('policyRiskLevel').value = btn.getAttribute('data-risk') || 'LOW';
                document.getElementById('policyRecommendation').value = btn.getAttribute('data-recommendation') || '';
                document.getElementById('policyDisclaimer').value = btn.getAttribute('data-disclaimer') || '';
            });
        })();
    </script>
</div>

<jsp:include page="/WEB-INF/views/layout/admin-footer.jsp" />
