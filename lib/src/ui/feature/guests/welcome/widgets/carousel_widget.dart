import 'package:flutter/material.dart';

import 'package:spotsell/src/ui/feature/guests/welcome/domain/entity/carousel_item.dart';

class CarouselWidget extends StatelessWidget {
  const CarouselWidget(this.item, {super.key});

  final CarouselItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: item.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(60),
          ),
          child: Icon(item.icon, size: 60, color: item.color),
        ),
        const SizedBox(height: 32),
        Text(
          item.title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: item.color,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          item.subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          textAlign: TextAlign.center,
          maxLines: 3,
        ),
      ],
    );
  }
}
