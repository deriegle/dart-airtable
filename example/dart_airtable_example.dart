import 'package:dart_airtable/dart_airtable.dart';
import 'package:dotenv/dotenv.dart' as dotenv;

void main() async {
  dotenv.load();

  final apiKey = dotenv.env['AIRTABLE_API_KEY'];
  final projectBase = dotenv.env['AIRTABLE_PROJECT_BASE'];
  final recordName = dotenv.env['AIRTABLE_RECORD_NAME'];

  assert(apiKey != null);
  assert(projectBase != null);
  assert(recordName != null);

  var airtable = Airtable(apiKey: apiKey, projectBase: projectBase);
  var records = await airtable.getAllRecords(recordName);

  print(records);
}
