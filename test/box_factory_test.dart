import 'package:computer_factory/manager.dart';
import 'package:test/test.dart';

void main() {
  test('doesn\'t crash with an empty list', () {
    manage([]);
  });
}
