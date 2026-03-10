import 'dart:io';
import 'dart:math';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  final random = Random();
  final colors = [
    'Colors.amber[100]',
    'Colors.blue[100]',
    'Colors.pink[100]',
    'Colors.purple[100]',
    'Colors.green[100]',
    'Colors.teal[100]',
    'Colors.orange[100]',
    'Colors.yellow[100]',
    'Colors.cyan[100]',
  ];

  for (final file in files) {
    String content = file.readAsStringSync();
    
    // Check if it already has a background color to avoid duplicates
    if (content.contains('Scaffold(') && !content.contains('Scaffold(backgroundColor:')) {
      final randomColor = colors[random.nextInt(colors.length)];
      content = content.replaceAll('Scaffold(', 'Scaffold(backgroundColor: $randomColor,');
      file.writeAsStringSync(content);
      print('Updated ${file.path} with $randomColor');
    }
  }
}
