import 'package:aurafit_ai/widgets/aurafit_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AuraFitLogo renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: AuraFitLogo(size: 80)),
        ),
      ),
    );

    expect(find.byType(AuraFitLogo), findsOneWidget);
  });
}
