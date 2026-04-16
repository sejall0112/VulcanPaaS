# VulcanPaaS - Windows 11 Startup Script
# Run from the project root in PowerShell:
#   .\start.ps1

$ErrorActionPreference = "Stop"
$ProjectRoot = $PSScriptRoot

Write-Host ""
Write-Host "  VulcanPaaS - Windows 11 Launcher" -ForegroundColor Cyan
Write-Host "  ==================================" -ForegroundColor DarkCyan
Write-Host ""

# Check Docker is running
Write-Host "  [1/4] Checking Docker Desktop..." -ForegroundColor Yellow
$dockerRunning = $false
try {
    $null = docker info 2>&1
    $dockerRunning = ($LASTEXITCODE -eq 0)
} catch {}

if (-not $dockerRunning) {
    Write-Host ""
    Write-Host "  ERROR: Docker Desktop is not running." -ForegroundColor Red
    Write-Host "  Please start Docker Desktop, wait for it to be ready, then re-run this script." -ForegroundColor Red
    Write-Host ""
    exit 1
}
Write-Host "  OK: Docker Desktop is running." -ForegroundColor Green

# Ensure .env exists
Write-Host "  [2/4] Checking .env file..." -ForegroundColor Yellow
$envFile = Join-Path $ProjectRoot ".env"
$envExample = Join-Path $ProjectRoot ".env.example"
if (-not (Test-Path $envFile)) {
    Copy-Item $envExample $envFile
    Write-Host "  INFO: Created .env from .env.example." -ForegroundColor Cyan
    Write-Host "  Edit .env to add your GitHub token, DeepSeek key, etc. (all optional)." -ForegroundColor DarkCyan
} else {
    Write-Host "  OK: .env found." -ForegroundColor Green
}

# Build & Start
Write-Host "  [3/4] Cleaning up and starting VulcanPaaS..." -ForegroundColor Yellow
Set-Location $ProjectRoot
docker compose down --remove-orphans
docker compose up --build -d
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "  ERROR: docker compose up failed. Check the output above." -ForegroundColor Red
    Write-Host ""
    exit 1
}

# Wait for healthy
Write-Host "  [4/4] Waiting for services to become healthy..." -ForegroundColor Yellow
$maxWait = 120
$elapsed  = 0
$interval = 5

while ($elapsed -lt $maxWait) {
    Start-Sleep -Seconds $interval
    $elapsed += $interval

    $psOutput = docker compose ps --format json 2>$null
    if ($psOutput) {
        try {
            $status = $psOutput | ConvertFrom-Json -ErrorAction SilentlyContinue
            if ($status) {
                $notHealthy = @($status | Where-Object {
                    $_.Health -ne "healthy" -and $_.State -ne "exited" -and $_.Service -ne "nginx-init"
                })
                if ($notHealthy.Count -eq 0) { break }
            }
        } catch {}
    }
    Write-Host "    Waiting... ($elapsed s)" -ForegroundColor DarkGray
}

# Done
Write-Host ""
Write-Host "  VulcanPaaS is up!" -ForegroundColor Green
Write-Host ""
Write-Host "  Dashboard   ->  http://localhost" -ForegroundColor Cyan
Write-Host "  API Health  ->  http://localhost/api/health" -ForegroundColor Cyan
Write-Host "  Grafana     ->  http://localhost/grafana/" -ForegroundColor Cyan
Write-Host "  Prometheus  ->  http://localhost/prometheus/" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Run 'docker compose ps' to check service health." -ForegroundColor DarkGray
Write-Host "  Run 'docker compose down' to stop everything." -ForegroundColor DarkGray
Write-Host ""
