import 'dart:async';
import 'file_stub.dart' if (dart.library.io) 'dart:io';

class SendPort {
  final ReceivePort partner;

  void send(Object? object) {
    for (void Function(dynamic) listener in partner.listeners) {
      listener(object);
    }
    partner.sent.add(object);
  }

  SendPort(this.partner);
}

class ReceivePort {
  final List<void Function(dynamic)> listeners = [];
  final List<Object?> sent = [];
  late final SendPort sendPort = SendPort(this);
  void listen(void Function(dynamic) listener) {
    listeners.add(listener);
    for (Object? object in sent) {
      listener(object);
    }
  }
}

List<String> logs = [];
void log(String name, String msg) {
  if (logs.contains(name)) {
    File("$name.log").writeAsStringSync("$msg\n", mode: FileMode.append);
  } else {
    logs.add(name);
    File("$name.log").writeAsStringSync("$msg\n", mode: FileMode.write);
  }
}

/// Class for making between-isolate communication easier.
class SRPWrapper {
  /// Internal constructor.
  SRPWrapper.raw(this.sp, this.name, [ReceivePort? _rp]) {
    if (_rp != null) rp = _rp;
  }

  /// For creator of isolate. Make a recieve port, give the isolate the send port, and give this constructor the recieve port. This class is expecting a send port to be sent to the receive port.
  factory SRPWrapper(ReceivePort rp, String name) {
    return SRPWrapper.raw(null, name, rp);
  }

  /// For created isolate. Pass this constructor the send port you were given at the start. This class will send the creator a send port.
  factory SRPWrapper.fromSendPort(SendPort sp, String name) {
    ReceivePort rp = ReceivePort();
    SRPWrapper result = SRPWrapper.raw(sp, name, rp);
    result.send(rp.sendPort);
    return result;
  }

  SendPort? sp;
  final String name;
  Completer<void> moreItems = Completer();
  List<(String, Object?)> items = [];
  List<Object?> sent = [];
  set rp(ReceivePort x) {
    x.listen((x) {
      if (x.$2 is SendPort && sp == null) {
        sp = x.$2;
        for (Object? thingToSend in sent) {
          x.$2.send(MapEntry(name, thingToSend));
        }
        return;
      }
      log("SRPW-$name", "${x.$1} sent ${x.$2}");
      items.add(x);
      moreItems.complete();
      moreItems = Completer();
    });
  }

  /// Sends [thingToSend] to the connected isolate, if there is one.
  void send(Object? thingToSend) {
    log("SRPW-$name", "Sending $thingToSend");
    sent.add(thingToSend);
    if (sp != null) {
      sp!.send((name, thingToSend));
    }
  }

  // Waits for an item to be recieved, makes sure it's of type T, and returns it.
  Future<T> readItem<T>() async {
    if (items.isEmpty) await moreItems.future;
    assert(items.isNotEmpty, "moreItems should make more items");
    (String, Object?) result = items.first;
    items.removeAt(0);
    if (result.$2 is T) {
      return result.$2 as T;
    } else {
      throw FormatException(
          "SRPW-$name: Expected a $T, got $result (which is a ${result.runtimeType})");
    }
  }
}
