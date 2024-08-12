import 'package:dart_airtable/dart_airtable.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();

  String apiKey = dotenv.env['AIRTABLE_API_KEY']!;
  String projectBase = dotenv.env['AIRTABLE_PROJECT_BASE']!;
  String recordName = dotenv.env['AIRTABLE_RECORD_NAME']!;

  final airtable = Airtable(apiKey: apiKey, projectBase: projectBase);
  final records = await airtable.getAllRecords(recordName);

  print(records);
}
