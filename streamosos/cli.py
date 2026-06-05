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


def run_interactive(default_session_id=None):
    """Interactive loop: ask for a link, download, repeat until the user quits."""
    print('Интерактивный режим. Вставляй ссылки по одной.')
    print("Команды: 'q' / 'exit' — выход.\n")

    while True:
        try:
            url = input('Ссылка на запись МТС Линк (q — выход): ').strip()
        except (EOFError, KeyboardInterrupt):
            print('\nВыход.')
            break

        if url.lower() in ('q', 'quit', 'exit'):
            print('Выход.')
            break
        if not url:
            continue

        event_sessions, _ = extract_ids_from_url(url)
        if not event_sessions:
            logging.error('Неверный формат ссылки. Проверь URL.')
            continue

        session_id = default_session_id
        if not session_id:
            entered = input('sessionId для приватной записи (Enter — пропустить): ').strip()
            session_id = entered or None

        try:
            download_one(url, session_id=session_id)
        except KeyboardInterrupt:
            logging.warning('Загрузка прервана пользователем.')
        except Exception as exc:
            logging.error(f'Ошибка при загрузке: {exc}')


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