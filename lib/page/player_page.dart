import 'package:audio_player/locator/locator.dart';
import 'package:audio_player/model/media_state.dart';
import 'package:audio_player/model/queue_state.dart';
import 'package:audio_player/service/audio_player_service.dart';
import 'package:audio_player/service/player_stream.dart';
import 'package:audio_player/widget/player_buttons.dart';
import 'package:audio_player/widget/seek_bar.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({Key? key}) : super(key: key);

  @override
  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  var _audioPlayerService = locator<AudioPlayerService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Background Player'),
        actions: [
          IconButton(
            onPressed: () {
              // Navigator.of(context).push(MaterialPageRoute(
              //     fullscreenDialog: true,
              //     builder: (context) => PlaylistPage()));
            },
            icon: Icon(Icons.playlist_play),
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        width: double.infinity,
        child: Column(
          children: [
            Spacer(),
            StreamBuilder<QueueState>(
                stream: playerStream.queueStateStream,
                builder: (context, snapshot) {
                  final queueState = snapshot.data;
                  final mediaItem = queueState?.mediaItem;

                  var imageUrl =
                      mediaItem?.artUri != null ? mediaItem!.artUri : null;

                  if (imageUrl == null) {
                    return Container(
                      color: Theme.of(context).primaryColor,
                      width: double.infinity,
                      height: MediaQuery.of(context).size.width - 32,
                      child: Center(
                          child: Icon(
                        Icons.mic_outlined,
                        color: Colors.white,
                        size: MediaQuery.of(context).size.width / 3,
                      )),
                    );
                  } else {
                    return Image.network(
                      imageUrl.origin + imageUrl.path,
                      height: MediaQuery.of(context).size.width,
                    );
                  }
                }),
            Spacer(),

            // controller
            Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // title
                  StreamBuilder<QueueState>(
                      stream: playerStream.queueStateStream,
                      builder: (context, snapshot) {
                        final queueState = snapshot.data;
                        final mediaItem = queueState?.mediaItem;

                        var title =
                            mediaItem?.title != null ? mediaItem!.title : '-';

                        var artist =
                            mediaItem?.artist != null ? mediaItem!.artist : '-';

                        return Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(bottom: 16, top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  title.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ),
                              Text(artist!.toString()),
                            ],
                          ),
                        );
                      }),

                  // Seek bar.
                  StreamBuilder<MediaState>(
                    stream: playerStream.mediaStateStream,
                    builder: (context, snapshot) {
                      final mediaState = snapshot.data;
                      return SeekBar(
                        duration:
                            mediaState?.mediaItem?.duration ?? Duration.zero,
                        position: mediaState?.position ?? Duration.zero,
                        onChangeEnd: (newPosition) {
                          _audioPlayerService.handler.seek(newPosition);
                        },
                      );
                    },
                  ),

                  SizedBox(height: 16.0),

                  // Controllers button
                  StreamBuilder<QueueState>(
                    stream: playerStream.queueStateStream,
                    builder: (context, snapshot) {
                      final queueState = snapshot.data;
                      final queue = queueState?.queue ?? const [];
                      final mediaItem = queueState?.mediaItem;

                      if (queue.isNotEmpty)
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // previous
                            skipPreviousButton(
                              context,
                              onPressed: mediaItem == queue.first
                                  ? null
                                  : _audioPlayerService.handler.skipToPrevious,
                            ),

                            SizedBox(width: 8.0),

                            // Play/pause/stop buttons.
                            StreamBuilder<bool>(
                              stream: _audioPlayerService.handler.playbackState
                                  .map((state) => state.playing)
                                  .distinct(),
                              builder: (context, snapshot) {
                                final playing = snapshot.data ?? false;

                                if (playing)
                                  return pauseButton(context);
                                else
                                  return playButton(context);
                              },
                            ),

                            SizedBox(width: 8.0),

                            // next
                            skipNextButton(
                              context,
                              onPressed: mediaItem == queue.last
                                  ? null
                                  : _audioPlayerService.handler.skipToNext,
                            ),
                          ],
                        );
                      else
                        // queue empty
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            StreamBuilder<bool>(
                              stream: _audioPlayerService.handler.playbackState
                                  .map((state) => state.playing)
                                  .distinct(),
                              builder: (context, snapshot) {
                                final playing = snapshot.data ?? false;

                                if (playing)
                                  return pauseButton(context);
                                else
                                  return playButton(context);
                              },
                            ),
                          ],
                        );
                    },
                  ),
                  SizedBox(height: 8.0),
                  // Display the processing state.
                  StreamBuilder<AudioProcessingState>(
                    stream: _audioPlayerService.handler.playbackState
                        .map((state) => state.processingState)
                        .distinct(),
                    builder: (context, snapshot) {
                      final processingState =
                          snapshot.data ?? AudioProcessingState.idle;
                      return Text(
                          "Processing state: ${describeEnum(processingState)}");
                    },
                  ),
                  // Display the latest custom event.
                  StreamBuilder<dynamic>(
                    stream: _audioPlayerService.handler.customEvent,
                    builder: (context, snapshot) {
                      return Text("custom event: ${snapshot.data}");
                    },
                  ),
                  // Display the notification click status.
                  StreamBuilder<bool>(
                    stream: AudioService.notificationClicked,
                    builder: (context, snapshot) {
                      return Text(
                        'Notification Click Status: ${snapshot.data}',
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
