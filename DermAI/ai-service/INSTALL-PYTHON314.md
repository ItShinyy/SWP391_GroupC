# Cài đặt AI Service với Python 3.14

## ✅ Python 3.14 có tương thích không?

**CÓ!** Python 3.14 tương thích ngược với Python 3.11+. Tất cả dependencies sẽ hoạt động tốt:

- ✅ `fastapi==0.115.6` - Hỗ trợ Python 3.8+
- ✅ `uvicorn==0.34.0` - Hỗ trợ Python 3.8+
- ✅ `pydantic==2.10.4` - Hỗ trợ Python 3.8+
- ✅ `numpy==1.26.4` - Hỗ trợ Python 3.9+
- ✅ `opencv-python-headless==4.10.0.84` - Hỗ trợ Python 3.8+
- ✅ `onnxruntime==1.27.0` - Hỗ trợ Python 3.8+

---

## 🚀 Cách cài đặt

### Bước 1: Kiểm tra Python 3.14

```powershell
py -3.14 --version
# Hoặc xem tất cả versions
py --list
```

### Bước 2: Chạy script cài đặt

```powershell
cd ai-service
.\install-py314.ps1
```

### Bước 3: Cấu hình .env.local

Chỉnh sửa file `.env.local`:

```env
AI_SERVICE_API_KEY=gODrVeFSrcQVSLnNeyjVlAU5aSqSmSHMUTUfdGe+2CjkxCO7e51lAaG7lWiUD0Wx
AI_MODELS_ROOT=C:/path/to/models
AI_MAX_INPUT_BYTES=15728640
HARD_MAX_AI_CONCURRENCY=3
```

### Bước 4: Chạy server

```powershell
.\start-ai-service.ps1
```

---

## 🔧 Cài đặt thủ công với Python 3.14

```powershell
# 1. Tạo venv với Python 3.14
py -3.14 -m venv venv

# 2. Activate
.\venv\Scripts\Activate.ps1

# 3. Upgrade pip
python -m pip install --upgrade pip

# 4. Cài packages
pip install -r requirements.txt

# 5. Setup env
copy .env.local.example .env.local
# Edit .env.local

# 6. Run
python -m uvicorn app.main:app --host 127.0.0.1 --port 8000
```

---

## 🧪 Test sau khi cài

```powershell
# Health check
Invoke-WebRequest http://127.0.0.1:8000/health -UseBasicParsing

# API Docs
Start-Process http://127.0.0.1:8000/docs
```

---

## ⚠️ Lưu ý

1. **Nếu gặp lỗi với một package cụ thể**: Một số binary packages như `onnxruntime` có thể chưa có pre-built wheel cho Python 3.14 mới nhất. Trong trường hợp đó:
   - Dùng Python 3.11 hoặc 3.12 thay thế
   - Hoặc đợi package maintainer build wheel mới

2. **Performance**: Python 3.14 có nhiều cải tiến về performance so với 3.11, nên model inference có thể nhanh hơn!

3. **Compatibility**: Nếu có warning về deprecations, không cần lo lắng - chúng sẽ không ảnh hưởng đến functionality.

---

## 🔍 Troubleshooting

### Lỗi: "No matching distribution found for onnxruntime"

Nếu `onnxruntime` không có wheel cho Python 3.14:

```powershell
# Option 1: Dùng Python 3.12
py -3.12 -m venv venv

# Option 2: Install từ source (slower)
pip install onnxruntime --no-binary onnxruntime
```

### Lỗi: "DLL load failed"

Cài Visual C++ Redistributable:
- Download: https://aka.ms/vs/17/release/vc_redist.x64.exe

---

## 📊 So sánh Python versions

| Version | Tương thích | Khuyến nghị |
|---------|-------------|-------------|
| 3.14.x  | ✅ Có       | Tốt (mới nhất) |
| 3.13.x  | ✅ Có       | Tốt |
| 3.12.x  | ✅ Có       | Tốt |
| 3.11.x  | ✅ Có       | **Được test kỹ** |
| 3.10.x  | ⚠️ Có thể   | Không khuyến nghị |
| 3.9.x   | ❌ Không    | numpy 1.26 yêu cầu 3.9+ |
