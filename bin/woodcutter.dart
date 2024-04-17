/// Chop trees to craft planks.
library woodcutter;

import 'dart:isolate';

import 'package:computer_factory/client_lib.dart';

void run(SendPort port) async {
  PersonManager manager = PersonManager(port, 'woodcutter');
  await manager.init();
  while (true) {
    await manager.chop();
    await manager.craft(Item.planks);
    log('woodcutter', 'I now have ${await manager.inv[Item.planks]} planks');
  }
}
