

import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/data.dart';
import 'package:flutter_application_1/models/favorites_model.dart';
import 'package:flutter_application_1/models/playing_model.dart';
import 'package:flutter_application_1/models/playlist_view_model.dart';
import 'package:flutter_application_1/models/search_model.dart';
import 'package:flutter_application_1/repository/base_repository.dart';
import 'package:flutter_application_1/widgets/playlist_page.dart';
import 'package:flutter_application_1/widgets/youtube_page.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>{
  late PageController _pageController;
  PlaylistItem? pl;
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void setPlaylist() {
    _pageController.animateToPage(1, duration: Duration(milliseconds: 150), curve: Curves.easeIn);
  }

  void cancelPlaylist() {
    _pageController.animateToPage(0, duration: Duration(milliseconds: 150), curve: Curves.easeIn);
  }

    int index = 0;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PlaylistViewModel(),
      child: PageView(
        controller: _pageController,
        children: [
          SearchView(setPlaylist: setPlaylist),
          IndividualPlaylist(cancelPlaylist: cancelPlaylist, isOnline: true)
        ],
      ),
    );
  }
}

class SearchView extends StatelessWidget {
  final Function setPlaylist;

  const SearchView({super.key, required this.setPlaylist});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchBox(),
        SearchList(setPlaylist: setPlaylist)
      ],
    );
  }
}

class SearchList extends StatefulWidget {
  final Function setPlaylist;

  const SearchList({super.key, required this.setPlaylist});
  @override
  State<StatefulWidget> createState() => SearchListState();
}

class SearchListState extends State<SearchList> with AutomaticKeepAliveClientMixin<SearchList> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;
  @override
  void initState() {
    super.initState();
    
    _scrollController = ScrollController();
    _scrollController?.addListener(_loadMore);
  }

  void _loadMore() {
    if (_scrollController!.position.pixels >= _scrollController!.position.maxScrollExtent && !_isLoadingMore) {
      setState(() {
        _isLoadingMore = true;
      });

      context.read<SearchModel>().update(Provider.of<SearchModel>(context, listen: false).searched).then((_) {
        setState(() {
          _isLoadingMore = false;
        });
      });
    }
  }

  @override void dispose() {
    
    _scrollController?.removeListener(_loadMore);
    _scrollController?.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final searchList = context.watch<SearchModel>().searchList;
    final playing = context.watch<PlayingModel>();
    return Expanded(
      child: ListView(
        controller: _scrollController,
        children: [...searchList.map((item) => SearchElement(item: item, setPlaylist: widget.setPlaylist,)), _isLoadingMore ? Center(child: CircularProgressIndicator()) : SizedBox.shrink()],
      ),
    );
  }
  @override
  bool get wantKeepAlive => true;
}

class SearchElement extends StatelessWidget {
  const SearchElement({
    super.key,
    required this.item, required this.setPlaylist,
  });
  final Function setPlaylist;
  final SearchItem item;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              customBorder: const LinearBorder(),
              onTap: () {
                if (item.type == 'video') context.read<PlayingModel>().updateSong(item);
                else context.read<PlayingModel>().update(item);
              },
              child: Row(
                children: [
                  Image.network(
                    item.imageURL,
                    fit: BoxFit.cover,
                    width: 144.0,
                    height: 81.0,
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, overflow: TextOverflow.ellipsis,),
                        Text('${item.artist} | ${item.views} | ${item.duration}', overflow: TextOverflow.ellipsis,),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              if (item.type == 'video') {
                var a = context.read<FavoritesModel>().get(item.id);
                if (a == null)
                  context.read<FavoritesModel>().add(item);
                else
                  context.read<FavoritesModel>().delete(item.id);
              } else if (item.type == 'playlist') {
                context.read<PlaylistViewModel>().init(item);
                context.read<PlaylistViewModel>().updateAll();
                //PlaylistItem pl = context.read<PlaylistViewModel>().playlistItem;
                setPlaylist();
              }
            },
            child: Container(
              width: 50.0,
              height: double.infinity,
              child: Icon(
                item.type == 'video' ? context.watch<FavoritesModel>().get(item.id) == null ? Icons.add : Icons.favorite : Icons.arrow_forward_ios,
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchBox extends StatefulWidget {
    @override
    _SearchBoxState createState() {
      return _SearchBoxState();
    }
}

class _SearchBoxState extends State<SearchBox>{
  TextEditingController? _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController?.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search',
          suffixIcon: IconButton(
            onPressed: () => _searchController?.clear(),
            icon: Icon(Icons.clear_rounded)
          ),
          prefixIcon: IconButton(
            onPressed: () => context.read<SearchModel>().update(_searchController?.text), //perform search here
            icon: Icon(Icons.search)
          )
        ),
      ),
    );
  }
}