@echo off
REM Setup script for Streamosos (Windows).
REM Creates a virtual environment, installs the package and checks for ffmpeg.

setlocal enabledelayedexpansion
cd /d "%~dp0"

set "VENV_DIR=.venv"

REM --- 1. Locate a suitable Python interpreter ---------------------------------
set "PYTHON="
where python >nul 2>&1 && set "PYTHON=python"
if not defined PYTHON (
    where py >nul 2>&1 && set "PYTHON=py"
)
if not defined PYTHON (
    echo error: Python 3.8+ is required but was not found in PATH.
    exit /b 1
)

echo ==^> Using %PYTHON%
%PYTHON% --version

REM --- 2. Create / reuse the virtual environment -------------------------------
if not exist "%VENV_DIR%" (
    echo ==^> Creating virtual environment in %VENV_DIR%
    %PYTHON% -m venv "%VENV_DIR%"
) else (
    echo ==^> Reusing existing virtual environment in %VENV_DIR%
)

call "%VENV_DIR%\Scripts\activate.bat"

REM --- 3. Install dependencies -------------------------------------------------
echo ==^> Upgrading pip
python -m pip install --upgrade pip >nul

REM Detect a previously installed Streamosos in this environment.
set "INSTALLED_VERSION="
for /f "tokens=2" %%v in ('python -m pip show streamosos 2^>nul ^| findstr /b "Version:"') do set "INSTALLED_VERSION=%%v"
if defined INSTALLED_VERSION (
    echo ==^> Streamosos %INSTALLED_VERSION% is already installed - updating it.
) else (
    echo ==^> Streamosos is not installed yet - installing.
)

echo ==^> Installing streamosos and its dependencies
python -m pip install -e .
if errorlevel 1 (
    echo error: installation failed.
    exit /b 1
)

REM --- 4. Check for ffmpeg / ffprobe -------------------------------------------
set "MISSING_FFMPEG=0"
where ffmpeg >nul 2>&1 || set "MISSING_FFMPEG=1"
where ffprobe >nul 2>&1 || set "MISSING_FFMPEG=1"

if "%MISSING_FFMPEG%"=="1" (
    echo warning: ffmpeg/ffprobe not found in PATH. They are required at runtime.
    echo          Install with: winget install Gyan.FFmpeg
) else (
    echo ==^> ffmpeg and ffprobe are available.
)

REM --- 5. Done -----------------------------------------------------------------
echo.
echo ==^> Готово! Streamosos установлен.
echo.
echo ============================================================
echo   КАК ЗАПУСТИТЬ:
echo.
echo   - Дважды кликни по файлу streamosos.bat в этой папке
echo     (откроется окно, куда можно вставлять ссылки)
echo.
echo   - Или скачать запись сразу по ссылке:
echo       streamosos.bat "https://my.mts-link.ru/.../record-new/123456789"
echo.
echo   - Нужна команда streamosos в консоли? Запусти activate.bat
echo ============================================================
echo.
pause

endlocal
