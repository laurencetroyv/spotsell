import 'package:flutter/material.dart';

import 'package:spotsell/src/ui/feature/guests/welcome/domain/entity/carousel_item.dart';

class Constants {
  static const title = 'SpotSell';
  static const logo = 'assets/logo.svg';
  static const logoWithoutName = 'assets/logo-wo-name.svg';

  static const List<CarouselItem> carouselItems = [
    CarouselItem(
      title: "Sell",
      subtitle:
          "Turn your unused items into cash with our easy-to-use selling platform",
      icon: Icons.sell_outlined,
      color: Colors.green,
    ),
    CarouselItem(
      title: "Discover",
      subtitle:
          "Find unique items and great deals from people in your community",
      icon: Icons.explore_outlined,
      color: Colors.blue,
    ),
    CarouselItem(
      title: "Chat",
      subtitle:
          "Connect directly with buyers and sellers through secure messaging",
      icon: Icons.chat_bubble_outline,
      color: Colors.orange,
    ),
    CarouselItem(
      title: "Reduce Waste",
      subtitle: "Help the environment by giving items a second life",
      icon: Icons.eco_outlined,
      color: Colors.teal,
    ),
    CarouselItem(
      title: "Build Community",
      subtitle: "Connect with neighbors and build stronger local communities",
      icon: Icons.people_outline,
      color: Colors.purple,
    ),
  ];
}
