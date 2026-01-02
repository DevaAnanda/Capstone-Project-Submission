// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:moodtrack/main.dart';
import 'package:moodtrack/services/mood_provider.dart';

void main() {
  testWidgets('MoodTrack app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => MoodProvider(),
        child: const MyApp(),
      ),
    );

    // Verify that app starts with correct title
    expect(find.text('MoodTrack'), findsOneWidget);
    
    // Verify floating action button exists
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
