/// Mines gold to craft iron.
library;

import 'dart:isolate';

import 'package:computer_factory/client_lib.dart';

void run(SendPort port) async {
  PersonManager manager = PersonManager(port, 'miner');
  await manager.init();
  while (true) {
    log('miner', 'mining three gold');
    await manager.mine();
    await manager.mine();
    await manager.mine();
    log('miner', 'crafting three coins');
    await manager.craft(Item.coin);
    await manager.craft(Item.coin);
    await manager.craft(Item.coin);
    log('miner', 'buying box');
    await manager.trade(1, Item.coin, 3);
    log('miner', 'boxes received: ${await manager.inv[Item.box]}');
  }
}
