import 'package:spotsell/src/data/entities/entities.dart';
import 'package:spotsell/src/ui/shared/view_model/base_view_model.dart';

class ProfileViewModel extends BaseViewModel {
  List<Store> userStores = [];
  bool isLoadingStores = false;
}
