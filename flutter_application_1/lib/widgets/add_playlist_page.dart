import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/data.dart';
import 'package:flutter_application_1/models/favorites_model.dart';
import 'package:flutter_application_1/models/playing_model.dart';
import 'package:flutter_application_1/models/playlists_model.dart';
import 'package:provider/provider.dart';

class AddPlaylistPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    final playing = context.watch<PlayingModel>().song;
    final pm = context.watch<PlayingModel>();
    final SearchItem item = pm.song!.type == 'playlist' ? pm.playlist![pm.currentIndex!] : pm.song!;
    final playlists = context.watch<PlaylistsModel>().getAll();
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('Add to playlists', overflow: TextOverflow.ellipsis,),
      ),
      body: ListView(
        children: [
          PlayingCard(pm: pm),
          ListTile(
            leading: const Icon(Icons.add),
            title: Text('Add to a new playlist', overflow: TextOverflow.ellipsis,),
            onTap: () async {
              String? result = await _showDialogWithForm(context);
              if (result != null) {
                
                 context.read<PlaylistsModel>().createPlaylist(result,url: item.imageURL);
                 context.read<PlaylistsModel>().addSong(result, item);
              }
            } 
          ),
          ...playlists.map((pl) {
            return ListTile(
              leading: Image.network(
                pl.imageURL,
                fit: BoxFit.cover
              ),
              title: Text(pl.title, overflow: TextOverflow.ellipsis,),
              trailing: const Icon(Icons.add),
              onTap: () {
                context.read<PlaylistsModel>().addSong(pl.id, item);
                Navigator.pop(context);
              }
            );
          }).toList()
        ]
      ),
    );
  }
}

Future<String?> _showDialogWithForm(BuildContext context) {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Title of new playlist', overflow: TextOverflow.ellipsis,),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Enter title',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(null);
            },
            child: Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.of(context).pop(_controller.text);
              }
            },
            child: Text('Yes'),
          ),
        ],
      );
    },
  );
}

class PlayingCard extends StatelessWidget {
  final PlayingModel pm;

  const PlayingCard({super.key, required this.pm});
  @override
  Widget build(BuildContext context) {
    if (pm.song == null) return Card(child: Center(child: Text('No Music Playing')));
    //String url = pm.song!.type == 'playlist' ? pm.playlist![pm.currentIndex!].imageURL : pm.song!.imageURL;
    SearchItem item = pm.song!.type == 'playlist' ? pm.playlist![pm.currentIndex!] : pm.song!;

    return Card(
      child: Row(
        children: [
          Image.network(
            item.imageURL,
            height: 40.5,
            width: 72.0,
            fit: BoxFit.cover
          ),
          Expanded(
            child: Column(
              children: [
                Text(item.title, overflow: TextOverflow.ellipsis,),
                Text(item.artist, overflow: TextOverflow.ellipsis,)
              ],
            ),
          )
        ],
      ),
    );
  }
}
