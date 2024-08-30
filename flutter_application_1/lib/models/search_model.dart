import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/data.dart';
import '../repository/base_repository.dart';

class SearchModel extends ChangeNotifier{
  List<SearchItem> searchList = List<SearchItem>.empty(growable: true);
  String? searched;
  String? token;
  SearchRepository searchRepository = SearchRepository();
  Future<void> update(String? s) async {
    if (s == null) return;
    if (searched == null) {searched = s;}
    else if (searched?.compareTo(s) != 0) {
      searchList.clear();
      searched = s;
      token = null;
    }
    var value = await searchRepository.getData(s,token);
    if (value.success == false) return;
    searchList.addAll(value.searchItems as Iterable<SearchItem>);
    
    token = value.token;
    notifyListeners();
  }
}