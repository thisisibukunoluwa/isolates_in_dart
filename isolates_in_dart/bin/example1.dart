// isolates
// Think of an isolate like a thread
// the function that spawns the isolte creates a port that you can send and receive messages

import 'dart:isolate';

void main(List<String> args) async {
  await for (final msg in getMessages().take(10)) {
    print(msg);
  }
}

// Helper function that creates the instance of the isolate
Stream<String> getMessages() async* {
  final rp = ReceivePort();
  // the Isolate.spwan() function creates a Future<Isolate> and you have to wait for the Futre to complete
  // return Isolate.spawn(_getMessages, rp.sendPort)
  //     .asStream()
  //     .asyncExpand((event) => rp)
  //     .takeWhile((element) => element is String)
  //     .cast<String>();
  // another way of writing the same function

  // final future = await Isolate.spawn(_getMessages, rp.sendPort);
  // return rp.takeWhile((element) => element is String).cast();

  // another way to do it
  // await Isolate.spawn(_getMessages, rp.sendPort);
  await for (final msg
      in rp.takeWhile((element) => element is String).cast<String>()) {
    yield msg;
  }
  ;
}

// Function that creates the isolate
void _getMessages(SendPort sp) async {
  await for (final now in Stream.periodic(const Duration(milliseconds: 200),
      (_) => DateTime.now().toIso8601String())) {
    sp.send(now);
  }
  ;
}
