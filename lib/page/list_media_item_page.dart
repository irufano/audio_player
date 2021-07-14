import '../locator/locator.dart';
import '../model/media_library.dart';
import '../model/media_state.dart';
import '../model/queue_state.dart';
import 'player_page.dart';
import 'player_widget.dart';
import '../service/audio_player_service.dart';
import '../service/player_stream.dart';
import '../widget/player_buttons.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sliding_up_panel/flutter_sliding_up_panel.dart';
import 'package:marquee/marquee.dart';

import 'mini_player_widget.dart';
import 'playlist_page.dart';

class ListMediaItemPage extends StatefulWidget {
  const ListMediaItemPage({Key? key}) : super(key: key);

  @override
  _ListMediaItemPageState createState() => _ListMediaItemPageState();
}

class _ListMediaItemPageState extends State<ListMediaItemPage> {
  AudioPlayerService _audioPlayerService = locator<AudioPlayerService>();
  MediaLibrary _mediaLibrary = MediaLibrary();

  late ScrollController panelScrollController;

  ///The controller of sliding up panel
  SlidingUpPanelController panelController = SlidingUpPanelController();
  bool _isPanelExpanded = false;

  @override
  void initState() {
    panelScrollController = ScrollController();
    panelScrollController.addListener(() {
      if (panelScrollController.offset >=
              panelScrollController.position.maxScrollExtent &&
          !panelScrollController.position.outOfRange) {
        panelController.expand();
      } else if (panelScrollController.offset <=
              panelScrollController.position.minScrollExtent &&
          !panelScrollController.position.outOfRange) {
        // panelController.anchor();
      } else {}
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
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
                                  _mediaLibrary.items[
                                      MediaLibrary.albumsRootId]![index]);
                            },
                            icon: Icon(Icons.add)),
                        onTap: () async {
                          // Navigator.of(context).push(MaterialPageRoute(
                          //     fullscreenDialog: true,
                          //     builder: (context) => PlayerPage()));

                          await _audioPlayerService.handler.addQueueItem(
                              _mediaLibrary
                                  .items[MediaLibrary.albumsRootId]![index]);

                          if (_mediaLibrary
                                  .items[MediaLibrary.albumsRootId]![index]
                                  .extras?['position'] !=
                              null) {
                            await _audioPlayerService.handler.seek(_mediaLibrary
                                .items[MediaLibrary.albumsRootId]![index]
                                .extras!['position']);
                          }
                        },
                      );
                    }),
              ),

              // player indicator
              // StreamBuilder<QueueState>(
              //   stream: playerStream.queueStateStream,
              //   builder: (context, snapshot) {
              //     final queueState = snapshot.data;
              //     final queue = queueState?.queue ?? const [];

              //     if (queue.isEmpty) {
              //       return SizedBox();
              //     } else {
              //       return Align(
              //         alignment: Alignment.bottomCenter,
              //         child: StreamBuilder<QueueState>(
              //           stream: playerStream.queueStateStream,
              //           builder: (context, snapshot) {
              //             final queueState = snapshot.data;
              //             final mediaItem = queueState?.mediaItem;

              //             var title =
              //                 mediaItem?.title != null ? mediaItem!.title : '-';

              //             var artist = mediaItem?.artist != null
              //                 ? mediaItem!.artist
              //                 : '-';

              //             var imageUrl = mediaItem?.artUri != null
              //                 ? mediaItem!.artUri
              //                 : null;

              //             return InkWell(
              //               onTap: () {
              //                 Navigator.of(context).push(MaterialPageRoute(
              //                     fullscreenDialog: true,
              //                     builder: (context) => PlayerPage()));
              //               },
              //               child: Container(
              //                 height: 100,
              //                 width: double.infinity,
              //                 padding: EdgeInsets.symmetric(
              //                     vertical: 16, horizontal: 16),
              //                 decoration: BoxDecoration(
              //                   color: Colors.white,
              //                   boxShadow: [
              //                     BoxShadow(
              //                       color: Colors.grey,
              //                       blurRadius: 20,
              //                       offset: Offset(4, 8), // Shadow position
              //                     ),
              //                   ],
              //                 ),
              //                 child: Row(
              //                   children: [
              //                     (imageUrl == null)
              //                         ? Container(
              //                             width: 64,
              //                             color: Theme.of(context).primaryColor,
              //                             child: Center(
              //                               child: Icon(
              //                                 Icons.mic_outlined,
              //                                 color: Colors.white,
              //                                 size: 20,
              //                               ),
              //                             ),
              //                           )
              //                         : Image.network(
              //                             imageUrl.origin + imageUrl.path,
              //                           ),
              //                     Expanded(
              //                       child: Padding(
              //                         padding: EdgeInsets.only(
              //                             left: 16.0, right: 16.0),
              //                         child: Column(
              //                           crossAxisAlignment:
              //                               CrossAxisAlignment.start,
              //                           mainAxisSize: MainAxisSize.min,
              //                           children: [
              //                             Flexible(
              //                                 child: Text(title,
              //                                     style: TextStyle(
              //                                         fontWeight:
              //                                             FontWeight.bold,
              //                                         fontSize: 14))),
              //                             Flexible(
              //                                 child: Padding(
              //                               padding: EdgeInsets.only(top: 6.0),
              //                               child: Text(artist!),
              //                             )),
              //                           ],
              //                         ),
              //                       ),
              //                     ),
              //                     Flexible(
              //                       flex: 0,
              //                       child: StreamBuilder<bool>(
              //                           stream: _audioPlayerService
              //                               .handler.playbackState
              //                               .map((state) => state.playing)
              //                               .distinct(),
              //                           builder: (context, snapshot) {
              //                             final playing =
              //                                 snapshot.data ?? false;

              //                             if (playing)
              //                               return IconButton(
              //                                 icon: Icon(Icons.pause),
              //                                 onPressed: _audioPlayerService
              //                                     .handler.pause,
              //                               );
              //                             else
              //                               return IconButton(
              //                                 icon: Icon(Icons.play_arrow),
              //                                 onPressed: _audioPlayerService
              //                                     .handler.play,
              //                               );
              //                           }),
              //                     )
              //                   ],
              //                 ),
              //               ),
              //             );
              //           },
              //         ),
              //       );
              //     }
              //   },
              // )
            ],
          ),
        ),

        // sliding
        StreamBuilder<QueueState>(
          stream: playerStream.queueStateStream,
          builder: (context, snapshot) {
            final queueState = snapshot.data;
            final queue = queueState?.queue ?? const [];

            if (queue.isEmpty) {
              return SizedBox(height: 0);
            } else {
              return SlidingUpPanelWidget(
                controlHeight: 100.0,
                anchor: 0.4,
                panelController: panelController,
                enableOnTap: false,
                dragEnd: (details) {
                  if (panelController.status == SlidingUpPanelStatus.expanded) {
                    setState(() {
                      _isPanelExpanded = true;
                    });
                  }
                  if (panelController.status ==
                      SlidingUpPanelStatus.collapsed) {
                    setState(() {
                      _isPanelExpanded = false;
                    });
                  }
                  print('dragEnd');
                },
                child: Container(
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shadows: [
                      BoxShadow(
                        blurRadius: 5.0,
                        spreadRadius: 2.0,
                        color: const Color(0x11000000),
                      )
                    ],
                    shape: RoundedRectangleBorder(),
                  ),
                  child: Column(
                    children: <Widget>[
                      // mini player
                      Visibility(
                        visible: !_isPanelExpanded,
                        child: MiniPlayerWidget(),
                      ),
                      Flexible(
                        child: Container(
                          child: PlayerWidget(),
                        ),
                      ),
                    ],
                    mainAxisSize: MainAxisSize.min,
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
