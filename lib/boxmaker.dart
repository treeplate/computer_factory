/// Makes boxes.
library;

import 'srp.dart';

import 'package:computer_factory/client_lib.dart';

void run(SendPort port) async {
  PersonManager manager = PersonManager(port, 'boxmaker');
  await manager.init();
  int coins = 0;
  int realcoins = 0;
  int cows = 0;
  int sheep = 0;
  int planks = 0;
  while (true) {
    while (planks < 12) {
      planks = await manager.inv[Item.planks];
      while (cows < 3) {
        cows = await manager.inv[Item.cow];
        if (cows < 3) {
          log('boxmaker', 'waiting for cows');
        }
      }
      await manager.trade(2, Item.cow, 3);
      cows -= 3;
      log('boxmaker', 'traded 3 cows');
      while (sheep < 1) {
        sheep = await manager.inv[Item.sheep];
        if (sheep < 1) {
          log('boxmaker', 'waiting for sheep');
        }
      }
      await manager.trade(2, Item.sheep, 1);
      sheep--;
      log('boxmaker', 'traded sheep');
    }
    log('boxmaker', 'got planks');
    await manager.craft(Item.box);
    planks -= 12;
    log('boxmaker', 'made box');
    while (realcoins < coins + 3) {
      realcoins = await manager.inv[Item.coin];
      if (realcoins < coins + 3) {
        log('boxmaker', 'waiting for coins');
      }
    }
    coins += 3;
    await manager.trade(3, Item.box, 1);
    log('boxmaker', 'sold box');
  }
}
