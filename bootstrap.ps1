# Streamosos one-shot bootstrap for Windows PowerShell.
#
# Paste-and-go: downloads Streamosos, sets up a virtual environment, installs
# everything, checks for ffmpeg and launches the program.
#
# Quick start (paste into PowerShell):
#     irm https://raw.githubusercontent.com/flexiy0/streamosos/main/bootstrap.ps1 | iex
#
# Optional overrides (set before running):
#     $env:STREAMOSOS_DIR    = "C:\Tools\Streamosos"   # target folder
#     $env:STREAMOSOS_BRANCH = "main"                  # branch to fetch

$ErrorActionPreference = "Stop"
# git/pip write progress to stderr; don't let that abort the script on PS 7.4+.
if (Get-Variable -Name PSNativeCommandUseErrorActionPreference -Scope Global -ErrorAction SilentlyContinue) {
    $PSNativeCommandUseErrorActionPreference = $false
}

$Repo   = "https://github.com/flexiy0/streamosos"
$Branch = if ($env:STREAMOSOS_BRANCH) { $env:STREAMOSOS_BRANCH } else { "main" }

function Info($msg) { Write-Host "==> $msg" -ForegroundColor Green }
function Fail($msg) { Write-Host "ОШИБКА: $msg" -ForegroundColor Red; exit 1 }

function Test-Checkout($path) {
    # A real Streamosos checkout has these.
    return (Test-Path (Join-Path $path "pyproject.toml")) -and
           (Test-Path (Join-Path $path "streamosos"))
}

# --- 1. Decide where to put the code -----------------------------------------
$cwd = (Get-Location).Path
if ($env:STREAMOSOS_DIR) {
    $Target = $env:STREAMOSOS_DIR
} elseif (Test-Checkout $cwd) {
    # Already standing inside a Streamosos folder -> update it in place,
    # do NOT create a nested Streamosos\Streamosos.
    $Target = $cwd
} else {
    $Target = Join-Path $cwd "Streamosos"
}

# --- 2. Get / update the source ----------------------------------------------
$hasGit = [bool](Get-Command git -ErrorAction SilentlyContinue)

if (Test-Path (Join-Path $Target ".git")) {
    # Existing git checkout -> pull latest.
    Info "Папка уже существует ($Target) — обновляю до последней версии."
    Push-Location $Target
    try {
        git fetch origin $Branch
        git checkout $Branch
        git pull --ff-only origin $Branch
    } finally {
        Pop-Location
    }
} elseif (Test-Checkout $Target) {
    Info "Использую существующую папку: $Target"
} elseif (Test-Path $Target) {
    Fail "Папка '$Target' уже есть, но это не Streamosos. Удали её или укажи другую через `$env:STREAMOSOS_DIR."
} elseif ($hasGit) {
    Info "Скачиваю Streamosos (git clone) в $Target"
    git clone --branch $Branch --depth 1 "$Repo.git" "$Target"
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path $Target)) {
        Fail "git clone не удался. Проверь интернет или скачай репозиторий вручную: $Repo"
    }
} else {
    Info "git не найден — скачиваю ZIP-архив"
    $zip = Join-Path $env:TEMP "streamosos.zip"
    Invoke-WebRequest -Uri "$Repo/archive/refs/heads/$Branch.zip" -OutFile $zip
    $tmp = Join-Path $env:TEMP "streamosos_extract"
    if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
    Expand-Archive -Path $zip -DestinationPath $tmp -Force
    $inner = Get-ChildItem $tmp -Directory | Select-Object -First 1
    Move-Item $inner.FullName $Target
    Remove-Item $zip -Force
}

if (-not (Test-Path $Target)) {
    Fail "Не удалось получить файлы Streamosos в $Target."
}

# --- 3. Run the setup script -------------------------------------------------
Set-Location $Target
Info "Устанавливаю..."
& powershell -ExecutionPolicy Bypass -File (Join-Path $Target "setup.ps1")

Write-Host ""
Info "Streamosos готов: $Target"
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  ЧТО ДЕЛАТЬ ДАЛЬШЕ:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  - Сейчас откроется меню — просто вставь ссылку на запись." -ForegroundColor Cyan
Write-Host "  - В следующий раз: дважды кликни streamosos.bat в папке" -ForegroundColor Cyan
Write-Host "        $Target" -ForegroundColor White
Write-Host "============================================================" -ForegroundColor Cyan

# Сразу запускаем программу, чтобы пользователю не пришлось ничего искать.
$launcher = Join-Path $Target "streamosos.bat"
if (Test-Path $launcher) {
    Write-Host ""
    Info "Запускаю Streamosos..."
    & $launcher
}
