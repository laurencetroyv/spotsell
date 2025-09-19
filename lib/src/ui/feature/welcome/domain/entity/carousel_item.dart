import 'package:flutter/material.dart';

class CarouselItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const CarouselItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
