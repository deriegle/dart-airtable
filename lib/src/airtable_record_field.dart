part of dart_airtable;

class AirtableRecordField<T extends Object> {
  String fieldName;
  T value;

  AirtableRecordField({
    required this.fieldName,
    required this.value,
  });

  Map<String, String> toJSON() => {fieldName: _valueToJSON};

  MapEntry<String, dynamic> toMapEntry() => MapEntry(fieldName, _valueToJSON);

  factory AirtableRecordField.fromMapEntry(
          MapEntry<dynamic, dynamic> mapEntry) =>
      AirtableRecordField(
        fieldName: mapEntry.key,
        value: mapEntry.value,
      );

  dynamic get _valueToJSON {
    if (value.runtimeType == DateTime) {
      return (value as DateTime).toIso8601String();
    }
    if (value is int) {
      return value;
    }
    return value.toString();
  }
}
