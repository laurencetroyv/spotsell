import 'package:flutter/material.dart';
import 'package:spotsell/src/ui/feature/welcome/domain/entity/carousel_item.dart';

class CarouselPageIndicatorWidget extends StatelessWidget {
  const CarouselPageIndicatorWidget(
    this.items, {
    super.key,
    required this.currentIndex,
  });

  final List<CarouselItem> items;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        items.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: currentIndex == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == index
                ? items[index].color
                : Colors.grey.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
