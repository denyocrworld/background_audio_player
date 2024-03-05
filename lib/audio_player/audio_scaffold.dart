// ignore_for_file: public_member_api_docs

// FOR MORE EXAMPLES, VISIT THE GITHUB REPOSITORY AT:
//
//  https://github.com/ryanheise/audio_service
//
// This example implements a minimal audio handler that renders the current
// media item and playback state to the system notification and responds to 4
// media actions:
//
// - play
// - pause
// - seek
// - stop
//
// To run this example, use:
//
// flutter run

import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_service_example/audio_player/common.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

// You might want to provide this using dependency injection rather than a
// global variable.
late AudioHandler audioHandler;
bool initialized = false;
AudioPlayerHandler adh = AudioPlayerHandler();

class AudioScaffold extends StatefulWidget {
  final MediaItem? media;
  final Widget body;
  AudioScaffold({
    Key? key,
    this.media,
    required this.body,
  }) : super(key: key);

  @override
  State<AudioScaffold> createState() => _AudioScaffoldState();
}

class _AudioScaffoldState extends State<AudioScaffold> {
  bool fullScreen = false;
  setFullScreen() {
    fullScreen = true;
    setState(() {});
  }

  setMinimized() {
    fullScreen = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  bool ready = false;
  initialize() async {
    if (widget.media != null) {
      if (initialized == true) {
        await audioHandler.stop();
      }
      AudioPlayerHandler.audioItem = widget.media!;

      if (!initialized)
        audioHandler = await AudioService.init(
          builder: () => adh,
          config: AudioServiceConfig(
            androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
            androidNotificationChannelName: 'Audio playback',
            androidNotificationOngoing: true,
          ),
        );

      initialized = true;
      // audioHandler.stop().then((value) async {

      // });
      // await audioHandler.seek(Duration(seconds: 0));
      // await audioHandler.stop();
      // await Future.delayed(Duration(seconds: 1));
      // audioHandler.play();

      ready = true;
      setState(() {});

      // await audioHandler.stop();
      // print(await audioHandler.mediaItem.value!.artUri.toString());
      // await audioHandler.updateMediaItem(widget.media!);
      // await audioHandler.seek(Duration.zero);
      // await audioHandler.play();

      // audioHandler.playFromUri(Uri.parse(widget.media!.id.toString()));
      adh.setMediaAndPlay(widget.media!);

      // AudioPlayerHandler.player.play();
      print("UPdate media done!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: UniqueKey(),
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          double containerHeight = 80;
          double imageHeight =
              constraints.biggest.height - containerHeight - 50;
          return GestureDetector(
            onTap: () {
              setFullScreen();
            },
            onVerticalDragUpdate: (details) {
              int sensitivity = 8;
              if (details.delta.dy > sensitivity) {
                // Down Swipe
                setMinimized();
              } else if (details.delta.dy < -sensitivity) {
                // Up Swipe
                setFullScreen();
              }
            },
            child: Stack(
              children: [
                widget.body,
                if (widget.media != null && ready)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedContainer(
                      height: fullScreen ? 800 : containerHeight,
                      duration: Duration(milliseconds: 300),
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x19000000),
                            blurRadius: 24,
                            offset: Offset(0, 11),
                          ),
                        ],
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xfff675f6),
                            Colors.black,
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (fullScreen) ...[
                            StreamBuilder<MediaItem?>(
                              stream: audioHandler.mediaItem,
                              builder: (context, snapshot) {
                                final mediaItem = snapshot.data;
                                return Text(
                                  widget.media!.title ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 12.0,
                            ),
                          ],
                          Expanded(
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                    widget.media!.artUri.toString(),
                                  ),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                    8.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (fullScreen) ...[
                            StreamBuilder<MediaState>(
                              stream: _mediaStateStream,
                              builder: (context, snapshot) {
                                final mediaState = snapshot.data;
                                return SeekBar(
                                  duration: mediaState?.mediaItem?.duration ??
                                      Duration.zero,
                                  position:
                                      mediaState?.position ?? Duration.zero,
                                  onChangeEnd: (newPosition) {
                                    audioHandler.seek(newPosition);
                                  },
                                );
                              },
                            ),

                            // Play/pause/stop buttons.
                            StreamBuilder<bool>(
                              stream: audioHandler.playbackState
                                  .map((state) => state.playing)
                                  .distinct(),
                              builder: (context, snapshot) {
                                final playing = snapshot.data ?? false;
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _button(
                                        Icons.fast_rewind, audioHandler.rewind),
                                    if (playing)
                                      _button(Icons.pause, audioHandler.pause)
                                    else
                                      _button(
                                          Icons.play_arrow, audioHandler.play),
                                    _button(Icons.stop, audioHandler.stop),
                                    _button(Icons.fast_forward,
                                        audioHandler.fastForward),
                                  ],
                                );
                              },
                            ),
                          ],
                          if (!fullScreen)
                            // Play/pause/stop buttons.
                            StreamBuilder<bool>(
                              stream: audioHandler.playbackState
                                  .map((state) => state.playing)
                                  .distinct(),
                              builder: (context, snapshot) {
                                final playing = snapshot.data ?? false;
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 48.0,
                                      width: 48,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            widget.media!.artUri.toString(),
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(
                                            8.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8.0,
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      child: StreamBuilder<MediaItem?>(
                                        stream: audioHandler.mediaItem,
                                        builder: (context, snapshot) {
                                          final mediaItem = snapshot.data;
                                          return Text(
                                            widget.media!.title ?? '',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8.0,
                                    ),
                                    _button(
                                        Icons.fast_rewind, audioHandler.rewind),
                                    if (playing)
                                      _button(Icons.pause, audioHandler.pause)
                                    else
                                      _button(
                                          Icons.play_arrow, audioHandler.play),
                                    _button(Icons.stop, audioHandler.stop),
                                    _button(Icons.fast_forward,
                                        audioHandler.fastForward),
                                  ],
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// A stream reporting the combined state of the current media item and its
  /// current position.
  Stream<MediaState> get _mediaStateStream =>
      Rx.combineLatest2<MediaItem?, Duration, MediaState>(
          audioHandler.mediaItem,
          AudioService.position,
          (mediaItem, position) => MediaState(mediaItem, position));

  Widget _button(IconData iconData, VoidCallback onPressed) => Expanded(
        child: IconButton(
          icon: Icon(iconData),
          iconSize: 20.0,
          onPressed: onPressed,
          color: Colors.white,
        ),
      );
}

class MediaState {
  final MediaItem? mediaItem;
  final Duration position;

  MediaState(this.mediaItem, this.position);
}

/// An [AudioHandler] for playing a single item.
class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  static late MediaItem audioItem;
  static AudioPlayer player = AudioPlayer();

  static late BehaviorSubject<MediaItem?> me;

  /// Initialise our audio handler.
  AudioPlayerHandler() {
    // So that our clients (the Flutter UI and the system notification) know
    // what state to display, here we set up our audio handler to broadcast all
    // playback state changes as they happen via playbackState...
    player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    // ... and also the current media item via mediaItem.
    mediaItem.add(audioItem);
    // Load the player.
    player.setAudioSource(AudioSource.uri(Uri.parse(audioItem.id)));
  }

  setMediaAndPlay(MediaItem m) async {
    // player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    // ... and also the current media item via mediaItem.
    mediaItem.add(m);
    // Load the player.
    await player.setAudioSource(AudioSource.uri(Uri.parse(m.id)));
    await player.seek(Duration(seconds: 0));
    await player.play();
  }

  // In this simple example, we handle only 4 actions: play, pause, seek and
  // stop. Any button press from the Flutter UI, notification, lock screen or
  // headset will be routed through to these 4 methods so that you can handle
  // your audio playback logic in one place.

  @override
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> seek(Duration position) => player.seek(position);

  @override
  Future<void> stop() => player.stop();

  /// Transform a just_audio event into an audio_service state.
  ///
  /// This method is used from the constructor. Every event received from the
  /// just_audio player will be transformed into an audio_service state so that
  /// it can be broadcast to audio_service clients.
  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        if (player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.fastForward,
      ],
      systemActions: {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: [0, 1, 3],
      processingState: {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[player.processingState]!,
      playing: player.playing,
      updatePosition: player.position,
      bufferedPosition: player.bufferedPosition,
      speed: player.speed,
      queueIndex: event.currentIndex,
    );
  }
}
