import 'package:audio_player/locator/locator.dart';
import 'package:audio_player/model/media_library.dart';
import 'package:audio_player/model/queue_state.dart';
import 'package:audio_player/page/player_page.dart';
import 'package:audio_player/service/audio_player_service.dart';
import 'package:audio_player/service/player_stream.dart';
import 'package:flutter/material.dart';

import 'playlist_page.dart';

class ListMediaItemPage extends StatefulWidget {
  const ListMediaItemPage({Key? key}) : super(key: key);

  @override
  _ListMediaItemPageState createState() => _ListMediaItemPageState();
}

class _ListMediaItemPageState extends State<ListMediaItemPage> {
  AudioPlayerService _audioPlayerService = locator<AudioPlayerService>();
  MediaLibrary _mediaLibrary = MediaLibrary();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List Audio'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) => PlaylistPage()));
            },
            icon: Icon(Icons.playlist_play),
          )
        ],
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: ListView.separated(
                separatorBuilder: (context, index) => Divider(),
                itemCount:
                    _mediaLibrary.items[MediaLibrary.albumsRootId]!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_mediaLibrary
                        .items[MediaLibrary.albumsRootId]![index].title),
                    subtitle: Text(_mediaLibrary
                        .items[MediaLibrary.albumsRootId]![index].artist!),
                    trailing: IconButton(
                        onPressed: () async {
                          // update dynamic queue
                          await _audioPlayerService.handler.updateMediaItem(
                              _mediaLibrary
                                  .items[MediaLibrary.albumsRootId]![index]);
                        },
                        icon: Icon(Icons.add)),
                    onTap: () async {
                      // Navigator.of(context).push(MaterialPageRoute(
                      //     fullscreenDialog: true,
                      //     builder: (context) => PlayerPage()));

                      await _audioPlayerService.handler.addQueueItem(
                          _mediaLibrary
                              .items[MediaLibrary.albumsRootId]![index]);
                    },
                  );
                }),
          ),

          // player indicator
          StreamBuilder<QueueState>(
            stream: playerStream.queueStateStream,
            builder: (context, snapshot) {
              final queueState = snapshot.data;
              final queue = queueState?.queue ?? const [];

              if (queue.isEmpty) {
                return SizedBox();
              } else {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: StreamBuilder<QueueState>(
                    stream: playerStream.queueStateStream,
                    builder: (context, snapshot) {
                      final queueState = snapshot.data;
                      final mediaItem = queueState?.mediaItem;

                      var title =
                          mediaItem?.title != null ? mediaItem!.title : '-';

                      var artist =
                          mediaItem?.artist != null ? mediaItem!.artist : '-';

                      var imageUrl =
                          mediaItem?.artUri != null ? mediaItem!.artUri : null;

                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              fullscreenDialog: true,
                              builder: (context) => PlayerPage()));
                        },
                        child: Container(
                          height: 100,
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 20,
                                offset: Offset(4, 8), // Shadow position
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              (imageUrl == null)
                                  ? Container(
                                      width: 64,
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
                                  padding:
                                      EdgeInsets.only(left: 16.0, right: 16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                          child: Text(title,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14))),
                                      Flexible(
                                          child: Padding(
                                        padding: EdgeInsets.only(top: 6.0),
                                        child: Text(artist!),
                                      )),
                                    ],
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 0,
                                child: StreamBuilder<bool>(
                                    stream: _audioPlayerService
                                        .handler.playbackState
                                        .map((state) => state.playing)
                                        .distinct(),
                                    builder: (context, snapshot) {
                                      final playing = snapshot.data ?? false;

                                      if (playing)
                                        return IconButton(
                                          icon: Icon(Icons.pause),
                                          onPressed:
                                              _audioPlayerService.handler.pause,
                                        );
                                      else
                                        return IconButton(
                                          icon: Icon(Icons.play_arrow),
                                          onPressed:
                                              _audioPlayerService.handler.play,
                                        );
                                    }),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          )
        ],
      ),
    );
  }
}
