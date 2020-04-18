import 'package:meta/meta.dart';

class AirtableRecord {
  String id;
  DateTime createdTime = DateTime.now();
  List<AirtableRecordField> fields = [];

  AirtableRecord({
    @required this.id,
    @required this.createdTime,
    @required this.fields,
  });

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'createdTime': createdTime.toIso8601String(),
      'fields': _jsonFields,
    };
  }

  factory AirtableRecord.fromJSON(Map<String, dynamic> json) {
    var fields = Map.from(json['fields']);

    return AirtableRecord(
      id: json['id'],
      createdTime: DateTime.tryParse(json['createdTime']),
      fields: fields.entries.map(
        (mapEntry) => AirtableRecordField(
          fieldName: mapEntry.key,
          value: mapEntry.value,
        ),
      ).toList(),
    );
  }

  @override
  String toString() {
    return 'AirtableRecord(id: $id, createdTime: ${createdTime.toString()}, fields: ${_jsonFields.toString()}';
  }

  Map<String, dynamic> get _jsonFields {
    Map<String, dynamic> json = {};

    fields.forEach((field) => json[field.fieldName] = field.value);

    return json;
  }
}

class AirtableRecordField {
  String fieldName;
  dynamic value;

  AirtableRecordField({
    @required this.fieldName,
    @required this.value,
  });

  Map<String, dynamic> toJSON() {
    return {fieldName: _valueToJSON};
  }

  dynamic get _valueToJSON {
    if (value is DateTime) {
      return (value as DateTime).toIso8601String();
    }

    return value;
  }
}
