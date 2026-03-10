import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    bool changed = false;
    
    // Replace "Swiggy" with "Foodora" securely, maintaining cases if possible
    if (content.contains('Swiggy')) {
      content = content.replaceAll('Swiggy', 'Foodora');
      changed = true;
    }
    if (content.contains('swiggy')) {
      content = content.replaceAll('swiggy', 'foodora');
      changed = true;
    }
    if (content.contains('SWIGGY')) {
      content = content.replaceAll('SWIGGY', 'FOODORA');
      changed = true;
    }

    // specific footer
    if (content.contains('MADE BY FOOD LOVERS')) {
      content = content.replaceAll('MADE BY FOOD LOVERS', 'MADE BY ASWATH');
      changed = true;
    }
    if (content.contains('BANGALORE')) {
      content = content.replaceAll('BANGALORE', '');
      changed = true;
    }

    if (changed) {
      file.writeAsStringSync(content);
      print('Updated ${file.path}');
    }
  }
}
