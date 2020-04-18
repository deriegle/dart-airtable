import 'package:meta/meta.dart';
import 'airtable_record_field.dart';

class AirtableRecord {
  String _id;
  DateTime _createdTime;
  List<AirtableRecordField> fields = [];

  AirtableRecord({
    @required this.fields,
    String id,
    DateTime createdTime,
  }) {
    _id = id;
    _createdTime = createdTime;
  }

  String get id => _id;
  DateTime get createdTime => _createdTime;

  AirtableRecordField getField(String fieldName) {
    return fields.firstWhere(
      (f) => f.fieldName == fieldName,
      orElse: () => null,
    );
  }

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> json = {
      'fields': _jsonFields,
    };

    if (id != null) {
      json['id'] = id;
    }

    if (createdTime != null) {
      json['createdTime'] = createdTime.toIso8601String();
    }

    return json;
  }

  factory AirtableRecord.fromJSON(Map<String, dynamic> json) {
    var fields = Map.from(json['fields']);

    return AirtableRecord(
      id: json['id'],
      createdTime: json['createdTime'] != null
          ? DateTime.tryParse(json['createdTime'])
          : null,
      fields: fields.entries
          .map(
            (mapEntry) => AirtableRecordField(
              fieldName: mapEntry.key,
              value: mapEntry.value,
            ),
          )
          .toList(),
    );
  }

  @override
  String toString() {
    return 'AirtableRecord(id: $id, createdTime: ${createdTime.toString()}, fields: ${_jsonFields.toString()})';
  }

  Map<String, dynamic> get _jsonFields {
    Map<String, dynamic> json = {};

    json.addEntries(
        fields.map<MapEntry<String, dynamic>>((f) => f.toMapEntry()));

    return json;
  }
}
