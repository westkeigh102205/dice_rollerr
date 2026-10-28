import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dice_rollerr/main.dart';

void main() {
  testWidgets('rolls a die and disables the button while rolling', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Dice Roller'), findsOneWidget);
    expect(find.text('READY WHEN YOU ARE'), findsOneWidget);

    await tester.tap(find.text('Roll the dice'));
    await tester.pump();

    expect(find.text('Rolling...'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );

    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pump();

    expect(find.text('YOU ROLLED'), findsOneWidget);
    expect(
      find.byWidgetPredicate((widget) {
        if (widget is! Text || widget.data == null) return false;
        final value = int.tryParse(widget.data!);
        return value != null && value >= 1 && value <= 6;
      }),
      findsOneWidget,
    );
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });
}
