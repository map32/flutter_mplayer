//basic abstract class for fetching data
import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/data/data.dart';

class SearchHelpers {
  static String convertDuration(String duration) {
    final regex = RegExp(r'PT(\d+H)?(\d+M)?(\d+S)?');
    final match = regex.firstMatch(duration);

    if (match == null) {
      
      return '';
    }

    final hours = int.tryParse(match.group(1)?.replaceAll('H', '') ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(2)?.replaceAll('M', '') ?? '0') ?? 0;
    final seconds = int.tryParse(match.group(3)?.replaceAll('S', '') ?? '0') ?? 0;
    if (hours != 0) return '${hours}:${minutes}:${seconds}';
    else if (minutes < 10) return '0${minutes}:${seconds < 10 ? '0${seconds}' : seconds}';
    else return '${minutes}:${seconds < 10 ? '0${seconds}' : seconds}';
  }
  static String formatViews(int num) {
  if (num >= 1000000000) {
    // Billions
    double result = num / 1000000000;
    return result.toStringAsFixed(result == result.toInt() ? 0 : 1) + 'B';
  } else if (num >= 1000000) {
    // Millions
    double result = num / 1000000;
    return result.toStringAsFixed(result == result.toInt() ? 0 : 1) + 'M';
  } else if (num >= 1000) {
    // Thousands
    double result = num / 1000;
    return result.toStringAsFixed(result == result.toInt() ? 0 : 1) + 'K';
  } else {
    // Less than a thousand, show exact number
    return num.toString();
  }
}
}

class SearchRepository {
  final int maxResults = 20;
  
  Future<SearchObject> getData(String keyword, [String? token = '']) async {
    String uri = 'https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=${maxResults}&q=${keyword}&key=${API_KEY}${token == null ? '' : '&pageToken=${token}'}';
    List<SearchItem> searchList = List<SearchItem>.empty(growable: true);
    http.Response res = await http.get(Uri.parse(uri));
    if (res.statusCode == 200) {
      dynamic json = jsonDecode(res.body);
      //String token = json['nextPageToken'];
      List<dynamic> items = json['items'];
      List<String> ids = List<String>.empty(growable: true);
      items.forEach((item)
      {
        String type = item['id']['kind'];
        String id = '';
        if (type.compareTo('youtube#video') == 0) {
          type = 'video';
          id = item['id']['videoId'];
        } else if (type.compareTo('youtube#playlist') == 0) {
          type = 'playlist';
          id = item['id']['playlistId'];
        } else
          type = '';
        String imageURL = item['snippet']['thumbnails']['default']['url'];
        String author = item['snippet']['channelTitle'];
        String title = item['snippet']['title'];
        //print(title);
        //print(id);
        ids.add(id);
        searchList.add( SearchItem(title: title, artist: author, imageURL: imageURL, duration: '0:00', views: '0', type : type, id: id));
      });
      StringBuffer sb = StringBuffer();
      sb.writeAll(ids,',');
      String ids_ = sb.toString();
      await hydrateSearchList(searchList, ids_);
      return SearchObject(success: true, searchItems: searchList, token: json['nextPageToken']);
    }
    return SearchObject(success: false);
  }

  //hydrate searchList with duration and view count for each video item.
  Future<void> hydrateSearchList(List<SearchItem> searchList, String ids_) async {
    String uri_videos = 'https://www.googleapis.com/youtube/v3/videos?part=contentDetails,statistics&key=${API_KEY}&id=${ids_}';
    http.Response res = await http.get(Uri.parse(uri_videos));
    if (res.statusCode != 200) return;
    dynamic json = jsonDecode(res.body);
    List<dynamic> items = json['items'];
    int curr = 0;
    int curr2 = 0;
    
    StringBuffer t = StringBuffer();
    t.writeAll(items.map((item) => item['id']),',');
    
    while (curr < searchList.length && curr2 < items.length) {
      
      if (searchList[curr].id.compareTo(items[curr2]['id']) == 0) {
        searchList[curr] = searchList[curr].copyWith(
          duration: SearchHelpers.convertDuration(items[curr2]['contentDetails']['duration']),
          views: SearchHelpers.formatViews(int.parse(items[curr2]['statistics']['viewCount']))
          );
        curr++;
        curr2++;
      } else {
        curr++;
      }
    }
  }
}

class PlaylistRepository {
  Future<SearchObject> getPlaylistVideoId(String playlist_id, String? token) async {
    String uri = 'https://www.googleapis.com/youtube/v3/playlistItems?part=snippet,contentDetails&key=${API_KEY}&playlistId=${playlist_id}&maxResults=50${token==null ? '' : '&pageToken=${token}'}';
    
    http.Response res = await http.get(Uri.parse(uri));
    if (res.statusCode != 200) return SearchObject(success: false);
    dynamic json = jsonDecode(res.body);
    List<dynamic> items = json['items'];
    String? nextToken = json['nextPageToken'];
    SearchObject obj = SearchObject(success: true,
      searchItems: List<SearchItem>.empty(growable: true)
      );
    List<String> ids = List.empty(growable: true);

    items.forEach((item) {
      ids.add(item['contentDetails']['videoId']);
    });
    
    // ignore: unused_local_variable
    SearchObject videos = await getVideoIds(ids);
    if (videos.success) {
      return SearchObject(success: true,
       searchItems: videos.searchItems, 
       token: nextToken);
    }
    return SearchObject(success: false);
  }

  Future<SearchObject> getVideoIds(List<String> ids) async {
    StringBuffer buf = StringBuffer();
    buf.writeAll(ids,',');
    String uri_videos = 'https://www.googleapis.com/youtube/v3/videos?part=contentDetails,statistics,snippet&key=${API_KEY}&id=${buf.toString()}';
    
    http.Response res = await http.get(Uri.parse(uri_videos));
    if (res.statusCode != 200) return SearchObject(success: false);
    dynamic json = jsonDecode(res.body);
    List<dynamic> items = json['items'];
    List<SearchItem> searchItems = items.map((item) {
      String type = item['kind'];
      String id = item['id'];
      if (type.compareTo('youtube#video') == 0) {
        type = 'video';
      }
      else type = '';
      String imageURL = item['snippet']['thumbnails']['default']['url'];
      String author = item['snippet']['channelTitle'];
      String title = item['snippet']['title'];
      String duration = SearchHelpers.convertDuration(item['contentDetails']['duration']);
      String views = SearchHelpers.formatViews(int.parse(item['statistics']['viewCount']));
      //print(id);
      return SearchItem(
        imageURL: imageURL,
        artist: author,
        title: title,
        duration: duration,
        views: views, type: type, id: id
      );
    }).toList();
    return SearchObject(success: true, searchItems: searchItems, token: json['nextPageToken']);
  }
}