import 'dart:isolate';

import 'package:computer_factory/manager.dart';
import 'package:computer_factory/srp.dart';
import 'farmer.dart' as farmer;
import 'woodcutter.dart' as woodcutter;
import 'miner.dart' as miner;

void main(List<String> arguments) {
  manage(
    [
      (farmer.run, 'farmer'),
      (woodcutter.run, 'woodcutter'),
      (miner.run, 'miner'),
    ].map((e) {
      ReceivePort rp = ReceivePort();
      Isolate.spawn(e.$1, rp.sendPort);
      return SRPWrapper(rp, 'manager(${e.$2})');
    }).toList(),
  );
}
