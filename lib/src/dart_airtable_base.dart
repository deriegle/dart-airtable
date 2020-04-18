// TODO: Put public facing types in this file.
import 'package:http/http.dart' as http;
import 'dart:convert' show jsonEncode, jsonDecode;
import 'package:dart_airtable/src/airtable_record.dart';

const _defaultAirtableApiUrl = 'https://api.airtable.com';

/// Checks if you are awesome. Spoiler: you are.
class Airtable {
  final String _apiKey;
  final String _projectBase;
  final String apiUrl;

  Airtable(this._apiKey, this._projectBase, { this.apiUrl = _defaultAirtableApiUrl })
      : assert(_apiKey != null && _projectBase != null && apiUrl != null);

  Future<List<AirtableRecord>> getAllRecords(String recordName, {int maxRecords, int pageSize}) async {
    var response = await http.get(_recordApiUrl(recordName), headers: {
      'Authorization': 'Bearer $_apiKey',
    });

    Map<String, dynamic> body = jsonDecode(response.body);
    if (body == null) { return []; }

    var records = List<Map<String, dynamic>>.from(body['records']);

    if (records == null || records.isEmpty) {
      return [];
    }

    return records.map<AirtableRecord>((Map<String, dynamic> record) => AirtableRecord.fromJSON(record)).toList();
  }

  Future<List<AirtableRecord>> createRecords(String recordName, List<AirtableRecord> records) async {
    var response = await http.post(_recordApiUrl(recordName),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'records': records.map((record) => record.toJSON()).toList(),
      }),
    );

    Map<String, dynamic> body = jsonDecode(response.body);
    if (body == null) { return []; }

    List<Map<String, dynamic>> savedRecords = body['records'];

    if (savedRecords == null || savedRecords.isEmpty) {
      return [];
    }

    return savedRecords
        .map<AirtableRecord>((Map<String, dynamic> record) => AirtableRecord.fromJSON(record))
        .toList();
  }

  Future<AirtableRecord> getRecord(String recordName, String recordId) async {
    var response = await http.get('${_recordApiUrl(recordName)}/$recordId', headers: {
      'Authorization': 'Bearer $_apiKey',
    });

    Map<String, dynamic> body = jsonDecode(response.body);

    // TODO: Return error if body is null
    if (body == null) { return null; }

    return AirtableRecord.fromJSON(body);
  }

  String _recordApiUrl(String recordName) {
    return '$apiUrl/v0/$_projectBase/$recordName';
  }
}
