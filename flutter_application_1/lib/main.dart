import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/favorites_model.dart';
import 'package:flutter_application_1/models/playing_model.dart';
import 'package:flutter_application_1/models/playlists_model.dart';
import 'package:flutter_application_1/models/search_model.dart';
import 'package:flutter_application_1/widgets/favorite_page.dart';
import 'package:flutter_application_1/widgets/playlist_page.dart';
import 'package:flutter_application_1/widgets/search_page.dart';
import 'package:flutter_application_1/widgets/youtube_page.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import './widgets/widgets.dart';
import 'data/data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) 
    await DesktopWindow.setMinWindowSize(const Size(600,800));
  await Hive.initFlutter();
  Hive.registerAdapter(SearchItemAdapter());
  Hive.registerAdapter(PlaylistItemAdapter());
  await Hive.openBox<SearchItem>('SearchItemBox');
  await Hive.openBox<PlaylistItem>('PlaylistItemBox');
  await Hive.openBox<SearchItem>('FavoriteItemBox');
  runApp(
    MyApp()
    );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final GlobalKey<YoutubePageState> _youtubePageKey = GlobalKey<YoutubePageState>();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => FavoritesModel()),
        ChangeNotifierProvider(create: (context) => PlaylistsModel()),
        ChangeNotifierProvider(create: (context) => SearchModel()),
        ChangeNotifierProvider(create: (context) => PlayingModel())
      ],
      child: MaterialApp(
        title: 'Flutter Youtube Player',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          primaryColor: Colors.black87,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.black87),
          useMaterial3: true,
        ),
        home: Screen(youtubePageKey : _youtubePageKey)
      ),
    );
  }
}

class Screen extends StatefulWidget {
  final GlobalKey<YoutubePageState> youtubePageKey;
  const Screen({required this.youtubePageKey});

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen>{
  final List<Widget> pages = [FavoritePage(),
    PlaylistPage(),
    SearchPage()];
  late PageController _pageController;
  int selectedIndex = 0;

  void onNavChange(int i) {
    setState(() {selectedIndex = i;});
    _pageController.jumpToPage(i);
  }

  void onControllerChange() {
    setState(() {selectedIndex = _pageController.page!.round();});
  }

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: 0);
    _pageController.addListener(onControllerChange);
  }

  @override
  void dispose() {
    _pageController.removeListener(onControllerChange);
    _pageController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    //final index = context.watch<CurrentTabModel>().selectedIndex;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Scaffold(
            resizeToAvoidBottomInset:false,
            body: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                PageView( 
                  controller: _pageController,
                  children: pages,
                ),
                YoutubePage(key: widget.youtubePageKey)
              ]
            ),
            bottomNavigationBar: _buildMobileLayout(onNavChange: onNavChange,index:selectedIndex),
          );
        } else {
          
          return Scaffold(
            resizeToAvoidBottomInset:false,
            body: Row(
              children: [
                _buildDesktopLayout(onNavChange: onNavChange,index:selectedIndex),
                Expanded(
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      PageView(
                        controller: _pageController,
                        children: pages,
                      ),
                      YoutubePage(key: widget.youtubePageKey)
                    ]
                  ),
                )
              ],
            ),
          );
        }
      }
    );
  }
}

class _buildMobileLayout extends StatelessWidget {
    final void Function(int) onNavChange;
    final int index;

  const _buildMobileLayout({super.key, required this.onNavChange, required this.index});
    @override
    Widget build(BuildContext context) {
      return NavigationBar(
          height: 60.0,
          onDestinationSelected: onNavChange,
          indicatorColor: Colors.amber,
          selectedIndex: index,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          destinations: [
            const NavigationDestination(icon: const Icon(Icons.favorite), label: 'Favorite'),
            const NavigationDestination(icon: const Icon(Icons.playlist_play), label: 'Playlist'),
            const NavigationDestination(icon: const Icon(Icons.search), label: 'Search'),
          ],
        );
    }
  }

  class _buildDesktopLayout extends StatelessWidget{
    final void Function(int) onNavChange;
    final int index;

  const _buildDesktopLayout({super.key, required this.onNavChange, required this.index});

    @override
    Widget build(BuildContext context) {
    return NavigationRail(
      onDestinationSelected: onNavChange,
      indicatorColor: Colors.amber,
      selectedIndex: index,
      labelType: NavigationRailLabelType.selected,
      destinations: [
        const NavigationRailDestination(
          icon: const Icon(Icons.favorite),
          label: Text('Favorite'),
        ),
        const NavigationRailDestination(
          icon: const Icon(Icons.playlist_play),
          label: Text('Playlist'),
        ),
        const NavigationRailDestination(
          icon: const Icon(Icons.search),
          label: Text('Search'),
        ),
      ],
    );
  }
}

