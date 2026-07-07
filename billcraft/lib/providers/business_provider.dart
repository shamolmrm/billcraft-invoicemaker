import 'package:flutter/foundation.dart';
import '../models/business_model.dart';
import '../core/constants/dummy_data.dart';

class BusinessProvider extends ChangeNotifier {
  BusinessModel _business = dummyBusiness;
  BusinessModel get business => _business;

  void updateBusiness(BusinessModel business) {
    _business = business;
    notifyListeners();
  }
}
