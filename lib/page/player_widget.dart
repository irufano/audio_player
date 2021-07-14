import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

import '../locator/locator.dart';
import '../model/media_state.dart';
import '../model/queue_state.dart';
import '../service/audio_player_service.dart';
import '../service/player_stream.dart';
import '../widget/player_buttons.dart';

class PlayerWidget extends StatefulWidget {
  final Function()? appBarOnTap;

  const PlayerWidget({
    Key? key,
    this.appBarOnTap,
  }) : super(key: key);

  @override
  _PlayerWidgetState createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {
  AudioPlayerService _audioPlayerService = locator<AudioPlayerService>();

  bool hasTextOverflow(String text, TextStyle style,
      {double minWidth = 0,
      double maxWidth = double.infinity,
      int maxLines = 1}) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: minWidth, maxWidth: maxWidth);
    return textPainter.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          InkWell(
            onTap: widget.appBarOnTap,
            child: AppBar(
              backgroundColor: Colors.white,
              elevation: 0.5,
              centerTitle: true,
              title: Text(
                'Background Player',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: MediaQuery.of(context).size.width / 24,
                ),
              ),
              leading: RotationTransition(
                turns: AlwaysStoppedAnimation(0.25),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 30,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 32),
            width: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // art media
                  StreamBuilder<QueueState>(
                      stream: playerStream.queueStateStream,
                      builder: (context, snapshot) {
                        final queueState = snapshot.data;
                        final mediaItem = queueState?.mediaItem;

                        var imageUrl = mediaItem?.artUri != null
                            ? mediaItem!.artUri
                            : null;

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

                              var title = mediaItem?.title != null
                                  ? mediaItem!.title
                                  : '-';

                              var artist = mediaItem?.artist != null
                                  ? mediaItem!.artist
                                  : '-';

                              var isTitleOverFlow = hasTextOverflow(
                                title,
                                TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                maxWidth:
                                    MediaQuery.of(context).size.width - 64,
                              );

                              var isArtistOverFlow = hasTextOverflow(
                                artist!.toString(),
                                TextStyle(
                                  fontSize: 12,
                                ),
                                maxWidth:
                                    MediaQuery.of(context).size.width - 64,
                              );

                              return Container(
                                width: double.infinity,
                                padding: EdgeInsets.only(bottom: 0, top: 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 8.0),
                                      child: Container(
                                        height: 20.0,
                                        child: isTitleOverFlow
                                            ? Marquee(
                                                text: title.toString(),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                                blankSpace: 50,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                              )
                                            : Text(
                                                title.toString(),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 0.0),
                                      child: Container(
                                        height: 20.0,
                                        child: isArtistOverFlow
                                            ? Marquee(
                                                text: title.toString(),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                                blankSpace: 50,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                              )
                                            : Text(
                                                artist.toString(),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),

                        // Seek bar.
                        StreamBuilder<MediaState>(
                          stream: playerStream.mediaStateStream,
                          builder: (context, snapshot) {
                            final mediaState = snapshot.data;

                            var now = mediaState?.position ?? Duration.zero;
                            var buffered =
                                mediaState?.bufferedPosition ?? Duration.zero;
                            var total = mediaState?.mediaItem?.duration ??
                                Duration.zero;

                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: ProgressBar(
                                    thumbRadius: 5.0,
                                    timeLabelLocation: TimeLabelLocation.none,
                                    progress: now,
                                    buffered: buffered,
                                    total: total,
                                    onSeek: (newPosition) {
                                      _audioPlayerService.handler
                                          .seek(newPosition);
                                    },
                                  ),
                                ),
                                Stack(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: 20,
                                    ),
                                    Positioned(
                                      left: 0.0,
                                      bottom: 0.0,
                                      child: Text(
                                          RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                                                  .firstMatch("$now")
                                                  ?.group(1) ??
                                              '$now',
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption),
                                    ),
                                    Positioned(
                                      right: 0.0,
                                      bottom: 0.0,
                                      child: Text(
                                          RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                                                  .firstMatch("$total")
                                                  ?.group(1) ??
                                              '$total',
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption),
                                    ),
                                  ],
                                ),
                              ],
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
                                        : _audioPlayerService
                                            .handler.skipToPrevious,
                                  ),

                                  SizedBox(width: 8.0),

                                  // Play/pause/stop buttons.
                                  StreamBuilder<bool>(
                                    stream: playerStream.playingStream,
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
                                        : _audioPlayerService
                                            .handler.skipToNext,
                                  ),
                                ],
                              );
                            else
                              // queue empty
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  StreamBuilder<bool>(
                                    stream: _audioPlayerService
                                        .handler.playbackState
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
                            // Navigator.pop(context);
                            return Text(
                              'Notification Click Status: ${snapshot.data}',
                            );
                          },
                        ),

                        SizedBox(height: 24.0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
