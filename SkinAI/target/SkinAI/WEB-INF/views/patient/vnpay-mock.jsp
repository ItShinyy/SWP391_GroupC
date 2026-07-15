<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VNPay - Cổng Thanh Toán</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        .vnpay-container {
            max-width: 600px;
            margin: 50px auto;
            background: white;
            border-radius: 15px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        
        .vnpay-header {
            background: linear-gradient(45deg, #1e3c72, #2a5298);
            color: white;
            padding: 30px;
            text-align: center;
        }
        
        .vnpay-logo {
            font-size: 2.5rem;
            margin-bottom: 10px;
        }
        
        .vnpay-body {
            padding: 40px;
        }
        
        .payment-info {
            background: #f8f9fa;
            border-left: 4px solid #007bff;
            padding: 20px;
            margin: 20px 0;
            border-radius: 0 8px 8px 0;
        }
        
        .amount-display {
            font-size: 2.2rem;
            font-weight: bold;
            color: #28a745;
            text-align: center;
            margin: 20px 0;
            padding: 20px;
            background: #f8fff9;
            border: 2px dashed #28a745;
            border-radius: 10px;
        }
        
        .payment-methods {
            margin: 30px 0;
        }
        
        .method-card {
            border: 2px solid #e9ecef;
            border-radius: 10px;
            padding: 15px;
            margin: 10px 0;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .method-card:hover {
            border-color: #007bff;
            background: #f8f9ff;
        }
        
        .method-card.selected {
            border-color: #007bff;
            background: #e3f2fd;
        }
        
        .demo-warning {
            background: linear-gradient(45deg, #ff6b6b, #ffa500);
            color: white;
            padding: 15px;
            border-radius: 10px;
            margin: 20px 0;
            text-align: center;
            font-weight: bold;
        }
        
        .btn-vnpay {
            background: linear-gradient(45deg, #1e3c72, #2a5298);
            border: none;
            padding: 15px 30px;
            font-size: 1.1rem;
            font-weight: bold;
            border-radius: 8px;
            transition: transform 0.2s;
        }
        
        .btn-vnpay:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 16px rgba(0,0,0,0.2);
        }
        
        .countdown {
            text-align: center;
            font-size: 1.1rem;
            color: #dc3545;
            margin: 15px 0;
        }
    </style>
</head>
<body>
    <div class="vnpay-container">
        <!-- Header -->
        <div class="vnpay-header">
            <div class="vnpay-logo">
                <i class="fas fa-credit-card"></i>
            </div>
            <h3>VNPay - Cổng Thanh Toán</h3>
            <p class="mb-0">Thanh toán an toàn & bảo mật</p>
        </div>
        
        <!-- Body -->
        <div class="vnpay-body">
            <div class="demo-warning">
                <i class="fas fa-exclamation-triangle me-2"></i>
                ĐÂY LÀ MÔI TRƯỜNG DEMO - KHÔNG THỰC HIỆN GIAO DỊCH THẬT
            </div>
            
            <!-- Payment Information -->
            <div class="payment-info">
                <h6><i class="fas fa-info-circle me-2"></i>Thông Tin Giao Dịch</h6>
                <div class="row">
                    <div class="col-sm-4"><strong>Mã GD:</strong></div>
                    <div class="col-sm-8"><code>${param.txnRef}</code></div>
                </div>
                <div class="row mt-2">
                    <div class="col-sm-4"><strong>Merchant:</strong></div>
                    <div class="col-sm-8">SkinAI - Hệ thống khám da liễu</div>
                </div>
                <div class="row mt-2">
                    <div class="col-sm-4"><strong>Nội dung:</strong></div>
                    <div class="col-sm-8">Thanh toán phí khám và tư vấn da liễu</div>
                </div>
            </div>
            
            <!-- Amount -->
            <div class="amount-display">
                <i class="fas fa-money-bill-wave me-2"></i>
                250.000 đ
            </div>
            
            <!-- Countdown Timer -->
            <div class="countdown">
                <i class="fas fa-clock me-2"></i>
                Thời gian còn lại: <span id="countdown">14:59</span>
            </div>
            
            <!-- Payment Methods (Demo) -->
            <div class="payment-methods">
                <h6><i class="fas fa-wallet me-2"></i>Chọn Phương Thức Thanh Toán</h6>
                
                <div class="method-card selected" onclick="selectMethod(this)">
                    <div class="d-flex align-items-center">
                        <div class="me-3">
                            <i class="fas fa-university fa-2x text-primary"></i>
                        </div>
                        <div>
                            <h6 class="mb-1">Internet Banking</h6>
                            <small class="text-muted">Thanh toán qua tài khoản ngân hàng</small>
                        </div>
                        <div class="ms-auto">
                            <i class="fas fa-check-circle text-success"></i>
                        </div>
                    </div>
                </div>
                
                <div class="method-card" onclick="selectMethod(this)">
                    <div class="d-flex align-items-center">
                        <div class="me-3">
                            <i class="fas fa-credit-card fa-2x text-warning"></i>
                        </div>
                        <div>
                            <h6 class="mb-1">Thẻ ATM/Debit</h6>
                            <small class="text-muted">Thanh toán bằng thẻ nội địa</small>
                        </div>
                    </div>
                </div>
                
                <div class="method-card" onclick="selectMethod(this)">
                    <div class="d-flex align-items-center">
                        <div class="me-3">
                            <i class="fas fa-qrcode fa-2x text-info"></i>
                        </div>
                        <div>
                            <h6 class="mb-1">QR Code</h6>
                            <small class="text-muted">Quét mã QR để thanh toán</small>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Demo Buttons -->
            <div class="text-center mt-4">
                <h6 class="mb-3">Kết Quả Demo:</h6>
                <div class="d-grid gap-2 d-md-flex justify-content-md-center">
                    <a href="${pageContext.request.contextPath}/patient/payment?action=vnpay-mock&txnRef=${param.txnRef}&result=success" 
                       class="btn btn-success btn-lg me-md-2">
                        <i class="fas fa-check-circle me-2"></i>
                        Thanh Toán Thành Công
                    </a>
                    <a href="${pageContext.request.contextPath}/patient/payment?action=vnpay-mock&txnRef=${param.txnRef}&result=failed" 
                       class="btn btn-danger btn-lg">
                        <i class="fas fa-times-circle me-2"></i>
                        Hủy/Thất Bại
                    </a>
                </div>
                
                <div class="mt-3">
                    <small class="text-muted">
                        <i class="fas fa-info-circle me-1"></i>
                        Trong môi trường thật, bạn sẽ nhập thông tin thẻ hoặc đăng nhập ngân hàng
                    </small>
                </div>
            </div>
            
            <!-- Security Info -->
            <div class="mt-4 p-3 bg-light rounded">
                <div class="d-flex align-items-center justify-content-center">
                    <i class="fas fa-shield-alt text-success me-2"></i>
                    <small class="text-success">
                        <strong>Bảo mật SSL 256-bit</strong> - Giao dịch được mã hóa an toàn
                    </small>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function selectMethod(element) {
            // Remove selected class from all methods
            document.querySelectorAll('.method-card').forEach(card => {
                card.classList.remove('selected');
                const checkIcon = card.querySelector('.fa-check-circle');
                if (checkIcon) {
                    checkIcon.style.display = 'none';
                }
            });
            
            // Add selected class to clicked method
            element.classList.add('selected');
            let checkIcon = element.querySelector('.fa-check-circle');
            if (!checkIcon) {
                checkIcon = document.createElement('i');
                checkIcon.className = 'fas fa-check-circle text-success ms-auto';
                element.querySelector('.d-flex').appendChild(checkIcon);
            } else {
                checkIcon.style.display = 'inline';
            }
        }
        
        // Countdown timer
        let timeLeft = 15 * 60; // 15 minutes in seconds
        
        function updateCountdown() {
            const minutes = Math.floor(timeLeft / 60);
            const seconds = timeLeft % 60;
            
            document.getElementById('countdown').textContent = 
                minutes.toString().padStart(2, '0') + ':' + 
                seconds.toString().padStart(2, '0');
            
            if (timeLeft <= 0) {
                alert('Phiên thanh toán đã hết hạn!');
                window.location.href = '${pageContext.request.contextPath}/patient/payment?action=vnpay-mock&txnRef=${param.txnRef}&result=failed';
            }
            
            timeLeft--;
        }
        
        // Update countdown every second
        setInterval(updateCountdown, 1000);
        updateCountdown(); // Initial call
    </script>
</body>
</html>