import 'dart:convert';

import 'sandboxed_filesystem_service.dart';

class MayaOmegaDocumentService {
  MayaOmegaDocumentService({SandboxedFilesystemService? filesystem})
      : filesystem = filesystem ?? SandboxedFilesystemService();

  final SandboxedFilesystemService filesystem;

  Future<Map<String, dynamic>> ingest(String relativePath) async {
    final extension = relativePath.split('.').last.toLowerCase();
    if (extension == 'pdf') {
      return {
        'success': false,
        'state': 'companion',
        'error': 'PDF extraction requires the PC/PDF adapter in this release.',
      };
    }
    if (!const {
      'txt', 'md', 'json', 'csv', 'yaml', 'yml', 'dart', 'kt', 'py',
    }.contains(extension)) {
      return {
        'success': false,
        'error': 'Unsupported document type: .$extension',
      };
    }
    final result = await filesystem.read(relativePath);
    if (result['success'] != true) return result;
    final contents = result['contents']?.toString() ?? '';
    final excerpt =
        contents.length > 6000 ? contents.substring(0, 6000) : contents;
    return {
      'success': true,
      'path': relativePath,
      'format': extension,
      'bytes': contents.codeUnits.length,
      'lineCount': '\n'.allMatches(contents).length + 1,
      'excerpt': excerpt,
      'structured': _structured(contents, extension),
      'provenance': {'source': 'maya_private_workspace', 'path': relativePath},
    };
  }

  static dynamic _structured(String contents, String extension) {
    if (extension == 'json') {
      try {
        return jsonDecode(contents);
      } catch (_) {
        return {'parseError': 'Invalid JSON'};
      }
    }
    if (extension == 'csv') {
      return contents
          .split(RegExp(r'\r?\n'))
          .where((line) => line.trim().isNotEmpty)
          .take(200)
          .map((line) => line.split(',').map((cell) => cell.trim()).toList())
          .toList();
    }
    return null;
  }
}
