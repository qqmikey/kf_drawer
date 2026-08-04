import 'package:flutter_test/flutter_test.dart';
import 'package:kf_drawer_example/main.dart';

void main() {
  testWidgets('opens the drawer and switches pages', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Main'), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.text('CALENDAR'), findsOneWidget);

    await tester.tap(find.text('CALENDAR'));
    await tester.pumpAndSettle();

    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Main'), findsNothing);
  });
}
