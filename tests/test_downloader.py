import pytest

from streamosos.downloader import construct_json_data_url


def test_url_without_recording_id():
    url = construct_json_data_url(event_session_id='123', recording_id=None)
    assert url == 'https://my.mts-link.ru/api/eventsessions/123/record?withoutCuts=false'


def test_url_with_recording_id():
    url = construct_json_data_url(event_session_id='123', recording_id='456')
    assert url == (
        'https://my.mts-link.ru/api/event-sessions/123/record-files/456/flow?withoutCuts=false'
    )


def test_missing_event_session_raises():
    with pytest.raises(ValueError):
        construct_json_data_url(event_session_id='', recording_id=None)
