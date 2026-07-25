import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:art_price_predictor/main.dart';

void main() {
  testWidgets('Prediction page loads with all input fields', (WidgetTester tester) async {
    await tester.pumpWidget(const ArtPriceApp());

    expect(find.text('Art Price Predictor'), findsOneWidget);
    expect(find.text('Predict'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.byType(DropdownButtonFormField), findsNWidgets(5));
  });
}