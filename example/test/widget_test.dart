// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ChatUI demo loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ChatUIDemoApp());

    // Verify that the demo app loads with the correct title
    expect(find.text('ChatUI Demo'), findsOneWidget);
    expect(find.text('ChatUI Package Demo'), findsOneWidget);

    // Allow the widget to finish building
    await tester.pumpAndSettle();

    // Verify that chat interface is displayed
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
