import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Generic JSON file CRUD service. Acts as the local "fake API" layer.
/// All repositories use this as the underlying storage mechanism.
class JsonStorageService {
  Future<String> get _localPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> _file(String fileName) async {
    final path = await _localPath;
    return File('$path/$fileName');
  }

  /// Returns all records from [fileName]. Returns [] if file missing/empty.
  Future<List<Map<String, dynamic>>> readAll(String fileName) async {
    try {
      final file = await _file(fileName);
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      if (content.trim().isEmpty) return [];
      final decoded = jsonDecode(content);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Overwrites [fileName] with [data].
  Future<void> writeAll(String fileName, List<Map<String, dynamic>> data) async {
    final file = await _file(fileName);
    await file.writeAsString(jsonEncode(data));
  }

  /// Appends a single [record] to [fileName].
  Future<void> add(String fileName, Map<String, dynamic> record) async {
    final records = await readAll(fileName);
    records.add(record);
    await writeAll(fileName, records);
  }

  /// Updates the record with matching [id] in [fileName].
  Future<void> update(
    String fileName,
    String id,
    Map<String, dynamic> updates,
  ) async {
    final records = await readAll(fileName);
    final idx = records.indexWhere((r) => r['id'] == id);
    if (idx != -1) {
      records[idx] = {...records[idx], ...updates};
      await writeAll(fileName, records);
    }
  }

  /// Deletes the record with matching [id] from [fileName].
  Future<void> delete(String fileName, String id) async {
    final records = await readAll(fileName);
    records.removeWhere((r) => r['id'] == id);
    await writeAll(fileName, records);
  }

  /// Returns true if [fileName] already exists on disk.
  Future<bool> fileExists(String fileName) async {
    final file = await _file(fileName);
    return file.exists();
  }
}
