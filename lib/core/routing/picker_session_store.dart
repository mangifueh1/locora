import 'picker_session_store_io.dart'
    if (dart.library.html) 'picker_session_store_web.dart';

Map<String, String> readCompletedPickerTokens() =>
    readCompletedPickerTokensImpl();

void writeCompletedPickerTokens(Map<String, String> tokens) =>
    writeCompletedPickerTokensImpl(tokens);
