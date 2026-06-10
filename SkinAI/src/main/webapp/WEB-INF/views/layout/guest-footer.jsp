<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

</main>
<!-- End Main Content -->

<style>
    /* CSS hiệu ứng tương tác nâng cao cho Footer */
    .footer-link {
        color: #64748b;
        text-decoration: none;
        transition: all 0.3s ease;
        display: inline-block;
    }
    .footer-link:hover {
        color: #198754 !important; /* Màu xanh lá đặc trưng của SkinAI */
        transform: translateX(4px);
    }
    .social-icon {
        color: #64748b;
        transition: all 0.3s ease;
    }
    .social-icon:hover {
        color: #198754;
        transform: translateY(-3px);
    }
    .disclaimer-box {
        border-left: 4px solid #ffc107;
        background-color: #fffbeb;
        border-radius: 12px;
        padding: 1rem;
        transition: transform 0.3s ease;
    }
    .disclaimer-box:hover {
        transform: translateY(-2px);
    }
</style>

<footer class="bg-white pt-5 pb-4 mt-5 border-top">
    <div class="container">
        <div class="row g-4">
            <!-- Column 1: Brand & Socials -->
            <div class="col-12 col-md-4 mb-4">
                <h3 class="fw-bold m-0" style="color: #198754; font-family: 'Inter', sans-serif;">
                    Skin<span class="text-dark">AI</span>
                </h3>
                <p class="text-muted mt-3 mb-4" style="font-size: 0.9rem; line-height: 1.6;">
                    An artificial intelligence platform supporting preliminary diagnosis of dermatological conditions through images. Fast, secure, and convenient.
                </p>
                <div class="d-flex gap-3">
                    <a href="#" class="social-icon fs-4"><i class="fa-brands fa-facebook"></i></a>
                    <a href="#" class="social-icon fs-4"><i class="fa-brands fa-twitter"></i></a>
                    <a href="#" class="social-icon fs-4"><i class="fa-brands fa-linkedin"></i></a>
                </div>
            </div>
            
            <!-- Column 2: Quick Links -->
            <div class="col-12 col-md-4 mb-4 px-md-5">
                <h5 class="fw-bold mb-4 text-dark" style="font-size: 1.1rem; letter-spacing: -0.2px;">Quick Links</h5>
                <ul class="list-unstyled m-0">
                    <li class="mb-2">
                        <a href="${pageContext.request.contextPath}/home" class="footer-link">
                            <i class="fa-solid fa-chevron-right me-1 small" style="font-size: 0.7rem;"></i> Home Page
                        </a>
                    </li>
                    <li class="mb-2">
                        <a href="${pageContext.request.contextPath}/patient/diagnose" class="footer-link">
                            <i class="fa-solid fa-chevron-right me-1 small" style="font-size: 0.7rem;"></i> AI Diagnosis
                        </a>
                    </li>
                    <li class="mb-2">
                        <a href="${pageContext.request.contextPath}/articles" class="footer-link">
                            <i class="fa-solid fa-chevron-right me-1 small" style="font-size: 0.7rem;"></i> Medical Knowledge
                        </a>
                    </li>
                    <li class="mb-2">
                        <a href="${pageContext.request.contextPath}/clinics" class="footer-link">
                            <i class="fa-solid fa-chevron-right me-1 small" style="font-size: 0.7rem;"></i> Clinic Directory
                        </a>
                    </li>
                </ul>
            </div>
            
            <!-- Column 3: Medical Disclaimer -->
            <div class="col-12 col-md-4 mb-4">
                <h5 class="fw-bold mb-4 text-warning d-flex align-items-center" style="font-size: 1.1rem; letter-spacing: -0.2px;">
                    <i class="fa-solid fa-triangle-exclamation me-2"></i> Medical Disclaimer
                </h5>
                <div class="disclaimer-box text-muted small">
                    The SkinAI system is for <strong>preliminary reference only</strong> based on computer vision algorithms. AI results <strong>cannot replace</strong> professional clinical diagnoses performed by a certified Dermatologist. Please consult a healthcare professional if you experience severe symptoms.
                </div>
            </div>
        </div>
        
        <hr class="mt-4 mb-4 text-muted" style="opacity: 0.1;">
        
        <div class="d-flex flex-column flex-sm-row justify-content-between align-items-center text-muted small gap-2">
            <div>
                &copy; 2026 SkinAI Project - SWP391. All rights reserved.
            </div>
            <div class="d-flex gap-3">
                <a href="#" class="text-muted text-decoration-none hover-primary">Terms of Service</a>
                <span class="text-light-muted">|</span>
                <a href="#" class="text-muted text-decoration-none hover-primary">Privacy Policy</a>
            </div>
        </div>
    </div>
</footer>

<!-- Bootstrap 5 JS Bundle with Popper -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
