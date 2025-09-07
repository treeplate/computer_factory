import 'dart:isolate';

import 'package:computer_factory/manager.dart';
import 'package:computer_factory/srp.dart';
import 'package:computer_factory/farmer.dart' as farmer;
import 'package:computer_factory/boxmaker.dart' as boxmaker;
import 'package:computer_factory/woodcutter.dart' as woodcutter;
import 'package:computer_factory/miner.dart' as miner;

void main(List<String> arguments) async {
  Manager manager = await Manager.create([
    (farmer.run, 'farmer'),
    (boxmaker.run, 'boxmaker'),
    (woodcutter.run, 'woodcutter'),
    (miner.run, 'miner'),
  ].map((e) {
    ReceivePort rp = ReceivePort();
    Isolate.spawn(e.$1, rp.sendPort);
    return SRPWrapper(rp, 'manager(${e.$2})');
  }).toList());
  while (true) {
    manager.tick();
  }
}
