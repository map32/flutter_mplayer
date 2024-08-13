import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/data.dart';
import 'package:flutter_application_1/models/current_track_model.dart';
import 'package:provider/provider.dart';

class Tracklist extends StatelessWidget{
  final List<Song> tracklist;

  const Tracklist({super.key, required this.tracklist});

  @override
  Widget build(BuildContext context) {
    return DataTable(
      showCheckboxColumn: false,
      columns: const [
        DataColumn(label: Text('TITLE')),
        DataColumn(label: Text('ARTIST')),
        DataColumn(label: Text('ALBUM')),
        DataColumn(label: Icon(Icons.access_time)),
      ],
      rows: tracklist.map((e) {
        final selected = context.watch<CurrentTrackModel>().selected?.id == e.id;
        final textStyle = selected ? TextStyle(color: Colors.green,) : null;
        return DataRow(cells: [
              DataCell(Text(e.title, style:textStyle)),
              DataCell(Text(e.artist, style:textStyle)),
              DataCell(Text(e.album, style:textStyle)),
              DataCell(Text(e.duration, style:textStyle)),
            ],
            selected: selected,
            onSelectChanged: (_) => context.read<CurrentTrackModel>().selectTrack(e)
          );
        }
      ).toList()
    );
  }
}