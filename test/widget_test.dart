import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:decide/app.dart';

void main() {
  testWidgets('App boots and shows the home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: DecideApp()));
    await tester.pumpAndSettle();

    expect(find.text('DECIDE'), findsOneWidget);
  });
}
