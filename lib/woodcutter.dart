/// Chop trees to craft planks.
library;

import 'srp.dart';

import 'package:computer_factory/client_lib.dart';

void run(SendPort port) async {
  PersonManager manager = PersonManager(port, 'woodcutter');
  await manager.init();
  int logs = 0;
  int planks = 0;
  int cows = 0;
  int realcows = 0;
  int sheep = 0;
  int realsheep = 0;
  while (true) {
    if (planks == 0) {
      if (logs == 0) {
        log('woodcutter', 'chopping wood');
        await manager.chop();
        logs++;
      }
      log('woodcutter', 'crafting planks');
      await manager.craft(Item.planks);
      planks += 4;
      logs--;
    }
    while (realcows < cows + 3) {
      realcows = await manager.inv[Item.cow];
      if (realcows < cows + 3) {
        if (logs == 0) {
          log('woodcutter', 'waiting for cows, chopping wood to pass time');
          await manager.chop();
          logs++;
        } else {
          log('woodcutter', 'waiting for cows, crafting planks to pass time');
          await manager.craft(Item.planks);
          planks += 4;
          logs--;
        }
      }
    }
    cows += 3;
    while (realsheep < sheep + 1) {
      realsheep = await manager.inv[Item.sheep];
      if (realsheep < sheep + 1) {
        log('woodcutter', 'waiting for sheep');
      }
    }
    sheep += 1;
    log('woodcutter', 'got cows+sheep, giving plank to #1');
    await manager.trade(1, Item.planks, 1);
    planks--;
  }
}
