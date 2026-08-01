# DermAI AI Service - Hướng dẫn cài đặt

## 📋 Yêu cầu

- **Python 3.11** (bắt buộc)
- **Windows** với PowerShell
- Ít nhất **2GB RAM** và **1GB disk space**

---

## 🚀 Cài đặt nhanh (Khuyên dùng)

### Bước 1: Cài Python 3.11

1. Download Python 3.11: https://www.python.org/downloads/
2. Chạy installer và **BẮT BUỘC check**:
   - ✅ **Add Python to PATH**
   - ✅ **Install launcher for all users (py)**
3. Restart PowerShell sau khi cài

Verify:
```powershell
py -3.11 --version
# Should show: Python 3.11.x
```

### Bước 2: Setup AI Service

```powershell
cd ai-service
.\setup-ai-service.ps1
```

Script này sẽ:
- ✅ Kiểm tra Python 3.11
- ✅ Tạo `.env.local` từ example
- ✅ Tạo virtual environment
- ✅ Cài đặt tất cả dependencies
- ✅ Verify installation

### Bước 3: Cấu hình .env.local

Chỉnh sửa file `.env.local`:

```env
# Phải khớp với AI_SERVICE_API_KEY trong local.properties
AI_SERVICE_API_KEY=gODrVeFSrcQVSLnNeyjVlAU5aSqSmSHMUTUfdGe+2CjkxCO7e51lAaG7lWiUD0Wx

# Đường dẫn đến models folder (phải có thư mục active/ bên trong)
AI_MODELS_ROOT=C:/Users/phong/Downloads/SWP391/DermAI-private-artifacts

# Giới hạn upload (bytes)
AI_MAX_INPUT_BYTES=15728640

# Số lượng request đồng thời tối đa
HARD_MAX_AI_CONCURRENCY=3
```

⚠️ **Quan trọng:**
- `AI_MODELS_ROOT` phải trỏ đến thư mục chứa `active/` folder với model ONNX
- `AI_SERVICE_API_KEY` phải khớp với Java `local.properties`

### Bước 4: Chạy server

```powershell
.\start-ai-service.ps1
```

Hoặc chạy thủ công:
```powershell
.\venv\Scripts\Activate.ps1
python -m uvicorn app.main:app --host 127.0.0.1 --port 8000
```

---

## 🧪 Test

Khi server đang chạy:

```powershell
# Health check
Invoke-WebRequest http://127.0.0.1:8000/health -UseBasicParsing

# API Docs
Start-Process http://127.0.0.1:8000/docs
```

---

## 🔧 Cài đặt thủ công

Nếu script tự động không hoạt động:

### 1. Kiểm tra Python

```powershell
py -3.11 --version
```

Nếu không có, cài từ: https://www.python.org/downloads/

### 2. Tạo virtual environment

```powershell
cd ai-service
py -3.11 -m venv venv
```

### 3. Activate venv

```powershell
.\venv\Scripts\Activate.ps1
```

Nếu gặp lỗi ExecutionPolicy:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 4. Upgrade pip

```powershell
python -m pip install --upgrade pip
```

### 5. Cài dependencies

```powershell
pip install -r requirements.txt
```

### 6. Setup .env.local

```powershell
copy .env.local.example .env.local
# Sau đó edit .env.local
```

### 7. Chạy server

```powershell
python -m uvicorn app.main:app --host 127.0.0.1 --port 8000
```

---

## 📦 Dependencies

Được cài từ `requirements.txt`:

- `fastapi==0.115.6` - Web framework
- `pydantic==2.10.4` - Data validation
- `uvicorn==0.34.0` - ASGI server
- `opencv-python-headless==4.10.0.84` - Image processing
- `numpy==1.26.4` - Numerical computing
- `onnxruntime==1.27.0` - ONNX model inference

---

## 🐛 Troubleshooting

### Lỗi: "py: command not found"

Python launcher chưa được cài. Cài lại Python với option "Install launcher".

### Lỗi: "cannot be loaded because running scripts is disabled"

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Lỗi: "No module named 'app'"

Đảm bảo bạn đang ở trong thư mục `ai-service` khi chạy uvicorn.

### Lỗi: "AI_MODELS_ROOT not configured"

Kiểm tra file `.env.local` có đúng đường dẫn không.

### Lỗi: Port 8000 đã được sử dụng

```powershell
# Tìm process đang dùng port 8000
Get-NetTCPConnection -LocalPort 8000 | Select-Object OwningProcess
# Stop process
Stop-Process -Id <PID>
```

---

## 📚 Thêm thông tin

- FastAPI Docs: http://127.0.0.1:8000/docs (khi server chạy)
- Health endpoint: `GET /health`
- Screening endpoint: `POST /screen`
- Model package management: `POST /internal/packages/invalidate`

---

## 🔒 Bảo mật

- **KHÔNG** commit `.env.local` vào git
- `AI_SERVICE_API_KEY` phải được giữ bí mật
- Chỉ chạy trên `127.0.0.1` (localhost) trong development
