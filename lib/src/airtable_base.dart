part of dart_airtable;

const _defaultAirtableApiUrl = 'https://api.airtable.com';

class Airtable {
  final String? apiKey;
  final String? projectBase;
  final String apiUrl;
  http.Client client;

  Airtable({
    required this.apiKey,
    required this.projectBase,
    this.apiUrl = _defaultAirtableApiUrl,
    http.Client? client,
  }) : client = client ?? http.Client();

  /// Gets a List of AirtableRecords from Airtable based on the record name
  ///
  /// [Returns List of updated records]
  Future<List<AirtableRecord>> getAllRecords(
    String? recordName, {
    int? maxRecords,
    int? pageSize,
  }) async {
    final response = await client.get(
      _recordApiUrl(recordName),
      headers: _headers,
    );

    Map<String, dynamic>? body = jsonDecode(response.body);
    if (body == null) {
      return [];
    }

    final records = List<Map<String, dynamic>>.from(body['records']);

    if (records.isEmpty) {
      return [];
    }

    return records
        .map<AirtableRecord>(
            (Map<String, dynamic> record) => AirtableRecord.fromJSON(record))
        .toList();
  }

  /// Creates a new AirtableRecord in Airtable based on a given AirtableRecord
  ///
  /// [Returns AirtableRecord with ids when successful]
  /// [Returns null when unsuccessful]
  Future<AirtableRecord?> createRecord(String recordName, AirtableRecord record,
      {bool typecast = false}) async {
    final records =
        await createRecords(recordName, [record], typecast: typecast);
    return records.isEmpty ? null : records.first;
  }

  /// Creates multiple records in Airtable using a list of AirtableRecord instances
  ///
  Future<List<AirtableRecord>> createRecords(
      String recordName, List<AirtableRecord> records,
      {bool typecast = false}) async {
    final body = {
      'records': records.map((record) => record.toJSON()).toList(),
      'typecast': typecast,
    };

    final response = await client.post(
      _recordApiUrl(recordName),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.body.isEmpty ||
        response.statusCode == HttpStatus.unprocessableEntity) {
      return [];
    }

    Map<String, dynamic>? responseBody = jsonDecode(response.body);
    if (responseBody == null || responseBody['error'] != null) {
      return [];
    }

    final savedRecords =
        List<Map<String, dynamic>>.from(responseBody['records']);

    if (savedRecords.isEmpty) {
      return [];
    }

    return savedRecords
        .map<AirtableRecord>(
            (Map<String, dynamic> record) => AirtableRecord.fromJSON(record))
        .toList();
  }

  /// Gets a single record based on the record name and ID from Airtable
  ///
  /// [Returns nullable Future]
  Future<AirtableRecord?> getRecord(String recordName, String recordId) async {
    final response = await client
        .get(_recordApiUrl(recordName, path: '/$recordId'), headers: _headers);

    if (response.statusCode == HttpStatus.notFound || response.body.isEmpty) {
      return null;
    }

    Map<String, dynamic> body = jsonDecode(response.body);

    return AirtableRecord.fromJSON(body);
  }

  /// Get records based on the filtering formula supplied as defined by [Airtable API](https://support.airtable.com/hc/en-us/articles/203255215-Formula-Field-Reference)
  ///
  /// [Returns Future or throws exception]
  Future<List<AirtableRecord>?> getRecordsFilterByFormula(
      String recordName, String filter) async {
    final response = await client.get(
      _recordApiUrl(recordName, queryParams: {
        'filterByFormula': filter,
      }),
      headers: _headers,
    );

    Map<String, dynamic> responseJson = jsonDecode(response.body);
    if (responseJson.containsKey('error')) {
      throw Exception(
          "${responseJson['error']['type']}::${responseJson['error']['message']}");
    }

    if (!responseJson.containsKey('records')) {
      throw Exception('Response is missing records.');
    }

    return responseJson['records']
        .map<AirtableRecord>((record) => AirtableRecord.fromJSON(record))
        .toList();
  }

  /// Returns a list of updated AirtableRecords
  ///
  /// [Returns empty if update is not successful]
  Future<List<AirtableRecord>> updateRecords(
      String recordName, List<AirtableRecord> records,
      {bool typecast = false}) async {
    final body = {
      'records': records.map((record) => record.toJSON()).toList(),
      'typecast': typecast,
    };

    final response = await client.patch(
      _recordApiUrl(recordName),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == HttpStatus.unprocessableEntity) {
      return [];
    }

    Map<String, dynamic>? responseBody = jsonDecode(response.body);
    if (responseBody == null || responseBody['error'] != null) {
      return [];
    }

    final savedRecords =
        List<Map<String, dynamic>>.from(responseBody['records']);

    if (savedRecords.isEmpty) {
      return [];
    }

    return savedRecords
        .map<AirtableRecord>(
            (Map<String, dynamic> record) => AirtableRecord.fromJSON(record))
        .toList();
  }

  /// Updates a single AirtableRecord
  ///
  /// [Returns null if unsuccessful]
  Future<AirtableRecord?> updateRecord(String recordName, AirtableRecord record,
      {bool typecast = false}) async {
    final records = await updateRecords(
      recordName,
      [record],
      typecast: typecast,
    );
    return records.isEmpty ? null : records.first;
  }

  /// Deletes a list of AirtableRecords
  ///
  /// [Returns List of ids]
  Future<List<String?>> deleteRecords(
      String recordName, List<AirtableRecord> records) async {
    final params = {for (var record in records) 'records[]': record.id};

    final response = await client.delete(
      _recordApiUrl(recordName, queryParams: params),
      headers: _headers,
    );

    if (response.body.isEmpty) {
      return [];
    }

    Map<String, dynamic>? body = jsonDecode(response.body);
    if (body == null || body['error'] != null) {
      return [];
    }

    final resultRecords = List<Map<String, dynamic>>.from(body['records']);

    return resultRecords
        .where((record) => record['deleted'] == true)
        .map<String?>((record) => record['id'])
        .toList();
  }

  Uri _recordApiUrl(String? recordName,
      {String? path, Map<String, String?>? queryParams}) {
    var url = apiUrl.replaceAll(RegExp('^https?:\/\/'), '');
    final fullPath = '/v0/$projectBase/$recordName${path ?? ''}';
    return Uri.https(url, fullPath, queryParams);
  }

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      };
}
