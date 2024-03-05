// ignore_for_file: camel_case_types, prefer_typing_uninitialized_variables

import 'package:audio_service/audio_service.dart';
import 'package:audio_service_example/audio_player/audio_scaffold.dart';
import 'package:flutter/material.dart';

class VideoListView extends StatefulWidget {
  VideoListView({Key? key}) : super(key: key);

  @override
  State<VideoListView> createState() => _VideoListViewState();
}

class _VideoListViewState extends State<VideoListView> {
  List<Map> videos = [
    {
      "cover":
          "https://images.unsplash.com/photo-1506157786151-b8491531f063?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      "title": "Sample ACSD",
      "url":
          "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3",
    },
    {
      "cover":
          "https://images.unsplash.com/photo-1506157786151-b8491531f063?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      "title": "Sample xxx",
      "url": "https://samplelib.com/lib/preview/mp3/sample-6s.mp3",
    },
    {
      "cover":
          "https://images.unsplash.com/photo-1506157786151-b8491531f063?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      "title": "Sample YYY",
      "url": "https://samplelib.com/lib/preview/mp3/sample-15s.mp3",
    },
  ];

  int selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    Map? item = selectedIndex == -1 ? null : videos[selectedIndex];

    return Builder(builder: (context) {
      return AudioScaffold(
        key: Key("_${selectedIndex}"),
        body: ListView.builder(
          itemCount: videos.length,
          physics: ScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            var item = videos[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  backgroundImage: NetworkImage(
                    item["cover"],
                  ),
                ),
                title: Text(item["title"]),
                trailing: InkWell(
                  onTap: () async {
                    selectedIndex = index;
                    setState(() {});
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.black,
                    radius: 16.0,
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 16.0,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        media: item == null
            ? null
            : MediaItem(
                id: item["url"],
                album: "Science Friday",
                title: item["title"],
                artist: "Science Friday and WNYC Studios",
                duration: Duration(milliseconds: 5739820),
                artUri: Uri.parse(
                  item["cover"],
                ),
              ),
      );
    });
  }
}
