import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/data.dart';
import 'package:hive/hive.dart';

class PlaylistsModel extends ChangeNotifier{
  Box<PlaylistItem> playbox = Hive.box<PlaylistItem>('PlaylistItemBox');

  List<PlaylistItem> getAll() {
    return playbox.values.toList();
  }

  PlaylistItem? get(String id) {
    return playbox.get(id);
  }

  void add(PlaylistItem pl) async {
    await playbox.put(pl.id, pl);
    notifyListeners();
  }

  void createPlaylist(String title, {String url=''}) async {
    PlaylistItem pl = PlaylistItem(title, playlist: List.empty(growable: true), title: title, imageURL:url);
    await playbox.put(pl.id, pl);
    notifyListeners();
  }

  void addSong(String id, SearchItem song) async {
    PlaylistItem? pl = this.get(id);
    if (pl == null) return;
    PlaylistItem pl_ = pl.copyWith(playlist: [...pl!.playlist, song]);
    await playbox.put(id, pl_);
    notifyListeners();
  }
  
  void delete(String id) async {
    await playbox.delete(id);
    notifyListeners();
  }

  void deleteSong(String id, SearchItem song) async {
    PlaylistItem? pl = this.get(id);
    if (pl == null) return;
    PlaylistItem pl_ = pl.copyWith(playlist: pl.playlist.where((item) => item.id != song.id).toList());
    await playbox.put(id, pl_);
    notifyListeners();
  }
}