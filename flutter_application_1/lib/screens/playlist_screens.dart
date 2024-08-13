import 'package:flutter/material.dart';

import '../data/data.dart';
import '../widgets/widgets.dart';

class PlaylistScreens extends StatefulWidget{
    final Playlist playlist;

  const PlaylistScreens({super.key, required this.playlist});
    
    @override
    _PlaylistScreensState createState() => _PlaylistScreensState();
}

class _PlaylistScreensState extends State<PlaylistScreens> {
  ScrollController? _scrollController;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 140.0,
        leading: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          InkWell(
            customBorder: const CircleBorder(),
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(6.0),
              decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
              child: const Icon(Icons.chevron_left,size: 28.0)
            )
          ),
          const SizedBox(width: 16.0),
          InkWell(
            customBorder: const CircleBorder(),
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(6.0),
              decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
              child: const Icon(Icons.chevron_right,size: 28.0)
            )
          ),
        ],),
        actions: [
          TextButton.icon(onPressed: () {},
           icon: const Icon(
            Icons.account_circle_outlined,
            size: 30.0
           ),
           label: const Text('freepina')),
          const SizedBox(width: 8.0),
          IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_downward,size: 30.0)),
          const SizedBox(width: 20.0),
        ],
      ),
      body: Container(width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.red,
            Theme.of(context).scaffoldBackgroundColor
          ]
        )
      ),
      child: Scrollbar(
        trackVisibility: true,
        thumbVisibility: true,
        controller: _scrollController,
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(
            vertical: 60.0,
            horizontal: 20.0,
          ),
          children: [
            PlaylistHeader(playlist: widget.playlist),
            Tracklist(tracklist: widget.playlist.songs),
          ],
        )
      ),
      )
    );
  }
}