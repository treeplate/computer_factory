import 'dart:isolate';

import 'srp.dart';
export 'srp.dart' show log;

enum Item {
  cow,
  sheep,
  coin,
  planks,
  log,
  goldOre,
  box,
}

class Inventory {
  final SRPWrapper _port;

  Inventory(this._port);

  Future<int> operator [](Item item) async {
    _port.send(('getInv', item.name));
    return await _port.readItem<int>();
  }
}

class PersonManager {
  late final SRPWrapper _port;
  late final int index;
  late final Inventory inv = Inventory(_port);
  PersonManager(SendPort sp, String name) {
    SRPWrapper port = SRPWrapper.fromSendPort(sp, name);
    port.send(name);
    port.send('index');
    print('$name sent');
    _port = port;
  }

  Future<void> init() async {
    index = await _port.readItem<int>();
  }

  Future<void> _confirmSuccess(String context) async {
    Object result = await _port.readItem();
    if (result != 'success') {
      if (result is! Record || (result as dynamic).$1 != 'invalid') {
        throw FormatException("Unrecognized server message $result $context");
      }
      throw FormatException(
          "Server sent error for ${_port.name} (#$index): $result $context");
    }
  }

  Future<void> farm(Item item) async {
    _port.send(('farm', item.name));
    await _confirmSuccess('while farming ${item.name}');
  }

  Future<void> chop() async {
    _port.send('chop');
    await _confirmSuccess('while chopping');
  }

  Future<void> mine() async {
    _port.send('mine');
    await _confirmSuccess('while mining');
  }

  Future<void> craft(Item item) async {
    _port.send(('craft', item.name));
    await _confirmSuccess('while crafting ${item.name}');
  }

  Future<void> trade(int target, Item item, int amount) async {
    _port.send(('trade', target, item.name, amount));
    await _confirmSuccess('while trading $amount ${item.name}s to $target');
  }
}
