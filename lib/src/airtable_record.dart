part of dart_airtable;

extension FirstWhereOrNull<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
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
    if (id == null) {
      return <String, dynamic>{
        'fields': _jsonFields,
      };
    } else {
      return <String, dynamic>{
        'fields': _jsonFields,
        'id': id,
      };
    }
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
