import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/data.dart';
import 'package:flutter_application_1/models/playing_model.dart';
import 'package:flutter_application_1/models/playlist_view_model.dart';
import 'package:flutter_application_1/models/playlists_model.dart';
import 'package:provider/provider.dart';

class PlaylistList extends StatefulWidget {
  final Function setPlaylist;

  const PlaylistList({super.key, required this.setPlaylist});
  @override
  _PlaylistListState createState() => _PlaylistListState();
}

class _PlaylistListState extends State<PlaylistList>{
  bool _editing = false;
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

  Widget _Image(PlaylistItem playlist)  {
    if (playlist.imageURL == '')
    {
      if (playlist.playlist.length > 0) {
        return Image.network(playlist.playlist[0].imageURL,
                    height: 100.0,
                    width: 160.0,
                    fit: BoxFit.cover,
                  );
      } else return Container(height: 100.0, width:160.0);
    } else return Image.network(playlist.imageURL,
                    height: 100.0,
                    width: 160.0,
                    fit: BoxFit.cover,
                  );
  }

  @override
  Widget build(BuildContext context) {
    var playlists = context.watch<PlaylistsModel>().getAll();
    if (playlists.length == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('No Playlists'),
        ],
      );
    }
    return Scaffold(
      appBar:AppBar(
        title: Text('Playlists'),
        actions: [
          IconButton(onPressed: () {setState(() {_editing = !_editing;});}, icon: Icon(Icons.edit, color: _editing ? Colors.orange : null)),
        ]
      ),
      body: Scrollbar(
        controller: _scrollController,
        child: ListView(
          controller: _scrollController,
          children: [
              Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: playlists.map((e) => 
                InkWell(
                  child: Row(
                    children: [
                      _Image(e),
                      const SizedBox(width: 8.0),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(e.title, overflow: TextOverflow.ellipsis,),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                          icon: Icon(
                            !_editing ? Icons.arrow_forward_ios : Icons.delete,
                            color: _editing ? Colors.orange : null,
                        ),
                        onPressed: () {
                          if (_editing) {
                            context.read<PlaylistsModel>().delete(e.id);
                            return;
                          }
                          context.read<PlaylistViewModel>().updateFromStorage(e); widget.setPlaylist();
                        },
                        iconSize: 30.0,
                      )
                    ]
                  ),
                  onTap: () {
                    context.read<PlayingModel>().updatePlaylist(e);
                  }
                )
              ).toList(),
            ),
          ]
        ),
      ),
    );
  }
}

class PlaylistPage extends StatefulWidget {
  @override
  _PlaylistPageState createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  late PageController _pageController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageController = PageController();
  }

  @override void dispose() {
    // TODO: implement dispose
    _pageController.dispose();
    super.dispose();
  }

  void setPlaylist() {
    _pageController.animateToPage(1, duration: Duration(milliseconds: 150), curve: Curves.easeIn);
  }

  void cancelPlaylist() {
    _pageController.animateToPage(0, duration: Duration(milliseconds: 150), curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PlaylistViewModel(),
      child: PageView(
        controller: _pageController,
        children: [
          PlaylistList(setPlaylist: setPlaylist,),
          IndividualPlaylist(cancelPlaylist: cancelPlaylist)
        ],
      ),
    );
  }
}

class IndividualPlaylist extends StatefulWidget{
  final Function cancelPlaylist;
  final bool isOnline;

  const IndividualPlaylist({super.key, required this.cancelPlaylist, this.isOnline = false});
  @override
  _IndividualPlaylistState createState() => _IndividualPlaylistState();
}

class _IndividualPlaylistState extends State<IndividualPlaylist>{
  ScrollController? _scrollController;
  bool _editing = false;

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

  void update() {

  }

  @override
  Widget build(BuildContext context) {
    PlaylistItem pl = context.watch<PlaylistViewModel>().playlistItem;
    bool loaded = context.watch<PlaylistViewModel>().loaded;
    if (pl == null) return Container(child: Center(child: Text('Error')),);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () {widget.cancelPlaylist();}),
        title: Text(pl.title, overflow: TextOverflow.ellipsis,),
        actions: [
          !widget.isOnline ? IconButton(onPressed: () {setState(() {_editing = !_editing;});}, icon: Icon(Icons.edit, color: _editing ? Colors.orange : Colors.grey))
            : loaded ? IconButton(onPressed: () async {
              final result = await _showConfirmationDialog(context);
              if (result!) context.read<PlaylistsModel>().add(pl);
            },icon: const Icon(Icons.add)) : CircularProgressIndicator()
        ],
      ),
      body: Scrollbar(
        controller: _scrollController,
        child: ListView.builder(
        controller: _scrollController,
        itemCount: pl.playlist.length,
        itemBuilder: (context, _) =>
              Container(
                width: double.infinity, // Ensures the Row takes up the available width
                child: Row(
                  children: [
                    Expanded( // Ensure the inner Row expands to fill available space
                      child: InkWell(
                        child: Row(
                          children: [
                            Image.network(
                              pl.playlist[_].imageURL,
                              height: 81.0,
                              width: 144.0,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(width: 8.0),
                            Expanded( // Make the column expand to fill remaining space
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start, // Align to start
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(pl.playlist[_].title, overflow: TextOverflow.ellipsis,),
                                  Text('${pl.playlist[_].artist} | ${pl.playlist[_].duration} | ${pl.playlist[_].views}', overflow: TextOverflow.ellipsis,)
                                ],
                              ),
                            ),
                            !widget.isOnline ? IconButton(
                              icon: Icon(!_editing ? Icons.arrow_forward_ios : Icons.delete),
                              onPressed: () async {if (_editing) {
                                context.read<PlaylistsModel>().deleteSong(pl.id, pl.playlist[_]);
                                PlaylistItem? p = await context.read<PlaylistsModel>().get(pl.id);
                                context.read<PlaylistViewModel>().updateFromStorage(p!);
                                //print('hh');
                              }},
                              iconSize: 30.0,
                              color: _editing ? Colors.orange : null,
                            ) : const SizedBox.shrink(),
                          ],
                        ),
                        onTap: () {
                          if (_editing) return;
                          context.read<PlayingModel>().updatePlaylist(pl, index: _);
                        }
                      ),
                    ),
                  ],
                ),
              ),
      ),
      ),
    );
  }
}

Future<bool?> _showConfirmationDialog(BuildContext context) async {
    // Show the dialog
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Add this playlist?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                // Close the dialog and return false
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                // Close the dialog and return true
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }