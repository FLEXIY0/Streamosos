@echo off
chcp 65001 >nul
REM ============================================================
REM  Streamosos - удобный запуск.
REM  Просто дважды кликни по этому файлу, чтобы открыть программу,
REM  либо запусти из консоли:  streamosos.bat "ссылка"
REM ============================================================
setlocal
set "HERE=%~dp0"
set "EXE=%HERE%.venv\Scripts\streamosos.exe"

if not exist "%EXE%" (
    echo.
    echo  Streamosos ещё не установлен.
    echo  Сначала запусти setup.bat в этой папке.
    echo.
    pause
    exit /b 1
)

if "%~1"=="" (
    REM Запуск без аргументов / двойной клик -> интерактивный режим
    "%EXE%" -i
    echo.
    echo  Окно можно закрыть.
    pause
) else (
    "%EXE%" %*
)
endlocal
