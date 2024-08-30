import 'package:flutter/material.dart';

class CurrentTabModel extends ChangeNotifier{
  int selectedIndex = 0;
  void setSelectedIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }
}