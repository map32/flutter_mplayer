import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/data.dart';
import 'package:hive/hive.dart';

class FavoritesModel extends ChangeNotifier{
  Box<SearchItem> favbox = Hive.box<SearchItem>('FavoriteItemBox');

  List<SearchItem> getAll() {
    return favbox.values.toList();
  }

  SearchItem? get(String id) {
    return favbox.get(id);
  }

  void add(SearchItem song) async {
    await favbox.put(song.id, song);
    notifyListeners();
  }
  
  void delete(String id) async {
    await favbox.delete(id);
    notifyListeners();
  }
}