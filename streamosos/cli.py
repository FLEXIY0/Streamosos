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


def main():
    logging.basicConfig(level=logging.INFO)
    args = parse_arguments()
    print(BANNER.format(version=__version__))

    url = args.url
    if not url:
        url = input('Вставь ссылку на запись МТС Линк: ').strip()

    if not url:
        logging.error('Ссылка не введена.')
        return

    event_sessions, record_id = extract_ids_from_url(url)
    if not event_sessions:
        logging.error('Неверный формат ссылки. Проверь URL.')
        return

    logging.info(f'Starting download: event_sessions={event_sessions}, record_id={record_id}')

    if fetch_webinar_data(
        event_sessions=event_sessions,
        record_id=record_id,
        session_id=args.session_id
    ):
        logging.info('Download completed.')


if __name__ == '__main__':
    main()