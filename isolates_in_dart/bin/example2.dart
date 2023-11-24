import 'dart:isolate';

void main(List<String> args) async {}

Future<String> getMessage(String forGreeting) async {
  final rp = ReceivePort();
  Isolate.spawn(_communicator, rp.sendPort);
  //every receive port can both send and receive messages , while very send port can only sen messages
  // turn our receivePort into a brodcast stream because we are listening to it twice
  final broadcastRp = rp.asBroadcastStream();
  final SendPort communicatorSendPort = await broadcastRp.first;
  communicatorSendPort.send(forGreeting);
  return broadcastRp
      .takeWhile((element) => element is String)
      .cast<String>()
      .take(1)
      .first;
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
    sp.send('I have no response to that!');
  }
}

const messagesAndResponses = {
  '': 'Ask me a question like "How are you?"',
  'Hello': 'Hi',
  'How are you?': 'Fine',
  'What are you doing?': 'Learning about Isolates in Dart!',
  'Are you having fun?': 'Yeah sure!',
};
