[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
    [string]$TomcatHome
)

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$skinAi = Join-Path $root 'SkinAI'
$envFile = Join-Path $skinAi '.env'
$envExample = Join-Path $skinAi '.env.example'
$properties = Join-Path $skinAi 'src\main\resources\application.properties'
$propertiesExample = Join-Path $skinAi 'src\main\resources\application.properties.example'

function Require-Command([string]$Name) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Missing required command: $Name. Install it and run this script again."
    }
}

if (-not (Test-Path -LiteralPath $envFile)) {
    Copy-Item -LiteralPath $envExample -Destination $envFile
    Write-Host 'Da tao SkinAI/.env tu file mau. Hay dien SQL Server va VNPay credentials, sau do chay lai.' -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path -LiteralPath $properties)) {
    Copy-Item -LiteralPath $propertiesExample -Destination $properties
    Write-Host 'Da tao application.properties tu file mau. Hay dien DB/Google/SMTP configuration, sau do chay lai.' -ForegroundColor Yellow
    exit 1
}

Require-Command 'npm'
Require-Command 'mvn'

$war = Join-Path $skinAi 'target\SkinAI.war'
$tomcatWebapps = Join-Path $TomcatHome 'webapps'
$tomcatStartup = Join-Path $TomcatHome 'bin\startup.bat'
if (-not (Test-Path -LiteralPath $tomcatWebapps) -or -not (Test-Path -LiteralPath $tomcatStartup)) {
    throw 'TomcatHome khong dung: can co thu muc webapps va bin/startup.bat (Tomcat 10.1+).'
}

Push-Location $skinAi
try {
    npm ci
    npm run test
    Start-Process -FilePath 'npm.cmd' -ArgumentList 'run', 'start:prod' -WorkingDirectory $skinAi
    mvn clean package
} finally {
    Pop-Location
}

Copy-Item -LiteralPath $war -Destination (Join-Path $tomcatWebapps 'SkinAI.war') -Force
Start-Process -FilePath $tomcatStartup -WorkingDirectory (Join-Path $TomcatHome 'bin')
Write-Host 'SkinAI da duoc deploy. Mo http://localhost:8080/SkinAI sau khi Tomcat khoi dong.' -ForegroundColor Green
