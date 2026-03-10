import 'dart:io';

void renameRecursive(Directory dir) {
  final entities = dir.listSync();
  for (final entity in entities) {
    if (entity is Directory) {
      renameRecursive(entity);
    }
    
    // Rename entity if it contains swiggy
    final name = entity.uri.pathSegments.lastWhere((s) => s.isNotEmpty);
    if (name.contains('swiggy')) {
      final newName = name.replaceAll('swiggy', 'foodora');
      final newUri = entity.parent.uri.resolve(newName);
      try {
        entity.renameSync(newUri.toFilePath());
        print('Renamed $name to $newName');
      } catch (e) {
        print('Failed to rename $name: $e');
      }
    }
  }
}

void main() {
  final dir = Directory('lib');
  renameRecursive(dir);
}
