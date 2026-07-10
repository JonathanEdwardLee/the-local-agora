import 'package:flutter_test/flutter_test.dart';
import 'package:the_local_agora/main.dart';

void main() {
  testWidgets('Pass 01 foundation screen shows identity labels', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TheLocalAgoraApp());

    expect(find.text('JUNKFEATHERS TECH'), findsOneWidget);
    expect(find.text('THE LOCAL AGORA'), findsOneWidget);
    expect(find.text('PASS 01 // KERYX FEASIBILITY'), findsOneWidget);
    expect(
      find.textContaining('full civic receiver interface'),
      findsOneWidget,
    );
  });
}
