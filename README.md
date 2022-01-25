# Dart Airtable

A library for using the Airtable API in Dart & Flutter applications

## Usage

A simple usage example:

```dart
import 'package:dart_airtable/dart_airtable.dart';

void main() async {
  final apiKey = 'my-airtable-api-key'
  final projectBase = 'my-airtable-project-base';
  final recordName = 'Tasks';

  var airtable = Airtable(apiKey: apiKey, projectBase: projectBase);
  // default pageSize is 100
  var response = await airtable.getAllRecords(recordName); 
  var records = response.records;
  var offset = response.offset; // next page offset

  print(records);
}
```

## Running the example

1. Create a `.env` file

```bash
cp .env.example .env
```

2. Fill in your API Key, Project base key and Record Name in the `.env` file

3. Run the dart file

```bash
dart example/dart_airtable_example.dart
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/deriegle/dart-airtable/issues
