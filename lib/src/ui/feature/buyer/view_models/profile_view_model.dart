import 'package:spotsell/src/data/entities/store_request.dart';
import 'package:spotsell/src/ui/shared/view_model/base_view_model.dart';

class ProfileViewModel extends BaseViewModel {
  List<Store> userStores = [];
  bool isLoadingStores = false;
}
