import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/data.dart';
import 'package:flutter_application_1/models/playing_model.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'add_playlist_page.dart';



class YoutubePage extends StatefulWidget{

  const YoutubePage({super.key});
  @override
  State<StatefulWidget> createState() => YoutubePageState();
  
}

class YoutubePageState extends State<YoutubePage>{
  late YoutubePlayerController _controller;
  late YoutubePlayer _Youtube;
  late PlayingModel _playingModel;
  late List<Widget> _pages;
  int page = 0;
  bool init = true;
  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        mute: false,
        showFullscreenButton: false,
        loop: false,
      ),
    );
    _Youtube = YoutubePlayer(controller: _controller, aspectRatio: 16/9, keepAlive: true);
    _playingModel = context.read<PlayingModel>();
    _playingModel.addListener(update);
    //_controller.listen(_playingModel.updateFromListener);
    _pages = [
      MinimizedYoutube(minimize: minimize, youtube: _Youtube),
      MaximizedYoutube(minimize: minimize, youtube: _Youtube),
      ];
  }

  void update() {
    if (_playingModel.song?.type == 'video')  {
      _controller.loadVideoById(videoId: _playingModel.currentId!);
      if (init) setState(() {init = false; page = 1;});
    }
    else if (_playingModel.song?.type == 'playlist')  {
      if (_playingModel.playlistChangeFlag) {
      }
      else {
        _controller.loadPlaylist(index: _playingModel.currentIndex!, list: _playingModel.playlist!.map((e) => e.id).toList());
        if (init) setState(() {init = false; page = 1;});
      }
    }
  }

  @override
  void dispose() {
    _controller.close();
    print('youtube page is disposed.');
    super.dispose();
  }

  void minimize() {
    setState((){
      page = page == 0 ? 1 : 0;
    });
  }


  // Helper method to build each child widget with Offstage control
  Widget _buildChild(Widget child, int index) {
    return Offstage(
      offstage: page != index, // Hides the widget if it's not the current one
      child: child,
    );
  }
  
  @override
  Widget build(BuildContext context) {

    return YoutubePlayerControllerProvider(
      controller: _controller,
      child: Stack(
        children: [
          _buildChild(_pages[0], 0),
          _buildChild(_pages[1], 1)
        ]
      ),
    );

  }
}

class MaximizedYoutube extends StatelessWidget{
  final Function minimize;
  final Widget youtube;

  const MaximizedYoutube({super.key, required this.minimize, required this.youtube});
   @override
  Widget build(BuildContext context) {
    PlayingModel pm = context.watch<PlayingModel>();
    //if (pm.song == null) return const SizedBox.shrink();
    String title = '';
    if (pm.song?.type == 'video')
      title = '${pm.song!.artist} - ${pm.song!.title}';
    else if (pm.song?.type == 'playlist')
      title = '${pm.song?.title} - Now Playing: ${pm.playlist![pm.currentIndex!].artist} - ${pm.playlist![pm.currentIndex!].title}';
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => {minimize()},
            icon: const Icon(Icons.arrow_back_ios)
          ),
          title: 
              Text(title,
                overflow: TextOverflow.ellipsis,),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => AddPlaylistPage(),
                  )
                );
              },
              icon: const Icon(Icons.add)
            )
          ],
        ),
        body: Center(
          child: Container(
            width: min(MediaQuery.sizeOf(context).width, 800.0),
            child: 
              youtube
          ),
        )
      );
  }
}


class MinimizedYoutube extends StatelessWidget {
  final Function minimize;
  final Widget youtube;

  const MinimizedYoutube({super.key, required this.minimize, required this.youtube});
  @override
  Widget build(BuildContext context) {
    
    PlayingModel pm = context.watch<PlayingModel>();
    
    //if (pm.song == null) return Container(child: youtube);
    String title = '';
    if (pm.song?.type == 'video')
      title = '${pm.song!.artist} - ${pm.song!.title}';
    else if (pm.song?.type == 'playlist')
      title = '${pm.song?.title} - Now Playing: ${pm.playlist![pm.currentIndex!].artist} - ${pm.playlist![pm.currentIndex!].title}';
    //context.ytController.metadata.author;
    
    return Container(
            width: double.infinity,
            color: Colors.amber[50],
            height: 90.0,
              child: Row(
                children: [
                  InkWell(
                    onTap: () {if(context.read<PlayingModel>().song != null) minimize();},
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                      Text(title, overflow: TextOverflow.ellipsis,),
                      Center(
                        child: YoutubeValueBuilder(
                          builder: (context, value) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(onPressed: value.playerState != PlayerState.unknown ? () {
                                  PlayerState p = value.playerState;
                                  if (p == PlayerState.ended || p == PlayerState.paused || p == PlayerState.unStarted) {
                                    context.ytController.playVideo();
                                  } else context.ytController.pauseVideo();
                                } : null, icon: Icon(value.playerState == PlayerState.playing ? Icons.pause : Icons.play_arrow))
                              ],
                            );
                          }
                        ),
                      ),
                    ],
                    ),
                  ),
                ],
              ),
            );
  }
  
}
