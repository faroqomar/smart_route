import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_route/main.dart';

void main() {
  testWidgets('optimizes the sample visit order and restores the draft', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('7.3 km'), findsOneWidget);
    double rowTop(String name) => tester.getTopLeft(find.text(name)).dy;
    expect(rowTop('Atlas Fabrics'), lessThan(rowTop('Selin Trimmings')));

    await tester.tap(find.text('Optimize route'));
    await tester.pumpAndSettle();

    expect(find.text('4.0 km'), findsOneWidget);
    expect(find.text('3.3 km shorter'), findsOneWidget);
    expect(rowTop('Selin Trimmings'), lessThan(rowTop('Mavi Threads')));
    expect(rowTop('Mavi Threads'), lessThan(rowTop('Atlas Fabrics')));

    await tester.tap(find.text('Restore original order'));
    await tester.pumpAndSettle();
    expect(find.text('7.3 km'), findsOneWidget);
    expect(rowTop('Atlas Fabrics'), lessThan(rowTop('Selin Trimmings')));
  });

  testWidgets('edits the sample stops and handles an empty selection', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose stops'));
    await tester.pumpAndSettle();

    for (final shop in ['Atlas Fabrics', 'Selin Trimmings', 'Mavi Threads']) {
      await tester.tap(find.widgetWithText(CheckboxListTile, shop));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Apply stops (0)'));
    await tester.pumpAndSettle();

    expect(find.text('0.0 km'), findsOneWidget);
    expect(
      find.text('Choose at least two stops to compare visit orders.'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.ancestor(
              of: find.text('Optimize route'),
              matching: find.bySubtype<FilledButton>(),
            ),
          )
          .onPressed,
      isNull,
    );
  });
}
