<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

</main>
<!-- End Main Content -->

<!-- Slim footer -->
<footer class="w-100 bg-white border-top py-3 mt-auto">
  <div class="container d-flex flex-wrap justify-content-between align-items-center">
    <span class="text-muted" style="font-size:0.85rem;">© 2026 DermAI Project – SWP391</span>
    <div class="d-flex gap-4" style="font-size:0.85rem;">
      <a href="${pageContext.request.contextPath}/global/clinics"
         class="text-muted text-decoration-none fw-medium" style="color:#475569;">Phòng Khám</a>
      <a href="${pageContext.request.contextPath}/patient/diagnose"
         class="text-muted text-decoration-none fw-medium" style="color:#475569;">Sàng lọc AI</a>
    </div>
  </div>
</footer>

<!-- Bootstrap 5 JS Bundle with Popper -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
