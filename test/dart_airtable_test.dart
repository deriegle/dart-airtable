import 'package:dart_airtable/dart_airtable.dart';
import 'package:http/http.dart';
import 'package:test/test.dart';

const MOCK_API_KEY = '1234';
const MOCK_PROJECT_BASE = 'abcdefg';

void main() {
  group('Airtable', () {
    Airtable airtable;

    setUp(() {
      airtable = Airtable(MOCK_API_KEY, MOCK_PROJECT_BASE);
    });

    test('has the correct api url', () {
      expect(airtable.apiUrl, 'https://api.airtable.com');
    });
  });
}
