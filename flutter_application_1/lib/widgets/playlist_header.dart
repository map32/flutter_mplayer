import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/data.dart';

class PlaylistHeader extends StatelessWidget{
  final Playlist playlist;

  const PlaylistHeader({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Image.asset(
              playlist.imageURL,
              height: 200.0,
              width: 200.0,
              fit: BoxFit.cover,
            ),
            const SizedBox(width:16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PLAYLIST',style:Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height:12.0),
                  Text(playlist.name,style:Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height:16.0),
                  Text(playlist.description, style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height:16.0),
                  Text('Created by ${playlist.creator} | ${playlist.songs.length} songs, ${playlist.duration}',
                  style: Theme.of(context).textTheme.bodySmall),
                  
                ],
              
              )
            )
          ],
        ),
        const SizedBox(height: 20.0),
        _PlaylistButtons(followers: playlist.followers),
      ],
    );
  }
}

class _PlaylistButtons extends StatelessWidget{
  final String followers;

  const _PlaylistButtons({super.key, required this.followers});
  @override
  Widget build(BuildContext context) {

    return Row(
      children: [
        TextButton(
          onPressed: () {},
          child: Text('PLAY',
            style: TextStyle(
              color: Colors.white
            )
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 40.0,

            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            backgroundColor: Colors.green,
            textStyle: TextStyle(
              fontSize: 16.0
            ),
          )
        ),
        const SizedBox(width: 8.0),
        IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}, iconSize: 30.0),
        IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}, iconSize: 30.0),
        const Spacer(),
        Text(
          'FOLLOWERS\n$followers',
          textAlign: TextAlign.right,)
      ],
    );
  }
}