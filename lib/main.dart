import 'package:computer_factory/client_lib.dart';

import 'manager.dart';
import 'package:flutter/material.dart';
import 'srp.dart';
import 'farmer.dart' as farmer;
import 'boxmaker.dart' as boxmaker;
import 'woodcutter.dart' as woodcutter;
import 'miner.dart' as miner;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final Manager manager;
  bool managerExists = false;
  final ReceivePort connectionRP = ReceivePort();
  late final PersonManager connection =
      PersonManager(connectionRP.sendPort, 'user');

  @override
  void initState() {
    createManager();
    super.initState();
  }

  Future<void> createManager() async {
    connection.init();
    manager = await Manager.create([
      (farmer.run, 'farmer'),
      (boxmaker.run, 'boxmaker'),
      (woodcutter.run, 'woodcutter'),
      (miner.run, 'miner'),
    ].map((e) {
      ReceivePort rp = ReceivePort();
      e.$1(rp.sendPort);
      return SRPWrapper(rp, 'manager(${e.$2})');
    }).followedBy([SRPWrapper(connectionRP, 'manager(user)')]).toList());
    setState(() {
      managerExists = true;
    });
    manager.tick();
  }

  @override
  Widget build(BuildContext context) {
    return managerExists
        ? Scaffold(
            body: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ...manager.people.map((e) {
                      return Column(
                        children: [
                          Text(e.$1.name, style: TextStyle(fontSize: 30),),
                          Text('sheep: ${e.$1.sheep}'),
                          Text('cows: ${e.$1.cows}'),
                          Text('logs: ${e.$1.logs}'),
                          Text('planks: ${e.$1.planks}'),
                          Text('goldOre: ${e.$1.goldOre}'),
                          Text('coins: ${e.$1.coins}'),
                          Text('boxes: ${e.$1.boxes}'),
                        ],
                      );
                    }),
                  ],
                ),
                CommandWidget(
                  child: Text('Farm cow (${manager.people[4].$1.cows} cows)'),
                  onPressed: () => connection.farm(Item.cow),
                  setState: setState,
                  manager: manager,
                ),
                CommandWidget(
                  child: Text('Farm sheep (${manager.people[4].$1.sheep} sheep)'),
                  onPressed: () => connection.farm(Item.sheep),
                  setState: setState,
                  manager: manager,
                ),
                CommandWidget(
                  child: Text('Chop wood (${manager.people[4].$1.logs} logs)'),
                  onPressed: connection.chop,
                  setState: setState,
                  manager: manager,
                ),
                CommandWidget(
                  child: Text('Mine gold (${manager.people[4].$1.goldOre} gold)'),
                  onPressed: connection.mine,
                  setState: setState,
                  manager: manager,
                ),
                CommandWidget(
                  child: Text('Craft planks (${manager.people[4].$1.logs}/1 log, ${manager.people[4].$1.planks} planks)'),
                  onPressed: manager.people[4].$1.logs>=1?() => connection.craft(Item.planks):null,
                  setState: setState,
                  manager: manager,
                ),
                CommandWidget(
                  child: Text('Craft coin (${manager.people[4].$1.goldOre}/1 gold, ${manager.people[4].$1.coins} coins)'),
                  onPressed: manager.people[4].$1.goldOre>=1?() => connection.craft(Item.coin):null,
                  setState: setState,
                  manager: manager,
                ),
                CommandWidget(
                  child: Text('Craft box (${manager.people[4].$1.planks}/12 planks, ${manager.people[4].$1.boxes} boxes)'),
                  onPressed: manager.people[4].$1.planks>=12?() => connection.craft(Item.box):null,
                  setState: setState,
                  manager: manager,
                ),
              ],
            ),
          )
        : CircularProgressIndicator();
  }
}

class CommandWidget extends StatelessWidget {
  const CommandWidget(
      {super.key,
      required this.child,
      required this.onPressed,
      required this.setState,
      required this.manager});
  final Widget child;
  final Future<void> Function()? onPressed;
  final void Function(void Function()) setState;
  final Manager manager;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        child: child,
        onPressed: onPressed == null ? null : () {
          manager.tick().then((_) => setState(() {}));
          onPressed!().then((_) => setState(() {}), onError: (e, st) {
            showDialog(
                context: context,
                builder: (context) => Dialog(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Failed: $e'),
                          ),
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Ok'),
                          )
                        ],
                      ),
                    ));
          });
        });
  }
}
