import 'dart:isolate';
import 'dart:io';
import 'dart:convert';

void main(List<String> args) async {
  final responder = await Responder.create();
  do {
    stdout.write('Say something (or type exit): ');
    final line = stdin.readLineSync(encoding: utf8);
    switch (line?.trim().toLowerCase()) {
      case null:
        continue;
      case 'exit':
        exit(0);
      default:
        final msg = await responder.getMessage(line!);
        print(msg);
    }
  } while (true);
}

//da rt wil not allow you to create an instance of a class with an async constructor
class Responder {
  final ReceivePort rp;
  final Stream<dynamic> broadcastRp;
  final SendPort communicatorSendPort;

  Responder(
      {required this.rp,
      required this.broadcastRp,
      required this.communicatorSendPort});

  //properties
  static Future<Responder> create() async {
    final rp = ReceivePort();
    Isolate.spawn(_communicator, rp.sendPort);
    final broadCastRp = rp.asBroadcastStream();
    final SendPort communicatorSendPort = await broadCastRp.first;
    return Responder(
        rp: rp,
        broadcastRp: broadCastRp,
        communicatorSendPort: communicatorSendPort);
  }

  Future<String> getMessage(String forGreeting) async {
    communicatorSendPort.send(forGreeting);
    return broadcastRp
        .takeWhile((element) => element is String)
        .cast<String>()
        .take(1)
        .first;
  }
}

void _communicator(SendPort sp) async {
  // in your Isolate function we can create an Instance of receivePort and send your receivePort to the originator , being the function that creates an instance then we can use the receive port to receive messages from the originator

  final rp = ReceivePort();
  sp.send(rp.sendPort);

  final messages = rp.takeWhile((element) => element is String).cast<String>();

  await for (final message in messages) {
    for (final entry in messagesAndResponses.entries) {
      if (entry.key.trim().toLowerCase() == message.trim().toLowerCase()) {
        sp.send(entry.value);
        continue;
      }
    }
    // sp.send('I have no response to that!');
  }
}

const messagesAndResponses = {
  '': 'Ask me a question like "How are you?"',
  'Hello': 'Hi',
  'How are you?': 'Fine',
  'What are you doing?': 'Learning about Isolates in Dart!',
  'Are you having fun?': 'Yeah sure!',
};

// we created an isolate and kept it alive and eveery time we get a message from the user we them send the message to the isolate this reduces the cost of running the application dramatically , becuase we are not createing a new isolate everytiime the user sends a new message to us or enters a new message tp the application 