import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/data.dart';
import 'package:flutter_application_1/repository/base_repository.dart';

class PlaylistViewModel extends ChangeNotifier{
  late SearchItem searchItem;
  late PlaylistItem playlistItem;
  PlaylistRepository searchRepository = PlaylistRepository();
  String? token;
  bool loaded = false;

  void init(SearchItem s) {
    searchItem = s;
    playlistItem = PlaylistItem(s.id, imageURL: s.imageURL, playlist: [], title: s.title );
    token = null;
    loaded = false;
  }

  void updateFromStorage(PlaylistItem pl) {
    playlistItem = pl;
    loaded = true;
    token = null;
    notifyListeners();
  }

  Future<void> update() async {
    loaded = false;
    SearchObject res = await searchRepository.getPlaylistVideoId(searchItem.id, token);
    if (res.success) {
      //print(res.searchItems);
      token = res.token;
      playlistItem = playlistItem.copyWith(playlist: res.searchItems);
      //print(this.playlist);
      notifyListeners();
    }
  }

  Future<void> updateAll() async {
    loaded = false;
    notifyListeners();
    do {
      
      SearchObject res = await searchRepository.getPlaylistVideoId(searchItem.id, token);
      if (res.success) {
        //print(res.searchItems);
        
        token = res.token;
        playlistItem = playlistItem.copyWith(playlist: [...playlistItem.playlist, ...?res.searchItems]);
        if (token == null) loaded = true;
        notifyListeners();
        //print(this.playlist);
      } else {
        break;
      }
    } while (token != null);
  }

  PlaylistItem get() {return playlistItem;}

}