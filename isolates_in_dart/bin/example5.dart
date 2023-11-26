// how to spawn ian isolate form inside a library

import 'dart:isolate';

void main(List<String> args) async {
  final uri = Uri.parse('package:isolates_in_dart/isolates_in_dart.dart');
  final rp = ReceivePort();

  Isolate.spawnUri(uri, [], rp.sendPort);

  final firstMessage = await rp.first;

  print(firstMessage);
}
