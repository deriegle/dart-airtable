part of dart_airtable;

class AirtableRecord {
  final String id;
  final DateTime createdTime;
  List<AirtableRecordField> fields = [];

  AirtableRecord({
    @required this.fields,
    this.createdTime,
    this.id,
  });

  AirtableRecordField getField(String fieldName) => fields.firstWhere(
        (f) => f.fieldName == fieldName,
        orElse: () => null,
      );

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'fields': _jsonFields,
      'id': id,
      'createdTime': createdTime?.toIso8601String(),
    };
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
    return 'AirtableRecord(id: $id, createdTime: ${createdTime.toString()}, fields: ${_jsonFields.toString()})';
  }

  Map<String, dynamic> get _jsonFields {
    return {}..addEntries(
        fields.map<MapEntry<String, dynamic>>((f) => f.toMapEntry()).toList(),
      );
  }
}
