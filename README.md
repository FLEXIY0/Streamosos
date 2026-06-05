# Streamosos

CLI-утилита для скачивания записей вебинаров с **МТС Линк** (`my.mts-link.ru`).
Скрипт забирает все видео- и аудио-фрагменты записи, склеивает их через `ffmpeg`
и сохраняет готовый `.mp4` файл.

## Возможности

- Скачивание публичных записей по ссылке.
- Скачивание приватных записей через `sessionId` (параметр `--session-id`).
- **Интерактивный режим** (`-i`) — скачивай несколько записей подряд, не перезапуская команду.
- Автоматическая склейка видео/аудио чанков в один файл.
- Прогресс-бар загрузки и логирование в `logs/streamosos.log`.
- Сетап-скрипты определяют ранее установленную версию Streamosos и обновляют её.

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

### 🟢 Простой способ (рекомендуется)

В папке проекта лежит готовый запускатель — **активировать окружение не нужно**:

- **Windows:** дважды кликни по файлу **`streamosos.bat`** — откроется окно,
  куда можно вставлять ссылки на записи одну за другой.
- **Linux / macOS:** запусти **`./streamosos.sh`**.

Скачать запись сразу по ссылке:

```bat
:: Windows
streamosos.bat "https://my.mts-link.ru/12345678/987654321/record-new/123456789"
```

```bash
# Linux / macOS
./streamosos.sh "https://my.mts-link.ru/12345678/987654321/record-new/123456789"
```

### Команда `streamosos` (после активации окружения)

Если виртуальное окружение активировано (`(.venv)` в приглашении), доступна
команда `streamosos`:

```bash
# Интерактивный режим — вставляй ссылки по одной, выход по 'q'
streamosos -i

# С указанием ссылки
streamosos "https://my.mts-link.ru/12345678/987654321/record-new/123456789"

# Приватная запись (нужен sessionId из cookie браузера)
streamosos "https://my.mts-link.ru/.../record-new/123456789" --session-id "ВАШ_SESSION_ID"

# Версия
streamosos --version
```

> Без активации окружения команда `streamosos` не найдётся — используй
> запускатель `streamosos.bat` / `streamosos.sh` выше.

### Нужна именно команда `streamosos` в консоли?

- **Windows:** дважды кликни по **`activate.bat`** — откроется окно, где сразу
  работает команда `streamosos` (PowerShell-политики при этом не мешают).
- **Linux / macOS:** `source .venv/bin/activate`.

## Решение проблем

**PowerShell: «выполнение сценариев отключено в этой системе»** при попытке
запустить `Activate.ps1`. Это политика безопасности Windows. Тебе **не нужно**
активировать окружение вручную — просто используй `streamosos.bat` (двойной
клик) или `activate.bat`. Если всё же хочешь включить запуск скриптов в
PowerShell, выполни один раз:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
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
│   ├── __main__.py      # поддержка `python -m streamosos`
│   ├── cli.py           # точка входа, меню, разбор аргументов
│   ├── parsing.py       # разбор ссылок и имён файлов (без тяжёлых зависимостей)
│   ├── webinar.py       # оркестрация: получение данных и сборка видео
│   ├── downloader.py    # HTTP-запросы и скачивание чанков
│   ├── processor.py     # обработка/склейка через ffmpeg
│   └── utils.py         # логгер и вспомогательные функции
├── tests/               # юнит-тесты (pytest)
├── streamosos.bat       # запускатель для Windows (двойной клик)
├── streamosos.sh        # запускатель для Linux / macOS
├── activate.bat         # консоль с включённой командой streamosos
├── bootstrap.ps1        # one-shot установка для PowerShell
├── setup.ps1 / setup.bat / setup.sh   # локальные сетап-скрипты
├── .github/workflows/ci.yml   # автотесты на GitHub Actions
└── pyproject.toml       # метаданные пакета и зависимости
```

## Разработка

```bash
pip install -e ".[dev]"  # установка с dev-зависимостями (pytest)
pytest                  # запуск тестов
python -m streamosos    # запуск без установленной команды
```

Тесты и сборка автоматически проверяются на GitHub Actions при каждом push и PR.

## Лицензия

MIT — см. файл [LICENSE](LICENSE).
