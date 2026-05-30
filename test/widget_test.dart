import 'package:flutter_test/flutter_test.dart';
import 'package:vms_sports_consultoria/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VMSSportsApp());
    expect(find.byType(VMSSportsApp), findsOneWidget);
  });
}