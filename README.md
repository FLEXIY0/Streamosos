# Streamosos

CLI-утилита для скачивания записей вебинаров с **МТС Линк** (`my.mts-link.ru`).
Скрипт забирает все видео- и аудио-фрагменты записи, склеивает их через `ffmpeg`
и сохраняет готовый `.mp4` файл.

## Возможности

- Скачивание публичных записей по ссылке.
- Скачивание приватных записей через `sessionId` (параметр `--session-id`).
- Автоматическая склейка видео/аудио чанков в один файл.
- Прогресс-бар загрузки и логирование в `logs/streamosos.log`.

## Требования

- **Python 3.8+**
- **ffmpeg** и **ffprobe** в `PATH` (используются для склейки и анализа медиа).

Установка ffmpeg:

| ОС            | Команда                                                 |
|---------------|---------------------------------------------------------|
| Windows       | `winget install Gyan.FFmpeg` или `choco install ffmpeg` |
| Ubuntu/Debian | `sudo apt-get install -y ffmpeg`                        |
| Fedora        | `sudo dnf install -y ffmpeg`                            |
| Arch          | `sudo pacman -S ffmpeg`                                 |
| macOS (brew)  | `brew install ffmpeg`                                  |

---

## 🚀 Установка в одну команду (paste-and-go)

Открой **PowerShell** или **cmd**, вставь блок целиком — он сам создаст папку
`Streamosos`, скачает код, поднимет виртуальное окружение и всё установит.

### PowerShell

```powershell
irm https://raw.githubusercontent.com/flexiy0/streamosos/main/bootstrap.ps1 | iex
```

Либо вручную (если нет git — замени `git clone` на скачивание ZIP):

```powershell
git clone https://github.com/flexiy0/streamosos.git Streamosos
cd Streamosos
powershell -ExecutionPolicy Bypass -File setup.ps1
.\.venv\Scripts\Activate.ps1
```

### cmd

```bat
git clone https://github.com/flexiy0/streamosos.git Streamosos && cd Streamosos && setup.bat
```

### Linux / macOS

```bash
git clone https://github.com/flexiy0/streamosos.git Streamosos && cd Streamosos && ./setup.sh && source .venv/bin/activate
```

> После `setup` окружение готово — можно сразу запускать команду `streamosos`.

---

## Ручная установка

```bash
python -m venv .venv
# Windows (PowerShell): .venv\Scripts\Activate.ps1
# Windows (cmd):        .venv\Scripts\activate
# Linux / macOS:        source .venv/bin/activate
pip install --upgrade pip
pip install -e .
```

## Использование

После установки доступна команда `streamosos`:

```bash
# С указанием ссылки
streamosos "https://my.mts-link.ru/12345678/987654321/record-new/123456789"

# Запустить без аргументов — ссылку спросят интерактивно
streamosos

# Приватная запись (нужен sessionId из cookie браузера)
streamosos "https://my.mts-link.ru/.../record-new/123456789" --session-id "ВАШ_SESSION_ID"

# Версия
streamosos --version
```

Без установки пакета (из корня репозитория):

```bash
python -m streamosos.cli "https://my.mts-link.ru/.../record-new/123456789"
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
Streamosos/
├── streamosos/
│   ├── __init__.py      # инициализация логгера, версия
│   ├── cli.py           # точка входа, разбор аргументов, баннер
│   ├── webinar.py       # оркестрация: получение данных и сборка видео
│   ├── downloader.py    # HTTP-запросы и скачивание чанков
│   ├── processor.py     # обработка/склейка через ffmpeg
│   └── utils.py         # логгер и вспомогательные функции
├── bootstrap.ps1        # one-shot установка для PowerShell
├── setup.ps1 / setup.bat / setup.sh   # локальные сетап-скрипты
└── pyproject.toml       # метаданные пакета и зависимости
```

## Лицензия

MIT
