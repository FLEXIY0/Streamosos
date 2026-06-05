#!/usr/bin/env bash
# ============================================================
#  Streamosos - удобный запуск (Linux / macOS).
#  Запусти:  ./streamosos.sh           - интерактивный режим
#            ./streamosos.sh "ссылка"  - скачать сразу
# ============================================================
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXE="$HERE/.venv/bin/streamosos"

if [ ! -x "$EXE" ]; then
    echo
    echo " Streamosos ещё не установлен."
    echo " Сначала запусти ./setup.sh в этой папке."
    echo
    exit 1
fi

if [ "$#" -eq 0 ]; then
    exec "$EXE" -i
else
    exec "$EXE" "$@"
fi
