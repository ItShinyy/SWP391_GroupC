# SkinAI - local setup

This repository contains the SkinAI Jakarta web application, the Node.js VNPay payment API, database SQL scripts, Nginx configuration, and the project business guide.

## What is intentionally not in Git

`node_modules`, Maven `target` output, IDE folders, and real credential files are excluded. They are generated per machine or contain secrets. The committed `package-lock.json`, `pom.xml`, `.env.example`, and `application.properties.example` are enough to recreate a runnable local environment.

## Prerequisites

- JDK 17
- Apache Maven 3.9+
- Apache Tomcat 10.1+ (Jakarta Servlet 6)
- Node.js 20+ and npm
- SQL Server with a database named `SWP391`
- Optional: Nginx if testing reverse proxy on port 80

## First-time setup (Windows PowerShell)

1. Clone the repository and open its root folder.
2. Create local configuration files. Do not commit these files.

```powershell
Copy-Item SkinAI\.env.example SkinAI\.env
Copy-Item SkinAI\src\main\resources\application.properties.example SkinAI\src\main\resources\application.properties
```

3. Edit both copied files with the local SQL Server account and, if needed, VNPay/Google/SMTP credentials. The Node payment API reads `SkinAI\.env`; Java/Tomcat reads `SkinAI\src\main\resources\application.properties` at build time.
4. Create database `SWP391`, then run the base schema and migrations that are needed by your demo data. Start with `SkinAI\src\main\resources\schema.sql`, then apply focused scripts such as `add_payment_schema.sql`, `create_family_members_schema.sql`, `migrate_appointments_add_family_member.sql`, `create_medical_reports_schema.sql`, `create_issue_reports_schema.sql`, and `notification.sql`. Review each migration before running it against an existing database.

## Start the payment API

```powershell
Set-Location SkinAI
npm ci
npm run test
npm run start:prod
```

The API starts on `http://localhost:3000`. Keep this terminal open while testing payment.

## Build and deploy SkinAI

Open a second terminal in the repository root:

```powershell
Set-Location SkinAI
mvn clean package
Copy-Item .\target\SkinAI.war "C:\path\to\apache-tomcat-10.1\webapps\SkinAI.war" -Force
& "C:\path\to\apache-tomcat-10.1\bin\startup.bat"
```

Then open `http://localhost:8080/SkinAI`.

## Optional Nginx proxy

`nginx-1.30.3\conf\nginx.conf` proxies `/` to Tomcat port 8080 and `/api/` plus `/payments/vnpay/` to Node port 3000. Run Nginx only after both services are reachable directly. For public VNPay IPN, configure a public HTTPS domain; localhost cannot receive VNPay callbacks from the internet.

## One-command helper

After completing configuration, this command installs Node dependencies, checks Node source, builds the WAR, starts the payment API, and deploys the WAR to the Tomcat folder supplied:

```powershell
.\run-local.ps1 -TomcatHome "C:\path\to\apache-tomcat-10.1"
```

The helper never creates real credentials. On a fresh clone it copies the two templates and stops so the developer can fill in local values first.
