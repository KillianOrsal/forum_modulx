import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('App launches correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const ModulXForumApp());
    expect(find.text('ModulX'), findsOneWidget);
  });
}
