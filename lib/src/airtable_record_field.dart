part of dart_airtable;

class AirtableRecordField<T> {
  String fieldName;
  T value;

  AirtableRecordField({
    @required this.fieldName,
    @required this.value,
  }) : assert(value.runtimeType != T);

  Map<String, String> toJSON() => {fieldName: _valueToJSON};

  MapEntry<String, dynamic> toMapEntry() => MapEntry(fieldName, _valueToJSON);

  factory AirtableRecordField.fromMapEntry(
          MapEntry<dynamic, dynamic> mapEntry) =>
      AirtableRecordField(
        fieldName: mapEntry.key,
        value: mapEntry.value,
      );

  String get _valueToJSON {
    if (value.runtimeType == DateTime) {
      return (value as DateTime)?.toIso8601String();
    }

    return value?.toString();
  }
}

void hi() {
  AirtableRecordField<dynamic>.fromMapEntry(MapEntry('hi', 'hi'));
}
