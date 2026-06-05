from streamosos.parsing import extract_ids_from_url, sanitize_filename


class TestExtractIdsFromUrl:
    def test_url_without_record_file(self):
        url = 'https://my.mts-link.ru/12345678/987654321/record-new/123456789'
        assert extract_ids_from_url(url) == ('123456789', None)

    def test_url_with_record_file(self):
        url = ('https://my.mts-link.ru/12345678/987654321/record-new/'
               '123456789/record-file/1234567890')
        assert extract_ids_from_url(url) == ('123456789', '1234567890')

    def test_url_with_extra_leading_segment(self):
        # The (?:[^/]+/)? optional segment before the two numeric ids.
        url = 'https://my.mts-link.ru/org/12345678/987654321/record-new/123456789'
        assert extract_ids_from_url(url) == ('123456789', None)

    def test_surrounding_whitespace_is_ignored(self):
        url = '  https://my.mts-link.ru/12345678/987654321/record-new/123456789  '
        assert extract_ids_from_url(url) == ('123456789', None)

    def test_invalid_domain(self):
        assert extract_ids_from_url('https://example.com/record-new/1') == (None, None)

    def test_garbage_input(self):
        assert extract_ids_from_url('not a url') == (None, None)

    def test_empty_input(self):
        assert extract_ids_from_url('') == (None, None)


class TestSanitizeFilename:
    def test_replaces_unsafe_characters(self):
        assert sanitize_filename('Вебинар: 1/2 *тест*') == 'Вебинар_1_2_тест'

    def test_collapses_runs_of_unsafe_chars(self):
        assert sanitize_filename('a   b') == 'a_b'

    def test_strips_leading_and_trailing_separators(self):
        assert sanitize_filename('  ...name...  ') == 'name'

    def test_empty_name_uses_fallback(self):
        assert sanitize_filename('') == 'webinar'
        assert sanitize_filename('   ', fallback='record') == 'record'

    def test_none_is_handled(self):
        assert sanitize_filename(None) == 'webinar'
