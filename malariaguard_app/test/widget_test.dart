import 'package:flutter_test/flutter_test.dart';
import 'package:malariaguard_app/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MalariaGuardApp());
    expect(find.text('MalariaGuard'), findsWidgets);
  });
}
