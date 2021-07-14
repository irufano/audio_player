import 'package:audio_player/widget/player_buttons.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

import '../locator/locator.dart';
import '../model/queue_state.dart';
import '../service/audio_player_service.dart';
import '../service/player_stream.dart';

class MiniPlayerWidget extends StatefulWidget {
  const MiniPlayerWidget({Key? key}) : super(key: key);

  @override
  _MiniPlayerWidgetState createState() => _MiniPlayerWidgetState();
}

class _MiniPlayerWidgetState extends State<MiniPlayerWidget> {
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
    return StreamBuilder<QueueState>(
      stream: playerStream.queueStateStream,
      builder: (context, snapshot) {
        final queueState = snapshot.data;
        final mediaItem = queueState?.mediaItem;

        var title = mediaItem?.title != null ? mediaItem!.title : '-';

        var artist = mediaItem?.artist != null ? mediaItem!.artist : '-';

        var imageUrl = mediaItem?.artUri != null ? mediaItem!.artUri : null;

        var isTitleOverFlow = hasTextOverflow(
          title,
          TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          maxWidth: MediaQuery.of(context).size.width - 64,
        );

        var isArtistOverFlow = hasTextOverflow(
          artist!.toString(),
          TextStyle(
            fontSize: 12,
          ),
          maxWidth: MediaQuery.of(context).size.width - 64,
        );

        return Container(
          height: 100,
          width: double.infinity,
          child: Row(
            children: [
              (imageUrl == null)
                  ? Container(
                      width: 100,
                      color: Theme.of(context).primaryColor,
                      child: Center(
                        child: Icon(
                          Icons.mic_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    )
                  : Image.network(
                      imageUrl.origin + imageUrl.path,
                    ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 16.0, right: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          height: 20.0,
                          child: isTitleOverFlow
                              ? Marquee(
                                  startPadding: 20,
                                  text: title.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  blankSpace: 50,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                )
                              : Text(
                                  title.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
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
                                  startPadding: 20,
                                  text: title.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  blankSpace: 50,
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                ),
              ),
              Container(
                padding: EdgeInsets.only(right: 16),
                child: StreamBuilder<bool>(
                    stream: _audioPlayerService.handler.playbackState
                        .map((state) => state.playing)
                        .distinct(),
                    builder: (context, snapshot) {
                      final playing = snapshot.data ?? false;

                      if (playing)
                        return pauseButtonMini(context);
                      else
                        return playButtonMini(context, mediaItem);
                    }),
              )
            ],
          ),
        );
      },
    );
  }
}
