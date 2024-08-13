
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/current_track_model.dart';
import 'package:provider/provider.dart';

class CurrentTrack extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
      return Container(
        width: double.infinity,
        height: 100.0,
        color: Colors.black12,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              _Trackinfo(),
              const Spacer(),
            _PlayerControls(),
            const Spacer(),
            ]
          )
        ),
      );
  }
}

class _Trackinfo extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    final selected = context.watch<CurrentTrackModel>().selected;
    if (selected == null) return const SizedBox.shrink();
    return Row(children: [
        Image.asset('assets/lofigirl.jpg',
          height: 60.0,
          width: 60.0,
          fit: BoxFit.cover
        ),
        const SizedBox(width: 12.0,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(selected.title),
            const SizedBox(height:4.0),
            Text(selected.artist),
          ],
        ),
        IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
          ),      
      ],
    );
  }
}

class _PlayerControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final selected = context.watch<CurrentTrackModel>().selected;
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.shuffle),
              iconSize: 20.0,
              padding: EdgeInsets.only(),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.skip_previous_outlined),
              iconSize: 20.0,
              padding: EdgeInsets.only(),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.play_circle_outline),
              iconSize: 34.0,
              padding: EdgeInsets.only(),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.skip_next_outlined),
              iconSize: 20.0,
              padding: EdgeInsets.only(),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.repeat),
              iconSize: 20.0,
              padding: EdgeInsets.only(),
            )
          ],
        ),
        const SizedBox(height:4.0),
        Row(
          children: [
            Text('0:00'),
            const SizedBox(width: 8.0),
            Container(
              height: 5.0,
              width: MediaQuery.of(context).size.width * 0.3,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(2.5),
              )
            ),
            const SizedBox(width: 8.0),
            Text(selected?.duration ?? '0:00'),
          ],
        ),
      ],
    );
  }
}