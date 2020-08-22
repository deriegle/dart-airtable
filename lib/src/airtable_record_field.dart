part of dart_airtable;

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
