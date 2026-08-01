# DermAI - Start All Services Checklist

Complete guide to start Payment Service and AI Service.

---

## 📋 Prerequisites Check

### 1. Check Python 3.11
```powershell
py -3.11 --version
```
Should show: `Python 3.11.x`

### 2. Check Node.js
```powershell
node --version
npm --version
```

### 3. Check Nginx
```powershell
Get-Process nginx -ErrorAction SilentlyContinue
```

### 4. Check SQL Server
```powershell
# Test database connection
sqlcmd -S localhost -d SWP391 -U sa -P 123 -Q "SELECT 1"
```

---

## 🚀 Part 1: Start Payment Service (Node.js + Nginx)

### Step 1.1: Install Payment Service Dependencies (First Time Only)
```powershell
cd c:\Users\admin\Downloads\DermAI\DermAI\payment-service
npm install
```

### Step 1.2: Check Configuration
```powershell
# Verify .env.local exists
Test-Path .env.local
```

If false, create it:
```powershell
copy .env.local.example .env.local
# Then edit .env.local with your settings
```

### Step 1.3: Start Payment Service
```powershell
cd c:\Users\admin\Downloads\DermAI\DermAI\payment-service
npm start
```

**Expected output:**
```
Payment API listening on port 3000
```

**Keep this terminal open!**

### Step 1.4: Test Payment Service (New Terminal)
```powershell
# Direct test (bypass nginx)
Invoke-WebRequest http://localhost:3000/api/health -UseBasicParsing
```

Should return: `{"status":"ok"}`

### Step 1.5: Start Nginx
```powershell
cd C:\Users\admin\Downloads\nginx-1.30.4\nginx-1.30.4
.\nginx.exe -c c:\Users\admin\Downloads\DermAI\DermAI\nginx\conf\nginx.conf
```

### Step 1.6: Test Payment via Nginx
```powershell
Invoke-WebRequest http://localhost/api/health -UseBasicParsing
```

Should return: `{"status":"ok"}`

---

## 🤖 Part 2: Start AI Service (Python FastAPI)

### Step 2.1: Check AI Service Installation (First Time)
```powershell
cd c:\Users\admin\Downloads\DermAI\DermAI\ai-service

# Check if venv exists
Test-Path venv\Scripts\python.exe
```

If false, install:
```powershell
.\install-py311.ps1
```

### Step 2.2: Verify Model Files
```powershell
dir C:\Users\admin\Downloads\DermAI\DermAI\DermAI-private-artifacts\active
```

Should show:
- model.onnx
- labels.json
- reference_features.npz
- metadata.json

### Step 2.3: Check Configuration
```powershell
# Verify .env.local
cat .env.local
```

Should have:
```
AI_SERVICE_API_KEY=gODrVeFSrcQVSLnNeyjVlAU5aSqSmSHMUTUfdGe+2CjkxCO7e51lAaG7lWiUD0Wx
AI_MODELS_ROOT=C:/Users/admin/Downloads/DermAI/DermAI/DermAI-private-artifacts
```

### Step 2.4: Start AI Service
```powershell
cd c:\Users\admin\Downloads\DermAI\DermAI\ai-service
.\start-ai-service.ps1
```

**Expected output:**
```
INFO:     Uvicorn running on http://127.0.0.1:8000 (Press CTRL+C to quit)
INFO:     Started reloader process
INFO:     Started server process
INFO:     Waiting for application startup.
INFO:     Application startup complete.
```

**Keep this terminal open!**

### Step 2.5: Test AI Service (New Terminal)
```powershell
Invoke-WebRequest http://127.0.0.1:8000/health -UseBasicParsing
```

Should return: `{"status":"ok"}`

---

## 🎯 Part 3: Start Main Application (Tomcat/Java)

### Step 3.1: Check Configuration
```powershell
cd c:\Users\admin\Downloads\DermAI\DermAI

# Verify local.properties
cat local.properties | Select-String "AI_SERVICE_ENABLED|PAYMENT_API_BASE_URL|AI_MODELS_ROOT"
```

Should show:
```
AI_SERVICE_ENABLED=true
PAYMENT_API_BASE_URL=http://localhost
AI_MODELS_ROOT=C:/Users/admin/Downloads/DermAI/DermAI/DermAI-private-artifacts
```

### Step 3.2: Build Project (if needed)
```powershell
mvn clean package -DskipTests
```

### Step 3.3: Run in NetBeans/IntelliJ
- Open project in IDE
- Run on Tomcat (port 9999)

Or command line:
```powershell
mvn tomcat7:run
```

### Step 3.4: Test Main Application
```powershell
# Test Tomcat directly
Invoke-WebRequest http://localhost:9999/DermAI -UseBasicParsing

# Test via Nginx
Invoke-WebRequest http://localhost/DermAI -UseBasicParsing
```

---

## ✅ Part 4: Verification Checklist

Run all these tests to confirm everything works:

### Check 1: Payment Service Direct
```powershell
Invoke-WebRequest http://localhost:3000/api/health -UseBasicParsing
```
✅ Should return: `{"status":"ok"}`

### Check 2: Payment Service via Nginx
```powershell
Invoke-WebRequest http://localhost/api/health -UseBasicParsing
```
✅ Should return: `{"status":"ok"}`

### Check 3: AI Service
```powershell
Invoke-WebRequest http://127.0.0.1:8000/health -UseBasicParsing
```
✅ Should return: `{"status":"ok"}`

### Check 4: Main Application via Nginx
```powershell
Invoke-WebRequest http://localhost/DermAI -UseBasicParsing -MaximumRedirection 0 -ErrorAction SilentlyContinue
```
✅ Should return 302 redirect or 200

### Check 5: All Processes Running
```powershell
# Payment Service
Get-Process node

# AI Service
Get-Process python

# Nginx
Get-Process nginx

# Tomcat/Java
Get-Process java
```

---

## 🖥️ Summary: Terminal Windows Needed

You need **3 terminal windows** running:

### Terminal 1: Payment Service
```powershell
cd c:\Users\admin\Downloads\DermAI\DermAI\payment-service
npm start
```

### Terminal 2: AI Service
```powershell
cd c:\Users\admin\Downloads\DermAI\DermAI\ai-service
.\start-ai-service.ps1
```

### Terminal 3: Main Application
```
# Run in IDE (NetBeans/IntelliJ) on Tomcat
```

### Background: Nginx
```powershell
# Start once in background (separate command)
C:\Users\admin\Downloads\nginx-1.30.4\nginx-1.30.4\nginx.exe -c c:\Users\admin\Downloads\DermAI\DermAI\nginx\conf\nginx.conf
```

---

## 🛑 Stop All Services

### Stop Payment Service
```
Ctrl+C in Terminal 1
```

### Stop AI Service
```
Ctrl+C in Terminal 2
```

### Stop Nginx
```powershell
Get-Process nginx | Stop-Process -Force
```

### Stop Tomcat
```
Stop button in IDE or Ctrl+C if running from command line
```

---

## 🔧 Troubleshooting

### Port Already in Use
```powershell
# Check what's using port 3000 (Payment)
Get-NetTCPConnection -LocalPort 3000 -ErrorAction SilentlyContinue

# Check what's using port 8000 (AI)
Get-NetTCPConnection -LocalPort 8000 -ErrorAction SilentlyContinue

# Check what's using port 80 (Nginx)
Get-NetTCPConnection -LocalPort 80 -ErrorAction SilentlyContinue

# Kill process by PID
Stop-Process -Id <PID> -Force
```

### Service Returns 503
- Check if service is actually running
- Check configuration files (.env.local, local.properties)
- Check logs in terminal for error messages

### Cannot Connect to Database
```powershell
# Test SQL Server connection
sqlcmd -S localhost -d SWP391 -U sa -P 123 -Q "SELECT 1"
```

---

## 📝 Quick Start Commands (Copy-Paste)

Open 3 PowerShell terminals and run these:

**Terminal 1 - Payment:**
```powershell
cd c:\Users\admin\Downloads\DermAI\DermAI\payment-service; npm start
```

**Terminal 2 - AI:**
```powershell
cd c:\Users\admin\Downloads\DermAI\DermAI\ai-service; .\start-ai-service.ps1
```

**Terminal 3 - Nginx:**
```powershell
C:\Users\admin\Downloads\nginx-1.30.4\nginx-1.30.4\nginx.exe -c c:\Users\admin\Downloads\DermAI\DermAI\nginx\conf\nginx.conf
```

**Then start Tomcat in your IDE**

---

## 🌐 Service URLs

| Service | Direct URL | Via Nginx |
|---------|-----------|-----------|
| Payment Service | http://localhost:3000/api/health | http://localhost/api/health |
| AI Service | http://127.0.0.1:8000/health | N/A |
| Main App | http://localhost:9999/DermAI | http://localhost/DermAI |
| API Docs (AI) | http://127.0.0.1:8000/docs | N/A |

---

## ✨ Success Indicators

When everything is running correctly:

1. ✅ 3 terminal windows showing logs
2. ✅ All health checks return OK
3. ✅ Can access http://localhost/DermAI
4. ✅ Payment flow works (no 404)
5. ✅ AI screening works (no 503)
