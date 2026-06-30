# SkinAI - AI Dermatology Diagnosis System 🩺🤖

SkinAI (DermaAI) là một ứng dụng nền tảng web hỗ trợ chẩn đoán các bệnh lý về da liễu thông qua Trí tuệ Nhân tạo (AI). Hệ thống cung cấp giải pháp kết nối giữa Bệnh nhân và các Phòng khám/Bác sĩ chuyên khoa, đồng thời tích hợp mô hình học máy (Machine Learning) để phân tích hình ảnh bệnh lý và đưa ra các gợi ý y khoa ban đầu.

---

## 👥 Đội ngũ Phát triển (Team Size: 5)

Dự án đang trong quá trình phát triển (Work In Progress). Dưới đây là phân chia tiến độ và vai trò:

- **Core Backend & Security (Hoàn thiện 100%)**: Xây dựng kiến trúc nền tảng, thiết kế cơ sở dữ liệu, quản lý xác thực (Authentication), phân quyền (Authorization) và bảo mật hệ thống (RBAC, OTP, OAuth2, Anti-Brute-Force).
- **AI Integration (WIP)**: Tích hợp mô hình AI chẩn đoán hình ảnh. *(Đang phát triển bởi các thành viên khác)*
- **Clinic & Appointment Module (WIP)**: Quản lý phòng khám, đặt lịch khám. *(Đang phát triển bởi các thành viên khác)*
- **Blog & Information Module (WIP)**: Quản lý bài viết, tin tức y khoa. *(Đang phát triển bởi các thành viên khác)*
- **Frontend Polish (WIP)**: Hoàn thiện giao diện người dùng (UI/UX). *(Đang phát triển bởi các thành viên khác)*

---

## 🛠 Tech Stack (Công nghệ sử dụng)

Hệ thống được xây dựng từ đầu (from scratch) để tối ưu hiệu năng và làm chủ hoàn toàn vòng đời ứng dụng, không phụ thuộc vào các Web Framework nặng nề.

- **Ngôn ngữ**: Java 17
- **Backend Framework**: Java Servlet API (Jakarta EE 10), JSP
- **Database**: Microsoft SQL Server
- **Connection Pool**: HikariCP (Tối ưu kết nối DB)
- **Bảo mật**: BCrypt (Hashing), JavaMail (SMTP), Google API (OAuth2)
- **Build Tool**: Apache Maven
- **Web Server**: Apache Tomcat 10+
- **Frontend**: HTML5, CSS3, JavaScript, JSP (Server-side rendering)

---

## 🏗 Architecture & Design Patterns

Dự án được thiết kế chặt chẽ, dễ mở rộng và bảo trì với các tiêu chuẩn thiết kế phần mềm:
- **MVC (Model-View-Controller)**: Tách biệt hoàn toàn tầng giao diện (JSP) và tầng xử lý nghiệp vụ (Servlet).
- **Layered Architecture**: Chia project thành các package rõ ràng: `controller` -> `service` -> `dao` -> `model`.
- **DAO Pattern**: Cô lập các câu lệnh SQL, đảm bảo Controller/Service không can thiệp trực tiếp vào Database.
- **Connection Pooling & Transactions**: Quản lý kết nối Database bằng HikariCP và sử dụng Transaction (`setAutoCommit(false)`) để đảm bảo tính nhất quán dữ liệu (ACID).
- **Manual Dependency Injection**: Khởi tạo và tiêm phụ thuộc giữa các tầng một cách tường minh mà không cần Framework hỗ trợ.
- **In-Memory Caching**: Sử dụng `ConcurrentHashMap` để lưu trữ bộ nhớ đệm (Cache) cho các phiên đăng ký chưa hoàn tất, tối ưu tốc độ và chống rác Database.

---

## 🔐 Core Features (Đã hoàn thành)

Phần lõi hệ thống (Core Backend) đã được xây dựng hoàn thiện với các tính năng:

### 1. Authentication & Authorization
- Đăng ký/Đăng nhập bằng Email, Số điện thoại hoặc **Google Sign-In (OAuth2)**.
- Đăng xuất an toàn, xóa toàn bộ Session.
- **Role-Based Access Control (RBAC)** thông qua Custom Filter, phân quyền chặt chẽ các URL (Admin, Patient, Guest).

### 2. Multi-factor & OTP Security
- Xác thực tài khoản qua luồng **Email OTP** hoặc **SMS OTP**.
- Hỗ trợ luồng Quên Mật Khẩu, Mở Khóa Tài Khoản và Thay đổi thông tin nhạy cảm qua OTP.
- **Brute-force Protection**: Giới hạn số lần nhập sai OTP (Tối đa 3 lần). Khóa OTP ngay lập tức và buộc người dùng xin cấp mã mới nếu vi phạm.
- **Cooldown Mechanism**: Áp dụng thời gian chờ (60s) giữa các lần yêu cầu gửi lại OTP để chống Spam.

### 3. Advanced Security Mechanisms
- **Anti-CSRF Tokens**: Bảo vệ mọi Form POST khỏi các cuộc tấn công giả mạo (Cross-Site Request Forgery).
- **Password Hashing**: Mã hóa mật khẩu một chiều an toàn tuyệt đối bằng thuật toán **BCrypt**.
- **Audit Logging**: Tự động lưu vết mọi hành động nhạy cảm trong hệ thống (Đăng nhập, Đổi mật khẩu, Xóa tài khoản,...) kèm theo địa chỉ IP thật của Client (X-Forwarded-For) và User-Agent.

### 4. Database Design
- Schema chuẩn hóa (3NF) gồm 13 bảng.
- Ứng dụng **Constraints** (CHECK, UNIQUE) và **Indexing** để tối ưu hóa hiệu suất truy vấn SQL.

---

## 🚀 Hướng dẫn cài đặt (Local Development)

### Yêu cầu hệ thống:
- JDK 17+
- Apache Tomcat 10.1.x
- Microsoft SQL Server 2019+
- Apache Maven 3.8+

### Các bước chạy dự án:

1. **Clone repository:**
   ```bash
   git clone https://github.com/your-username/SkinAI.git
   cd SkinAI
   ```

2. **Thiết lập Database:**
   - Tạo một Database mới trong SQL Server (Ví dụ: `SkinAI_DB`).
   - Mở file `src/main/resources/schema.sql` và chạy toàn bộ Script để tạo Bảng, Index và dữ liệu mẫu (Seed Data).

3. **Cấu hình kết nối:**
   - Mở file `src/main/resources/ConnectDB.properties` (hoặc `application.properties`).
   - Thay đổi các thông số cấu hình kết nối DB (User, Password, Database Name, OAuth2 Credentials, SMTP Credentials) cho phù hợp với máy cá nhân của bạn.

4. **Biên dịch và chạy (Build & Run):**
   ```bash
   mvn clean compile war:war
   ```
   - Deploy file `.war` sinh ra trong thư mục `target` lên Apache Tomcat.
   - Hoặc chạy trực tiếp thông qua IDE (IntelliJ IDEA / Eclipse) bằng cách Add Tomcat Server.

5. **Truy cập ứng dụng:**
   - Mở trình duyệt và truy cập: `http://localhost:8080/SkinAI/`

---
*Dự án đang trong quá trình phát triển (WIP). Tài liệu này sẽ được cập nhật thêm khi các module khác hoàn thiện.*
