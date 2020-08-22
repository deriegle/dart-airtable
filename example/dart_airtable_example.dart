import 'dart:io';

import 'package:dart_airtable/dart_airtable.dart';
import 'package:dotenv/dotenv.dart' as dotenv;

void main() async {
  dotenv.load();

  final apiKey = dotenv.env['AIRTABLE_API_KEY'];
  final projectBase = dotenv.env['AIRTABLE_PROJECT_BASE'];
  final recordName = dotenv.env['AIRTABLE_RECORD_NAME'];

  final Map<String, dynamic> envvars = {
    'apiKey': dotenv.env['AIRTABLE_API_KEY'],
    'projectBase': dotenv.env['AIRTABLE_PROJECT_BASE'],
    'recordName': dotenv.env['AIRTABLE_RECORD_NAME'],
  }..removeWhere((k, v) => v != null);

  if (envvars.isNotEmpty) {
    throw StdinException(
      'You must specify the envvars ${envvars.keys.join(', ')}',
    );
  }

  final airtable = Airtable(apiKey: apiKey, projectBase: projectBase);
  final records = await airtable.getAllRecords(recordName);

  print(records);
}
