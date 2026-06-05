# Setup script for Streamosos (Windows PowerShell).
# Creates a virtual environment, installs the package and checks for ffmpeg.
#
# Run it from the project folder:
#     powershell -ExecutionPolicy Bypass -File setup.ps1

$ErrorActionPreference = "Stop"

function Info($msg)  { Write-Host "==> $msg" -ForegroundColor Green }
function Warn($msg)  { Write-Host "warning: $msg" -ForegroundColor Yellow }
function Fail($msg)  { Write-Host "error: $msg" -ForegroundColor Red; exit 1 }

Set-Location -Path $PSScriptRoot
$VenvDir = ".venv"

# --- 1. Locate a suitable Python interpreter ---------------------------------
$Python = $null
foreach ($candidate in @("python", "py")) {
    if (Get-Command $candidate -ErrorAction SilentlyContinue) { $Python = $candidate; break }
}
if (-not $Python) { Fail "Python 3.8+ is required but was not found in PATH." }

Info "Using $Python"
& $Python --version

# --- 2. Create / reuse the virtual environment -------------------------------
if (-not (Test-Path $VenvDir)) {
    Info "Creating virtual environment in $VenvDir"
    & $Python -m venv $VenvDir
} else {
    Info "Reusing existing virtual environment in $VenvDir"
}

$VenvPython = Join-Path $VenvDir "Scripts\python.exe"

# --- 3. Install dependencies -------------------------------------------------
Info "Upgrading pip"
& $VenvPython -m pip install --upgrade pip | Out-Null

# Detect a previously installed Streamosos in this environment.
$InstalledVersion = (& $VenvPython -m pip show streamosos 2>$null |
    Where-Object { $_ -match '^Version:' }) -replace '^Version:\s*', ''
if ($InstalledVersion) {
    Info "Streamosos $InstalledVersion is already installed - updating it."
} else {
    Info "Streamosos is not installed yet - installing."
}

Info "Installing Streamosos and its dependencies"
& $VenvPython -m pip install -e .
if ($LASTEXITCODE -ne 0) { Fail "installation failed." }

# --- 4. Check for ffmpeg / ffprobe -------------------------------------------
$MissingFfmpeg = $false
foreach ($tool in @("ffmpeg", "ffprobe")) {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        Warn "$tool was not found in PATH."
        $MissingFfmpeg = $true
    }
}
if ($MissingFfmpeg) {
    Warn "ffmpeg/ffprobe are required at runtime. Install with:"
    Write-Host "        winget install Gyan.FFmpeg"
} else {
    Info "ffmpeg and ffprobe are available."
}

# --- 5. Done -----------------------------------------------------------------
Write-Host ""
Info "Готово! Streamosos установлен."
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  КАК ЗАПУСТИТЬ:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  - Дважды кликни по файлу streamosos.bat в этой папке" -ForegroundColor Cyan
Write-Host "    (откроется окно, куда можно вставлять ссылки)" -ForegroundColor Cyan
Write-Host ""
Write-Host "  - Или в этом окне выполни команду:" -ForegroundColor Cyan
Write-Host "        .\streamosos.bat" -ForegroundColor White
Write-Host ""
Write-Host "  - Скачать запись сразу по ссылке:" -ForegroundColor Cyan
Write-Host '        .\streamosos.bat "https://my.mts-link.ru/.../record-new/123456789"' -ForegroundColor White
Write-Host ""
Write-Host "  - Нужна команда streamosos в консоли? Запусти activate.bat" -ForegroundColor Cyan
Write-Host "    (откроется окно, где работает команда streamosos -i)" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
