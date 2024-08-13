import 'package:flutter/material.dart';
import '../data/data.dart';

class SideMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height:double.infinity,
      width: 280.0,
      color: Theme.of(context).primaryColor,
      child: Column(children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(children: [
                Image.asset('assets/logo.png',height:55.0),
                Text('stupid',textAlign: TextAlign.center,)
              ],),
            ),
          ],
        ),
      _SideMenuIconTab(
        iconData: Icons.home,
        title:'Home',
        onTap: () {}
      ),
      _SideMenuIconTab(
        iconData: Icons.search,
        title:'Search',
        onTap: () {}
      ),
      _SideMenuIconTab(
        iconData: Icons.audiotrack,
        title:'Radio',
        onTap: () {}
      ),
      const SizedBox(height: 12.0),
      _LibraryPlayLists(),
      ],
      )
    );
  }
}

class _LibraryPlayLists extends StatefulWidget {
    @override
    _LibraryPlayListsState createState() => _LibraryPlayListsState();
}

class _LibraryPlayListsState extends State<_LibraryPlayLists> {
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
    return Expanded(
      child: Scrollbar(
        trackVisibility: true,
        thumbVisibility: true,
        controller: _scrollController,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          controller: _scrollController,
          physics: const ClampingScrollPhysics(),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
        
                  child: Text('YOUR LIBRARY',
                  style: Theme.of(context).textTheme.headlineMedium,
                  overflow: TextOverflow.ellipsis
                  ),
                ),
                ...yourLibrary.map((e) => 
                ListTile(
                  dense: true,
                  title: Text(
                    e,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {}
                )).toList()
              ],
            ),
            const SizedBox(height: 24.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
        
                  child: Text('PLAYLISTS',
                  style: Theme.of(context).textTheme.headlineMedium,
                  overflow: TextOverflow.ellipsis
                  ),
                ),
                ...playlists.map((e) => 
                ListTile(
                  dense: true,
                  title: Text(
                    e,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {}
                )).toList()
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SideMenuIconTab extends StatelessWidget {
  final IconData iconData;
  final String title;
  final VoidCallback onTap;



  const _SideMenuIconTab({
    Key? key,
    required this.iconData,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(iconData,
        color: Theme.of(context).iconTheme.color,
        size: 28.0),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium,
        overflow: TextOverflow.ellipsis
      ),
      onTap: onTap,
    );
  }
}