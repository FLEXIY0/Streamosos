import argparse
import logging
import re

from streamosos import __version__
from streamosos.webinar import fetch_webinar_data

BANNER = r"""
  ____  _
 / ___|| |_ _ __ ___  __ _ _ __ ___   ___  ___  ___  ___
 \___ \| __| '__/ _ \/ _` | '_ ` _ \ / _ \/ __|/ _ \/ __|
  ___) | |_| | |  __/ (_| | | | | | | (_) \__ \ (_) \__ \
 |____/ \__|_|  \___|\__,_|_| |_| |_|\___/|___/\___/|___/
        MTS Link webinar downloader  v{version}
"""


def parse_arguments():
    parser = argparse.ArgumentParser(
        prog='streamosos',
        description='Streamosos - tool for downloading MTS Link webinars.'
    )
    parser.add_argument(
        'url',
        nargs='?',
        help=(
            'Webinar link in one of the following formats: '
            'https://my.mts-link.ru/12345678/987654321/record-new/123456789/record-file/1234567890 or '
            'https://my.mts-link.ru/12345678/987654321/record-new/123456789'
        )
    )
    parser.add_argument(
        '--session-id',
        help='[Optional] sessionId token for accessing private recordings.'
    )
    parser.add_argument(
        '-i', '--interactive',
        action='store_true',
        help='Start interactive mode: download several recordings one after another.'
    )
    parser.add_argument(
        '--version',
        action='version',
        version=f'Streamosos {__version__}'
    )
    return parser.parse_args()


def extract_ids_from_url(url: str):
    url_pattern = (
        r'^https://my\.mts-link\.ru/(?:[^/]+/)?\d+/\d+/record-new/(\d+)(?:/record-file/(\d+))?$'
    )
    match = re.match(url_pattern, url)
    if match:
        event_sessions = match.group(1)
        record_id = match.group(2) if match.group(2) else None
        return event_sessions, record_id

    return None, None


def download_one(url: str, session_id=None) -> bool:
    """Download a single recording by URL. Returns True on success."""
    event_sessions, record_id = extract_ids_from_url(url)
    if not event_sessions:
        logging.error('Неверный формат ссылки. Проверь URL.')
        return False

    logging.info(f'Starting download: event_sessions={event_sessions}, record_id={record_id}')
    if fetch_webinar_data(
        event_sessions=event_sessions,
        record_id=record_id,
        session_id=session_id
    ):
        logging.info('Download completed.')
        return True
    return False


MENU = """
==================================================
            STREAMOSOS  -  главное меню
==================================================

   1  - Скачать запись  (просто вставь ссылку)
   2  - Скачать приватную запись  (нужен sessionId)
   3  - Помощь: где взять ссылку и sessionId
   0  - Выход

  Подсказка: можно сразу вставить ссылку и нажать Enter.
"""

HELP_TEXT = """
  --- Где взять ССЫЛКУ ---
    Открой нужную запись на my.mts-link.ru и скопируй адрес
    из адресной строки браузера. Подходящий вид ссылки:
        https://my.mts-link.ru/.../record-new/123456789

  --- Где взять sessionId (только для приватных записей) ---
    1) Открой запись в браузере, войдя в свой аккаунт.
    2) Нажми F12 -> вкладка Application (Приложение) -> Cookies.
    3) Найди значение sessionId для my.mts-link.ru и скопируй его.
"""


def handle_url(url: str, session_id=None):
    """Validate a link, download it and print a human-friendly result."""
    event_sessions, _ = extract_ids_from_url(url)
    if not event_sessions:
        print('\n  [!] Это не похоже на ссылку записи МТС Линк. Проверь и попробуй ещё раз.\n')
        return

    try:
        ok = download_one(url, session_id=session_id)
    except KeyboardInterrupt:
        print('\n  Загрузка прервана.\n')
        return
    except Exception as exc:
        logging.error(f'Ошибка при загрузке: {exc}')
        return

    if ok:
        print('\n  [OK] Готово! Видео сохранено в папке с названием вебинара.\n')
    else:
        print('\n  [!] Не получилось скачать. Если запись приватная — выбери пункт 2 '
              'и укажи sessionId.\n')


def run_interactive(default_session_id=None):
    """Friendly menu-driven loop until the user chooses to exit."""
    while True:
        print(MENU)
        try:
            choice = input('  Твой выбор (0-3 или ссылка): ').strip()
        except (EOFError, KeyboardInterrupt):
            print('\n  Выход.')
            break

        low = choice.lower()

        if low in ('0', 'q', 'quit', 'exit', 'выход'):
            print('  Выход. До встречи!')
            break

        # Пользователь сразу вставил ссылку — скачиваем без лишних вопросов.
        if low.startswith('http'):
            handle_url(choice, session_id=default_session_id)

        elif choice == '1':
            url = input('  Вставь ссылку на запись и нажми Enter: ').strip()
            if url:
                handle_url(url, session_id=default_session_id)

        elif choice == '2':
            url = input('  Вставь ссылку на запись: ').strip()
            if not url:
                continue
            session_id = default_session_id
            if not session_id:
                session_id = input('  Вставь sessionId (или Enter, чтобы пропустить): ').strip() or None
            handle_url(url, session_id=session_id)

        elif choice == '3':
            print(HELP_TEXT)

        else:
            print('\n  Не понял выбор. Введи 0, 1, 2 или 3 — или сразу вставь ссылку.\n')


def main():
    logging.basicConfig(level=logging.INFO)
    args = parse_arguments()
    print(BANNER.format(version=__version__))

    # No URL on the command line, or -i requested -> interactive loop.
    if args.interactive or not args.url:
        run_interactive(default_session_id=args.session_id)
        return

    download_one(args.url, session_id=args.session_id)


if __name__ == '__main__':
    main()