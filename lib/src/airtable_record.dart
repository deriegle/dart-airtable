part of dart_airtable;

extension FirstWhereOrNull<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

class AirtableRecordsResponse {
  List<AirtableRecord> records = [];
  String? offset;

  AirtableRecordsResponse(this.records, this.offset);
}

class AirtableRecord {
  final String? id;
  final DateTime? createdTime;
  List<AirtableRecordField> fields = [];

  AirtableRecord({
    required this.fields,
    this.createdTime,
    this.id,
  });

  AirtableRecordField? getField(String fieldName) =>
      fields.firstWhereOrNull((f) => f.fieldName == fieldName);

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> result = {
      'fields': _jsonFields,
    };

    if (id != null) {
      result['id'] = id;
    }

    return result;
  }

  factory AirtableRecord.fromJSON(Map<String, dynamic> json) {
    final fields = Map.from(json['fields']);

    return AirtableRecord(
      id: json['id'],
      createdTime: DateTime.tryParse(json['createdTime']),
      fields: fields.entries
          .map((e) => AirtableRecordField.fromMapEntry(e))
          .toList(),
    );
  }

  @override
  String toString() {
    if (id != null && createdTime != null) {
      return 'AirtableRecord(id: $id, createdTime: $createdTime, fields: $_jsonFields)';
    } else {
      return 'AirtableRecord(fields: $_jsonFields)';
    }
  }

  Map<String, dynamic> get _jsonFields {
    return Map.fromEntries(
      fields.map<MapEntry<String, dynamic>>((f) => f.toMapEntry()).toList(),
    );
  }
}
