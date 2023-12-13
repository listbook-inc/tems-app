import 'package:flutter/material.dart';

class HomePageProvider extends ChangeNotifier {
  Map<String, dynamic> _user = {};
  List<dynamic> _mainPageBucket = [];
  bool _isWelcome = true;

  Map get user => _user;
  List<dynamic> get mainPageBucket => _mainPageBucket;
  bool get isWelcome => _isWelcome;

  setUser(Map<String, dynamic> user) {
    _user = user;
    notifyListeners();
  }

  setMainBuckets(List<dynamic> mainBuckets) {
    _mainPageBucket = mainBuckets;
    print("refresh됨??");
    notifyListeners();
  }

  setIsWelcome(bool isWelcome) {
    _isWelcome = isWelcome;
  }
}
