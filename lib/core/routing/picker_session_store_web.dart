import 'dart:convert';
import 'dart:html';

const String _storageKey = 'locora_completed_picker_tokens';

Map<String, String> readCompletedPickerTokensImpl() {
  final rawValue = window.sessionStorage[_storageKey];
  if (rawValue == null || rawValue.isEmpty) {
    return <String, String>{};
  }

  try {
    final decoded = jsonDecode(rawValue) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value?.toString() ?? ''));
  } catch (_) {
    return <String, String>{};
  }
}

void writeCompletedPickerTokensImpl(Map<String, String> tokens) {
  final payload = jsonEncode(tokens);
  window.sessionStorage[_storageKey] = payload;
}
