import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warung_dhiesna/data/mock_food_data.dart';
import 'package:warung_dhiesna/widgets/food_image.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('All 44 menu images use unique JPG filenames matching their IDs', () {
    expect(mockFoods, hasLength(44));
    expect(mockFoods.map((food) => food.id).toSet(), hasLength(44));
    for (final food in mockFoods) {
      expect(food.image, 'assets/images/foods/${food.id}.jpg');
    }
  });

  test('Header and splash logo are bundled at their canonical paths', () async {
    for (final path in [
      'assets/images/restaurant/header.png',
      'assets/images/splash/splash_logo.png',
    ]) {
      expect((await rootBundle.load(path)).lengthInBytes, greaterThan(0));
    }
  });

  testWidgets('Missing food image shows a placeholder and keeps cover fit', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FoodImage(path: 'assets/images/foods/__missing_test__.jpg'),
        ),
      ),
    );
    expect(tester.widget<Image>(find.byType(Image)).fit, BoxFit.cover);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
