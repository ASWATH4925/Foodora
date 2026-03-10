import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    if (!file.existsSync()) continue;
    final content = file.readAsStringSync();
    if (content.contains('package:foodora_ui')) {
      final updatedContent = content.replaceAll('package:foodora_ui', 'package:swiggy_ui');
      file.writeAsStringSync(updatedContent);
      print('Updated: ${file.path}');
    }
  }
}
