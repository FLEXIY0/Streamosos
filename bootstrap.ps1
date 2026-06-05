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
Info "Streamosos is ready in: $Target"
Write-Host "  Next steps:"
Write-Host "      cd `"$Target`""
Write-Host "      .\.venv\Scripts\Activate.ps1"
Write-Host '      streamosos "https://my.mts-link.ru/.../record-new/123456789"'
