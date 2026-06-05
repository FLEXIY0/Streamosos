@echo off
chcp 65001 >nul
REM ============================================================
REM  Открывает консоль с уже включённым окружением Streamosos.
REM  Дважды кликни по этому файлу — откроется окно, где сразу
REM  работает команда  streamosos  (активация venv не нужна,
REM  PowerShell-политики тут ни при чём).
REM ============================================================
if not exist "%~dp0.venv\Scripts\activate.bat" (
    echo.
    echo  Streamosos ещё не установлен. Сначала запусти setup.bat
    echo.
    pause
    exit /b 1
)
call "%~dp0.venv\Scripts\activate.bat"
echo.
echo  Окружение Streamosos включено. Теперь работает команда:  streamosos
echo  Примеры:
echo      streamosos              (откроет меню)
echo      streamosos "ССЫЛКА"     (скачает запись сразу)
echo.
cmd /k
