import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  final replacements = {
    'headline1': 'displayLarge',
    'headline2': 'displayMedium',
    'headline3': 'displaySmall',
    'headline4': 'headlineLarge',
    'headline5': 'headlineMedium',
    'headline6': 'headlineSmall',
    'subtitle1': 'titleMedium',
    'subtitle2': 'titleSmall',
    'bodyText1': 'bodyLarge',
    'bodyText2': 'bodyMedium',
    'textTheme.caption': 'textTheme.bodySmall',
    'textTheme.button': 'textTheme.labelLarge',
    '  button:': '  labelLarge:',
    '  caption:': '  bodySmall:',
    'onPrimary:': 'foregroundColor:',
    'primary:': 'backgroundColor:',
  };

  for (final file in files) {
    String content = file.readAsStringSync();
    bool changed = false;
    for (final entry in replacements.entries) {
      if (content.contains(entry.key)) {
        content = content.replaceAll(entry.key, entry.value);
        changed = true;
      }
    }
    if (changed) {
      file.writeAsStringSync(content);
      print('Updated ${file.path}');
    }
  }
}
