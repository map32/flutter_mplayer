import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/current_tab_model.dart';
import 'package:provider/provider.dart';

class Navbar extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      onDestinationSelected: (index) => context.read<CurrentTabModel>().setSelectedIndex(index),
      indicatorColor: Colors.amber,
      selectedIndex: context.watch<CurrentTabModel>().selectedIndex,
      destinations: [
        NavigationDestination(
          selectedIcon: Icon(Icons.home),
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Badge(child: Icon(Icons.notifications_sharp)),
          label: 'Notifications',
        ),
        NavigationDestination(
          icon: Badge(
            label: Text('2'),
            child: Icon(Icons.messenger_sharp),
          ),
          label: 'Messages',
        ),
      ],
    );
  }
}