// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:psutil_flutter_example/main.dart';

void main() {
  testWidgets('renders dashboard cards', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Psutil Flutter Dashboard'), findsOneWidget);
    expect(find.text('CPU'), findsOneWidget);
    expect(find.text('Total Memory'), findsOneWidget);
    expect(find.text('Avail Memory'), findsOneWidget);
    expect(find.text('Top 20 Processes'), findsOneWidget);
  });
}
