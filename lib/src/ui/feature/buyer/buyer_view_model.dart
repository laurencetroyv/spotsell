import 'package:flutter/material.dart';

import 'package:spotsell/src/ui/shared/view_model/base_view_model.dart';

class BuyerViewModel extends BaseViewModel {
  bool extend = false;
  int selectedNavIndex = 0;

  final List<String> categories = [
    'Property',
    'Autos',
    'Mobile Phones & Gadgets',
  ];

  List<Widget> pages = [];

  void updateSelectedNavIndex(int index) {
    if (selectedNavIndex != index) {
      selectedNavIndex = index;
      safeNotifyListeners();
    }
  }

  void toggleExtended() {
    extend = !extend;
    safeNotifyListeners();
  }
}
