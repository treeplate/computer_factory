/// Mines gold to craft iron.
library miner;

import 'dart:isolate';

import 'package:computer_factory/client_lib.dart';

void run(SendPort port) async {
  PersonManager manager = PersonManager(port, 'miner');
  await manager.init();
  while (true) {
    await manager.mine();
    await manager.craft(Item.coin);
    log('miner', 'I now have ${await manager.inv[Item.coin]} coins');
  }
}
