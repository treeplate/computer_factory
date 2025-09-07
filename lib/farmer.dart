/// Farms cows.
library;

import 'dart:isolate';

import 'package:computer_factory/client_lib.dart';

void run(SendPort port) async {
  PersonManager manager = PersonManager(port, 'farmer');
  await manager.init();
  while (true) {
    await manager.farm(Item.cow);
    await manager.farm(Item.cow);
    await manager.farm(Item.cow);
    await manager.trade(1, Item.cow, 3);
    await manager.farm(Item.sheep);
    await manager.trade(1, Item.sheep, 1);
    log('farmer', 'gave three cows + one sheep to #1');
  }
}
