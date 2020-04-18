import 'package:meta/meta.dart';

class AirtableRecord {
  String id;
  DateTime createdTime = DateTime.now();
  List<AirtableRecordField> fields = [];

  AirtableRecord({
    this.fields,
    this.id,
    this.createdTime,
  });

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
    return 'AirtableRecord(id: $id, createdTime: ${createdTime.toString()}, fields: ${_jsonFields.toString()})';
  }

  Map<String, dynamic> get _jsonFields {
    Map<String, dynamic> json = {};

    json.addEntries(fields.map<MapEntry<String, dynamic>>((f) => f.toMapEntry()));

    return json;
  }
}

class AirtableRecordField<T> {
  String fieldName;
  T value;

  AirtableRecordField({
    @required this.fieldName,
    @required this.value,
  });

  Map<String, String> toJSON() {
    return {fieldName: _valueToJSON};
  }

  MapEntry<String, dynamic> toMapEntry() {
    return MapEntry(fieldName, _valueToJSON);
  }


  String get _valueToJSON {
    if (value == null) {
      return null;
    }

    if (T == DateTime) {
      return (value as DateTime).toIso8601String();
    }

    return T == int || T == double ? value : value.toString();
  }
}
