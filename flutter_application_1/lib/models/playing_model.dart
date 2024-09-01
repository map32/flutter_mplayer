import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/data.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../repository/base_repository.dart';

//functions needed
//load song
//load playlist
//next/prev/set on playlist

class PlayingModel extends ChangeNotifier{
  List<SearchItem>? playlist;
  SearchItem? song;
  int? currentIndex = 0;
  String? currentId;
  bool playlistChangeFlag = false;
  bool maximized = false;
  YoutubePlayerController _controller = YoutubePlayerController(
    params: const YoutubePlayerParams(
      //showControls: true,
      mute: false,
      showFullscreenButton: false,
      loop: false,
      enableCaption: false,
      showVideoAnnotations: false,
      showControls: true,
      strictRelatedVideos: true,
    ),
  );
  //YoutubePlayer _Youtube = YoutubePlayer(controller: _controller, aspectRatio: 16/9, keepAlive: true);
  //playlist token
  String? token;
  PlaylistRepository playlistRepository = PlaylistRepository();

  YoutubePlayerController get controller => _controller;

  void switchTab() {
    maximized = !maximized;
    notifyListeners();
  }

  void updateSong(SearchItem song) async {
    
    token = null;
    currentIndex = 0;
    currentId = song.id;
    this.song = song;
    _controller.loadVideoById(videoId: song.id);
    maximized = true;
    notifyListeners();
  }
  String formatDuration(Duration duration) {
  // Calculate hours, minutes, and seconds
  int hours = duration.inHours;
  int minutes = duration.inMinutes.remainder(60);
  int seconds = duration.inSeconds.remainder(60);

  // Format each part to be at least two digits, using `padLeft`
  String formattedHours = hours.toString().padLeft(2, '0');
  String formattedMinutes = minutes.toString().padLeft(2, '0');
  String formattedSeconds = seconds.toString().padLeft(2, '0');

  // Return the formatted string in HH:MM:SS format
  return '$formattedHours:$formattedMinutes:$formattedSeconds';
}
  void updatePlaylist(PlaylistItem pl, {int index = 0}) async {
    assert (pl.playlist.length > 0);
    token = null;
    currentIndex = index;
    currentId = pl.playlist[index].id;
    this.song = SearchItem(imageURL: pl.playlist[0].imageURL, title: pl.title, artist: '', duration: '', views: '', type: 'playlist', id: pl.id);
    playlist = pl.playlist;
    playlistChangeFlag = false;
    _controller.loadPlaylist(list: playlist!.map((e) => e.id).toList());
    maximized = true;
    notifyListeners();
  }
  void next() {
    if (playlist == null || currentIndex == null) return;
    if (currentIndex == playlist?.length) return;
    currentIndex = currentIndex! + 1;
    currentId = playlist?[currentIndex!].id;
    notifyListeners();
  }
  void prev() {
    if (playlist == null || currentIndex == null) return;
    if (currentIndex == 0) return;
    currentIndex = currentIndex! - 1;
    currentId = playlist?[currentIndex!].id;
    notifyListeners();
  }
  Future<void> update(SearchItem playlist) async {
    //print(playlist.id);
    if (song?.id.compareTo(playlist.id) != 0) token = null;
    song = playlist;
    SearchObject res = await playlistRepository.getPlaylistVideoId(playlist.id, token);
    if (res.success) {
      //print(res.searchItems);
      token = res.token;
      this.playlist = res.searchItems;
      //print(this.playlist);
      currentId = this.playlist?[0].id;
      currentIndex = 0;
      playlistChangeFlag = false;
      notifyListeners();
    }
  }

  void set(int index) {
    try {
      currentId = playlist?[index].id;
      currentIndex = index;
      notifyListeners();
    } catch (exception, stacktrace) {
      print(exception.toString());
    }
  }
}