// The below comment (minus the frame) is something that makes
// no sense to me, being that when it was published on github
// it was inconsistent with both the README and what the code
// does. It is preserved here because why not.
// |========================================================|
// | 1: farms cows and sheep under 2's command              |
// | 2: decides whether to farm cows or sheep               |
// | 3: tells 2 what they need given current inventory of 4 |
// | 4: trades 3 cows 1 sheep for 1 plank                   |
// | 5: makes boxes from 12 planks, and sells for 3 coins   |
// | us: trades 1 plank for 3 cows 1 sheep                  |
// | also us: trades 3 coins for a box                      |
// =========================================================|

import 'srp.dart';

class Person {
  int sheep = 0;
  int cows = 0;
  int logs = 0;
  int planks = 0;
  int goldOre = 0;
  int coins = 0;
  int boxes = 0;
  final String name;

  @override
  String toString() => name;
  Person(this.name);
}

class Manager {
  final List<(Person, SRPWrapper, int)> people;

  Manager._(this.people);
  static Future<Manager> create(List<SRPWrapper> managees) async {
    List<String> names = [];
    int i = 0;
    for (SRPWrapper port in managees) {
      names.add(await port.readItem<String>());
      print(i);
      i++;
    }
    i = 0;
    List<(Person, SRPWrapper, int)> people = [];
    for (SRPWrapper port in managees) {
      Person person = Person(names[i]);
      people.add((person, port, i));
      i++;
    }
    return Manager._(people);
  }

  Future<void> tick() async {
    for ((Person, SRPWrapper, int) record in people) {
      int i = record.$3;
      SRPWrapper port = record.$2;
      Person person = record.$1;
      Object message = await port.readItem();
      log('manager', '$person (#$i) is doing $message');
      if (message is! Record && message is! String) {
        port.send(('invalid', 'type', 'must be record or string'));
        return;
      }
      outer:
      switch (message) {
        case (String action):
          switch (action) {
            case 'index':
              port.send(i);
            case 'chop':
              person.logs++;
              port.send('success');
            case 'mine':
              person.goldOre++;
              port.send('success');

            default:
              port.send(('invalid', 'action'));
          }
        case (String action, String item):
          mid:
          switch (action) {
            case 'farm':
              switch (item) {
                case 'cow':
                  person.cows++;
                case 'sheep':
                  person.sheep++;
                default:
                  port.send(('invalid', 'item'));
                  break mid;
              }
              port.send('success');
            case 'craft':
              switch (item) {
                case 'coin':
                  if (person.goldOre < 1) {
                    port.send(('invalid', 'craft-attempt'));
                    break mid;
                  }
                  person.goldOre--;
                  person.coins++;
                case 'planks':
                  if (person.logs < 1) {
                    port.send(('invalid', 'craft-attempt'));
                    break mid;
                  }
                  person.logs--;
                  person.planks += 4;
                case 'box':
                  if (person.planks < 12) {
                    port.send(('invalid', 'craft-attempt'));
                    break mid;
                  }
                  person.planks -= 12;
                  person.boxes++;
                default:
                  port.send(('invalid', 'item'));
                  break mid;
              }
              port.send('success');
            case 'getInv':
              switch (item) {
                case 'cow':
                  port.send(person.cows);
                case 'sheep':
                  port.send(person.sheep);
                case 'coin':
                  port.send(person.coins);
                case 'planks':
                  port.send(person.planks);
                case 'log':
                  port.send(person.logs);
                case 'goldOre':
                  port.send(person.goldOre);
                case 'box':
                  port.send(person.boxes);
                default:
                  port.send(('invalid', 'item'));
              }
            default:
              port.send(('invalid', 'action'));
          }
        case (String action, int index, String item, int amount):
          if (action != 'trade') {
            port.send(('invalid', 'action'));
            break;
          }
          if (index >= people.length) {
            port.send(('invalid', 'index'));
            break;
          }

          if (amount < 0) {
            port.send(('invalid', 'amount'));
            break;
          }
          Person target = people[index].$1;
          switch (item) {
            case 'cow':
              if (person.cows < amount) {
                port.send(('invalid', 'amount'));
                break outer;
              }
              person.cows -= amount;
              target.cows += amount;
            case 'sheep':
              if (person.sheep < amount) {
                port.send(('invalid', 'amount'));
                break outer;
              }
              person.sheep -= amount;
              target.sheep += amount;
            case 'coin':
              if (person.coins < amount) {
                port.send(('invalid', 'amount'));
                break outer;
              }
              person.coins -= amount;
              target.coins += amount;
            case 'planks':
              if (person.planks < amount) {
                port.send(('invalid', 'amount'));
                break outer;
              }
              person.planks -= amount;
              target.planks += amount;
            case 'log':
              if (person.logs < amount) {
                port.send(('invalid', 'amount'));
                break outer;
              }
              person.logs -= amount;
              target.logs += amount;
            case 'goldOre':
              if (person.goldOre < amount) {
                port.send(('invalid', 'amount'));
                break outer;
              }
              person.goldOre -= amount;
              target.goldOre += amount;
            case 'box':
              if (person.boxes < amount) {
                port.send(('invalid', 'amount'));
                break outer;
              }
              person.boxes -= amount;
              target.boxes += amount;
          }
          port.send('success');
        default:
          port.send(('invalid', 'action'));
      }
    }
  }
}
