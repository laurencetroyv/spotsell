import 'package:flutter/material.dart';

import 'package:spotsell/src/ui/shared/view_model/base_view_model.dart';

class BuyerViewModel extends BaseViewModel {
  late TabController tabController;
  final TextEditingController searchController = TextEditingController();

  bool extend = false;
  int selectedNavIndex = 0;

  final List<String> categories = [
    'Property',
    'Autos',
    'Mobile Phones & Gadgets',
  ];

  final List<String> tabs = ['Top Picks', 'Nearby', 'Free Items', 'Following'];

  List<Widget> pages = [];

  @override
  void dispose() {
    tabController.dispose();
    searchController.dispose();
    super.dispose();
  }
}
