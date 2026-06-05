# Streamosos one-shot bootstrap for Windows PowerShell.
#
# Paste-and-go: this downloads Streamosos into a fresh folder, sets up a
# virtual environment, installs everything and checks for ffmpeg.
#
# Quick start (paste into PowerShell):
#     irm https://raw.githubusercontent.com/flexiy0/streamosos/main/bootstrap.ps1 | iex
#
# Optional overrides (set before running):
#     $env:STREAMOSOS_DIR    = "C:\Tools\Streamosos"   # target folder
#     $env:STREAMOSOS_BRANCH = "main"                  # branch to fetch

$ErrorActionPreference = "Stop"

$Repo   = "https://github.com/flexiy0/streamosos"
$Branch = if ($env:STREAMOSOS_BRANCH) { $env:STREAMOSOS_BRANCH } else { "main" }
$Target = if ($env:STREAMOSOS_DIR) { $env:STREAMOSOS_DIR } else { Join-Path (Get-Location) "Streamosos" }

function Info($msg) { Write-Host "==> $msg" -ForegroundColor Green }

# --- 1. Get the source -------------------------------------------------------
if (Test-Path $Target) {
    Info "Folder '$Target' already exists - reusing it."
} elseif (Get-Command git -ErrorAction SilentlyContinue) {
    Info "Cloning $Repo (branch $Branch) into $Target"
    git clone --branch $Branch --depth 1 "$Repo.git" $Target
} else {
    Info "git not found - downloading ZIP archive instead"
    $zip = Join-Path $env:TEMP "streamosos.zip"
    Invoke-WebRequest -Uri "$Repo/archive/refs/heads/$Branch.zip" -OutFile $zip
    $tmp = Join-Path $env:TEMP "streamosos_extract"
    if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
    Expand-Archive -Path $zip -DestinationPath $tmp -Force
    $inner = Get-ChildItem $tmp | Select-Object -First 1
    Move-Item $inner.FullName $Target
    Remove-Item $zip -Force
}

# --- 2. Run the setup script -------------------------------------------------
Set-Location $Target
Info "Running setup..."
& powershell -ExecutionPolicy Bypass -File (Join-Path $Target "setup.ps1")

Write-Host ""
Info "Streamosos установлен в папку: $Target"
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  ЧТО ДЕЛАТЬ ДАЛЬШЕ:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1) Открой папку:  $Target" -ForegroundColor Cyan
Write-Host "  2) Дважды кликни по файлу streamosos.bat" -ForegroundColor Cyan
Write-Host "     -> откроется программа, вставляй ссылку на запись" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# Сразу запускаем программу, чтобы пользователю не пришлось ничего искать.
$launcher = Join-Path $Target "streamosos.bat"
if (Test-Path $launcher) {
    Write-Host ""
    Info "Запускаю Streamosos..."
    & $launcher
}
