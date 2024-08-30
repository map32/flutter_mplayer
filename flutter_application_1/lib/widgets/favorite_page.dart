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

  @override
  Widget build(BuildContext context) {
    List<SearchItem> favorites = context.watch<FavoritesModel>().getAll();
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
            onPressed: () {setState(() {_editing = !_editing;});}, 
            icon: Icon(Icons.edit, color: _editing ? Colors.orange : Colors.grey)
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
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          child: Row(
                            children: [
                              Image.network(
                                e.imageURL,
                                fit: BoxFit.cover,
                                width: 144.0,
                                height: 81.0,
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
                            context.read<PlayingModel>().updateSong(e);
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
                            context.read<FavoritesModel>().delete(e.id);
                          }
                        ),
                        width: 50.0,
                      ) : const SizedBox.shrink()
                    ]
                  ),
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