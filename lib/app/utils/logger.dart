import 'package:flutter/foundation.dart';

class Logger {
  final String name;

  Logger([this.name = 'Logger']);

  // ANSI color codes
  static const _reset = '\x1B[0m';
  static const _red = '\x1B[31m';
  static const _yellow = '\x1B[33m';
  static const _green = '\x1B[32m';
  static const _cyan = '\x1B[36m';

  // Core static log
  static void _log(
    String level,
    Object? message,
    String color, [
    String name = 'Logger',
  ]) {
    if (kDebugMode) {
      print('$color[$name] [$level] $message$_reset');
    }
  }

  // Instance methods call static log with this.name
  void d(Object? message) => _log('DEBUG', message, _cyan, name);
  void i(Object? message) => _log('INFO', message, _green, name);
  void w(Object? message) => _log('WARN', message, _yellow, name);
  void e(Object? message, [Object? error, StackTrace? stackTrace]) {
    final buffer = StringBuffer(message.toString());
    if (error != null) buffer.writeln('\nError: $error');
    if (stackTrace != null) buffer.writeln(stackTrace);
    _log('ERROR', buffer.toString(), _red, name);
  }

  // Static methods allow optional name
  static void dS(Object? message, [String name = 'Logger']) =>
      _log('DEBUG', message, _cyan, name);
  static void iS(Object? message, [String name = 'Logger']) =>
      _log('INFO', message, _green, name);
  static void wS(Object? message, [String name = 'Logger']) =>
      _log('WARN', message, _yellow, name);
  static void eS(
    Object? message, [
    Object? error,
    StackTrace? stackTrace,
    String name = 'Logger',
  ]) {
    final buffer = StringBuffer(message.toString());
    if (error != null) buffer.writeln('\nError: $error');
    if (stackTrace != null) buffer.writeln(stackTrace);
    _log('ERROR', buffer.toString(), _red, name);
  }
}
