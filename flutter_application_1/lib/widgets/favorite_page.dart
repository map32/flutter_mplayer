import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/data.dart';
import 'package:flutter_application_1/models/favorites_model.dart';
import 'package:flutter_application_1/models/playing_model.dart';
import 'package:provider/provider.dart';


class FavoriteList extends StatefulWidget {
  @override
  _FavoriteListState createState() => _FavoriteListState();
}

class _FavoriteListState extends State<FavoriteList>{
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

  void onEditChange() {
    setState(() {
      _editing = !_editing;
    });
  }


  @override
  Widget build(BuildContext context) {
    List<SearchItem> favorites = context.watch<FavoritesModel>().getAll();
    FavoritesModel fav = context.read<FavoritesModel>();
    PlayingModel pm = context.read<PlayingModel>();
    if (favorites.length == 0) {
      return Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No Favorites'),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
        actions: [
          IconButton(
            onPressed: onEditChange, 
            icon: Icon(Icons.edit, color: _editing ? Colors.orange : null)
          )
        ],
      ),
      body: Scrollbar(
        controller: _scrollController,
        child: ListView(
          controller: _scrollController,
          children: [
              Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: favorites.map((e) => 
                Row(
                  children: [
                
                    Expanded(
                      child: InkWell(
                        child: Row(
                          children: [
                            Image.network(
                              e.imageURL,
                              fit: BoxFit.cover,
                              height: 40.5,
                              width: 72.0,
                            ),
                            const SizedBox(width:8.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.title, overflow: TextOverflow.ellipsis,),
                                  Text('${e.artist} | ${e.views}', overflow: TextOverflow.ellipsis,)
                                ],
                              ),
                            ),
                          ]
                        ),
                        onTap: () {
                          if (_editing) return;
                          pm.updateSong(e);
                        }
                      ),
                    ),
                    _editing ?
                    Container(
                      child: IconButton(
                          icon: const Icon(Icons.delete,
                          color: Colors.orange,
                        ),
                        onPressed: () {
                          fav.delete(e.id);
                        }
                      ),
                      width: 50.0,
                    ) : const SizedBox.shrink()
                  ]
                )
              ).toList(),
            ),
          ]
        ),
      ),
    );
  }
}

class FavoritePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return FavoriteList();
  }
}