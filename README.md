# mtslinker

CLI-утилита для скачивания записей вебинаров с **МТС Линк** (`my.mts-link.ru`).
Скрипт забирает все видео- и аудио-фрагменты записи, склеивает их через `ffmpeg`
и сохраняет готовый `.mp4` файл.

## Возможности

- Скачивание публичных записей по ссылке.
- Скачивание приватных записей через `sessionId` (параметр `--session-id`).
- Автоматическая склейка видео/аудио чанков в один файл.
- Прогресс-бар загрузки и логирование в `logs/mtslinker.log`.

## Требования

- **Python 3.8+**
- **ffmpeg** и **ffprobe** в `PATH` (используются для склейки и анализа медиа).

Проверить наличие ffmpeg:

```bash
ffmpeg -version
ffprobe -version
```

Установка ffmpeg:

| ОС            | Команда                                              |
|---------------|------------------------------------------------------|
| Ubuntu/Debian | `sudo apt-get install -y ffmpeg`                     |
| Fedora        | `sudo dnf install -y ffmpeg`                         |
| Arch          | `sudo pacman -S ffmpeg`                              |
| macOS (brew)  | `brew install ffmpeg`                               |
| Windows       | `winget install Gyan.FFmpeg` или `choco install ffmpeg` |

## Быстрый старт (setup из коробки)

Скрипт сам создаст виртуальное окружение, поставит зависимости и проверит ffmpeg.

**Linux / macOS:**

```bash
./setup.sh
```

**Windows (cmd / PowerShell):**

```bat
setup.bat
```

После установки активируйте окружение:

```bash
# Linux / macOS
source .venv/bin/activate

# Windows
.venv\Scripts\activate
```

## Ручная установка

```bash
python3 -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate
pip install --upgrade pip
pip install -e .
```

## Использование

После установки доступна команда `mtslinker`:

```bash
# С указанием ссылки
mtslinker "https://my.mts-link.ru/12345678/987654321/record-new/123456789"

# Запустить без аргументов — ссылку спросят интерактивно
mtslinker

# Приватная запись (нужен sessionId из cookie браузера)
mtslinker "https://my.mts-link.ru/.../record-new/123456789" --session-id "ВАШ_SESSION_ID"
```

Без установки пакета (из корня репозитория):

```bash
python -m mtslinker.cli "https://my.mts-link.ru/.../record-new/123456789"
```

### Поддерживаемые форматы ссылок

```
https://my.mts-link.ru/12345678/987654321/record-new/123456789
https://my.mts-link.ru/12345678/987654321/record-new/123456789/record-file/1234567890
```

Готовое видео сохраняется в папку с названием вебинара рядом с местом запуска.

## Где взять `sessionId`

Откройте запись в браузере (будучи авторизованным), в DevTools → Application →
Cookies найдите значение `sessionId` для домена `my.mts-link.ru` и передайте его
через `--session-id`.

## Структура проекта

```
mtslinker/
├── __init__.py      # инициализация логгера
├── cli.py           # точка входа, разбор аргументов
├── webinar.py       # оркестрация: получение данных и сборка видео
├── downloader.py    # HTTP-запросы и скачивание чанков
├── processor.py     # обработка/склейка через ffmpeg
└── utils.py         # логгер и вспомогательные функции
```

## Лицензия

MIT
