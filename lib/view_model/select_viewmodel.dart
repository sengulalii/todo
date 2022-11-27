import 'package:flutter/material.dart';

class SelectItem extends ChangeNotifier {
  final List<String> _list = [];

  List<String> get list => _list;

  void addItem(String item) {
    _list.add(item);
    notifyListeners();
  }

  void removeItem(String item) {
    _list.remove(item);
    notifyListeners();
  }
}
