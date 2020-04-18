import 'package:dart_airtable/dart_airtable.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'dart:convert' show jsonEncode;

const MOCK_API_KEY = '1234';
const MOCK_PROJECT_BASE = 'abcdefg';

void main() {
  group('Airtable', () {
    Airtable airtable;

    setUp(() {
      airtable = Airtable(apiKey: MOCK_API_KEY, projectBase: MOCK_PROJECT_BASE);
    });

    test('has the correct api url', () {
      expect(airtable.apiUrl, 'https://api.airtable.com');
    });

    group('getAllRecords', () {
      test('it returns the expected records when given valid record name',
          () async {
        airtable.client = MockClient(
          (Request req) async => Response(
            jsonEncode({'records': []}),
            200,
          ),
        );

        expect(await airtable.getAllRecords('Transactions'), equals([]));
      });

      test('it returns the expected records when there are records', () async {
        airtable.client = MockClient(
          (Request req) async => Response(
            jsonEncode({
              'records': [
                {
                  'id': 'abcdefg',
                  'createdTime': DateTime.now().toIso8601String(),
                  'fields': {
                    'Name': 'Giant Eagle',
                    'Amount': 25.35,
                    'Date of Transaction': DateTime.now()
                        .subtract(Duration(days: 2))
                        .toIso8601String(),
                  },
                },
                {
                  'id': '12345',
                  'createdTime': DateTime.now().toIso8601String(),
                  'fields': {
                    'Name': 'Kroger',
                    'Amount': 53.35,
                    'Date of Transaction': DateTime.now()
                        .subtract(Duration(days: 4))
                        .toIso8601String(),
                  },
                }
              ]
            }),
            200,
          ),
        );

        var records = await airtable.getAllRecords('Transactions');

        expect(records, hasLength(2));
        expect(records.first, isA<AirtableRecord>());
        expect(records.first.id, 'abcdefg');
        expect(records.first.createdTime, isNotNull);
        expect(records.first.fields, hasLength(3));
        expect(records.first.getField('Name').value, 'Giant Eagle');
        expect(records.first.getField('Amount').value, 25.35);
        expect(records.first.getField('Date of Transaction').value, isNotNull);

        expect(records.last, isA<AirtableRecord>());
        expect(records.last.id, '12345');
        expect(records.last.createdTime, isNotNull);
        expect(records.last.fields, hasLength(3));
        expect(records.last.getField('Name').value, 'Kroger');
        expect(records.last.getField('Amount').value, 53.35);
        expect(records.last.getField('Date of Transaction').value, isNotNull);
      });
    });
  });
}
