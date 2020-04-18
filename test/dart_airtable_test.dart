import 'dart:math';

import 'package:dart_airtable/dart_airtable.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'dart:convert' show jsonEncode, jsonDecode;

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

    group('getRecord', () {
      test('it returns null when the record is not found', () async {
        airtable.client = MockClient(
          (Request req) async => Response(
            '',
            404,
          ),
        );

        expect(await airtable.getRecord('Transactions', '1234'), null);
      });

      test('it returns the expected record when the record exists', () async {
        airtable.client = MockClient(
          (Request req) async => Response(
            jsonEncode({
              'id': req.url.path.split('/').last,
              'createdTime': DateTime.now().toIso8601String(),
              'fields': {
                'Name': 'Giant Eagle',
                'Amount': 25.35,
                'Date of Transaction': DateTime.now()
                    .subtract(Duration(days: 2))
                    .toIso8601String(),
              },
            }),
            200,
          ),
        );

        var record = await airtable.getRecord('Transactions', '1234');

        expect(record, isNotNull);
        expect(record, isA<AirtableRecord>());
        expect(record.id, '1234');
        expect(record.createdTime, isNotNull);
        expect(record.getField('Name').value, 'Giant Eagle');
        expect(record.getField('Amount').value, 25.35);
        expect(record.getField('Date of Transaction').value, isNotNull);
      });
    });

    group('createRecords', () {
      test('it creates the records and returns an id & createdTime for each',
          () async {
        airtable.client = MockClient((Request req) async {
          var parsedBody = jsonDecode(req.body);
          var requestRecords =
              List<Map<String, dynamic>>.from(parsedBody['records']);
          var random = Random();

          return Response(
            jsonEncode({
              'records': requestRecords.map((Map<String, dynamic> record) {
                record['id'] = random.nextInt(1000).toString();
                record['createdTime'] = DateTime.now()
                    .subtract(Duration(days: random.nextInt(10)))
                    .toIso8601String();

                return record;
              }).toList(),
            }),
            200,
          );
        });

        var record1 = AirtableRecord(fields: [
          AirtableRecordField(fieldName: 'Name', value: 'Giant Eagle'),
        ]);
        var record2 = AirtableRecord(fields: [
          AirtableRecordField(fieldName: 'Name', value: 'Kroger'),
        ]);
        var records =
            await airtable.createRecords('Transactions', [record1, record2]);

        expect(records, hasLength(2));
        expect(records.first, isA<AirtableRecord>());
        expect(records.first.id, isNotNull);
        expect(records.first.fields, hasLength(1));
        expect(records.first.getField('Name').value, 'Giant Eagle');

        expect(records.last, isA<AirtableRecord>());
        expect(records.last.id, isNotNull);
        expect(records.last.fields, hasLength(1));
        expect(records.last.getField('Name').value, 'Kroger');
      });

      test('it handles errors', () async {
        airtable.client = MockClient(
          (Request req) async => Response(
            jsonEncode({
              'error': {
                'type': 'INVALID_REQUEST_UNKNOWN',
                'message':
                    'Invalid Request: parameter validation failed. Check your request data.',
              }
            }),
            422,
          ),
        );

        var record1 = AirtableRecord(
          id: '12345',
          fields: [
            AirtableRecordField(fieldName: 'Name', value: 'Giant Eagle'),
          ],
        );
        var records = await airtable.createRecords('Transactions', [record1]);

        expect(records, isEmpty);
      });
    });

    group('createRecord', () {
      test(
          'it creates the record and returns an id & createdTime for the record',
          () async {
        airtable.client = MockClient((Request req) async {
          var parsedBody = jsonDecode(req.body);
          var requestRecords =
              List<Map<String, dynamic>>.from(parsedBody['records']);
          var random = Random();

          return Response(
            jsonEncode({
              'records': requestRecords.map((Map<String, dynamic> record) {
                record['id'] = random.nextInt(1000).toString();
                record['createdTime'] = DateTime.now()
                    .subtract(Duration(days: random.nextInt(10)))
                    .toIso8601String();

                return record;
              }).toList(),
            }),
            200,
          );
        });

        var record = AirtableRecord(fields: [
          AirtableRecordField(fieldName: 'Name', value: 'Giant Eagle'),
        ]);
        AirtableRecord savedRecord =
            await airtable.createRecord('Transactions', record);

        expect(savedRecord, isA<AirtableRecord>());
        expect(savedRecord.id, isNotNull);
        expect(savedRecord.createdTime, isNotNull);
        expect(savedRecord.fields, hasLength(1));
        expect(savedRecord.getField('Name').value, 'Giant Eagle');
      });

      test('it handles errors', () async {
        airtable.client = MockClient(
          (Request req) async => Response(
            jsonEncode({
              'error': {
                'type': 'INVALID_REQUEST_UNKNOWN',
                'message':
                    'Invalid Request: parameter validation failed. Check your request data.',
              }
            }),
            422,
          ),
        );

        var record = AirtableRecord(
          id: '12345',
          fields: [
            AirtableRecordField(fieldName: 'Name', value: 'Giant Eagle'),
          ],
        );
        var savedRecord = await airtable.createRecord('Transactions', record);

        expect(savedRecord, isNull);
      });
    });

    group('updateRecords', () {
      test('it updates the records and returns the new records', () async {
        airtable.client = MockClient((Request req) async {
          var parsedBody = jsonDecode(req.body);
          var requestRecords =
              List<Map<String, dynamic>>.from(parsedBody['records']);

          return Response(
            jsonEncode({'records': requestRecords}),
            200,
          );
        });

        var record1 = AirtableRecord(
          id: '12345',
          createdTime: DateTime.now(),
          fields: [
            AirtableRecordField(fieldName: 'Name', value: 'Giant Eagle')
          ],
        );
        var record2 = AirtableRecord(
          id: 'abcdef',
          createdTime: DateTime.now(),
          fields: [
            AirtableRecordField(fieldName: 'Name', value: 'Giant Eagle')
          ],
        );

        record1.getField('Name').value = 'Kroger';

        List<AirtableRecord> savedRecords =
            await airtable.updateRecords('Transactions', [record1, record2]);

        expect(savedRecords, hasLength(2));
        expect(savedRecords.first, isA<AirtableRecord>());
        expect(savedRecords.first.id, record1.id);
        expect(savedRecords.first.createdTime, record1.createdTime);
        expect(savedRecords.first.fields, hasLength(1));
        expect(savedRecords.first.getField('Name').value, 'Kroger');

        expect(savedRecords.last, isA<AirtableRecord>());
        expect(savedRecords.last.id, record2.id);
        expect(savedRecords.last.createdTime, record2.createdTime);
        expect(savedRecords.last.fields, hasLength(1));
        expect(savedRecords.last.getField('Name').value, 'Giant Eagle');
      });

      test('it handles errors', () async {
        airtable.client = MockClient(
          (Request req) async => Response(
            jsonEncode({
              'error': {
                'type': 'INVALID_REQUEST_UNKNOWN',
                'message':
                    'Invalid Request: parameter validation failed. Check your request data.',
              }
            }),
            422,
          ),
        );

        var record = AirtableRecord(
          id: '12345',
          fields: [
            AirtableRecordField(fieldName: 'Name', value: 'Giant Eagle'),
          ],
        );
        var savedRecord = await airtable.createRecord('Transactions', record);

        expect(savedRecord, isNull);
      });
    });
  });
}
