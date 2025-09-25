import 'dart:io';

import 'package:flutter/widgets.dart';

import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class LoggerService extends LogOutput {
  static const int _maxLogFiles = 5;

  File? _logFile;
  final DateFormat _timestampFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
  final DateFormat _fileNameFormat = DateFormat('yyyy-MM-dd_HH-mm-ss');
  late final String _logFileName;

  Future<void> initialize() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDirectory = Directory('${directory.path}/logs');

      if (!await logDirectory.exists()) {
        await logDirectory.create(recursive: true);
      }

      // Create unique log file name for this app session
      _logFileName = 'spotsell-${_fileNameFormat.format(DateTime.now())}.log';
      _logFile = File('${logDirectory.path}/$_logFileName');

      if (!await _logFile!.exists()) {
        await _logFile!.create();
      }

      await _cleanupOldLogs();
    } catch (e) {
      print('Failed to initialize logger: $e');
    }
  }

  @override
  void output(OutputEvent event) {
    if (_logFile == null) return;

    try {
      final timestamp = _timestampFormat.format(DateTime.now());
      final level = event.level.name.toUpperCase();

      for (final line in event.lines) {
        final logEntry = '[$timestamp] [$level] $line\n';
        _logFile!.writeAsStringSync(logEntry, mode: FileMode.append);
      }
    } catch (e) {
      print('Failed to write log: $e');
    }
  }

  Future<void> _cleanupOldLogs() async {
    try {
      final directory = _logFile?.parent;
      if (directory == null) return;

      // Get all spotsell log files
      final logFiles = <File>[];
      await for (final entity in directory.list()) {
        if (entity is File &&
            entity.path.contains('spotsell-') &&
            entity.path.endsWith('.log')) {
          logFiles.add(entity);
        }
      }

      // Sort by creation time (newest first)
      logFiles.sort(
        (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
      );

      // Delete old log files if we exceed the maximum
      if (logFiles.length > _maxLogFiles) {
        for (int i = _maxLogFiles; i < logFiles.length; i++) {
          await logFiles[i].delete();
        }
        print('Cleaned up ${logFiles.length - _maxLogFiles} old log files');
      }
    } catch (e) {
      print('Failed to cleanup old logs: $e');
    }
  }

  Future<String?> getLogFilePath() async {
    return _logFile?.path;
  }

  Future<List<String>> getRecentLogs({int lines = 100}) async {
    if (_logFile == null || !await _logFile!.exists()) {
      return [];
    }

    try {
      final content = await _logFile!.readAsString();
      final logLines = content.split('\n');

      return logLines
          .where((line) => line.isNotEmpty)
          .toList()
          .reversed
          .take(lines)
          .toList();
    } catch (e) {
      print('Failed to read logs: $e');
      return [];
    }
  }

  Future<void> clearLogs() async {
    try {
      final directory = _logFile?.parent;
      if (directory != null) {
        await for (final entity in directory.list()) {
          if (entity is File &&
              entity.path.contains('spotsell-') &&
              entity.path.endsWith('.log')) {
            await entity.delete();
          }
        }
        print('All spotsell log files cleared');
      }
    } catch (e) {
      print('Failed to clear logs: $e');
    }
  }
}
