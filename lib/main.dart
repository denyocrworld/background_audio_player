import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audio_service_example/audio_player/audio_scaffold.dart';
import 'package:audio_service_example/video_list.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Service Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: VideoListView(),
    );
  }
}
