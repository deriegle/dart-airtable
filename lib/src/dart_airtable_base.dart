import 'dart:html';

import 'package:http/http.dart' as http;
import 'dart:convert' show jsonEncode, jsonDecode;
import 'package:dart_airtable/src/airtable_record.dart';
import 'package:meta/meta.dart';

const _defaultAirtableApiUrl = 'https://api.airtable.com';

/// Checks if you are awesome. Spoiler: you are.
class Airtable {
  final String apiKey;
  final String projectBase;
  final String apiUrl;
  http.Client client;

  Airtable({
    @required this.apiKey,
    @required this.projectBase,
    this.apiUrl = _defaultAirtableApiUrl,
    this.client,
  }) : assert(apiUrl != null) {
    client = client ?? http.Client();
  }

  Future<List<AirtableRecord>> getAllRecords(String recordName,
      {int maxRecords, int pageSize}) async {
    var response = await client.get(_recordApiUrl(recordName), headers: {
      'Authorization': 'Bearer $apiKey',
    });

    Map<String, dynamic> body = jsonDecode(response.body);
    if (body == null) {
      return [];
    }

    print(body);

    var records = List<Map<String, dynamic>>.from(body['records']);

    if (records == null || records.isEmpty) {
      return [];
    }

    return records
        .map<AirtableRecord>(
            (Map<String, dynamic> record) => AirtableRecord.fromJSON(record))
        .toList();
  }

  Future<List<AirtableRecord>> createRecords(
      String recordName, List<AirtableRecord> records) async {
    var requestBody = {
      'records': records.map((record) => record.toJSON()).toList(),
    };

    print(requestBody);
    var response = await client.post(
      _recordApiUrl(recordName),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    // TODO: Check for errors
    /*
       {
         "error": {
           "type": "INVALID_REQUEST_UNKNOWN",
           "message": "Invalid Request: paramter validation failed. Check your request data."
         }
       }
     */

    print(response.statusCode);
    print(response.body);

    Map<String, dynamic> body = jsonDecode(response.body);
    if (body == null) {
      return [];
    }

    List<Map<String, dynamic>> savedRecords = body['records'];

    if (savedRecords == null || savedRecords.isEmpty) {
      return [];
    }

    return savedRecords
        .map<AirtableRecord>(
            (Map<String, dynamic> record) => AirtableRecord.fromJSON(record))
        .toList();
  }

  Future<AirtableRecord> getRecord(String recordName, String recordId) async {
    var response =
        await client.get('${_recordApiUrl(recordName)}/$recordId', headers: {
      'Authorization': 'Bearer $apiKey',
    });

    if (response.statusCode == HttpStatus.notFound ||
        response.body == null ||
        response.body.isEmpty) {
      return null;
    }

    Map<String, dynamic> body = jsonDecode(response.body);

    return AirtableRecord.fromJSON(body);
  }

  String _recordApiUrl(String recordName) {
    return '$apiUrl/v0/$projectBase/$recordName';
  }
}
