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
    _playingModel = context.read<PlayingModel>();
    _controller = _playingModel.controller;
    _Youtube = YoutubePlayer(controller: _playingModel.controller, aspectRatio: 16/9, keepAlive: true);
    //_playingModel.addListener(update);
    _controller.listen(update);
    _pages = [
      MinimizedYoutube(minimize: _playingModel.switchTab, youtube: _Youtube),
      MaximizedYoutube(minimize: _playingModel.switchTab, youtube: _Youtube),
      ];
  }

  void update(YoutubePlayerValue value) async {
    if (_playingModel.song?.type == 'video') return;
    int index = await _controller.playlistIndex;
    if (index != _playingModel.currentIndex) {
      _playingModel.currentIndex = index;
      _playingModel.currentId = _playingModel.playlist![index].id;
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
  Widget _buildChild(Widget child, bool enabled) {
    return Offstage(
      offstage: !enabled, // Hides the widget if it's not the current one
      child: child,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    bool maximized = context.watch<PlayingModel>().maximized;
    print(maximized);
    return YoutubePlayerControllerProvider(
      controller: _controller,
      child: Stack(
        children: [
          _buildChild(_pages[0], !maximized),
          _buildChild(_pages[1], maximized)
        ]
      ),
    );

  }
}

class MaximizedYoutube extends StatelessWidget{
  final Function minimize;
  final YoutubePlayer youtube;

  const MaximizedYoutube({super.key, required this.minimize, required this.youtube});
   @override
  Widget build(BuildContext context) {
    PlayingModel pm = context.watch<PlayingModel>();
    print(youtube);
    //if (pm.song == null) return const SizedBox.shrink();
    String title = '';
    if (pm.song?.type == 'video')
      title = '${pm.song!.artist} - ${pm.song!.title}';
    else if (pm.song?.type == 'playlist')
      title = '${pm.song?.title} - Now Playing: ${pm.playlist![pm.currentIndex!].artist} - ${pm.playlist![pm.currentIndex!].title}';
    double videoWidth = min(MediaQuery.sizeOf(context).width, 800.0);
    double videoHeight = videoWidth * (9/16) + 500;
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
        body: Column(
          children: [
            ClipRect(
              child: SizedBox(
                height: videoHeight-500,
                width: videoWidth,
                child: OverflowBox(
                  maxWidth: videoWidth,
                  maxHeight: videoHeight,
                  child: Container(
                    width: videoWidth,
                    height: videoHeight,
                  
                    child: youtube
                      //youtube
                  ),
                ),
              ),
            ),
            //Text('stupid'),
            YoutubeMenu()
          ],
        )
      );
  }
}

class MyCustomClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    // Define the area to show (only top-left 100x100 area of the widget)
    return Rect.fromLTWH(0, 0, size.width, size.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return false;
  }
}

class YoutubeMenu extends StatefulWidget {
  const YoutubeMenu({super.key});
  
  @override
  _YoutubeMenuState createState() => _YoutubeMenuState();
}

class _YoutubeMenuState extends State<YoutubeMenu>{
  bool dragging = false;
  double val = 0.0;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder(
          stream: context.ytController.videoStateStream,
          builder: (context, snapshot) {
            //print(snapshot.connectionState);
            //print(snapshot.data);
            double max = context.ytController.metadata.duration.inMilliseconds / 1000;
            double currentTime = snapshot.hasData ? snapshot.data!.position.inMilliseconds / 1000 : 0.0;
            //return Text('${currentTime} / ${max}');
            return Slider(max: max, value: dragging ? val : currentTime, onChanged: (value) {setState(() {val = value;});}, onChangeStart: (value) {setState(() {dragging = true;});} , onChangeEnd: (value) {context.ytController.seekTo(seconds: value, allowSeekAhead: true).then((_){setState((){dragging = false;});});});
         }
        ),
        YoutubeValueBuilder(builder: (context, value) {
          return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.skip_previous),
              onPressed: context.ytController.previousVideo,
            ),
            IconButton(
              icon: Icon(value.playerState == PlayerState.playing ? Icons.pause : Icons.play_arrow),
              iconSize: 36.0,
              onPressed: value.playerState == PlayerState.playing ? context.ytController.pauseVideo : context.ytController.playVideo,
            ),
            IconButton(
              icon: const Icon(Icons.skip_next),
              onPressed: context.ytController.nextVideo,
            ),
          ]);
        }),
      ],
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
            height: 40.0,
              child: InkWell(
                onTap: () {if(context.read<PlayingModel>().song != null) minimize();},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //youtube,
                  Expanded(child: Text(title, overflow: TextOverflow.ellipsis,)),
                  YoutubeValueBuilder(
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
                ],
                ),
              ),
            );
  }
  
}
