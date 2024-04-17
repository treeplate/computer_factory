/// Farms cows.
library farmer;

import 'dart:isolate';

import 'package:computer_factory/client_lib.dart';

void run(SendPort port) async {
  PersonManager manager = PersonManager(port, 'farmer');
  await manager.init();
  while (true) {
    await manager.farm(Item.cow);
    log('farmer', 'I now have ${await manager.inv[Item.cow]} cows');
  }
}
