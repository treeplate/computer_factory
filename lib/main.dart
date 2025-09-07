import 'package:computer_factory/client_lib.dart';

import 'manager.dart';
import 'package:flutter/material.dart';
import 'dart:isolate';
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
  late final PersonManager connection = PersonManager(connectionRP.sendPort, 'user');

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
      Isolate.spawn(e.$1, rp.sendPort);
      return SRPWrapper(rp, 'manager(${e.$2})');
    }).followedBy([SRPWrapper(connectionRP, 'manager(user)')]).toList());
    setState(() {
      managerExists = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return managerExists
        ? Column(
            children: [
              Row(
                children: [
                  ...manager.people.map((e) {
                    return Column(
                      children: [
                        Text(e.$1.name),
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
                child: Text('Farm cow'),
                onPressed: () => connection.farm(Item.cow),
                setState: setState,
                manager: manager,
              ),
              CommandWidget(
                child: Text('Farm sheep'),
                onPressed: () => connection.farm(Item.sheep),
                setState: setState,
                manager: manager,
              ),
              CommandWidget(
                child: Text('Chop wood'),
                onPressed: connection.chop,
                setState: setState,
                manager: manager,
              ),
              CommandWidget(
                child: Text('Mine gold'),
                onPressed: connection.mine,
                setState: setState,
                manager: manager,
              ),
              CommandWidget(
                child: Text('Craft planks'),
                onPressed: () => connection.craft(Item.planks),
                setState: setState,
                manager: manager,
              ),
              CommandWidget(
                child: Text('Craft coin'),
                onPressed: () => connection.craft(Item.coin),
                setState: setState,
                manager: manager,
              ),
              CommandWidget(
                child: Text('Craft box'),
                onPressed: () => connection.craft(Item.box),
                setState: setState,
                manager: manager,
              ),
            ],
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
  final Future<void> Function() onPressed;
  final void Function(void Function()) setState;
  final Manager manager;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        child: child,
        onPressed: () {
          manager.tick();
          onPressed().then((_) => setState((){}), onError: (e, st) {
            showDialog(
                context: context,
                builder: (context) => Dialog(
                      child: Column(
                        children: [
                          Text('Failed: $e'),
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
