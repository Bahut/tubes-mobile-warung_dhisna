import 'package:flutter/material.dart';

import '../models/food_model.dart';
import 'quantity_selector.dart';
import 'formatters.dart';

class FoodOptionTile extends StatelessWidget {
  const FoodOptionTile({
    super.key,
    required this.option,
    required this.value,
    required this.onChanged,
  });
  final FoodOption option;
  final int value;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(option.name),
            Text(
              '+ ${rupiah(option.price)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      QuantitySelector(value: value, onChanged: onChanged),
    ],
  );
}
