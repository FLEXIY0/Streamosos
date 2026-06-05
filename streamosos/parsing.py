"""Pure helpers for URL parsing and filename sanitization.

This module intentionally imports only the standard library so it can be used
(and unit-tested) without the heavier runtime dependencies (httpx, tqdm).
"""
import re
from typing import Optional, Tuple

# Matches MTS Link record URLs, e.g.
#   https://my.mts-link.ru/12345678/987654321/record-new/123456789
#   https://my.mts-link.ru/12345678/987654321/record-new/123456789/record-file/1234567890
RECORD_URL_PATTERN = re.compile(
    r'^https://my\.mts-link\.ru/(?:[^/]+/)?\d+/\d+/record-new/(\d+)(?:/record-file/(\d+))?$'
)

# Characters not allowed (or awkward) in file/folder names across platforms.
_UNSAFE_NAME_CHARS = re.compile(r'[\s/:*?"<>|\\]+')


def extract_ids_from_url(url: str) -> Tuple[Optional[str], Optional[str]]:
    """Return (event_session_id, record_id) parsed from a record URL.

    record_id is None when the URL has no /record-file/ part.
    Returns (None, None) when the URL does not match the expected format.
    """
    match = RECORD_URL_PATTERN.match(url.strip()) if url else None
    if not match:
        return None, None
    return match.group(1), match.group(2) or None


def sanitize_filename(name: str, fallback: str = 'webinar') -> str:
    """Turn an arbitrary webinar name into a safe file/folder name."""
    cleaned = _UNSAFE_NAME_CHARS.sub('_', (name or '').strip())
    cleaned = cleaned.strip('_. ')
    return cleaned or fallback
