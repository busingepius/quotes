import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Group description', () {
    setUp(() {});
    test('Tester 1 description', () {
      expect(1, 1);
    });
    test('Tester 2 description', () {
      expect(1, 1);
    });
    tearDown(() {});
  });
  test('Test 3 description', () {
    expect(1, 1);
  });
}
