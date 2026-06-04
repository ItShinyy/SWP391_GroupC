package com.skinai.mail;

public class MailTemplate {

    /**
     * Builds a beautifully designed, mobile-responsive HTML OTP verification email for SkinAI.
     *
     * @param otp            The generated One-Time Password string.
     * @param expireMinutes The expiration window in minutes.
     * @return Formatted HTML email template as a String.
     */
    public static String buildOtpMail(String otp, int expireMinutes) {
        return """
            <!doctype html>
            <html lang="vi">
            <head>
              <meta charset="UTF-8">
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <title>Xác minh OTP - SkinAI</title>
            </head>
            <body style="margin:0; padding:0; background-color:#f8fafc; font-family:-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; -webkit-font-smoothing:antialiased;">
              <div style="max-width:550px; margin:40px auto; padding:0 20px;">
                <!-- Main Card Wrapper -->
                <div style="background-color:#ffffff; border-radius:16px; overflow:hidden; box-shadow:0 10px 25px -5px rgba(0,0,0,0.05), 0 8px 10px -6px rgba(0,0,0,0.05); border:1px solid #f1f5f9;">
                  
                  <!-- Gradient Header -->
                  <div style="background:linear-gradient(135deg, #0f172a 0%%, #0284c7 100%%); padding:36px 32px; color:#ffffff; text-align:center;">
                    <div style="font-size:28px; font-weight:800; letter-spacing:-0.5px; margin:0; font-family:inherit;">
                      Skin<span style="color:#38bdf8;">AI</span>
                    </div>
                    <div style="margin-top:10px; font-size:15px; opacity:0.9; font-weight:300; letter-spacing:0.5px; text-transform:uppercase;">
                      Xác thực tài khoản của bạn
                    </div>
                  </div>

                  <!-- Content Body -->
                  <div style="padding:40px 32px;">
                    <p style="margin:0 0 16px 0; font-size:16px; font-weight:600; color:#1e293b; line-height:1.5;">
                      Xin chào,
                    </p>

                    <p style="margin:0 0 24px 0; font-size:15px; line-height:1.6; color:#475569;">
                      Chúng tôi nhận được yêu cầu xác thực email cho tài khoản SkinAI của bạn. Vui lòng sử dụng mã xác minh dưới đây để hoàn tất quy trình:
                    </p>

                    <!-- Alert Banner for Expiration -->
                    <div style="background-color:#f0f9ff; border-left:4px solid #0284c7; padding:12px 16px; margin-bottom:28px; border-radius:6px;">
                      <p style="margin:0; font-size:14px; color:#0369a1; line-height:1.4;">
                        Mã OTP này có hiệu lực trong vòng <strong style="color:#0284c7;">%d phút</strong>. Vui lòng không chia sẻ mã này với bất kỳ ai.
                      </p>
                    </div>

                    <!-- Modern OTP Block -->
                    <div style="text-align:center; margin:32px 0;">
                      <div style="display:inline-block; padding:16px 36px; background-color:#f1f5f9; border:1px solid #e2e8f0; border-radius:12px;">
                        <span style="font-family:'Courier New', Courier, monospace; font-size:32px; font-weight:700; letter-spacing:6px; color:#0f172a;">
                          %s
                        </span>
                      </div>
                    </div>

                    <p style="margin:0 0 8px 0; font-size:13px; color:#94a3b8; text-align:center; line-height:1.5;">
                      Nếu bạn không thực hiện yêu cầu này, vui lòng bỏ qua email này một cách an toàn.
                    </p>
                  </div>

                  <!-- Clean Minimalist Footer -->
                  <div style="padding:24px 32px; background-color:#f8fafc; border-top:1px solid #f1f5f9; text-align:center;">
                    <p style="margin:0 0 6px 0; font-size:12px; font-weight:600; color:#64748b; letter-spacing:0.5px;">
                      SkinAI Team
                    </p>
                    <p style="margin:0; font-size:11px; color:#94a3b8;">
                      © %d SkinAI. Mọi quyền được bảo lưu.
                    </p>
                  </div>
                  
                </div>
              </div>
            </body>
            </html>
            """.formatted(expireMinutes, otp, java.time.Year.now().getValue());
    }
    public static String buildVerifyLinkMail(String link, int expireMinutes) {
        return """
            <!doctype html>
            <html lang="vi">
            <head>
              <meta charset="UTF-8">
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <title>Kích hoạt tài khoản - SkinAI</title>
            </head>
            <body style="margin:0; padding:0; background-color:#f8fafc; font-family:-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; -webkit-font-smoothing:antialiased;">
              <div style="max-width:550px; margin:40px auto; padding:0 20px;">
                <div style="background-color:#ffffff; border-radius:16px; overflow:hidden; box-shadow:0 10px 25px -5px rgba(0,0,0,0.05), 0 8px 10px -6px rgba(0,0,0,0.05); border:1px solid #f1f5f9;">
                  
                  <div style="background:linear-gradient(135deg, #0f172a 0%%, #0284c7 100%%); padding:36px 32px; color:#ffffff; text-align:center;">
                    <div style="font-size:28px; font-weight:800; letter-spacing:-0.5px; margin:0;">
                      Skin<span style="color:#38bdf8;">AI</span>
                    </div>
                    <div style="margin-top:10px; font-size:15px; opacity:0.9; font-weight:300; text-transform:uppercase;">
                      Kích hoạt tài khoản của bạn
                    </div>
                  </div>

                  <div style="padding:40px 32px;">
                    <p style="margin:0 0 16px 0; font-size:16px; font-weight:600; color:#1e293b; line-height:1.5;">
                      Xin chào,
                    </p>

                    <p style="margin:0 0 24px 0; font-size:15px; line-height:1.6; color:#475569;">
                      Chào mừng bạn đến với SkinAI. Vui lòng bấm vào nút bên dưới để xác thực email và kích hoạt tài khoản của bạn.
                    </p>

                    <div style="background-color:#f0f9ff; border-left:4px solid #0284c7; padding:12px 16px; margin-bottom:28px; border-radius:6px;">
                      <p style="margin:0; font-size:14px; color:#0369a1; line-height:1.4;">
                        Liên kết này có hiệu lực trong vòng <strong style="color:#0284c7;">%d phút</strong>.
                      </p>
                    </div>

                    <div style="text-align:center; margin:32px 0;">
                      <a href="%s" style="display:inline-block; padding:14px 32px; background-color:#0284c7; color:#ffffff; text-decoration:none; font-size:16px; font-weight:600; border-radius:8px; box-shadow:0 4px 6px -1px rgba(2, 132, 199, 0.4);">
                        Xác Thực Email
                      </a>
                    </div>
                    
                    <p style="margin:0 0 8px 0; font-size:13px; color:#64748b; line-height:1.5; word-break: break-all;">
                      Hoặc copy đường dẫn này vào trình duyệt:<br>
                      <a href="%s" style="color:#0284c7;">%s</a>
                    </p>
                  </div>

                  <div style="padding:24px 32px; background-color:#f8fafc; border-top:1px solid #f1f5f9; text-align:center;">
                    <p style="margin:0 0 6px 0; font-size:12px; font-weight:600; color:#64748b;">
                      SkinAI Team
                    </p>
                    <p style="margin:0; font-size:11px; color:#94a3b8;">
                      © %d SkinAI. Mọi quyền được bảo lưu.
                    </p>
                  </div>
                  
                </div>
              </div>
            </body>
            </html>
            """.formatted(expireMinutes, link, link, link, java.time.Year.now().getValue());
    }
}
