// Basic smoke test for CurioLock.
import 'package:flutter_test/flutter_test.dart';
import 'package:curiolock/main.dart';

void main() {
  testWidgets('CurioLock app builds', (WidgetTester tester) async {
    await tester.pumpWidget(const CurioLockApp());
    expect(find.text('CurioLock'), findsWidgets);
  });
}
