import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

const flagLineNumber = 'line-number';

void main(List<String> arguments) {
  exitCode = 0; // 假设成功
  final parser = ArgParser()..addFlag(flagLineNumber, negatable: false, abbr: 'n');

  ArgResults argResults = parser.parse(arguments);
  final paths = argResults.rest;

  dcat(paths, showLineNumbers: argResults[flagLineNumber] as bool);
}

Future<void> dcat(List<String> paths, {bool showLineNumbers = false}) async {
  if (paths.isEmpty) {
    // 没有提供文件作为参数。从stdin读取并打印每一行。
    await stdin.pipe(stdout);
  } else {
    for (final path in paths) {
      var lineNumber = 1;
      final lines = utf8.decoder.bind(File(path).openRead()).transform(const LineSplitter());
      try {
        await for (final line in lines) {
          if (showLineNumbers) {
            stdout.write('${lineNumber++} ');
          }
          stdout.writeln(line);
        }
      } catch (_) {
        await _handleError(path);
      }
    }
  }
}

Future<void> _handleError(String path) async {
  if (await FileSystemEntity.isDirectory(path)) {
    stderr.writeln('错误：$path 是一个目录');
  } else {
    exitCode = 2;
  }
}
