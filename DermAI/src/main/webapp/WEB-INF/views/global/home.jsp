<%@ page contentType="text/html;charset=UTF-8" language="java" %>
  <%@ taglib prefix="c" uri="jakarta.tags.core" %>
    <jsp:include page="/WEB-INF/views/layout/global-header.jsp" />

    <%-- Make this page fill exactly the viewport below the navbar --%>
      <style>
        /* Scope only to home — no impact on other pages */
        body.home-page {
          display: flex;
          flex-direction: column;
          height: 100dvh;
          overflow: hidden;
          background-color: #ffffff;
        }

        body.home-page>nav {
          flex-shrink: 0;
        }

        body.home-page>main {
          flex: 1;
          display: flex;
          flex-direction: column;
          overflow: hidden;
          min-height: 0;
        }

        /* Flex allocations to ensure 100vh fit */
        .home-hero {
          flex: 45;
          display: flex;
          align-items: center;
          position: relative;
          overflow: hidden;
          border-bottom: 1px solid #E5E7EB;
        }

        .home-steps {
          flex: 35;
          display: flex;
          align-items: center;
          position: relative;
        }

        .home-cta {
          flex: 15;
          display: flex;
          align-items: center;
          justify-content: center;
        }



        /* Hero specific */
        .hero-radial-bg {
          position: absolute;
          top: 0;
          right: 0;
          width: 50%;
          height: 100%;
          background: radial-gradient(circle at center, #DCFCE7 0%, transparent 70%);
          z-index: 0;
        }

        .badge-ai {
          background-color: #DCFCE7;
          color: #065F46;
          font-size: 0.75rem;
          font-weight: 700;
          padding: 0.35rem 0.8rem;
          border-radius: 99px;
          letter-spacing: 0.5px;
        }

        /* Phone Mockup */
        .phone-mockup {
          position: relative;
          width: 220px;
          height: 440px;
          border: 8px solid #0F172A;
          border-radius: 32px;
          background: #fff;
          box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
          overflow: hidden;
          z-index: 2;
          margin: 0 auto;
        }

        @media (max-height: 800px) {
          .phone-mockup {
            width: 180px;
            height: 360px;
            border-width: 6px;
            border-radius: 24px;
          }
        }

        .floating-card {
          position: absolute;
          background: white;
          border-radius: 12px;
          padding: 12px;
          box-shadow: 0 10px 25px rgba(0, 0, 0, 0.08);
          border: 1px solid #f1f5f9;
          z-index: 3;
          width: 160px;
        }

        .fc-left {
          left: -50px;
          top: 30%;
        }

        .fc-right {
          right: -50px;
          bottom: 25%;
        }

        /* Steps specific */
        .home-card {
          transition: transform 0.2s ease, box-shadow 0.2s ease;
          border: 1px solid #E5E7EB !important;
          border-radius: 16px !important;
        }

        .home-card:hover {
          transform: translateY(-4px);
          box-shadow: 0 12px 24px rgba(0, 0, 0, 0.05) !important;
        }

        .step-icon {
          width: 48px;
          height: 48px;
          background: #DCFCE7;
          border-radius: 50%;
          display: inline-flex;
          align-items: center;
          justify-content: center;
        }

        /* Step connector lines (desktop only) */
        .step-connector {
          position: absolute;
          top: 52px;
          left: -20px;
          width: 40px;
          height: 2px;
          background: #E5E7EB;
          z-index: -1;
        }

        /* CTA specific */
        .cta-banner {
          background-color: #F0FDF4;
          border-radius: 16px;
          padding: 1.5vh 2vw;
          border: 1px solid #DCFCE7;
        }

        .btn-primary-custom {
          background: #16A34A;
          color: white;
          border-radius: 8px;
          transition: transform 0.2s;
        }

        .btn-primary-custom:hover {
          background: #15803d;
          color: white;
          transform: scale(1.03);
        }
      </style>
      <script>document.body.classList.add('home-page');</script>

      <!-- Hero (approx 45% height) -->
      <section class="home-hero">
        <div class="hero-radial-bg d-none d-lg-block"></div>
        <div class="container position-relative" style="z-index: 1;">
          <div class="row align-items-center">
            <!-- Left Text -->
            <div class="col-lg-6 col-md-12 text-center text-lg-start">
              <span class="badge-ai mb-3 d-inline-block">AI CHO LÀN DA KHỎE</span>
              <h1 class="fw-bold mb-3"
                style="font-size:clamp(2rem,4vw,3.5rem);color:#0F172A;line-height:1.1;letter-spacing:-1px;">Sàng lọc Da
                liễu AI</h1>
              <p class="mb-4 mx-auto mx-lg-0" style="font-size:clamp(1rem,1.2vw,1.1rem);color:#475569;max-width:480px;">
                Phân tích hình ảnh AI phát hiện bệnh lý da trong vài giây.</p>
              <div class="mb-4">
                <a href="${pageContext.request.contextPath}/patient/diagnose"
                  class="btn btn-primary-custom fw-bold px-4 py-2" style="font-size:1.1rem;">
                  Bắt đầu Sàng lọc <i class="fa-solid fa-arrow-right ms-2"></i>
                </a>
              </div>
              <div class="d-flex justify-content-center justify-content-lg-start gap-4 small"
                style="color:#065F46;font-weight:600;">
                <div><i class="fa-regular fa-circle-check me-1"></i> An toàn dữ liệu</div>
                <div><i class="fa-solid fa-bullseye me-1"></i> Độ chính xác cao</div>
                <div><i class="fa-solid fa-lock me-1"></i> Bảo mật tuyệt đối</div>
              </div>
            </div>

            <!-- Right Illustration (Desktop only) -->
            <div class="col-lg-6 d-none d-lg-block position-relative">
              <div class="position-relative" style="max-width:400px; margin:0 auto;">
                <!-- Phone Mockup -->
                <div class="phone-mockup">
                  <div
                    style="position:absolute;top:20%;left:15%;right:15%;bottom:20%;border:2px dashed #16A34A;border-radius:12px;background:rgba(22, 163, 74, 0.1) url('${pageContext.request.contextPath}/assets/images/homepage_demo_image.png') center/cover;">
                  </div>
                </div>

                <!-- Floating Card Left -->
                <div class="floating-card fc-left">
                  <div class="small text-muted fw-bold mb-2" style="font-size:0.7rem;">AI Phân Tích</div>
                  <div class="d-flex align-items-center gap-2">
                    <i class="fa-solid fa-network-wired" style="color:#16A34A;"></i>
                    <div class="progress flex-grow-1" style="height:6px;">
                      <div class="progress-bar" style="background:#16A34A;width:92%"></div>
                    </div>
                  </div>
                  <div class="text-end mt-1 small fw-bold" style="font-size:0.75rem;">92%</div>
                </div>

                <!-- Floating Card Right -->
                <div class="floating-card fc-right">
                  <div class="small text-muted fw-bold mb-1" style="font-size:0.7rem;">Kết quả sàng lọc</div>
                  <div class="fw-bold" style="color:#0F172A;">Khả năng cao</div>
                  <div style="color:#16A34A;font-weight:700;font-size:0.9rem;">Là mụn trứng cá</div>
                  <div class="d-flex justify-content-between align-items-center mt-2 pt-2 border-top">
                    <span class="text-muted" style="font-size:0.7rem;">Độ tin cậy: 92%</span>
                    <i class="fa-solid fa-circle-check text-success"></i>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- How it works (approx 35% height) -->
      <section class="home-steps">
        <div class="container position-relative">
          <div class="text-center mb-3">
            <h2 class="fw-bold mb-1" style="font-size:clamp(1.2rem,2vw,1.8rem);color:#16A34A;">Cách Hoạt Động</h2>
            <p class="text-muted small mb-0">Đơn giản · Nhanh chóng · Bảo mật</p>
          </div>

          <div class="row text-center g-3 position-relative z-1">
            <div class="col-md-3 col-6">
              <div class="card h-100 p-3 home-card">
                <div class="card-body p-1">
                  <div class="step-icon mb-2 mx-auto"><i class="fa-solid fa-camera"
                      style="color:#16A34A;font-size:1.2rem;"></i></div>
                  <h6 class="fw-bold mb-1" style="color:#0F172A;">1. Tải Ảnh Lên</h6>
                  <p class="text-muted mb-0" style="font-size:0.85rem;">Chụp ảnh tình trạng da bằng điện thoại hoặc máy
                    ảnh.</p>
                </div>
              </div>
            </div>
            <div class="col-md-3 col-6 position-relative">
              <div class="d-none d-md-block step-connector"></div>
              <div class="card h-100 p-3 home-card">
                <div class="card-body p-1">
                  <div class="step-icon mb-2 mx-auto"><i class="fa-solid fa-microchip"
                      style="color:#16A34A;font-size:1.2rem;"></i></div>
                  <h6 class="fw-bold mb-1" style="color:#0F172A;">2. AI Phân Tích</h6>
                  <p class="text-muted mb-0" style="font-size:0.85rem;">Mô hình Học Sâu xử lý và phân tích hình ảnh của
                    bạn.</p>
                </div>
              </div>
            </div>
            <div class="col-md-3 col-6 position-relative">
              <div class="d-none d-md-block step-connector"></div>
              <div class="card h-100 p-3 home-card">
                <div class="card-body p-1">
                  <div class="step-icon mb-2 mx-auto"><i class="fa-solid fa-file-medical"
                      style="color:#16A34A;font-size:1.2rem;"></i></div>
                  <h6 class="fw-bold mb-1" style="color:#0F172A;">3. Nhận Kết Quả</h6>
                  <p class="text-muted mb-0" style="font-size:0.85rem;">Xem dự đoán, mức độ tin cậy và đánh giá rủi ro.
                  </p>
                </div>
              </div>
            </div>
            <div class="col-md-3 col-6 position-relative">
              <div class="d-none d-md-block step-connector"></div>
              <div class="card h-100 p-3 home-card">
                <div class="card-body p-1">
                  <div class="step-icon mb-2 mx-auto"><i class="fa-solid fa-user-doctor"
                      style="color:#16A34A;font-size:1.2rem;"></i></div>
                  <h6 class="fw-bold mb-1" style="color:#0F172A;">4. Khám Chuyên Khoa</h6>
                  <p class="text-muted mb-0" style="font-size:0.85rem;">Đặt lịch khám tại phòng khám da liễu gần nhất.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- CTA (approx 15% height) -->
      <section class="home-cta">
        <div class="container">
          <div class="cta-banner d-flex flex-wrap justify-content-between align-items-center">
            <div class="d-flex align-items-center gap-3">
              <div
                style="width:48px;height:48px;background:white;border-radius:50%;display:flex;align-items:center;justify-content:center;color:#16A34A;font-size:1.25rem;box-shadow:0 4px 6px rgba(0,0,0,0.05);">
                <i class="fa-solid fa-shield-halved"></i>
              </div>
              <div>
                <h5 class="fw-bold mb-1" style="color:#0F172A;">Bạn có vấn đề về da cần kiểm tra?</h5>
                <p class="text-muted mb-0 small">Đừng chần chừ, phát hiện sớm giúp điều trị hiệu quả hơn.</p>
              </div>
            </div>
            <div class="mt-3 mt-md-0">
              <a href="${pageContext.request.contextPath}/patient/diagnose"
                class="btn btn-primary-custom fw-bold px-4 py-2">
                <i class="fa-solid fa-upload me-2"></i> Tải Ảnh Lên Ngay
              </a>
            </div>
          </div>
        </div>
      </section>

      <jsp:include page="/WEB-INF/views/layout/global-footer.jsp" />