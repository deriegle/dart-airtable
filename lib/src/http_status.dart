part of dart_airtable;

class HttpStatus {
  final int code;

  const HttpStatus._(this.code);

  static const ok = HttpStatus._(200);
  static const unprocessableEntity = HttpStatus._(422);
  static const notFound = HttpStatus._(404);

  static const values = [ok, unprocessableEntity, notFound];

  @override
  String toString() {
    return 'HttpStatus.$code';
  }
}
