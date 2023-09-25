import 'package:flutter/material.dart';

class HomePageProvider extends ChangeNotifier {
  Map<String, dynamic> _user = {};
  List<dynamic> _mainPageBucket = [];

  Map get user => _user;
  List<dynamic> get mainPageBucket => _mainPageBucket;

  setUser(Map<String, dynamic> user) {
    _user = user;
    notifyListeners();
  }

  setMainBuckets(List<dynamic> mainBuckets) {
    _mainPageBucket = mainBuckets;
    notifyListeners();
  }
}
