// Main app widget test
import 'package:flutter_test/flutter_test.dart';
import 'package:nba_app/main.dart';

void main() {
  testWidgets('App should start and show home page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app bar is present
    expect(find.text('NBA TEAMS'), findsOneWidget);
  });
}
