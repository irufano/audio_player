import 'package:audio_player/locator/locator.dart';
import 'package:audio_player/model/queue_state.dart';
import 'package:audio_player/service/audio_player_service.dart';
import 'package:audio_player/service/player_stream.dart';
import 'package:flutter/material.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({Key? key}) : super(key: key);

  @override
  _PlaylistPageState createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  AudioPlayerService _audioPlayerService = locator<AudioPlayerService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Playlist'),
      ),
      body: StreamBuilder<QueueState>(
        stream: playerStream.queueStateStream,
        builder: (context, snapshot) {
          final queueState = snapshot.data;
          final playlist = queueState?.queue ?? [];
          final mediaItem = queueState?.mediaItem;

          return Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: ListView.separated(
              separatorBuilder: (context, index) => Divider(),
              itemCount: playlist.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(playlist[index].title),
                  subtitle: Text(playlist[index].artist!),
                  trailing: StreamBuilder<bool>(
                    stream: playerStream.playingStream,
                    builder: (context, snapshot) {
                      final playing = snapshot.data ?? false;

                      return IconButton(
                          onPressed: () {
                            if ((mediaItem == playlist[index]) && (playing)) {
                              _audioPlayerService.handler.pause();
                            } else {
                              if (mediaItem == playlist[index])
                                _audioPlayerService.handler.play();
                              else
                                _audioPlayerService.handler
                                    .skipToQueueItem(index);

                              if (!playing) {
                                _audioPlayerService.handler.play();
                              }
                            }
                          },
                          icon: Icon((mediaItem == playlist[index]) && (playing)
                              ? Icons.pause
                              : Icons.play_arrow));
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
