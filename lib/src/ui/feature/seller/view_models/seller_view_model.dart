import 'package:flutter/material.dart';

import 'package:spotsell/src/ui/shared/view_model/base_view_model.dart';

class SellerViewModel extends BaseViewModel {
  bool extend = false;
  int selectedNavIndex = 0;

  List<Widget> pages = [];
}
