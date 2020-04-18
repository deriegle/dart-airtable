// TODO: Put public facing types in this file.

const _defaultAirtableApiUrl = 'https://api.airtable.com';

/// Checks if you are awesome. Spoiler: you are.
class Airtable {
  final String _apiKey;
  final String _projectBase;
  final String apiUrl;

  Airtable(this._apiKey, this._projectBase, { this.apiUrl = _defaultAirtableApiUrl })
      : assert(_apiKey != null && _projectBase != null && apiUrl != null);
}
